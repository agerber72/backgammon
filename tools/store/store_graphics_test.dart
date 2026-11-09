// Renders the graphics for the Google Play listing into docs/store/:
// screenshots of the real game page in fixed situations, and the feature
// graphic. It runs as a widget test so the real widgets, theme, fonts and
// board images are used, without a device.
// Run: flutter test tools/store/store_graphics_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:backgammon/app/backgammon_app.dart';
import 'package:backgammon/application/game_controller.dart';
import 'package:backgammon/domain/board.dart';
import 'package:backgammon/domain/dice.dart';
import 'package:backgammon/domain/dice_stats.dart';
import 'package:backgammon/domain/game.dart';
import 'package:backgammon/engine/engine.dart';
import 'package:backgammon/l10n/app_localizations.dart';
import 'package:backgammon/persistence/session_store.dart';
import 'package:backgammon/presentation/app_scale.dart';
import 'package:backgammon/presentation/board/board_assets.dart';
import 'package:backgammon/presentation/board/board_painter.dart';
import 'package:backgammon/presentation/board/board_scene.dart';
import 'package:backgammon/presentation/game/game_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _out = 'docs/store';

/// Devices held sideways, each with the prefix of its file names. Google
/// Play allows at most 2:1; tablets use 16:10.
const _devices = [
  ('', Size(1920, 1080), 2.625), // phone
  ('tablet7_', Size(1920, 1200), 2.0), // 7-inch tablet, 960 x 600 dp
  ('tablet10_', Size(2560, 1600), 2.0), // 10-inch tablet, 1280 x 800 dp
];

/// Store languages with the folder of their pictures below docs/store/ and
/// the line under the title of the feature graphic.
const _languages = [
  ('de', '', 'Kostenlos · ohne Werbung · ohne Konto'),
  ('en', 'en/', 'Free · no ads · no account'),
];

/// Keeps a saved state in memory, so the leaderboard can be shown.
class _MemoryStore implements SessionStore {
  _MemoryStore(this.session);

  Session? session;

  @override
  Future<Session?> load() async => session;

  @override
  Future<void> save(Session session) async => this.session = session;
}

/// A few finished games for the leaderboard picture.
GameRecords _records() {
  final records = GameRecords();
  const games = [
    (Difficulty.easy, Player.white, 9, 2, 0),
    (Difficulty.easy, Player.black, 12, 1, 0),
    (Difficulty.medium, Player.white, 15, 0, 2),
    (Difficulty.medium, Player.white, 11, 2, 0),
    (Difficulty.hard, Player.black, 18, 0, 1),
    (Difficulty.medium, Player.black, 14, 4, 0),
    (Difficulty.hard, Player.white, 21, 1, 0),
  ];
  var day = 0;
  for (final (difficulty, color, minutes, points, computerPoints) in games) {
    records.add(
      GameRecord(
        finishedAt: DateTime(2026, 11, 2 + day, 19 + day % 3, 7 * day % 60),
        difficulty: difficulty,
        color: color,
        playTime: Duration(minutes: minutes, seconds: 13 * day % 60),
        points: points,
        computerPoints: computerPoints,
      ),
    );
    day++;
  }
  return records;
}

class _Roller implements DiceRoller {
  _Roller(this.values);

  final List<int> values;
  var _next = 0;

  @override
  int roll() => values[_next++ % values.length];
}

/// The computer waits, so every picture shows the moment it was set up for.
GameController _controller({Game? game, List<int> dice = const [3, 1]}) =>
    GameController(
      roller: _Roller(dice),
      game: game,
      computerPause: const Duration(hours: 1),
      autoActionDelay: null,
    );

/// A game in its middle: both sides have built points and moved on.
Board _midGame() => Board.fromCounts(
  white: const {24: 1, 13: 3, 8: 2, 6: 4, 5: 2, 4: 2, 3: 1},
  black: const {1: 2, 12: 4, 17: 2, 19: 3, 20: 2, 22: 2},
);

Future<void> _loadFonts() async {
  Future<void> family(String name, List<String> files) async {
    final loader = FontLoader(name);
    for (final file in files) {
      final bytes = File(file).readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }

  await family('Roboto', [
    'assets/fonts/Roboto-Regular.ttf',
    'assets/fonts/Roboto-Medium.ttf',
    'assets/fonts/Roboto-Bold.ttf',
  ]);
  // The symbols come with the Flutter SDK, next to the test runner.
  var cache = File(Platform.resolvedExecutable).parent;
  while (!Directory('${cache.path}/artifacts/material_fonts').existsSync()) {
    cache = cache.parent;
  }
  await family('MaterialIcons', [
    '${cache.path}/artifacts/material_fonts/materialicons-regular.otf',
  ]);
}

Future<void> _save(WidgetTester tester, GlobalKey key, String name) async {
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(
      pixelRatio: tester.view.devicePixelRatio,
    );
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$_out/$name.png')
      ..parent.createSync(recursive: true)
      ..writeAsBytesSync(png!.buffer.asUint8List());
  });
}

