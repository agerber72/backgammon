// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Backgammon';

  @override
  String get switchViewTooltip => 'Ansicht wechseln';

  @override
  String get chooseColor => 'Mit welcher Farbe spielst du?';

  @override
  String get playWhite => 'Weiß';

  @override
  String get playBlack => 'Schwarz';

  @override
  String get chooseDifficulty => 'Wie stark soll der Computer spielen?';

  @override
  String get difficultyEasy => 'Leicht';

  @override
  String get difficultyMedium => 'Mittel';

  @override
  String get difficultyHard => 'Schwer';

  @override
  String get white => 'Weiß';

  @override
  String get black => 'Schwarz';

  @override
  String get roll => 'Würfeln';

  @override
  String get doubleCube => 'Doppeln';

  @override
  String get accept => 'Annehmen';

  @override
  String get refuse => 'Ablehnen';

  @override
  String get confirm => 'Zug beenden';

  @override
  String get undo => 'Zurücknehmen';

  @override
  String get pass => 'Weiter';

  @override
  String get noMove => 'Kein Zug möglich';

  @override
  String get newGame => 'Neue Partie';

  @override
  String get autoFinish => 'Zu Ende spielen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get close => 'Schließen';

  @override
  String get legalPrivacy => 'Datenschutz';

  @override
  String get legalImprint => 'Impressum';

  @override
  String get legalLicenses => 'Lizenzen';

  @override
  String get legalLicensesIntro =>
      'Backgammon ist freie Software unter der GNU General Public License Version 3. Copyright © 2026 Achim Gerber. Den Quellcode gibt es auf GitHub.\n\nDie App baut auf fremden Programmteilen auf, vor allem auf Flutter von Google. Deren Lizenzen verlangen, dass sie hier genannt werden. Die folgende Liste wird automatisch erzeugt und nennt die Teile mit ihren technischen Namen. Für das Spiel musst du nichts davon beachten.';

  @override
  String get settingColor => 'Deine Farbe';

  @override
  String get settingDifficulty => 'Spielstärke';

  @override
  String get settingView => 'Ansicht';

  @override
  String get settingAutoDelay => 'Automatisch weiter nach';

  @override
  String get settingAutoDelayOff => 'Aus';

  @override
  String settingAutoDelaySeconds(int seconds) {
    return '$seconds s';
  }

  @override
  String appVersionLabel(String version, int build) {
    return 'Version $version ($build)';
  }

  @override
  String get settingsNextGame =>
      'Farbe und Spielstärke gelten ab der nächsten Partie.';

  @override
  String get diceStats => 'Würfelstatistik';

  @override
  String get statsThisGame => 'Diese Partie';

  @override
  String get statsAllGames => 'Alle Partien';

  @override
  String get statsDoubles => 'Pasch';

  @override
  String get statsExpected =>
      'Bei fairen Würfeln kommt jede Zahl und ein Pasch im Schnitt zu 16,7 % vor. Bei wenigen Würfen sind größere Abweichungen normal.';

  @override
  String get resign => 'Aufgeben';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get resignQuestion => 'Partie aufgeben?';

  @override
  String resignConsequence(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points Punkte',
      one: '1 Punkt',
    );
    return 'Du verlierst $_temp0.';
  }

  @override
  String cubeValue(int value) {
    return '×$value';
  }

  @override
  String doubleOffered(int value) {
    return 'Doppeln auf $value?';
  }

  @override
  String resultSingle(String winner, int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points Punkte',
      one: '1 Punkt',
    );
    return '$winner gewinnt: $_temp0';
  }

  @override
  String resultGammon(String winner, int points) {
    return '$winner gewinnt mit Gammon: $points Punkte';
  }

  @override
  String resultBackgammon(String winner, int points) {
    return '$winner gewinnt mit Backgammon: $points Punkte';
  }
}
