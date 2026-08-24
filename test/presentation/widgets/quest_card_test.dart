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
}
