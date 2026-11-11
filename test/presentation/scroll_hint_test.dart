import 'package:backgammon/l10n/app_localizations.dart';
import 'package:backgammon/presentation/scroll_hint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ScrollController> _show(WidgetTester tester, int lines) async {
  late ScrollController controller;
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 300,
            height: 200,
            child: ScrollHint(
              builder: (context, scroll) {
                controller = scroll;
                return ListView(
                  controller: scroll,
                  children: [
                    for (var line = 0; line < lines; line++)
                      SizedBox(height: 40, child: Text('Zeile $line')),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return controller;
}

final _arrow = find.byIcon(Icons.keyboard_arrow_down);
final _arrowUp = find.byIcon(Icons.keyboard_arrow_up);

void main() {
  testWidgets('A-327: Mehr Text unten – erwartet: '
      'Ein Pfeil zeigt ihn an, ein Tipp scrollt eine Seite weiter', (
    tester,
  ) async {
    final controller = await _show(tester, 20);
    expect(_arrow, findsOneWidget);

    await tester.tap(_arrow);
    await tester.pumpAndSettle();
    expect(controller.offset, 200 - ScrollHint.overlap);
  });

  testWidgets('A-327: Unten angekommen – erwartet: '
      'Der Pfeil nach unten verschwindet, der Pfeil nach oben scrollt eine '
      'Seite zurück', (tester) async {
    final controller = await _show(tester, 20);
    final end = controller.position.maxScrollExtent;
    controller.jumpTo(end);
    await tester.pumpAndSettle();
    expect(_arrow, findsNothing);

    await tester.tap(_arrowUp);
    await tester.pumpAndSettle();
    expect(controller.offset, end - (200 - ScrollHint.overlap));
  });

  testWidgets('A-327: Ganz oben – erwartet: '
      'Kein Pfeil nach oben', (tester) async {
    await _show(tester, 20);
    expect(_arrowUp, findsNothing);
  });

  testWidgets('A-327: Text passt ganz – erwartet: '
      'Kein Pfeil', (tester) async {
    await _show(tester, 3);
    expect(_arrow, findsNothing);
  });
}
