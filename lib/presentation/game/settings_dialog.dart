import 'package:flutter/material.dart' hide Step;

import '../../application/game_controller.dart';
import '../../domain/board.dart' show Player;
import '../../engine/engine.dart';
import '../../l10n/app_localizations.dart';
import '../board/board_assets.dart';
import 'legal_page.dart';

/// Pops with the chosen board view.
class SettingsDialog extends StatefulWidget {
  const SettingsDialog({
    super.key,
    required this.controller,
    required this.view,
  });

  final GameController controller;
  final BoardView view;

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late Player _color = widget.controller.preferredHuman ?? Player.white;
  late Difficulty _difficulty = widget.controller.difficulty;
  late BoardView _view = widget.view;
  late int _autoDelay = widget.controller.autoActionDelay?.inSeconds ?? 0;

  void _openLegal(String title, String asset) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => LegalPage(title: title, asset: asset),
      ),
    );
  }

  /// A label with its choice below it.
  Widget _setting(String label, Widget choice) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 8,
    children: [Text(label), choice],
  );

  /// Laid out in two columns, with the legal texts next to Close, so that the
  /// dialog fits a landscape display without scrolling.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.settings),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 32,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    _setting(
                      l10n.settingColor,
                      SegmentedButton<Player>(
                        segments: [
                          ButtonSegment(
                            value: Player.white,
                            label: Text(l10n.white),
                          ),
                          ButtonSegment(
                            value: Player.black,
                            label: Text(l10n.black),
                          ),
                        ],
                        selected: {_color},
                        onSelectionChanged: (choice) {
                          setState(() => _color = choice.single);
                          widget.controller.updateSettings(
                            human: choice.single,
                          );
                        },
                      ),
                    ),
                    _setting(
                      l10n.settingView,
                      SegmentedButton<BoardView>(
                        segments: [
                          ButtonSegment(
                            value: BoardView.white,
                            label: Text(l10n.white),
                          ),
                          ButtonSegment(
                            value: BoardView.black,
                            label: Text(l10n.black),
                          ),
                        ],
                        selected: {_view},
                        onSelectionChanged: (choice) =>
                            setState(() => _view = choice.single),
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    _setting(
                      l10n.settingDifficulty,
                      SegmentedButton<Difficulty>(
                        segments: [
                          ButtonSegment(
                            value: Difficulty.easy,
                            label: Text(l10n.difficultyEasy),
                          ),
                          ButtonSegment(
                            value: Difficulty.medium,
                            label: Text(l10n.difficultyMedium),
                          ),
                          ButtonSegment(
                            value: Difficulty.hard,
                            label: Text(l10n.difficultyHard),
                          ),
                        ],
                        selected: {_difficulty},
                        onSelectionChanged: (choice) {
                          setState(() => _difficulty = choice.single);
                          widget.controller.updateSettings(
                            difficulty: choice.single,
                          );
                        },
                      ),
                    ),
                    _setting(
                      l10n.settingAutoDelay,
                      SegmentedButton<int>(
                        segments: [
                          ButtonSegment(
                            value: 0,
                            label: Text(l10n.settingAutoDelayOff),
                          ),
                          for (final seconds in const [3, 5, 10])
                            ButtonSegment(
                              value: seconds,
                              label: Text(
                                l10n.settingAutoDelaySeconds(seconds),
                              ),
                            ),
                        ],
                        selected: {_autoDelay},
                        onSelectionChanged: (choice) {
                          final seconds = choice.single;
                          setState(() => _autoDelay = seconds);
                          widget.controller.updateAutoDelay(
                            seconds == 0 ? null : Duration(seconds: seconds),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              l10n.settingsNextGame,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        Wrap(
          children: [
            TextButton(
              onPressed: () =>
                  _openLegal(l10n.legalPrivacy, 'assets/legal/privacy_de.md'),
              child: Text(l10n.legalPrivacy),
            ),
            TextButton(
              onPressed: () =>
                  _openLegal(l10n.legalImprint, 'assets/legal/imprint_de.md'),
              child: Text(l10n.legalImprint),
            ),
            TextButton(
              onPressed: () => showLicensePage(
                context: context,
                applicationName: l10n.appTitle,
                applicationLegalese: l10n.legalLicensesIntro,
              ),
              child: Text(l10n.legalLicenses),
            ),
          ],
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _view),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}
