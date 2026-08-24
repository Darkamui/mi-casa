import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/widgets/companion_widget.dart';

void main() {
  testWidgets('tapping the companion invokes onTap', (tester) async {
    var tapped = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CompanionWidget(
          mood: CompanionMood.idle,
          onTap: () => tapped = true,
        ),
      ),
    ));

    await tester.tap(find.byKey(const ValueKey('companionTap')));

    expect(tapped, isTrue);
  });

  testWidgets('builds without error in celebrating mood', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CompanionWidget(
          mood: CompanionMood.celebrating,
          onTap: () {},
        ),
      ),
    ));

    expect(find.byKey(const ValueKey('companionTap')), findsOneWidget);
  });
}
