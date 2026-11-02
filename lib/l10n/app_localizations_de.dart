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
