// Writes the legal texts as web pages next to the web version, so that they
// can be reached on GitHub Pages. The app shows the same texts offline.
// Run: dart run tools/legal/build_pages.dart
import 'dart:io';

import 'package:backgammon/legal/legal_text.dart';

/// Source in assets/legal/, page in web/, its title and language.
const pages = [
  ('imprint_de.md', 'impressum.html', 'Impressum – Backgammon', 'de'),
  (
    'privacy_de.md',
    'datenschutz.html',
    'Datenschutzerklärung – Backgammon',
    'de',
  ),
  ('imprint_en.md', 'imprint.html', 'Imprint – Backgammon', 'en'),
  ('privacy_en.md', 'privacy.html', 'Privacy policy – Backgammon', 'en'),
];

/// The page for one entry of [pages].
String pageHtml(String text, String title, String language) => legalHtml(
  text,
  title: title,
  back: './',
  language: language,
  backLabel: language == 'de' ? 'Zurück zur App' : 'Back to the app',
);

void main() {
  for (final (source, page, title, language) in pages) {
    final text = File('assets/legal/$source').readAsStringSync();
    File('web/$page').writeAsStringSync(pageHtml(text, title, language));
    stdout.writeln('web/$page');
  }
}
