import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lib contains no hardcoded user-visible text', () {
    final literalText = RegExp(
      r'''(\bText\(\s*|\b(title|tooltip|label|hintText|semanticLabel): )['"](?!\$)''',
    );

    final offenders = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where((file) => !file.uri.pathSegments.contains('l10n'))
        .where((file) => literalText.hasMatch(file.readAsStringSync()))
        .map((file) => file.path)
        .toList();

    expect(offenders, isEmpty);
  });
}
