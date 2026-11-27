import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_settings.dart';
import 'core/app_theme.dart';
import 'core/platform_capabilities.dart';
import 'l10n/l10n.dart';
import 'screens/home_page.dart';
import 'widgets/window_title_bar.dart';

class FlupixApp extends StatelessWidget {
  const FlupixApp({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final locale = settings.locale;
        AppL10n.current = lookupAppLocalizations(resolveAppLocale(locale));
        return SettingsScope(
          settings: settings,
          child: MaterialApp(
            title: 'Flupix',
            debugShowCheckedModeBanner: false,
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            themeMode: settings.themeMode,
            theme: buildLightTheme(settings.seedColor),
            darkTheme: buildDarkTheme(settings.seedColor),
            // Windows 桌面端：在导航器之上注入自绘标题栏，所有页面共享。
            builder: (context, child) {
              if (!AppCapabilities.usesCustomWindowChrome || child == null) {
                return child ?? const SizedBox.shrink();
              }
              return Column(
                children: [
                  const WindowTitleBar(title: 'Flupix'),
                  Expanded(child: child),
                ],
              );
            },
            home: HomePage(settings: settings),
          ),
        );
      },
    );
  }
}
