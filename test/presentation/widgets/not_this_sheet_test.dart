import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/widgets/not_this_sheet.dart';
import 'package:micasa/simulation/kitchen_session.dart' show NotThisReason;

Widget _sheet({
  void Function(NotThisReason)? onChoose,
  VoidCallback? onDismiss,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          NotThisSheet(
            onChoose: onChoose ?? (_) {},
            onDismiss: onDismiss ?? () {},
          ),
        ],
      ),
    ),
  );
}

void main() {
  testWidgets('all five answers are offered', (tester) async {
    await tester.pumpWidget(_sheet());

    // Spec §3.7 names exactly these. A shorter list quietly removes the one
    // answer someone needed.
    for (final reason in NotThisReason.values) {
      expect(find.text(reason.label), findsOneWidget);
    }
  });

  testWidgets('choosing an answer reports it', (tester) async {
    NotThisReason? chosen;
    await tester.pumpWidget(_sheet(onChoose: (r) => chosen = r));

    await tester.tap(find.text('Takes too long'));

    expect(chosen, NotThisReason.takesTooLong);
  });

  testWidgets('tapping away closes without choosing anything', (tester) async {
    var dismissed = false;
    NotThisReason? chosen;
    await tester.pumpWidget(_sheet(
      onChoose: (r) => chosen = r,
      onDismiss: () => dismissed = true,
    ));

    await tester.tapAt(const Offset(10, 10));

    expect(dismissed, isTrue);
    expect(chosen, isNull);
  });

  testWidgets('nothing here blames the user', (tester) async {
    await tester.pumpWidget(_sheet());

    // §3.7 is a no-penalty escape. Any of these words would make it a
    // confession booth instead.
    for (final word in ['Sorry', 'Failed', 'Give up', 'Quit', 'Really']) {
      expect(find.textContaining(word, findRichText: true), findsNothing);
    }
  });
}
