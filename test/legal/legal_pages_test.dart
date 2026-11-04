import 'dart:io';

import 'package:backgammon/legal/legal_text.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tools/legal/build_pages.dart' show pages;

void main() {
  test('A-809: Impressum im Web – erwartet: '
      'Die Seiten in web/ entsprechen den Texten in assets/legal/; sonst '
      'tools/legal/build_pages.dart ausführen', () {
    for (final (source, page, title) in pages) {
      final text = File('assets/legal/$source').readAsStringSync();

      expect(
        File('web/$page').readAsStringSync(),
        legalHtml(text, title: title, back: './'),
        reason: page,
      );
    }
  });

  test('A-809: Ohne fremde Server – erwartet: '
      'Die Impressum-Seite lädt keine Schriften, Skripte oder Bilder von '
      'außen und nennt Anbieter und Kontakt', () {
    final html = File('web/impressum.html').readAsStringSync();

    expect(html, isNot(contains('<script')));
    expect(html, isNot(contains('<link')));
    expect(html, isNot(contains('src=')));
    expect(html, contains('<h2>Anbieter</h2>'));
    expect(html, contains('Passion to Grow GmbH<br>'));
    expect(html, contains('E-Mail: apps@passion-to-grow.com<br>'));
    expect(
      html,
      contains(
        'Umsatzsteuer-Identifikationsnummer nach § 27a UStG: DE326044499',
      ),
    );
  });

  test('A-809: Kontaktadresse – erwartet: '
      'Rechtstexte und Seiten nennen nur die Adresse apps@, ohne mailto-Link '
      'und ohne persönliche Adresse', () {
    for (final (source, page, _) in pages) {
      final text = File('assets/legal/$source').readAsStringSync();
      final html = File('web/$page').readAsStringSync();

      expect(text, contains('apps@passion-to-grow.com'), reason: source);
      expect(text, isNot(contains('achim.gerber@')), reason: source);
      expect(html, isNot(contains('mailto:')), reason: page);
    }
  });

  test('A-809: Datenschutz im Web – erwartet: '
      'Die Seite enthält die Abschnitte aller Plattformen, keine Platzhalter '
      'und lädt nichts von außen', () {
    final html = File('web/datenschutz.html').readAsStringSync();

    expect(html, isNot(contains('<script')));
    expect(html, isNot(contains('<link')));
    expect(html, isNot(contains('src=')));
    expect(html, contains('<h2>Android- und Windows-App</h2>'));
    expect(html, contains('<h2>Web-Version</h2>'));
    expect(html, contains('Unter Android'));
    expect(html, contains('Unter Windows'));
    expect(html, isNot(contains('ENTWURF')));
    expect(html, isNot(contains('[')));
  });

  test('A-809: Auszeichnung – erwartet: '
      'Fett, Code, Links und Listen erscheinen als HTML, Sonderzeichen '
      'werden maskiert', () {
    final html = legalHtml(
      '# Titel\n\n**Fett** und `Code` <b>\n\n- Eins\n- https://example.org.\n',
      title: 'T',
      back: './',
    );

    expect(html, contains('<h1>Titel</h1>'));
    expect(
      html,
      contains('<strong>Fett</strong> und <code>Code</code> &lt;b&gt;'),
    );
    expect(html, contains('<ul>\n<li>Eins</li>'));
    expect(
      html,
      contains('<a href="https://example.org">https://example.org</a>.'),
    );
  });
}
