import 'package:go_router/go_router.dart';
import 'package:story_app/screens/add_story_screen.dart';
import 'package:story_app/screens/authentication_screen.dart';
import 'package:story_app/screens/register_screen.dart';
import 'package:story_app/screens/story_detail_screen.dart';
import 'package:story_app/screens/story_list_screen.dart';
import 'package:story_app/services/preferences_service.dart';

class AppRouter {
  final GoRouter router;

  AppRouter()
      : router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const AuthenticationScreen(),
            ),
            GoRoute(
              path: '/stories',
              builder: (context, state) => StoryListScreen(isPaid: ''),
            ),
            GoRoute(
              path: '/addStory',
              builder: (context, state) => const AddStoryScreen(isPaid: ''),
            ),
            GoRoute(
              path: '/storyDetail/:id',
              builder: (context, state) {
                final storyId = state.pathParameters['id']!;
                return StoryDetailScreen(storyId: storyId);
              },
            ),
            GoRoute(
              path: '/register',
              builder: (context, state) => RegisterScreen(),
            ),
          ],
          redirect: (context, state) async {
            final preferencesService = PreferencesService();
            final token = await PreferencesService.getToken();
            final isLoggedIn = token != null;
            final goingToLogin = state.matchedLocation == '/';

            // Logika untuk redirect
            if (!isLoggedIn && !goingToLogin) return '/';
            if (isLoggedIn && goingToLogin) return '/stories';
            return null;
          },
        );
}
