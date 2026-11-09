import 'package:backgammon/app/app_version.dart';
import 'package:backgammon/app/backgammon_app.dart';
import 'package:backgammon/application/game_controller.dart';
import 'package:backgammon/domain/board.dart' show Board, Player;
import 'package:backgammon/domain/dice.dart';
import 'package:backgammon/domain/game.dart';
import 'package:backgammon/domain/move_generator.dart';
import 'package:backgammon/engine/engine.dart';
import 'package:backgammon/l10n/app_localizations.dart';
import 'package:backgammon/presentation/app_scale.dart';
import 'package:backgammon/presentation/board/board_assets.dart';
import 'package:backgammon/presentation/board/board_painter.dart';
import 'package:backgammon/presentation/board/board_scene.dart';
import 'package:backgammon/presentation/game/game_page.dart';
import 'package:backgammon/presentation/game/legal_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class FixedRoller implements DiceRoller {
  FixedRoller(this.values);

  final List<int> values;
  var _next = 0;

  @override
  int roll() => values[_next++ % values.length];
}

/// Answers at once and always plays the first legal play.
class InstantEngine implements Engine {
  @override
  Future<Play> choosePlay(
    Board board,
    Player player,
    Dice dice,
    Difficulty difficulty,
  ) async => legalPlays(board, player, dice).first;

  @override
  Future<bool> wantsToDouble(Game game, Difficulty difficulty) async => false;

  @override
  Future<bool> acceptsDouble(Game game, Difficulty difficulty) async => true;
}

