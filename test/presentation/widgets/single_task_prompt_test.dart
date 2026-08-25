import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/widgets/single_task_prompt.dart';

void main() {
  testWidgets('shows the task copy and invokes onDone', (tester) async {
    var done = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SingleTaskPrompt(onDone: () => done = true)),
    ));

    expect(find.text('Take out the garbage'), findsOneWidget);

    await tester.tap(find.text('DONE'));

    expect(done, isTrue);
  });
}
