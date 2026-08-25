import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/widgets/quest_card.dart';

void main() {
  testWidgets('tapping PLAY invokes onPlay', (tester) async {
    var played = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: QuestCard(onPlay: () => played = true)),
    ));

    await tester.tap(find.text('PLAY'));

    expect(played, isTrue);
  });

  testWidgets('the close button backs out without playing', (tester) async {
    var played = false;
    var dismissed = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: QuestCard(
          onPlay: () => played = true,
          onDismiss: () => dismissed = true,
        ),
      ),
    ));

    await tester.tap(find.byIcon(Icons.close));

    expect(dismissed, isTrue);
    expect(played, isFalse, reason: 'declining must never start the run');
  });

  testWidgets('NOT THIS is offered without being shouted', (tester) async {
    var opened = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: QuestCard(onPlay: () {}, onNotThis: () => opened = true),
      ),
    ));

    await tester.tap(find.text('NOT THIS'));

    expect(opened, isTrue);
  });

  testWidgets('a card with no escape route offers no NOT THIS',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: QuestCard(onPlay: () {})),
    ));

    expect(find.text('NOT THIS'), findsNothing);
  });

  testWidgets('a rung names itself as a rung, not as the chore',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: QuestCard(
          onPlay: () {},
          title: 'Stand the bag by the door',
          eyebrow: 'GETTING READY',
          minutes: 1,
        ),
      ),
    ));

    // Spec §3.6: a setup quest is its own thing, not a shrunken failure.
    expect(find.text('GETTING READY'), findsOneWidget);
    expect(find.text('KITCHEN RESCUE'), findsNothing);
  });

  testWidgets('the card stays sized to its content, not the screen',
      (tester) async {
    // The close button is easy to add in a way that stretches the card to
    // full width. It should stay a compact card floating over the room.
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(child: QuestCard(onPlay: () {}, onDismiss: () {})),
      ),
    ));

    final width = tester.getSize(find.byType(Card)).width;
    final screen = tester.getSize(find.byType(Scaffold)).width;

    expect(width, lessThan(screen * 0.6));
  });

  group('the optional before photo (spec 2.4)', () {
    testWidgets('is offered when the device has a camera', (tester) async {
      var asked = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: QuestCard(onPlay: () {}, onBeforePhoto: () => asked = true),
        ),
      ));

      await tester.tap(find.text('SNAP THE BEFORE'));
      expect(asked, isTrue);
    });

    testWidgets('is invisible on a device that cannot take one',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: QuestCard(onPlay: () {})),
      ));

      // Not a disabled button explaining what the user is missing.
      expect(find.byIcon(Icons.photo_camera_outlined), findsNothing);
    });

    testWidgets('never stands between the user and PLAY', (tester) async {
      var played = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: QuestCard(onPlay: () => played = true, onBeforePhoto: () {}),
        ),
      ));

      // §2.4 makes the photo optional. PLAY works whether it was taken or not.
      await tester.tap(find.text('PLAY'));
      expect(played, isTrue);
    });

    testWidgets('acknowledges one already taken without asking again',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: QuestCard(
            onPlay: () {},
            onBeforePhoto: () {},
            hasBeforePhoto: true,
          ),
        ),
      ));

      expect(find.text('BEFORE TAKEN'), findsOneWidget);
      expect(find.text('SNAP THE BEFORE'), findsNothing);
    });
  });
}
