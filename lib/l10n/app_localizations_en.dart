// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Backgammon';

  @override
  String get switchViewTooltip => 'Switch view';

  @override
  String get chooseColor => 'Which color do you play?';

  @override
  String get playWhite => 'White';

  @override
  String get playBlack => 'Black';

  @override
  String get chooseDifficulty => 'How strong should the computer play?';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get white => 'White';

  @override
  String get black => 'Black';

  @override
  String get roll => 'Roll';

  @override
  String get doubleCube => 'Double';

  @override
  String get accept => 'Take';

  @override
  String get refuse => 'Pass';

  @override
  String get confirm => 'End turn';

  @override
  String get undo => 'Undo';

  @override
  String get pass => 'Continue';

  @override
  String get noMove => 'No move possible';

  @override
  String get newGame => 'New game';

  @override
  String get autoFinish => 'Play to the end';

  @override
  String get settings => 'Settings';

  @override
  String get close => 'Close';

  @override
  String get legalPrivacy => 'Privacy';

  @override
  String get legalImprint => 'Imprint';

  @override
  String get legalLicenses => 'Licenses';

  @override
  String get legalLicensesIntro =>
      'Backgammon is free software under the GNU General Public License version 3. Copyright © 2026 Achim Gerber. The source code is available on GitHub.\n\nThe app builds on software by others, above all Flutter by Google. Their licenses require that they are named here. The following list is generated automatically and names the parts by their technical names. You do not need any of this to play.';

  @override
  String get settingColor => 'Your color';

  @override
  String get settingDifficulty => 'Level';

  @override
  String get settingView => 'View';

  @override
  String get settingLanguage => 'Language';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingPace => 'Pace';

  @override
  String get paceOff => 'Off';

  @override
  String get paceRelaxed => 'Relaxed';

  @override
  String get paceNormal => 'Normal';

  @override
  String get paceFast => 'Fast';

  @override
  String get settingAutoForced => 'Play forced moves';

  @override
  String get settingAutoForcedHint =>
      'If the roll allows only one move, the app moves the checkers.';

  @override
  String appVersionLabel(String version, int build) {
    return 'Version $version ($build)';
  }

  @override
  String get settingsNextGame => 'Color and level apply from the next game.';

  @override
  String get diceStats => 'Dice statistics';

  @override
  String get statsThisGame => 'This game';

  @override
  String get statsAllGames => 'All games';

  @override
  String get statsDoubles => 'Doubles';

  @override
  String get statistics => 'Statistics';

  @override
  String get statsDice => 'Dice';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get leaderboardTotals => 'Total points';

  @override
  String get leaderboardLatest => 'Latest games';

  @override
  String get leaderboardLevel => 'Level';

  @override
  String get leaderboardAllLevels => 'All levels';

  @override
  String get leaderboardGames => 'Games';

  @override
  String get leaderboardWins => 'Wins';

  @override
  String get leaderboardYou => 'You';

  @override
  String get leaderboardComputer => 'Computer';

  @override
  String get leaderboardDate => 'Date';

  @override
  String get leaderboardColor => 'Color';

  @override
  String get leaderboardPlayTime => 'Time';

  @override
  String get leaderboardEmpty => 'No game against the computer finished yet.';

  @override
  String playTime(int minutes, String seconds) {
    return '$minutes:$seconds min';
  }

  @override
  String get statsExpected =>
      'With fair dice, each number and doubles come up 16.7 % of the time on average. With few rolls, larger deviations are normal.';

  @override
  String get resign => 'Resign';

  @override
  String get cancel => 'Cancel';

  @override
  String get resignQuestion => 'Resign the game?';

  @override
  String resignConsequence(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points points',
      one: '1 point',
    );
    return 'You lose $_temp0.';
  }

  @override
  String cubeValue(int value) {
    return '×$value';
  }

  @override
  String doubleOffered(int value) {
    return 'Double to $value?';
  }

  @override
  String get doubleLater => 'Double at the next roll';

  @override
  String get doubleRequested => 'Double planned – tap again to cancel';

  @override
  String get or => 'or';

  @override
  String resultSingle(String winner, int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: '$points points',
      one: '1 point',
    );
    return '$winner wins: $_temp0';
  }

  @override
  String resultGammon(String winner, int points) {
    return '$winner wins a gammon: $points points';
  }

  @override
  String resultBackgammon(String winner, int points) {
    return '$winner wins a backgammon: $points points';
  }
}
