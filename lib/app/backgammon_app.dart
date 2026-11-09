import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../application/game_controller.dart';
import '../l10n/app_locale.dart';
import '../l10n/app_localizations.dart';
import '../persistence/session_store.dart';
import '../presentation/app_scale.dart';
import '../presentation/brand.dart';
import '../presentation/game/game_page.dart';

export '../l10n/app_locale.dart';
export '../presentation/brand.dart' show brandBlue;

class BackgammonApp extends StatefulWidget {
  const BackgammonApp({super.key, this.controller});

  /// Created by the app if not given, for example by tests.
  final GameController? controller;

  @override
  State<BackgammonApp> createState() => _BackgammonAppState();
}

class _BackgammonAppState extends State<BackgammonApp> {
  // The web version keeps nothing in the browser: a game lasts as long as
  // the page is open.
  late final GameController _controller =
      widget.controller ??
      GameController(store: kIsWeb ? null : SharedPreferencesSessionStore());

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  /// Rebuilds only when the language setting changes.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: _controller.language,
      builder: (context, language, _) => MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: language == null ? null : Locale(language),
        localeListResolutionCallback: (locales, supported) =>
            appLocale(locales),
        theme: appTheme(),
        builder: (context, child) => AppScale(child: child!),
        home: GamePage(controller: _controller),
      ),
    );
  }
}

/// The app's look, shared with the tool that renders store screenshots.
ThemeData appTheme() => ThemeData(
  fontFamily: 'Roboto',
  // Same touch targets everywhere; on desktop Flutter would make them
  // smaller by default.
  visualDensity: VisualDensity.standard,
  // Brand color of p2g-it from the P2G logo, with white, for every button,
  // symbol and selected choice.
  colorScheme:
      ColorScheme.fromSeed(
        seedColor: brandBlue,
        brightness: Brightness.dark,
      ).copyWith(
        primary: brandBlue,
        onPrimary: Colors.white,
        primaryContainer: brandBlue,
        onPrimaryContainer: Colors.white,
        secondaryContainer: brandBlue,
        onSecondaryContainer: Colors.white,
      ),
);
