import 'dart:io';

import 'package:backgammon/app/app_version.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('A-218: Version wie in pubspec.yaml – erwartet: '
      'appVersion und appBuild in lib/app/app_version.dart entsprechen der '
      'Zeile version: in pubspec.yaml', () {
    final line = File('pubspec.yaml')
        .readAsLinesSync()
        .firstWhere((line) => line.startsWith('version:'));
    final version = line.substring('version:'.length).trim();

    expect('$appVersion+$appBuild', version);
  });
}
