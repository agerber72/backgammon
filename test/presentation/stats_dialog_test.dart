import 'package:backgammon/application/game_controller.dart';
import 'package:backgammon/l10n/app_localizations.dart';
import 'package:backgammon/persistence/session_store.dart';
import 'package:backgammon/presentation/game/stats_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryStore implements SessionStore {
  Session? session;

  @override
  Future<Session?> load() async => session;

  @override
  Future<void> save(Session session) async => this.session = session;
}

Future<AppLocalizations> _show(
  WidgetTester tester,
  GameController controller,
) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: StatsDialog(controller: controller),
    ),
  );
  await tester.pumpAndSettle();
  return AppLocalizations.of(tester.element(find.byType(StatsDialog)));
}

void main() {
  testWidgets('A-219: Statistik öffnen – erwartet: '
      'Die Bestenliste steht vorn und ist ausgewählt, die Würfelstatistik '
      'folgt', (tester) async {
    final controller = GameController(
      store: _MemoryStore(),
      autoActionDelay: null,
    );
    addTearDown(controller.dispose);
    final l10n = await _show(tester, controller);

    expect(find.text(l10n.leaderboardEmpty), findsOneWidget);
    expect(find.text(l10n.statsThisGame), findsNothing);
    expect(
      tester.getTopLeft(find.text(l10n.leaderboard)).dx,
      lessThan(tester.getTopLeft(find.text(l10n.statsDice)).dx),
    );
  });

  testWidgets('A-502: Statistik ohne Bestenliste – erwartet: '
      'In der Web-Version zeigt der Dialog gleich die Würfelstatistik', (
    tester,
  ) async {
    final controller = GameController(autoActionDelay: null);
    addTearDown(controller.dispose);
    final l10n = await _show(tester, controller);

    expect(find.text(l10n.statsThisGame), findsOneWidget);
    expect(find.text(l10n.leaderboard), findsNothing);
  });
}
