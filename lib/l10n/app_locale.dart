import 'dart:ui';

/// German for a German system language, English for every other one.
Locale appLocale(List<Locale>? systemLocales) {
  final language = systemLocales?.firstOrNull?.languageCode;
  return Locale(language == 'de' ? 'de' : 'en');
}
