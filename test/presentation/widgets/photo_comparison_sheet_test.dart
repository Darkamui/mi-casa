import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/widgets/photo_comparison_sheet.dart';

void main() {
  Widget host({
    VoidCallback? onDismiss,
    VoidCallback? onDiscard,
    VoidCallback? onTakeAfter,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            PhotoComparisonSheet(
              beforePath: '/photos/a.jpg',
              onDismiss: onDismiss ?? () {},
              onDiscard: onDiscard ?? () {},
              onTakeAfter: onTakeAfter,
            ),
          ],
        ),
      ),
    );
  }

  group('the end of a run that was photographed (spec 2.4)', () {
    testWidgets('invites the matching after', (tester) async {
      await tester.pumpWidget(host(onTakeAfter: () {}));

      expect(find.text('TAKE THE AFTER'), findsOneWidget);
    });

    testWidgets('taking it is a choice, not a step', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(host(onDismiss: () => dismissed = true));

      await tester.tap(find.text('CLOSE'));
      await tester.pump();

      expect(dismissed, isTrue);
    });

    testWidgets('deleting is offered plainly, not buried', (tester) async {
      // These are pictures of the inside of someone's home. Throwing them
      // away has to be as easy as taking them (§2.4, local-only).
      var discarded = false;
      await tester.pumpWidget(host(onDiscard: () => discarded = true));

      await tester.tap(find.text('DELETE'));
      await tester.pump();

      expect(discarded, isTrue);
    });

    testWidgets('nothing here grades the room', (tester) async {
      await tester.pumpWidget(host(onTakeAfter: () {}));

      for (final word in ['%', 'Score', 'points', 'Well done', 'Failed']) {
        expect(find.textContaining(word, findRichText: true), findsNothing);
      }
    });
  });
}