/// Like the app: the whole interface scales with the window.
Future<void> showScaledPage(
  WidgetTester tester,
  GameController controller,
) async {
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
      builder: (context, child) => AppScale(child: child!),
      home: GamePage(preloadedAssets: assets, controller: controller),
    ),
  );
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
    await showPage(tester, GameController(roller: FixedRoller([1, 3])));
    expect(find.text('Mit welcher Farbe spielst du?'), findsOneWidget);

    await tester.tap(find.text('Schwarz'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey(BoardView.black)), findsOneWidget);
    expect(find.text('Mit welcher Farbe spielst du?'), findsNothing);
    expect(find.text('Wie stark soll der Computer spielen?'), findsOneWidget);
  });

  testWidgets('A-203: Zug bedienen – erwartet: '
      'Nach beiden Zügen erscheint Zug beenden, danach Würfeln', (
    tester,
  ) async {
    final controller = GameController(
      roller: FixedRoller([3, 1, 6, 5]),
      engine: InstantEngine(),
      computerPause: Duration.zero,
      autoActionDelay: null,
    );
    await showPage(tester, controller);
    await tester.tap(find.text('Weiß'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mittel'));
    await tester.pumpAndSettle();

    controller
      ..tap(8)
      ..tap(5);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Zurücknehmen'), findsOneWidget);
    expect(find.byTooltip('Zug beenden'), findsNothing);

    controller
      ..tap(6)
      ..tap(5);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Zug beenden'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Würfeln'), findsOneWidget);
    expect(find.byTooltip('Doppeln'), findsOneWidget);
  });

  testWidgets('A-203: Stein ziehen – erwartet: '
      'Ziehen von Zunge 8 auf Zunge 5 bewegt den Stein wie zwei Tipps', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = GameController(
      roller: FixedRoller([3, 1]),
      engine: InstantEngine(),
      computerPause: Duration.zero,
      autoActionDelay: null,
    );
    await showPage(tester, controller);
    await tester.tap(find.text('Weiß'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mittel'));
    await tester.pumpAndSettle();

    final assets = (await tester.runAsync(
      () => BoardAssets.load(BoardView.white, rootBundle),
    ))!;
    final layout = assets.layout;
    const insets = BoardPage.insets;
    final size = insets.deflateSize(const Size(1600, 900));
    final fit = BoardFit.compute(layout.bounds, layout.aspect, size);
    Offset place(int point, int slot) {
      final position = layout.points[point]![slot];
      return insets.topLeft +
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

    // The only possible move ends the turn by itself (A-221).
    controller
      ..tap(1)
      ..tap(0);
    await tester.pumpAndSettle();

    expect(find.text('Weiß gewinnt mit Gammon: 2 Punkte'), findsOneWidget);
    await tester.tap(find.text('Neue Partie'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Weiß'));
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

    await tester.tap(find.byTooltip('Doppeln'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Doppeln auf 2?'), findsOneWidget);
    expect(find.text('×2'), findsOneWidget);

    await tester.tap(find.byTooltip('Ablehnen'));
    await tester.pumpAndSettle();
    expect(find.text('Weiß gewinnt: 1 Punkt'), findsOneWidget);
  });

  testWidgets('A-315: Gleiche Höhe – erwartet: '
      'Die Knöpfe sind in Farbwahl und Stufenwahl gleich hoch, die Symbole '
      'im Spiel gleich groß wie die übrigen, und nichts läuft über', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(2400, 1080);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final controller = GameController(
      roller: FixedRoller([3, 1, 6, 5]),
      engine: InstantEngine(),
      computerPause: Duration.zero,
      autoActionDelay: null,
    );
    await showPage(tester, controller);
    double height(String text) => tester
        .getSize(
          find.ancestor(
            of: find.text(text),
            matching: find.byType(FilledButton),
          ),
        )
        .height;

    final colorRow = height('Weiß');
    await tester.tap(find.text('Weiß'));
    await tester.pumpAndSettle();
    final levelRow = height('Mittel');
    await tester.tap(find.text('Mittel'));
    await tester.pumpAndSettle();

    controller
      ..tap(8)
      ..tap(5)
      ..tap(6)
      ..tap(5);
    await tester.pumpAndSettle();
    final symbol = tester.getSize(find.byTooltip('Einstellungen'));

    expect(levelRow, closeTo(colorRow, 0.01));
    for (final decision in ['Zug beenden', 'Zurücknehmen', 'Aufgeben']) {
      expect(
        tester.getSize(find.byTooltip(decision)),
        symbol,
        reason: decision,
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('A-112: Aufgeben bedienen – erwartet: '
      'Erst nach der Rückfrage endet die Partie, Abbrechen lässt sie laufen', (
    tester,
  ) async {
    final controller = GameController(
      game: Game.at(
        board: Board.start(),
        turn: Player.white,
        phase: GamePhase.awaitingRoll,
      ),
    );
    await showPage(tester, controller);

    await tester.tap(find.byTooltip('Aufgeben'));
    await tester.pumpAndSettle();
    expect(find.text('Du verlierst 1 Punkt.'), findsOneWidget);
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();
    expect(controller.game!.result, isNull);

    await tester.tap(find.byTooltip('Aufgeben'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Aufgeben'));
    await tester.pumpAndSettle();

    expect(controller.game!.phase, GamePhase.finished);
    expect(find.text('Neue Partie'), findsOneWidget);
    expect(find.byTooltip('Aufgeben'), findsNothing);
  });

  testWidgets('A-805: Rechtliches – erwartet: '
      'Die Einstellungen öffnen Datenschutz und Impressum in der App, '
      'beide sind veröffentlicht ohne Entwurfsvermerk', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = GameController(
      game: Game.at(
        board: Board.start(),
        turn: Player.white,
        phase: GamePhase.awaitingRoll,
      ),
    );
    await showPage(tester, controller);

    Future<void> open(String text) async {
      await tester.tap(find.text(text));
      await tester.pump();
      await tester.runAsync(
        () => rootBundle.loadString('assets/legal/privacy_de.md'),
      );
      await tester.pumpAndSettle();
    }

    await tester.tap(find.byTooltip('Einstellungen'));
    await tester.pumpAndSettle();
    await open('Datenschutz');
    expect(find.textContaining('ENTWURF'), findsNothing);
    expect(find.textContaining('Stand: 9. November 2026'), findsOneWidget);
    expect(find.text('Verantwortlicher'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await open('Impressum');
    expect(find.textContaining('ENTWURF'), findsNothing);
    expect(find.text('Anbieter'), findsOneWidget);
  });

  testWidgets('A-313: Handy – erwartet: '
      'Auf einem kleinen Bildschirm sind die Knöpfe mindestens 48 hoch '
      'und vollständig sichtbar', (tester) async {
    tester.view.physicalSize = const Size(2400, 1080);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await showPage(tester, GameController(roller: FixedRoller([3, 1])));

    final button = find.ancestor(
      of: find.text('Weiß'),
      matching: find.byType(FilledButton),
    );

    expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
    expect(tester.takeException(), isNull);
  });

  testWidgets('A-313: Großer Bildschirm – erwartet: '
      'Am Monitor bleiben die Knöpfe auf dem Filz, ohne Popup', (tester) async {
    tester.view.physicalSize = const Size(2560, 1440);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await showPage(tester, GameController(roller: FixedRoller([3, 1])));

    final button = find.ancestor(
      of: find.text('Weiß'),
      matching: find.byType(FilledButton),
    );
    expect(tester.getSize(button).height, 40);
  });

  testWidgets('A-114: Knopf rechts – erwartet: '
      'Im Rennen zeigt die Symbolleiste Zu Ende spielen', (tester) async {
    final race = GameController(
      game: Game.at(
        board: Board.fromCounts(
          white: const {6: 5, 5: 5, 4: 5},
          black: const {19: 5, 20: 5, 21: 5},
        ),
        turn: Player.white,
        phase: GamePhase.awaitingRoll,
      ),
    );
    await showPage(tester, race);
    expect(find.byTooltip('Zu Ende spielen'), findsOneWidget);
  });

  testWidgets('A-114: Knopf rechts bei Kontakt – erwartet: '
      'Solange sich Steine treffen können, fehlt Zu Ende spielen', (
    tester,
  ) async {
    final contact = GameController(
      game: Game.at(
        board: Board.start(),
        turn: Player.white,
        phase: GamePhase.awaitingRoll,
      ),
    );
    await showPage(tester, contact);
    expect(find.byTooltip('Zu Ende spielen'), findsNothing);
  });

  group('A-317: Würfelgröße', () {
    double diceScale(WidgetTester tester) => tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((paint) => paint.painter)
        .whereType<BoardPainter>()
        .single
        .diceScale;

    testWidgets('A-317: Handy – erwartet: '
        'Die Würfel sind doppelt so groß', (tester) async {
      tester.view.physicalSize = const Size(2400, 1080);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);
      await showPage(tester, GameController(roller: FixedRoller([3, 1])));

      expect(diceScale(tester), 2);
    });

    testWidgets('A-317: Großer Bildschirm – erwartet: '
        'Die Würfel bleiben in normaler Größe', (tester) async {
      tester.view.physicalSize = const Size(2560, 1440);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await showPage(tester, GameController(roller: FixedRoller([3, 1])));

      expect(diceScale(tester), 1);
    });
  });

  group('Kleines Fenster', () {
    void smallWindow(WidgetTester tester) {
      tester.view.physicalSize = const Size(500, 420);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    GameController startPosition() => GameController(
      game: Game.at(
        board: Board.start(),
        turn: Player.white,
        phase: GamePhase.awaitingRoll,
      ),
    );

    testWidgets('A-318: Mitskalieren – erwartet: '
        'Im kleinen Fenster schrumpfen Knöpfe und Symbole mit, und die '
        'Einstellungen zeigen alle Bereiche ohne Scrollen', (tester) async {
      smallWindow(tester);
      await showScaledPage(tester, startPosition());
      final symbol = tester.getSize(find.byTooltip('Einstellungen'));

      await tester.tap(find.byTooltip('Einstellungen'));
      await tester.pumpAndSettle();

      expect(
        symbol.height * AppScale.factorFor(const Size(500, 420)),
        lessThan(40),
      );
      final window = Offset.zero & const Size(500, 420);
      for (final text in [
        'Deine Farbe',
        'Spielstärke',
        'Spieltempo',
        'Pflichtzüge selbst setzen',
        'Zügig',
        'Datenschutz',
        'Schließen',
      ]) {
        expect(
          window.contains(tester.getCenter(find.text(text))),
          isTrue,
          reason: text,
        );
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('A-318: Einstellungen ohne Scrollen – erwartet: '
        'Auf dem Handy und im breiten Fenster passt der ganze Dialog auf den '
        'Bildschirm', (tester) async {
      addTearDown(tester.view.reset);
      for (final (window, ratio) in [
        (const Size(2400, 1080), 2.625),
        (const Size(1376, 756), 1.75),
        (const Size(3816, 2012), 1.75),
      ]) {
        tester.view.physicalSize = window;
        tester.view.devicePixelRatio = ratio;
        await showScaledPage(tester, startPosition());
        await tester.tap(find.byTooltip('Einstellungen'));
        await tester.pumpAndSettle();

        final scroll = tester.state<ScrollableState>(
          find
              .descendant(
                of: find.byType(AlertDialog),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        expect(scroll.position.maxScrollExtent, 0, reason: '$window');
        expect(find.text('Datenschutz'), findsOneWidget);
        await tester.tap(find.text('Schließen'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('A-218: Version in den Einstellungen – erwartet: '
        'Die App-Version steht rechts oben im Dialog, vollständig lesbar, im '
        'kleinen Fenster, auf dem Handy und auf einem 4K-Bildschirm', (
      tester,
    ) async {
      addTearDown(tester.view.reset);
      final label = 'Version $appVersion ($appBuild)';
      for (final (window, ratio) in [
        (const Size(500, 420), 1.0),
        (const Size(2400, 1080), 2.625),
        (const Size(3840, 2160), 1.5),
      ]) {
        tester.view.physicalSize = window;
        tester.view.devicePixelRatio = ratio;
        await showScaledPage(tester, startPosition());
        await tester.tap(find.byTooltip('Einstellungen'));
        await tester.pumpAndSettle();

        final dialog = tester.getRect(find.byType(AlertDialog));
        final version = tester.getRect(find.text(label));
        final title = tester.getRect(find.text('Einstellungen').last);
        expect(version.top, lessThan(dialog.center.dy), reason: '$window');
        expect(version.left, greaterThan(title.right), reason: '$window');
        expect(
          dialog.right - version.right,
          lessThan(dialog.width / 6),
          reason: '$window',
        );
        final text = tester.renderObject<RenderParagraph>(find.text(label));
        expect(text.didExceedMaxLines, isFalse, reason: '$window');
        expect(tester.takeException(), isNull, reason: '$window');
        await tester.tap(find.text('Schließen'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('A-318: Großes Fenster – erwartet: '
        'Auf einem großen Bildschirm wachsen Knöpfe und Symbole mit', (
      tester,
    ) async {
      expect(AppScale.factorFor(const Size(1800, 1000)), greaterThan(1));
      expect(AppScale.factorFor(const Size(500, 420)), lessThan(1));
      expect(AppScale.factorFor(const Size(900, 420)), 1);
    });

    testWidgets('A-318: Maximiertes Fenster – erwartet: '
        'Dialoge, Knöpfe und Symbole wachsen ohne Obergrenze im selben '
        'Verhältnis wie das Fenster', (tester) async {
      Future<(Rect, Rect, Rect)> measure(Size window) async {
        tester.view.physicalSize = window;
        tester.view.devicePixelRatio = 1;
        await showScaledPage(tester, startPosition());
        final symbol = tester.getRect(find.byTooltip('Einstellungen'));
        final button = tester.getRect(find.byTooltip('Würfeln'));
        await tester.tap(find.byTooltip('Einstellungen'));
        await tester.pumpAndSettle();
        final dialog = tester.getRect(find.byType(AlertDialog));
        await tester.tap(find.text('Schließen'));
        await tester.pumpAndSettle();
        return (symbol, button, dialog);
      }

      addTearDown(tester.view.reset);
      final (smallSymbol, smallButton, smallDialog) = await measure(
        const Size(900, 420),
      );
      final (largeSymbol, largeButton, largeDialog) = await measure(
        const Size(2700, 1260),
      );

      expect(largeSymbol.height, closeTo(3 * smallSymbol.height, 0.5));
      expect(largeButton.height, closeTo(3 * smallButton.height, 0.5));
      expect(largeDialog.width, closeTo(3 * smallDialog.width, 1));
      expect(largeDialog.height, closeTo(3 * smallDialog.height, 1));
    });

    testWidgets('A-207: Ergebnis im kleinen Fenster – erwartet: '
        'Ergebnis und Neue Partie stehen vollständig und einzeilig da', (
      tester,
    ) async {
      smallWindow(tester);
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
      await showScaledPage(tester, controller);
      controller
        ..tap(1)
        ..tap(0);
      await tester.pumpAndSettle();

      final button = tester.getSize(
        find.ancestor(
          of: find.text('Neue Partie'),
          matching: find.byType(FilledButton),
        ),
      );
      final result = find.text('Weiß gewinnt mit Gammon: 2 Punkte');
      expect(result, findsOneWidget);
      expect(tester.getSize(result).height, lessThan(2 * 16 * 1.5));
      expect(button.width, greaterThan(button.height));
      expect(button.height, lessThanOrEqualTo(48));
      expect(tester.takeException(), isNull);
    });

    testWidgets('A-319: Symbole neben dem Brett – erwartet: '
        'Im kleinen Fenster liegen die Symbole rechts neben dem Brett und '
        'überdecken es nicht', (tester) async {
      smallWindow(tester);
      final controller = startPosition();
      await showPage(tester, controller);
      final assets = (await tester.runAsync(
        () => BoardAssets.load(BoardView.white, rootBundle),
      ))!;
      final layout = assets.layout;
      const insets = BoardPage.insets;
      final fit = BoardFit.compute(
        layout.bounds,
        layout.aspect,
        insets.deflateSize(const Size(500, 420)),
      );
      final boardRight =
          insets.left +
          fit.offset.dx +
          (layout.bounds.left + layout.bounds.width) * fit.imageSize.width;

      for (final symbol in [
        'Ansicht wechseln',
        'Einstellungen',
        'Würfelstatistik',
      ]) {
        expect(
          tester.getRect(find.byTooltip(symbol)).left,
          greaterThanOrEqualTo(boardRight),
          reason: symbol,
        );
      }
    });
  });

  group('A-805: Rechtstexte je Plattform', () {
    const text = '''
<!--
Hinweis für Bearbeiter
-->
# Titel
<!-- nur: android, windows -->
Installiert
<!-- ende -->
<!-- nur: windows -->
Nur Windows
<!-- ende -->
<!-- nur: web -->
Nur Web
<!-- ende -->
Für alle''';

    test('A-805: Windows – erwartet: '
        'Der Windows-Build zeigt die Abschnitte für Windows und alle, '
        'aber nicht die für das Web', () {
      expect(legalLines(text, LegalPlatform.windows), [
        '# Titel',
        'Installiert',
        'Nur Windows',
        'Für alle',
      ]);
    });

    test('A-805: Android – erwartet: '
        'Der Speicherort unter Windows erscheint auf Android nicht', () {
      expect(legalLines(text, LegalPlatform.android), [
        '# Titel',
        'Installiert',
        'Für alle',
      ]);
    });

    test('A-805: Web – erwartet: '
        'Die Web-Version zeigt nur den Web-Abschnitt und die gemeinsamen', () {
      expect(legalLines(text, LegalPlatform.web), [
        '# Titel',
        'Nur Web',
        'Für alle',
      ]);
    });

    testWidgets('A-805: Speicherort Windows – erwartet: '
        'Nur unter Windows nennt die Datenschutzerklärung die Datei mit dem '
        'Spielstand', (tester) async {
      // Tall enough that the list builds the whole text.
      tester.view.physicalSize = const Size(1000, 6000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      Future<void> open(LegalPlatform platform) async {
        await tester.pumpWidget(
          MaterialApp(
            home: LegalPage(
              title: 'Datenschutz',
              asset: 'assets/legal/privacy_de.md',
              platform: platform,
            ),
          ),
        );
        await tester.runAsync(
          () => rootBundle.loadString('assets/legal/privacy_de.md'),
        );
        await tester.pumpAndSettle();
      }

      await open(LegalPlatform.windows);
      expect(find.textContaining('shared_preferences.json'), findsOneWidget);
      expect(find.text('Web-Version'), findsNothing);

      await open(LegalPlatform.android);
      expect(find.textContaining('shared_preferences.json'), findsNothing);
      expect(find.textContaining('Geräte-Sicherung'), findsOneWidget);

      await open(LegalPlatform.web);
      expect(find.text('Web-Version'), findsOneWidget);
      expect(find.textContaining('nichts in deinem Browser'), findsWidgets);
    });
  });

  testWidgets('A-806: Lizenzen erklärt – erwartet: '
      'Vor der Liste der Pakete erklärt ein Text die Lizenz der App und was '
      'die Liste zeigt', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await showPage(
      tester,
      GameController(
        game: Game.at(
          board: Board.start(),
          turn: Player.white,
          phase: GamePhase.awaitingRoll,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Einstellungen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lizenzen'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('GNU General Public License'), findsOneWidget);
    expect(find.textContaining('technischen Namen'), findsOneWidget);
  });

  group('A-320: Entscheidungen in der Leiste', () {
    testWidgets('A-320: Brett frei – erwartet: '
        'Im Spiel liegen alle Entscheidungen als Symbole unten in der rechten '
        'Leiste, auf dem Brett steht kein Knopf', (tester) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final controller = GameController(
        roller: FixedRoller([3, 1]),
        game: Game.at(
          board: Board.start(),
          turn: Player.white,
          phase: GamePhase.awaitingRoll,
        ),
        autoActionDelay: null,
      );
      await showPage(tester, controller);

      expect(find.byType(FilledButton), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);
      final settings = tester.getRect(find.byTooltip('Einstellungen'));
      final roll = tester.getRect(find.byTooltip('Würfeln'));
      expect(roll.left, settings.left);
      expect(roll.bottom, greaterThan(900 - 80));

      await tester.tap(find.byTooltip('Würfeln'));
      await tester.pumpAndSettle();
      controller
        ..tap(8)
        ..tap(5);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Zurücknehmen'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('A-320: Kein Zug möglich – erwartet: '
        'Das Symbol zum Weitermachen nennt den Grund', (tester) async {
      final controller = GameController(
        game: Game.at(
          board: Board.fromCounts(
            white: const {24: 2},
            black: const {18: 2, 19: 2, 20: 2, 21: 2, 22: 2, 23: 2},
          ),
          turn: Player.white,
          phase: GamePhase.awaitingPlay,
          dice: const Dice(6, 6),
        ),
      );
      await showPage(tester, controller);

      await tester.tap(find.byTooltip('Kein Zug möglich'));
      await tester.pumpAndSettle();
      expect(controller.game!.turn, Player.black);
    });

    testWidgets('A-324: Situationsabhängige Symbole – erwartet: '
        'Kein Zug möglich ist weiß mit blauem Symbol, Einstellungen und '
        'Aufgeben bleiben blau mit weißem Symbol', (tester) async {
      final controller = GameController(
        game: Game.at(
          board: Board.fromCounts(
            white: const {24: 1},
            black: const {18: 2, 19: 2, 20: 2, 21: 2, 22: 2, 23: 2},
            whiteBar: 1,
          ),
          turn: Player.white,
          phase: GamePhase.awaitingPlay,
          dice: const Dice(6, 6),
        ),
      );
      await showPage(tester, controller);

      IconButton button(String tooltip) => tester.widget<IconButton>(
        find.ancestor(
          of: find.byTooltip(tooltip),
          matching: find.byType(IconButton),
        ),
      );
      Color? symbol(String tooltip) => IconTheme.of(
        tester.element(
          find.descendant(
            of: find.byTooltip(tooltip),
            matching: find.byType(Icon),
          ),
        ),
      ).color;

      expect(
        button('Kein Zug möglich').style?.backgroundColor?.resolve({}),
        Colors.white,
      );
      expect(symbol('Kein Zug möglich'), brandBlue);
      // Without a style of their own they take the brand colors of the theme,
      // which A-321 checks.
      for (final permanent in ['Einstellungen', 'Aufgeben']) {
        expect(button(permanent).style, isNull, reason: permanent);
      }
    });

    testWidgets('A-321: Markenfarbe – erwartet: '
        'Knöpfe nutzen das Blau des P2G-Logos mit weißer Schrift', (
      tester,
    ) async {
      await tester.pumpWidget(const BackgammonApp());
      final scheme = Theme.of(tester.element(find.byType(Scaffold).first))
          .colorScheme;

      expect(scheme.primary, const Color(0xFF5B84C3));
      expect(scheme.onPrimary, const Color(0xFFFFFFFF));
      expect(scheme.secondaryContainer, const Color(0xFF5B84C3));
      expect(scheme.onSecondaryContainer, const Color(0xFFFFFFFF));
    });

    testWidgets('A-320: Aufgeben ganz unten – erwartet: '
        'Aufgeben bleibt das unterste Symbol, auch wenn darüber Entscheidungen '
        'erscheinen und verschwinden', (tester) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final controller = GameController(
        roller: FixedRoller([3, 1]),
        game: Game.at(
          board: Board.start(),
          turn: Player.white,
          phase: GamePhase.awaitingRoll,
        ),
        autoActionDelay: null,
      );
      await showPage(tester, controller);
      final resign = tester.getRect(find.byTooltip('Aufgeben'));
      expect(
        tester.getRect(find.byTooltip('Würfeln')).bottom,
        lessThan(resign.top),
      );

      await tester.tap(find.byTooltip('Würfeln'));
      await tester.pumpAndSettle();
      controller
        ..tap(8)
        ..tap(5);
      await tester.pumpAndSettle();

      expect(tester.getRect(find.byTooltip('Aufgeben')), resign);
      expect(
        tester.getRect(find.byTooltip('Zurücknehmen')).bottom,
        lessThan(resign.top),
      );
    });
  });

  testWidgets('A-216: Neue Partie – erwartet: '
      'Nach dem Ende fragt die App erneut nach der Farbe und startet mit der '
      'gewählten Farbe und der bisherigen Stufe', (tester) async {
    final controller = GameController(
      roller: FixedRoller([3, 1]),
      engine: InstantEngine(),
      computerPause: Duration.zero,
      autoActionDelay: null,
    );
    await showPage(tester, controller);
    await tester.tap(find.text('Weiß'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Schwer'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Aufgeben'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Aufgeben'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Neue Partie'));
    await tester.pumpAndSettle();
    expect(find.text('Mit welcher Farbe spielst du?'), findsOneWidget);
    expect(controller.game!.phase, GamePhase.finished);

    await tester.tap(find.text('Schwarz'));
    await tester.pumpAndSettle();
    expect(controller.human, Player.black);
    expect(controller.difficulty, Difficulty.hard);
    expect(controller.game!.result, isNull);
    expect(find.byKey(const ValueKey(BoardView.black)), findsOneWidget);
    expect(find.text('Wie stark soll der Computer spielen?'), findsNothing);
  });

  testWidgets('A-322: Spielrichtung zu Beginn – erwartet: '
      'Nach dem Start zeigt das Brett den Pfeil des Spielers, '
      'nach einigen Sekunden ist er ausgeblendet', (tester) async {
    final controller = GameController(
      roller: FixedRoller([3, 1]),
      engine: InstantEngine(),
      computerPause: Duration.zero,
      autoActionDelay: null,
    );
    BoardScene scene() =>
        (tester
                    .widget<CustomPaint>(
                      find.byWidgetPredicate(
                        (widget) =>
                            widget is CustomPaint &&
                            widget.painter is BoardPainter,
                      ),
                    )
                    .painter!
                as BoardPainter)
            .scene;
    await showPage(tester, controller);
    await tester.tap(find.text('Schwarz'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mittel'));
    await tester.pump(const Duration(seconds: 1));

    expect(scene().direction, Player.black);
    expect(scene().directionOpacity, 1);

    await tester.pumpAndSettle();
    expect(scene().directionOpacity, 0);
  });

  testWidgets('A-223: Kein Zug möglich – erwartet: '
      'Der Hinweis steht direkt neben dem Symbol Weiter, um das der '
      'Countdown läuft', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = GameController(
      roller: FixedRoller([6, 6]),
      game: Game.at(
        board: Board.fromCounts(
          white: const {24: 1},
          black: const {18: 2, 19: 2, 20: 2, 21: 2, 22: 2, 23: 2},
          whiteBar: 1,
        ),
        turn: Player.white,
        phase: GamePhase.awaitingRoll,
      ),
    );
    addTearDown(controller.dispose);
    await showPage(tester, controller);

    controller.roll();
    await tester.pump();

    expect(find.text('Kein Zug möglich'), findsOneWidget);
    expect(find.byType(CountdownRing), findsOneWidget);
    // The note sits right next to its symbol, and the ring does not make the
    // symbol wider than the others.
    final hint = tester.getRect(find.text('Kein Zug möglich'));
    final pass = tester.getRect(find.byTooltip('Kein Zug möglich'));
    expect(hint.right, lessThan(pass.left));
    expect(pass.left - hint.right, lessThan(40));
    expect((hint.center.dy - pass.center.dy).abs(), lessThan(4));
    expect(pass.width, tester.getRect(find.byTooltip('Einstellungen')).width);
    await tester.pump(const Duration(seconds: 2));
    expect(controller.game!.turn, Player.black);
  });

  testWidgets('A-225: Würfel im eigenen Zug – erwartet: '
      'Während des Ziehens steht der Dopplerwürfel rechts und merkt das '
      'Doppeln vor', (tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = GameController(
      roller: FixedRoller([3, 1]),
      engine: InstantEngine(),
      autoActionDelay: null,
    )..startGame(human: Player.white);
    addTearDown(controller.dispose);
    await showPage(tester, controller);

    expect(controller.game!.phase, GamePhase.awaitingPlay);
    await tester.tap(find.byTooltip('Beim nächsten Wurf doppeln'));
    await tester.pump();

    expect(controller.doubleRequested, isTrue);
    expect(
      find.byTooltip('Doppeln vorgemerkt – erneut tippen zum Zurücknehmen'),
      findsOneWidget,
    );
  });

  testWidgets('A-223: Sprechblase antippen – erwartet: '
      'Ein Tipp auf „Kein Zug möglich“ neben dem Symbol geht weiter', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = GameController(
      roller: FixedRoller([6, 6]),
      game: Game.at(
        board: Board.fromCounts(
          white: const {24: 1},
          black: const {18: 2, 19: 2, 20: 2, 21: 2, 22: 2, 23: 2},
          whiteBar: 1,
        ),
        turn: Player.white,
        phase: GamePhase.awaitingRoll,
      ),
      autoActionDelay: null,
    );
    addTearDown(controller.dispose);
    await showPage(tester, controller);
    controller.roll();
    await tester.pump();

    await tester.tap(find.text('Kein Zug möglich'));
    await tester.pump();

    expect(controller.game!.turn, Player.black);
  });

  group('A-225: Nachfrage neben dem Würfel', () {
    /// White has marked the wish to double and is about to roll.
    Future<GameController> asking(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final controller = GameController(
        roller: FixedRoller([3, 1, 6, 5, 4, 2]),
        engine: InstantEngine(),
        computerPause: Duration.zero,
        autoActionDelay: null,
      )..startGame(human: Player.black);
      addTearDown(controller.dispose);
      await showPage(tester, controller);
      controller.requestDouble();
      for (var i = 0; i < 20 && !controller.asksToDouble; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(controller.asksToDouble, isTrue);
      return controller;
    }

    testWidgets('A-225: Doppeln antippen – erwartet: '
        'Die Sprechblase bietet Doppeln oder Würfeln, Doppeln doppelt', (
      tester,
    ) async {
      final controller = await asking(tester);

      expect(find.text('oder'), findsOneWidget);
      await tester.tap(find.text('Doppeln'));
      await tester.pump();

      expect(controller.game!.phase, GamePhase.awaitingDoubleResponse);
      // The computer answers the double.
      await tester.pump(const Duration(milliseconds: 100));
      expect(controller.game!.cube.value, 2);
    });

    testWidgets('A-225: Würfeln antippen – erwartet: '
        'Würfeln in der Sprechblase würfelt ohne zu doppeln', (tester) async {
      final controller = await asking(tester);

      await tester.tap(find.text('Würfeln'));
      await tester.pump();

      expect(controller.game!.phase, GamePhase.awaitingPlay);
      expect(controller.game!.cube.value, 1);
    });
  });
}
