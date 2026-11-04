import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../presentation/app_scale.dart';
import '../presentation/brand.dart';
import '../presentation/game/game_page.dart';

export '../presentation/brand.dart' show brandBlue;

class BackgammonApp extends StatelessWidget {
  const BackgammonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: appTheme(),
      builder: (context, child) => AppScale(child: child!),
      home: const GamePage(),
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
