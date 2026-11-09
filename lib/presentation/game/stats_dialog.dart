import 'package:flutter/material.dart' hide Step;
import 'package:intl/intl.dart';

import '../../application/game_controller.dart';
import '../../domain/board.dart' show Player;
import '../../domain/dice_stats.dart';
import '../../engine/engine.dart';
import '../../l10n/app_localizations.dart';
import '../../persistence/session_store.dart';

enum _StatsPage { dice, leaderboard }

/// Dice statistics and, where the app keeps its state, the leaderboard.
class StatsDialog extends StatefulWidget {
  const StatsDialog({super.key, required this.controller});

  final GameController controller;

  @override
  State<StatsDialog> createState() => _StatsDialogState();
}

class _StatsDialogState extends State<StatsDialog> {
  var _page = _StatsPage.dice;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = widget.controller;
    final withLeaderboard = controller.keepsRecords;
    return AlertDialog(
      title: Text(withLeaderboard ? l10n.statistics : l10n.diceStats),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            if (withLeaderboard)
              SegmentedButton<_StatsPage>(
                segments: [
                  ButtonSegment(
                    value: _StatsPage.dice,
                    label: Text(l10n.statsDice),
                  ),
                  ButtonSegment(
                    value: _StatsPage.leaderboard,
                    label: Text(l10n.leaderboard),
                  ),
                ],
                selected: {_page},
                onSelectionChanged: (choice) =>
                    setState(() => _page = choice.single),
              ),
            if (_page == _StatsPage.dice) ...[
              _StatsTable(
                title: l10n.statsThisGame,
                stats: controller.gameStats,
              ),
              _StatsTable(
                title: l10n.statsAllGames,
                stats: controller.totalStats,
              ),
              Text(
                l10n.statsExpected,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ] else
              _Leaderboard(records: controller.records),
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

/// A table with a header row, scrolling sideways if it does not fit. The
/// first [textColumns] hold words, the others numbers, aligned to the right.
Widget _table(
  List<Widget> header,
  List<List<Widget>> rows, {
  int textColumns = 1,
}) {
  TableRow row(List<Widget> cells) => TableRow(
    children: [
      for (var column = 0; column < cells.length; column++)
        Padding(
          padding: EdgeInsets.only(left: column == 0 ? 0 : 16, bottom: 4),
          child: Align(
            alignment: column < textColumns
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: cells[column],
          ),
        ),
    ],
  );

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: [row(header), for (final cells in rows) row(cells)],
    ),
  );
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
    List<Widget> row(String name, PlayerDiceCount count) => [
      Text(name),
      for (final face in count.faces) Text(_share(face, count.dice)),
      Text(_share(count.doubles, count.rolls)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        _table(
          [
            const SizedBox.shrink(),
            for (var face = 1; face <= 6; face++) Text('$face'),
            Text(l10n.statsDoubles),
          ],
          [
            row(l10n.white, stats.of(Player.white)),
            row(l10n.black, stats.of(Player.black)),
          ],
        ),
      ],
    );
  }
}

class _Leaderboard extends StatelessWidget {
  const _Leaderboard({required this.records});

  final GameRecords records;

  static String level(AppLocalizations l10n, Difficulty difficulty) =>
      switch (difficulty) {
        Difficulty.easy => l10n.difficultyEasy,
        Difficulty.medium => l10n.difficultyMedium,
        Difficulty.hard => l10n.difficultyHard,
      };

  static String playTime(AppLocalizations l10n, Duration time) =>
      l10n.playTime(time.inMinutes, '${time.inSeconds % 60}'.padLeft(2, '0'));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final heading = Theme.of(context).textTheme.titleSmall;
    if (records.games.isEmpty && records.total.games == 0) {
      return Text(l10n.leaderboardEmpty);
    }
    final date = DateFormat.yMd(l10n.localeName).add_Hm();

    List<Widget> totalsRow(String name, LevelTotals totals) => [
      Text(name),
      Text('${totals.games}'),
      Text('${totals.wins}'),
      Text('${totals.points}'),
      Text('${totals.computerPoints}'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(l10n.leaderboardTotals, style: heading),
        _table(
          [
            Text(l10n.leaderboardLevel),
            Text(l10n.leaderboardGames),
            Text(l10n.leaderboardWins),
            Text(l10n.leaderboardYou),
            Text(l10n.leaderboardComputer),
          ],
          [
            for (final difficulty in Difficulty.values)
              totalsRow(level(l10n, difficulty), records.totalsOf(difficulty)),
            totalsRow(l10n.leaderboardAllLevels, records.total),
          ],
        ),
        const SizedBox(height: 8),
        Text(l10n.leaderboardLatest, style: heading),
        _table(
          [
            Text(l10n.leaderboardDate),
            Text(l10n.leaderboardLevel),
            Text(l10n.leaderboardColor),
            Text(l10n.leaderboardPlayTime),
            Text(l10n.leaderboardYou),
            Text(l10n.leaderboardComputer),
          ],
          [
            for (final game in records.games)
              [
                Text(date.format(game.finishedAt)),
                Text(level(l10n, game.difficulty)),
                Text(game.color == Player.white ? l10n.white : l10n.black),
                Text(playTime(l10n, game.playTime)),
                Text('${game.points}'),
                Text('${game.computerPoints}'),
              ],
          ],
          textColumns: 3,
        ),
      ],
    );
  }
}
