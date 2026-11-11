import 'package:flutter/material.dart';

import 'core/app_settings.dart';
import 'core/app_theme.dart';
import 'screens/home_page.dart';

class FlupixApp extends StatelessWidget {
  const FlupixApp({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return MaterialApp(
          title: 'Flupix',
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          theme: buildLightTheme(settings.seedColor),
          darkTheme: buildDarkTheme(settings.seedColor),
          home: HomePage(settings: settings),
        );
      },
    );
  }
}
