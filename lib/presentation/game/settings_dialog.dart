import 'package:flutter/material.dart' hide Step;

import '../../app/app_version.dart';
import '../../application/game_controller.dart';
import '../../domain/board.dart' show Player;
import '../../engine/engine.dart';
import '../../l10n/app_locale.dart';
import '../../l10n/app_localizations.dart';
import '../board/board_assets.dart';
import 'language_flag.dart';
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
  late GamePace _pace = widget.controller.pace;
  late bool _autoForced = widget.controller.autoForced;

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
    spacing: 6,
    children: [Text(label), choice],
  );

  /// Two flags in the title row, because a further row would not fit a
  /// phone without scrolling. The flag of the device language means "follow
  /// the system"; the other one fixes the other language.
  Widget _languageFlags(AppLocalizations l10n, ThemeData theme) {
    final current = l10n.localeName;
    final system = appLocale(WidgetsBinding.instance.platformDispatcher.locales)
        .languageCode;
    Widget flag(String code, String name) {
      final selected = code == current;
      return Tooltip(
        message: name,
        child: Semantics(
          selected: selected,
          button: true,
          label: name,
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () =>
                widget.controller.updateLanguage(code == system ? null : code),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  width: 2,
                  color: selected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                ),
              ),
              child: Opacity(
                opacity: selected ? 1 : 0.6,
                child: LanguageFlag(code),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        flag('en', l10n.languageEnglish),
        flag('de', l10n.languageGerman),
      ],
    );
  }

  /// Laid out in two columns, with the legal texts next to Close, so that the
  /// dialog fits a landscape display without scrolling.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AlertDialog(
      // The version sits flush at the top right; title and version share the
      // width, so neither pushes the other out of a narrow dialog.
      // Centered, because the painted flags have no text baseline.
      title: Row(
        spacing: 16,
        children: [
          Expanded(child: Text(l10n.settings)),
          _languageFlags(l10n, theme),
          Expanded(
            child: Text(
              l10n.appVersionLabel(appVersion, appBuild),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 32,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
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
                  spacing: 12,
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
                      l10n.settingPace,
                      SegmentedButton<GamePace>(
                        // Without the tick and with less padding, four words
                        // fit a phone.
                        showSelectedIcon: false,
                        style: SegmentedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        segments: [
                          for (final (pace, label) in [
                            (GamePace.off, l10n.paceOff),
                            (GamePace.relaxed, l10n.paceRelaxed),
                            (GamePace.normal, l10n.paceNormal),
                            (GamePace.fast, l10n.paceFast),
                          ])
                            ButtonSegment(value: pace, label: Text(label)),
                        ],
                        selected: {_pace},
                        onSelectionChanged: (choice) {
                          setState(() => _pace = choice.single);
                          widget.controller.updatePace(choice.single);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Shares the row with the hint, because a further row would not
            // fit a phone without scrolling.
            Row(
              spacing: 16,
              children: [
                Expanded(
                  child: Text(
                    l10n.settingsNextGame,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                FilterChip(
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  label: Text(l10n.settingAutoForced),
                  tooltip: l10n.settingAutoForcedHint,
                  selected: _autoForced,
                  onSelected: (value) {
                    setState(() => _autoForced = value);
                    widget.controller.updateAutoForced(value);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        Wrap(
          children: [
            TextButton(
              onPressed: () => _openLegal(
                l10n.legalPrivacy,
                'assets/legal/privacy_${l10n.localeName}.md',
              ),
              child: Text(l10n.legalPrivacy),
            ),
            TextButton(
              onPressed: () => _openLegal(
                l10n.legalImprint,
                'assets/legal/imprint_${l10n.localeName}.md',
              ),
              child: Text(l10n.legalImprint),
            ),
            TextButton(
              onPressed: () => showLicensePage(
                context: context,
                applicationName: l10n.appTitle,
                applicationVersion: l10n.appVersionLabel(appVersion, appBuild),
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
