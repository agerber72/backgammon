import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter/services.dart';

import '../../legal/legal_text.dart';
import '../scroll_hint.dart';

export '../../legal/legal_text.dart' show LegalPlatform, legalLines;

/// The platform the app runs on.
LegalPlatform get currentLegalPlatform {
  if (kIsWeb) {
    return LegalPlatform.web;
  }
  return defaultTargetPlatform == TargetPlatform.windows
      ? LegalPlatform.windows
      : LegalPlatform.android;
}

/// Shows a legal text bundled with the app, so that it also works offline.
class LegalPage extends StatelessWidget {
  const LegalPage({
    super.key,
    required this.title,
    required this.asset,
    this.platform,
  });

  final String title;
  final String asset;

  /// Defaults to the platform the app runs on.
  final LegalPlatform? platform;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<String>(
        future: rootBundle.loadString(asset),
        builder: (context, snapshot) {
          final text = snapshot.data;
          if (text == null) {
            return const SizedBox.shrink();
          }
          final lines = legalLines(text, platform ?? currentLegalPlatform);
          return SelectionArea(
            child: ScrollHint(
              builder: (context, scroll) => ListView(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16 + ScrollHint.reserve,
                  16,
                ),
                children: [
                  for (final line in lines)
                    if (line.trim().isNotEmpty) _line(context, line),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// The texts use a small part of Markdown: headings, bullets, bold and code.
  Widget _line(BuildContext context, String line) {
    final styles = Theme.of(context).textTheme;
    final clean = line.replaceAll('**', '').replaceAll('`', '');
    if (clean.startsWith('# ')) {
      return Text(clean.substring(2), style: styles.headlineSmall);
    }
    if (clean.startsWith('## ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 6),
        child: Text(clean.substring(3), style: styles.titleMedium),
      );
    }
    if (clean.startsWith('- ')) {
      final bullet = '• ${clean.substring(2)}';
      return Padding(
        padding: const EdgeInsets.only(left: 12, bottom: 4),
        child: Text(bullet),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(clean),
    );
  }
}
