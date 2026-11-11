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
  String get settingLanguage => 'Sprache';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingPace => 'Spieltempo';

  @override
  String get paceOff => 'Aus';

  @override
  String get paceRelaxed => 'Ruhig';

  @override
  String get paceNormal => 'Normal';

  @override
  String get paceFast => 'Zügig';

  @override
  String get settingAutoForced => 'Pflichtzüge selbst setzen';

  @override
  String get settingAutoForcedHint =>
      'Lässt der Wurf nur einen Zug zu, setzt die App die Steine.';

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
  String get statistics => 'Statistik';

  @override
  String get statsDice => 'Würfel';

  @override
  String get scrollMore => 'Weiter unten';

  @override
  String get scrollBack => 'Weiter oben';

  @override
  String get leaderboard => 'Bestenliste';

  @override
  String get leaderboardTotals => 'Gesamtpunkte';

  @override
  String get leaderboardLatest => 'Letzte Partien';

  @override
  String get leaderboardLevel => 'Stufe';

  @override
  String get leaderboardAllLevels => 'Alle Stufen';

  @override
  String get leaderboardGames => 'Partien';

  @override
  String get leaderboardWins => 'Siege';

  @override
  String get leaderboardYou => 'Du';

  @override
  String get leaderboardComputer => 'Computer';

  @override
  String get leaderboardDate => 'Datum';

  @override
  String get leaderboardColor => 'Farbe';

  @override
  String get leaderboardPlayTime => 'Spielzeit';

  @override
  String get leaderboardEmpty =>
      'Noch keine Partie gegen den Computer beendet.';

  @override
  String playTime(int minutes, String seconds) {
    return '$minutes:$seconds min';
  }

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
  String get doubleLater => 'Beim nächsten Wurf doppeln';

  @override
  String get doubleRequested =>
      'Doppeln vorgemerkt – erneut tippen zum Zurücknehmen';

  @override
  String get or => 'oder';

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
