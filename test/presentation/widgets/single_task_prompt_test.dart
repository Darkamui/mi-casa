import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/widgets/single_task_prompt.dart';

void main() {
  /// The prompt reads elapsed time from the simulation rather than counting
  /// it, so tests hand it a Duration they control.
  Widget host({
    required Duration Function() elapsed,
    bool paused = false,
    VoidCallback? onDone,
    VoidCallback? onPause,
    VoidCallback? onResume,
    VoidCallback? onSkip,
  }) =>
      MaterialApp(
        home: Scaffold(
          body: SingleTaskPrompt(
            elapsed: elapsed,
            paused: paused,
            targetMinutes: 2,
            onDone: onDone ?? () {},
            onPause: onPause,
            onResume: onResume,
            onSkip: onSkip,
          ),
        ),
      );

  testWidgets('shows the task copy and invokes onDone', (tester) async {
    var done = false;

    await tester.pumpWidget(
      host(elapsed: () => Duration.zero, onDone: () => done = true),
    );

    expect(find.text('Take out the garbage'), findsOneWidget);

    await tester.tap(find.text('DONE'));
    expect(done, isTrue);
  });

  testWidgets('the digits follow the simulation, second by second',
      (tester) async {
    var elapsed = const Duration(seconds: 5);

    await tester.pumpWidget(host(elapsed: () => elapsed));
    expect(find.text('00:05'), findsOneWidget);

    elapsed = const Duration(minutes: 1, seconds: 9);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('01:09'), findsOneWidget);
  });

  testWidgets('running past the offered time is not a failure state',
      (tester) async {
    // Four minutes against a two-minute offer. Spec §3.8 - no OVERDUE, no
    // red, no negative clock.
    await tester.pumpWidget(host(elapsed: () => const Duration(minutes: 4)));

    expect(find.text('04:00'), findsOneWidget);
    expect(find.textContaining('-'), findsNothing);
    expect(find.text('DONE'), findsOneWidget);
  });

  testWidgets('pause and resume are one control that swaps', (tester) async {
    var paused = false;

    await tester.pumpWidget(host(
      elapsed: () => Duration.zero,
      onPause: () => paused = true,
      onResume: () {},
    ));

    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('Resume'), findsNothing);

    await tester.tap(find.text('Pause'));
    expect(paused, isTrue);

    await tester.pumpWidget(host(
      elapsed: () => Duration.zero,
      paused: true,
      onPause: () {},
      onResume: () {},
    ));

    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('Pause'), findsNothing);
  });

  testWidgets('a paused clock stops moving', (tester) async {
    // The widget must not run a clock of its own - if it did, pausing the
    // simulation would leave the digits ticking.
    await tester.pumpWidget(
      host(elapsed: () => const Duration(seconds: 30), paused: true),
    );

    expect(find.text('00:30'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('00:30'), findsOneWidget);
  });

  testWidgets('skip is offered plainly, with no penalty framing',
      (tester) async {
    var skipped = false;

    await tester.pumpWidget(
      host(elapsed: () => Duration.zero, onSkip: () => skipped = true),
    );

    await tester.tap(find.text('Skip'));
    expect(skipped, isTrue);
  });

  testWidgets('the ticker is cancelled when the run ends', (tester) async {
    await tester.pumpWidget(host(elapsed: () => Duration.zero));
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));

    // A leaked periodic Timer fails the test binding here.
    await tester.pump(const Duration(seconds: 2));
  });
}
