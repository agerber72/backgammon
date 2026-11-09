import 'dart:convert';
import 'dart:io';

import 'package:backgammon/app/backgammon_app.dart';
import 'package:backgammon/application/game_controller.dart';
import 'package:backgammon/persistence/session_store.dart';
import 'package:backgammon/presentation/game/language_flag.dart';
import 'package:backgammon/legal/legal_text.dart';
import 'package:backgammon/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The text keys of an ARB file, without metadata.
Set<String> keysOf(String file) =>
    (jsonDecode(File(file).readAsStringSync()) as Map<String, dynamic>).keys
        .where((key) => !key.startsWith('@'))
        .toSet();

void main() {
  test('A-603: Jeder Text auf Englisch – erwartet: '
      'app_en.arb enthält genau die Texte aus app_de.arb', () {
    expect(keysOf('lib/l10n/app_en.arb'), keysOf('lib/l10n/app_de.arb'));
  });

  test('A-603: Sprache nach System – erwartet: '
      'Deutsch bei deutscher Systemsprache, sonst Englisch', () {
    expect(appLocale(const [Locale('de', 'DE')]), const Locale('de'));
    expect(appLocale(const [Locale('de', 'AT')]), const Locale('de'));
    expect(appLocale(const [Locale('en', 'US')]), const Locale('en'));
    expect(appLocale(const [Locale('fr', 'FR')]), const Locale('en'));
    expect(appLocale(null), const Locale('en'));
  });

  testWidgets('A-603: Oberfläche auf Englisch – erwartet: '
      'Bei englischer Systemsprache erscheinen die englischen Texte', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('fr', 'FR')];
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        localeListResolutionCallback: (locales, supported) =>
            appLocale(locales),
        home: Builder(
          builder: (context) => Text(AppLocalizations.of(context).newGame),
        ),
      ),
    );

    expect(find.text('New game'), findsOneWidget);
  });

  testWidgets('A-605: Sprache mit Flaggen – erwartet: '
      'Die englische Flagge schaltet die Oberfläche sofort um, die Flagge '
      'der Gerätesprache folgt wieder dem System', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = GameController(autoActionDelay: null);
    addTearDown(controller.dispose);
    await tester.pumpWidget(BackgammonApp(controller: controller));
    await tester.pump();

    await tester.tap(find.byTooltip('Einstellungen'));
    await tester.pumpAndSettle();
    expect(find.byType(LanguageFlag), findsNWidgets(2));
    await tester.tap(find.byTooltip('English'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Your color'), findsOneWidget);
    expect(controller.language.value, 'en');

    // The tests run with a German system language.
    await tester.tap(find.byTooltip('Deutsch'));
    await tester.pumpAndSettle();

    expect(find.text('Einstellungen'), findsOneWidget);
    expect(controller.language.value, isNull);
  });

  test('A-605: Sprache gespeichert – erwartet: '
      'Nach einem Neustart gilt die gewählte Sprache weiter', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SharedPreferencesSessionStore();
    final first = GameController(store: store, autoActionDelay: null)
      ..updateLanguage('en');
    await Future<void>.delayed(const Duration(milliseconds: 20));

    final second = GameController(store: store, autoActionDelay: null);
    await second.restore();

    expect(second.language.value, 'en');
    first.dispose();
    second.dispose();
  });

  test('A-604: Rechtstexte auf Englisch – erwartet: '
      'Datenschutzerklärung und Impressum gibt es auf Englisch, mit dem '
      'Hinweis auf die maßgebliche deutsche Fassung und denselben '
      'Plattform-Abschnitten', () {
    for (final name in const ['privacy', 'imprint']) {
      final german = File('assets/legal/${name}_de.md').readAsStringSync();
      final english = File('assets/legal/${name}_en.md').readAsStringSync();
      final sections = RegExp(r'<!--\s*nur:.*?-->');

      expect(english, contains('The German version is legally binding.'));
      expect(
        sections.allMatches(english).map((match) => match[0]).toList(),
        sections.allMatches(german).map((match) => match[0]).toList(),
        reason: name,
      );
      for (final platform in LegalPlatform.values) {
        expect(legalLines(english, platform), isNotEmpty, reason: name);
      }
    }
  });
}
