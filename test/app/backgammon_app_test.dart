import 'package:backgammon/app/backgammon_app.dart';
import 'package:backgammon/application/game_controller.dart';
import 'package:backgammon/domain/board.dart' show Board, Player;
import 'package:backgammon/domain/dice.dart';
import 'package:backgammon/domain/game.dart';
import 'package:backgammon/l10n/app_localizations.dart';
import 'package:backgammon/presentation/board/board_assets.dart';
import 'package:backgammon/presentation/board/board_painter.dart';
import 'package:backgammon/presentation/game/game_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class FixedRoller implements DiceRoller {
  FixedRoller(this.values);

  final List<int> values;
  var _next = 0;

  @override
  int roll() => values[_next++];
}

Future<void> showPage(WidgetTester tester, GameController controller) async {
  final assets = (await tester.runAsync(
    () async => {
      for (final view in BoardView.values)
        view: await BoardAssets.load(view, rootBundle),
    },
  ))!;
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: GamePage(preloadedAssets: assets, controller: controller),
    ),
  );
}

void main() {
  // An image load left over from a previous test must not block the next one.
  setUp(rootBundle.clear);

  testWidgets('A-304: Ansicht wechseln – erwartet: '
      'Die App bietet einen Knopf "Ansicht wechseln" an', (tester) async {
    await tester.pumpWidget(const BackgammonApp());
    await tester.pump();

    expect(find.byTooltip('Ansicht wechseln'), findsOneWidget);
  });

  testWidgets('A-304: Ansicht wechseln – erwartet: '
      'Ein Tippen zeigt das Brett aus Sicht von Schwarz, ein zweites '
      'wieder aus Sicht von Weiß', (tester) async {
    final assets = (await tester.runAsync(
      () async => {
        for (final view in BoardView.values)
          view: await BoardAssets.load(view, rootBundle),
      },
    ))!;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: GamePage(preloadedAssets: assets),
      ),
    );
    final whiteBoard = find.byKey(const ValueKey(BoardView.white));
    final blackBoard = find.byKey(const ValueKey(BoardView.black));
    expect(whiteBoard, findsOneWidget);

    await tester.tap(find.byTooltip('Ansicht wechseln'));
    await tester.pumpAndSettle();
    expect(blackBoard, findsOneWidget);
    expect(whiteBoard, findsNothing);

    await tester.tap(find.byTooltip('Ansicht wechseln'));
    await tester.pumpAndSettle();
    expect(whiteBoard, findsOneWidget);
    expect(blackBoard, findsNothing);
  });

  testWidgets('A-206: Farbe wählen – erwartet: '
      'Wer Schwarz wählt, sieht das Brett aus Sicht von Schwarz', (
    tester,
  ) async {
    await showPage(tester, GameController(roller: FixedRoller([3, 1])));
    expect(find.text('Mit welcher Farbe spielst du?'), findsOneWidget);

    await tester.tap(find.text('Schwarz'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey(BoardView.black)), findsOneWidget);
    expect(find.text('Mit welcher Farbe spielst du?'), findsNothing);
  });

  testWidgets('A-203: Zug bedienen – erwartet: '
      'Nach beiden Zügen erscheint Zug beenden, danach Würfeln', (
    tester,
  ) async {
    final controller = GameController(roller: FixedRoller([3, 1, 6, 5]));
    await showPage(tester, controller);
    await tester.tap(find.text('Weiß'));
    await tester.pumpAndSettle();

    controller
      ..tap(8)
      ..tap(5);
    await tester.pumpAndSettle();
    expect(find.text('Zurücknehmen'), findsOneWidget);
    expect(find.text('Zug beenden'), findsNothing);

    controller
      ..tap(6)
      ..tap(5);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zug beenden'));
    await tester.pumpAndSettle();

    expect(find.text('Würfeln'), findsOneWidget);
    expect(find.text('Doppeln'), findsOneWidget);
  });

  testWidgets('A-203: Stein ziehen – erwartet: '
      'Ziehen von Zunge 8 auf Zunge 5 bewegt den Stein wie zwei Tipps', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = GameController(roller: FixedRoller([3, 1]));
    await showPage(tester, controller);
    await tester.tap(find.text('Weiß'));
    await tester.pumpAndSettle();

    final assets = (await tester.runAsync(
      () => BoardAssets.load(BoardView.white, rootBundle),
    ))!;
    final layout = assets.layout;
    const padding = 4.0;
    const size = Size(1600 - 2 * padding, 900 - 2 * padding);
    final fit = BoardFit.compute(layout.bounds, layout.aspect, size);
    Offset place(int point, int slot) {
      final position = layout.points[point]![slot];
      return const Offset(padding, padding) +
          fit.offset +
          Offset(
            position.u * fit.imageSize.width,
            position.v * fit.imageSize.height,
          );
    }

    await tester.dragFrom(place(8, 2), place(5, 0) - place(8, 2));
    await tester.pumpAndSettle();

    expect(controller.board.count(Player.white, 8), 2);
    expect(controller.board.count(Player.white, 5), 1);
  });

  testWidgets('A-207: Ergebnis anzeigen – erwartet: '
      'Am Ende stehen Sieger und Punkte da, und eine neue Partie ist möglich', (
    tester,
  ) async {
    final controller = GameController(
      roller: FixedRoller([3, 1]),
      game: Game.at(
        board: Board.fromCounts(
          white: const {1: 1},
          whiteOff: 14,
          black: const {12: 15},
        ),
        turn: Player.white,
        phase: GamePhase.awaitingPlay,
        dice: const Dice(1, 2),
      ),
    );
    await showPage(tester, controller);

    controller
      ..tap(1)
      ..tap(0)
      ..confirm();
    await tester.pumpAndSettle();

    expect(find.text('Weiß gewinnt mit Gammon: 2 Punkte'), findsOneWidget);
    await tester.tap(find.text('Neue Partie'));
    await tester.pumpAndSettle();
    expect(controller.game!.phase, GamePhase.awaitingPlay);
  });

  testWidgets('A-110: Doppeln bedienen – erwartet: '
      'Der Gegner sieht das Angebot und kann ablehnen', (tester) async {
    final controller = GameController(
      game: Game.at(
        board: Board.start(),
        turn: Player.white,
        phase: GamePhase.awaitingRoll,
      ),
    );
    await showPage(tester, controller);

    await tester.tap(find.text('Doppeln'));
    await tester.pumpAndSettle();
    expect(find.text('Doppeln auf 2?'), findsOneWidget);

    await tester.tap(find.text('Ablehnen'));
    await tester.pumpAndSettle();
    expect(find.text('Weiß gewinnt: 1 Punkt'), findsOneWidget);
  });
}
