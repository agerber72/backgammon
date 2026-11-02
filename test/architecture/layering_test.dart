import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('A-701: Spiellogik ohne Flutter – erwartet: '
      'domain und engine importieren kein Flutter', () {
    final offenders = ['lib/domain', 'lib/engine']
        .map(Directory.new)
        .where((directory) => directory.existsSync())
        .expand((directory) => directory.listSync(recursive: true))
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where((file) => file.readAsStringSync().contains('package:flutter/'))
        .map((file) => file.path)
        .toList();

    expect(offenders, isEmpty);
  });
}
