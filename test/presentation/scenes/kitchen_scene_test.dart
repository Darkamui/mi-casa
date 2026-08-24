import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/scenes/kitchen_scene.dart';

void main() {
  testWidgets('full M0 flow: tap companion -> PLAY -> DONE -> restored',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: KitchenScene())),
    );

    expect(find.text('KITCHEN RESTORED'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('companionTap')));
    await tester.pump();
    expect(find.text('PLAY'), findsOneWidget);

    await tester.tap(find.text('PLAY'));
    await tester.pump();
    expect(find.text('Put the dishes away'), findsOneWidget);

    await tester.tap(find.text('DONE'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('KITCHEN RESTORED'), findsOneWidget);
  });
}
