import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:story_app/providers/auth_provider.dart';
import 'package:story_app/providers/localization_provider.dart';
import 'package:story_app/providers/location_provider.dart';
import 'package:story_app/providers/map_zoom_provider.dart';
import 'package:story_app/providers/story_provider.dart';
import 'package:story_app/screens/location_search_screen.dart';
import 'package:story_app/screens/settings_screen.dart';

import 'generated/l10n.dart';
import 'screens/add_story_screen.dart';
import 'screens/authentication_screen.dart';
import 'screens/register_screen.dart';
import 'screens/story_detail_screen.dart';
import 'screens/story_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localizationProvider = LocalizationProvider();
  await localizationProvider.loadSavedLocale();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        ChangeNotifierProvider(create: (_) => MapZoomProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final localizationProvider = Provider.of<LocalizationProvider>(context);

    final GoRouter router = GoRouter(
      navigatorKey: _navigatorKey,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const AuthenticationScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => RegisterScreen(),
        ),
        GoRoute(
          path: '/stories',
          builder: (context, state) => StoryListScreen(isPaid: ''),
        ),
        GoRoute(
          path: '/addStory',
          builder: (context, state) => const AddStoryScreen(isPaid: 'Paid'),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/mapSearch',
          builder: (context, state) =>  LocationSearchScreen(),
        ),
        GoRoute(
          path: '/storyDetail/:id',
          builder: (context, state) {
            final storyId = state.pathParameters['id']!;
            return StoryDetailScreen(storyId: storyId);
          },
        ),
      ],
      redirect: (context, state) {
        final isLoggedIn = authProvider.isLoggedIn;
        final goingToLogin = state.matchedLocation == '/';
        //GoRouter.of(context).routerDelegate.addListener(_onRouteChange);

        final nonProtectedPaths = ['/', '/register'];

        //debugPrint('isLoggedIn: $isLoggedIn, goingToLogin: $goingToLogin, currentLocation: ${state.matchedLocation}   ${!nonProtectedPaths.contains(state.matchedLocation)}');

        if ((!isLoggedIn) &&
            !nonProtectedPaths.contains(state.matchedLocation) &&
            (state.matchedLocation != '/register')) {
          return '/';
        }

        if (isLoggedIn && goingToLogin) {
          return '/stories';
        }

        return null;
      },
      refreshListenable: authProvider,
    );

    //debugPrint(localizationProvider.locale.toString());

    return MaterialApp.router(
      locale: localizationProvider.locale,
      supportedLocales: const [
        Locale('en'), // English
        Locale('id'), // Indonesian
      ],
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'Story App',
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
