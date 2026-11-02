import 'package:backgammon/app/backgammon_app.dart';
import 'package:backgammon/l10n/app_localizations.dart';
import 'package:backgammon/presentation/board/board_assets.dart';
import 'package:backgammon/presentation/game/game_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
