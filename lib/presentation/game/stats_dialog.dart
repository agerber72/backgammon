import 'package:flutter/material.dart' hide Step;

import '../../application/game_controller.dart';
import '../../domain/board.dart' show Player;
import '../../domain/dice_stats.dart';
import '../../l10n/app_localizations.dart';

class StatsDialog extends StatelessWidget {
  const StatsDialog({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.diceStats),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            _StatsTable(title: l10n.statsThisGame, stats: controller.gameStats),
            _StatsTable(
              title: l10n.statsAllGames,
              stats: controller.totalStats,
            ),
            Text(
              l10n.statsExpected,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}

class _StatsTable extends StatelessWidget {
  const _StatsTable({required this.title, required this.stats});

  final String title;
  final DiceStats stats;

  static String _share(int part, int all) =>
      all == 0 ? '–' : '${(100 * part / all).round()} %';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    TableRow row(String name, PlayerDiceCount count) => TableRow(
      children: [
        Text(name),
        for (final face in count.faces) Text(_share(face, count.dice)),
        Text(_share(count.doubles, count.rolls)),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            columnWidths: const {0: IntrinsicColumnWidth()},
            border: TableBorder.symmetric(
              inside: const BorderSide(color: Colors.transparent, width: 6),
            ),
            children: [
              TableRow(
                children: [
                  const SizedBox.shrink(),
                  for (var face = 1; face <= 6; face++) Text('$face'),
                  Text(l10n.statsDoubles),
                ],
              ),
              row(l10n.white, stats.of(Player.white)),
              row(l10n.black, stats.of(Player.black)),
            ],
          ),
        ),
      ],
    );
  }
}
