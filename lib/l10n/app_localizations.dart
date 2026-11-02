import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('de')];

  /// Application name shown in the title bar.
  ///
  /// In de, this message translates to:
  /// **'Backgammon'**
  String get appTitle;

  /// Tooltip of the button that turns the board to the other player's side.
  ///
  /// In de, this message translates to:
  /// **'Ansicht wechseln'**
  String get switchViewTooltip;

  /// No description provided for @chooseColor.
  ///
  /// In de, this message translates to:
  /// **'Mit welcher Farbe spielst du?'**
  String get chooseColor;

  /// No description provided for @playWhite.
  ///
  /// In de, this message translates to:
  /// **'Weiß'**
  String get playWhite;

  /// No description provided for @playBlack.
  ///
  /// In de, this message translates to:
  /// **'Schwarz'**
  String get playBlack;

  /// No description provided for @chooseDifficulty.
  ///
  /// In de, this message translates to:
  /// **'Wie stark soll der Computer spielen?'**
  String get chooseDifficulty;

  /// No description provided for @difficultyEasy.
  ///
  /// In de, this message translates to:
  /// **'Leicht'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In de, this message translates to:
  /// **'Mittel'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In de, this message translates to:
  /// **'Schwer'**
  String get difficultyHard;

  /// No description provided for @white.
  ///
  /// In de, this message translates to:
  /// **'Weiß'**
  String get white;

  /// No description provided for @black.
  ///
  /// In de, this message translates to:
  /// **'Schwarz'**
  String get black;

  /// No description provided for @roll.
  ///
  /// In de, this message translates to:
  /// **'Würfeln'**
  String get roll;

  /// No description provided for @doubleCube.
  ///
  /// In de, this message translates to:
  /// **'Doppeln'**
  String get doubleCube;

  /// No description provided for @accept.
  ///
  /// In de, this message translates to:
  /// **'Annehmen'**
  String get accept;

  /// No description provided for @refuse.
  ///
  /// In de, this message translates to:
  /// **'Ablehnen'**
  String get refuse;

  /// No description provided for @confirm.
  ///
  /// In de, this message translates to:
  /// **'Zug beenden'**
  String get confirm;

  /// No description provided for @undo.
  ///
  /// In de, this message translates to:
  /// **'Zurücknehmen'**
  String get undo;

  /// No description provided for @pass.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get pass;

  /// No description provided for @noMove.
  ///
  /// In de, this message translates to:
  /// **'Kein Zug möglich'**
  String get noMove;

  /// No description provided for @newGame.
  ///
  /// In de, this message translates to:
  /// **'Neue Partie'**
  String get newGame;

  /// No description provided for @autoFinish.
  ///
  /// In de, this message translates to:
  /// **'Zu Ende spielen'**
  String get autoFinish;

  /// No description provided for @settings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settings;

  /// No description provided for @close.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get close;

  /// No description provided for @settingColor.
  ///
  /// In de, this message translates to:
  /// **'Deine Farbe'**
  String get settingColor;

  /// No description provided for @settingDifficulty.
  ///
  /// In de, this message translates to:
  /// **'Spielstärke'**
  String get settingDifficulty;

  /// No description provided for @settingView.
  ///
  /// In de, this message translates to:
  /// **'Ansicht'**
  String get settingView;

  /// No description provided for @settingAutoDelay.
  ///
  /// In de, this message translates to:
  /// **'Automatisch weiter nach'**
  String get settingAutoDelay;

  /// No description provided for @settingAutoDelayOff.
  ///
  /// In de, this message translates to:
  /// **'Aus'**
  String get settingAutoDelayOff;

  /// No description provided for @settingAutoDelaySeconds.
  ///
  /// In de, this message translates to:
  /// **'{seconds} s'**
  String settingAutoDelaySeconds(int seconds);

  /// No description provided for @settingsNextGame.
  ///
  /// In de, this message translates to:
  /// **'Farbe und Spielstärke gelten ab der nächsten Partie.'**
  String get settingsNextGame;

  /// No description provided for @diceStats.
  ///
  /// In de, this message translates to:
  /// **'Würfelstatistik'**
  String get diceStats;

  /// No description provided for @statsThisGame.
  ///
  /// In de, this message translates to:
  /// **'Diese Partie'**
  String get statsThisGame;

  /// No description provided for @statsAllGames.
  ///
  /// In de, this message translates to:
  /// **'Alle Partien'**
  String get statsAllGames;

  /// No description provided for @statsDoubles.
  ///
  /// In de, this message translates to:
  /// **'Pasch'**
  String get statsDoubles;

  /// No description provided for @statsExpected.
  ///
  /// In de, this message translates to:
  /// **'Bei fairen Würfeln kommt jede Zahl und ein Pasch im Schnitt zu 16,7 % vor. Bei wenigen Würfen sind größere Abweichungen normal.'**
  String get statsExpected;

  /// No description provided for @resign.
  ///
  /// In de, this message translates to:
  /// **'Aufgeben'**
  String get resign;

  /// No description provided for @cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// No description provided for @resignQuestion.
  ///
  /// In de, this message translates to:
  /// **'Partie aufgeben?'**
  String get resignQuestion;

  /// No description provided for @resignConsequence.
  ///
  /// In de, this message translates to:
  /// **'Du verlierst {points, plural, =1{1 Punkt} other{{points} Punkte}}.'**
  String resignConsequence(int points);

  /// No description provided for @doubleOffered.
  ///
  /// In de, this message translates to:
  /// **'Doppeln auf {value}?'**
  String doubleOffered(int value);

  /// No description provided for @resultSingle.
  ///
  /// In de, this message translates to:
  /// **'{winner} gewinnt: {points, plural, =1{1 Punkt} other{{points} Punkte}}'**
  String resultSingle(String winner, int points);

  /// No description provided for @resultGammon.
  ///
  /// In de, this message translates to:
  /// **'{winner} gewinnt mit Gammon: {points} Punkte'**
  String resultGammon(String winner, int points);

  /// No description provided for @resultBackgammon.
  ///
  /// In de, this message translates to:
  /// **'{winner} gewinnt mit Backgammon: {points} Punkte'**
  String resultBackgammon(String winner, int points);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
