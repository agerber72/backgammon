// Writes the legal texts as web pages next to the web version, so that they
// can be reached on GitHub Pages. The app shows the same texts offline.
// Run: dart run tools/legal/build_pages.dart
import 'dart:io';

import 'package:backgammon/legal/legal_text.dart';

/// Source in assets/legal/, page in web/ and its title.
const pages = [
  ('imprint_de.md', 'impressum.html', 'Impressum – Backgammon'),
  ('privacy_de.md', 'datenschutz.html', 'Datenschutzerklärung – Backgammon'),
];

void main() {
  for (final (source, page, title) in pages) {
    final text = File('assets/legal/$source').readAsStringSync();
    File('web/$page')
        .writeAsStringSync(legalHtml(text, title: title, back: './'));
    stdout.writeln('web/$page');
  }
}
