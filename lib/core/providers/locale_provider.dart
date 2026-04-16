import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _preferredLocaleKey = 'preferred_locale';

class AppLanguageOption {
  const AppLanguageOption({
    required this.locale,
    required this.nativeName,
    required this.englishName,
  });

  final Locale locale;
  final String nativeName;
  final String englishName;
}

const appLanguageOptions = <AppLanguageOption>[
  AppLanguageOption(
    locale: Locale('en'),
    nativeName: 'English',
    englishName: 'English',
  ),
  AppLanguageOption(
    locale: Locale('fr'),
    nativeName: 'Français',
    englishName: 'French',
  ),
  AppLanguageOption(
    locale: Locale('de'),
    nativeName: 'Deutsch',
    englishName: 'German',
  ),
  AppLanguageOption(
    locale: Locale('pt'),
    nativeName: 'Português',
    englishName: 'Portuguese',
  ),
  AppLanguageOption(
    locale: Locale('it'),
    nativeName: 'Italiano',
    englishName: 'Italian',
  ),
  AppLanguageOption(
    locale: Locale('es'),
    nativeName: 'Español',
    englishName: 'Spanish',
  ),
  AppLanguageOption(
    locale: Locale('ar'),
    nativeName: 'العربية',
    englishName: 'Arabic',
  ),
  AppLanguageOption(
    locale: Locale('ru'),
    nativeName: 'Русский',
    englishName: 'Russian',
  ),
  AppLanguageOption(
    locale: Locale('pl'),
    nativeName: 'Polski',
    englishName: 'Polish',
  ),
  AppLanguageOption(
    locale: Locale('kk'),
    nativeName: 'Қазақша',
    englishName: 'Kazakh',
  ),
  AppLanguageOption(
    locale: Locale('ky'),
    nativeName: 'Кыргызча',
    englishName: 'Kyrgyz',
  ),
  AppLanguageOption(
    locale: Locale('uz'),
    nativeName: "O'zbekcha",
    englishName: 'Uzbek',
  ),
  AppLanguageOption(
    locale: Locale('tg'),
    nativeName: 'Тоҷикӣ',
    englishName: 'Tajik',
  ),
  AppLanguageOption(
    locale: Locale('tk'),
    nativeName: 'Türkmençe',
    englishName: 'Turkmen',
  ),
  AppLanguageOption(
    locale: Locale('az'),
    nativeName: 'Azərbaycanca',
    englishName: 'Azerbaijani',
  ),
  AppLanguageOption(
    locale: Locale('hy'),
    nativeName: 'Հայերեն',
    englishName: 'Armenian',
  ),
  AppLanguageOption(
    locale: Locale('ka'),
    nativeName: 'ქართული',
    englishName: 'Georgian',
  ),
];

Locale? _localeFromTag(String? tag) {
  if (tag == null || tag.isEmpty) return null;
  final normalized = tag.replaceAll('_', '-');
  final parts = normalized.split('-');
  if (parts.isEmpty || parts.first.isEmpty) return null;
  final locale = Locale.fromSubtags(
    languageCode: parts.first,
    scriptCode: parts.length > 1 && parts[1].length == 4 ? parts[1] : null,
    countryCode: parts.isNotEmpty ? parts.last.toUpperCase() : null,
  );
  return languageOptionFor(locale) == null ? null : locale;
}

bool localeMatches(Locale a, Locale b) {
  return a.languageCode == b.languageCode &&
      (a.scriptCode ?? '') == (b.scriptCode ?? '') &&
      (a.countryCode ?? '') == (b.countryCode ?? '');
}

AppLanguageOption? languageOptionFor(Locale? locale) {
  if (locale == null) return null;
  for (final option in appLanguageOptions) {
    if (localeMatches(option.locale, locale) ||
        option.locale.languageCode == locale.languageCode) {
      return option;
    }
  }
  return null;
}

class AppLocaleNotifier extends StateNotifier<Locale?> {
  AppLocaleNotifier() : super(null);

  Future<void> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    state = _localeFromTag(prefs.getString(_preferredLocaleKey));
  }

  Future<void> setLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_preferredLocaleKey);
      state = null;
      return;
    }

    await prefs.setString(_preferredLocaleKey, locale.toLanguageTag());
    state = locale;
  }
}

final appLocaleProvider = StateNotifierProvider<AppLocaleNotifier, Locale?>(
  (ref) => AppLocaleNotifier(),
);
