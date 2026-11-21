import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

/// 无 [BuildContext] 的代码（网络层、解析器等）使用的当前语言。
///
/// 目前仅提供中文模板，因此默认即为中文；新增语言后可在此切换。
class AppL10n {
  AppL10n._();

  static AppLocalizations current = lookupAppLocalizations(const Locale('zh'));
}

/// 与 MaterialApp 相同的语言解析逻辑，供无 Context 的代码使用。
Locale resolveAppLocale(Locale? preferred) {
  return basicLocaleListResolution(
    [
      ?preferred,
      ...WidgetsBinding.instance.platformDispatcher.locales,
    ],
    AppLocalizations.supportedLocales,
  );
}

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
