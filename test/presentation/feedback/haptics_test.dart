import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/feedback/haptic_score.dart';
import 'package:micasa/presentation/feedback/haptics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// What actually reached the platform.
  late List<String> fired;

  setUp(() {
    fired = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        fired.add(call.arguments as String? ?? 'default');
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('playing a pattern', () {
    testWidgets('the first tap is immediate', (tester) async {
      final haptics = SystemHaptics()..play(HapticCue.combo);
      await tester.pump();

      // CLAUDE.md: DONE -> local state -> haptic. Nothing scheduled, nothing
      // awaited, for the tap the user is meant to feel as the same instant.
      expect(fired, hasLength(1));

      haptics.cancel();
    });

    testWidgets('the rest arrive on time', (tester) async {
      SystemHaptics().play(HapticCue.momentumMilestone);
      await tester.pump(const Duration(milliseconds: 500));

      expect(fired, hasLength(3));
    });

    testWidgets('a single-tap pattern schedules nothing', (tester) async {
      SystemHaptics().play(HapticCue.taskComplete);
      await tester.pump(const Duration(seconds: 1));

      expect(fired, hasLength(1));
    });
  });

  group('patterns never blur into each other', () {
    testWidgets('a new cue replaces one still playing', (tester) async {
      final haptics = SystemHaptics();

      haptics.play(HapticCue.momentumMilestone);
      await tester.pump(const Duration(milliseconds: 40));
      haptics.play(HapticCue.taskComplete);
      await tester.pump(const Duration(seconds: 1));

      // One tap from the interrupted pattern, one from the new one - not the
      // three-plus-one buzz that would make both unrecognisable.
      expect(fired, hasLength(2));
    });

    testWidgets('cancelling drops what has not played yet', (tester) async {
      final haptics = SystemHaptics();

      haptics.play(HapticCue.combo);
      haptics.cancel();
      await tester.pump(const Duration(seconds: 1));

      expect(fired, hasLength(1));
    });
  });

  test('silence really is silent', () {
    const SilentHaptics().play(HapticCue.roomRestored);

    expect(fired, isEmpty);
  });
}
