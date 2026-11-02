import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../presentation/game/game_page.dart';

class BackgammonApp extends StatelessWidget {
  const BackgammonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F4D3A),
          brightness: Brightness.dark,
        ),
      ),
      home: const GamePage(),
    );
  }
}