void main() {
  late Map<BoardView, BoardAssets> assets;

  setUpAll(() async {
    await _loadFonts();
  });

  var language = _languages.first.$1;
  var folder = _languages.first.$2;
  AppLocalizations l10n() => lookupAppLocalizations(Locale(language));
  var prefix = '';
  var size = _devices.first.$2;
  var ratio = _devices.first.$3;

  Future<GlobalKey> show(WidgetTester tester, GameController controller) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = ratio;
    tester.platformDispatcher.localesTestValue = [Locale(language)];
    addTearDown(tester.view.reset);
    assets = (await tester.runAsync(
      () async => {
        for (final view in BoardView.values)
          view: await BoardAssets.load(view, rootBundle),
      },
    ))!;
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: appTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          localeListResolutionCallback: (locales, supported) =>
              appLocale(locales),
          builder: (context, child) => AppScale(child: child!),
          home: GamePage(preloadedAssets: assets, controller: controller),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return key;
  }

  for (final (code, directory, _) in _languages) {
    for (final device in _devices) {
      group('Sprache $code, Gerät ${device.$1}', () {
        setUp(() {
          (prefix, size, ratio) = device;
          language = code;
          folder = directory;
        });

        testWidgets('Screenshot: Farbe wählen', (tester) async {
          final key = await show(tester, _controller());
          await _save(tester, key, '$folder${prefix}screenshot_1_farbwahl');
        });

        testWidgets('Screenshot: Spielbeginn mit Richtungspfeil', (
          tester,
        ) async {
          final controller = _controller(dice: const [3, 1, 6, 4]);
          final key = await show(tester, controller);
          await tester.tap(find.text(l10n().playWhite));
          await tester.pumpAndSettle();
          await tester.tap(find.text(l10n().difficultyMedium));
          await tester.pump(const Duration(milliseconds: 600));
          controller.tap(8);
          await tester.pump(const Duration(milliseconds: 600));
          await _save(tester, key, '$folder${prefix}screenshot_2_spielbeginn');
          await tester.pumpAndSettle();
        });

        testWidgets('Screenshot: Zug mit Zielen', (tester) async {
          final controller = _controller(
            game: Game.at(
              board: _midGame(),
              turn: Player.white,
              phase: GamePhase.awaitingPlay,
              dice: const Dice(6, 4),
            ),
          );
          final key = await show(tester, controller);
          controller.tap(13);
          await tester.pumpAndSettle();
          await _save(tester, key, '$folder${prefix}screenshot_3_zug');
        });

        testWidgets('Screenshot: Doppelangebot', (tester) async {
          final key = await show(
            tester,
            _controller(
              game: Game.at(
                board: _midGame(),
                turn: Player.black,
                phase: GamePhase.awaitingDoubleResponse,
              ),
            ),
          );
          await _save(tester, key, '$folder${prefix}screenshot_4_doppeln');
        });

        testWidgets('Screenshot: Ergebnis', (tester) async {
          final key = await show(
            tester,
            _controller(
              game: Game.at(
                board: Board.fromCounts(
                  black: const {19: 3, 20: 4, 22: 4, 24: 4},
                  whiteOff: 15,
                ),
                turn: Player.white,
                phase: GamePhase.finished,
                cube: const Cube(value: 2, owner: Player.black),
                result: const GameResult(Player.white, WinType.gammon, 4),
              ),
            ),
          );
          await _save(tester, key, '$folder${prefix}screenshot_5_ergebnis');
        });

        testWidgets('Screenshot: Einstellungen', (tester) async {
          // With the app's default waiting time; nobody rolls by itself here,
          // because both sides are played by hand.
          final key = await show(
            tester,
            GameController(
              game: Game.at(
                board: _midGame(),
                turn: Player.white,
                phase: GamePhase.awaitingRoll,
              ),
              computerPause: const Duration(hours: 1),
            ),
          );
          await tester.tap(find.byTooltip(l10n().settings));
          await tester.pumpAndSettle();
          await _save(
            tester,
            key,
            '$folder${prefix}screenshot_6_einstellungen',
          );
        });

        testWidgets('Screenshot: Bestenliste', (tester) async {
          final store = _MemoryStore(
            Session(
              gameStats: DiceStats(),
              totalStats: DiceStats(),
              preferredHuman: Player.white,
              records: _records(),
            ),
          );
          final controller = GameController(
            store: store,
            computerPause: const Duration(hours: 1),
            autoActionDelay: null,
          );
          final key = await show(tester, controller);
          await tester.tap(find.byTooltip(l10n().statistics));
          await tester.pumpAndSettle();
          await tester.tap(find.text(l10n().leaderboard));
          await tester.pumpAndSettle();
          await _save(tester, key, '$folder${prefix}screenshot_7_bestenliste');
        });
      });
    }
  }

  for (final (code, directory, tagline) in _languages) {
    testWidgets('Vorstellungsgrafik 1024 × 500, Sprache $code', (tester) async {
      tester.view.physicalSize = const Size(1024, 500);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final board = (await tester.runAsync(
        () =>
            BoardAssets.load(BoardView.white, rootBundle, highResolution: true),
      ))!;
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: Color(0xFF17191C)),
                // The board in its start position, as the app draws it.
                Positioned(
                  left: 470,
                  top: 20,
                  width: 620,
                  height: 460,
                  child: CustomPaint(
                    painter: BoardPainter(
                      board,
                      BoardScene.of(Board.start(), null),
                    ),
                  ),
                ),
                Positioned(
                  left: 48,
                  top: 160,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Backgammon',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                          fontSize: 58,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(width: 72, height: 5, color: brandBlue),
                      const SizedBox(height: 20),
                      Text(
                        tagline,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 21,
                          color: Color(0xFFDDE3EA),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await _save(tester, key, '${directory}feature_graphic');
    });
  }
}
