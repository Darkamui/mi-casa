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
}
