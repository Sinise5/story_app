import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:story_app/generated/l10n.dart';
import 'package:story_app/providers/localization_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    debugPrint("BACK BUTTON!"); // Do some stuff.
    context.go('/stories');
    return true;
  }

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  Widget build(BuildContext context) {
    final localizationProvider = Provider.of<LocalizationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/stories');
          },
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              S.of(context).settings,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.blueAccent),
              title: const Text('English'),
              trailing: Radio<Locale>(
                value: const Locale('en'),
                groupValue: localizationProvider.locale,
                onChanged: (value) {
                  if (value != null) {
                    localizationProvider.changeLocale(value.languageCode);
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.blueAccent),
              title: const Text('Bahasa Indonesia'),
              trailing: Radio<Locale>(
                value: const Locale('id'),
                groupValue: localizationProvider.locale,
                onChanged: (value) {
                  if (value != null) {
                    localizationProvider.changeLocale(value.languageCode);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
