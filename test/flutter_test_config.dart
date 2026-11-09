import 'dart:async';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

/// Runs every test with a German system language, so that the tests can name
/// the German texts. Tests for English set their own language.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    binding.platformDispatcher.localesTestValue = const [Locale('de', 'DE')];
    binding.platformDispatcher.localeTestValue = const Locale('de', 'DE');
  });
  tearDown(() {
    binding.platformDispatcher.clearLocalesTestValue();
    binding.platformDispatcher.clearLocaleTestValue();
  });
  await testMain();
}
