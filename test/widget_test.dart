import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/main.dart';

void main() {
  testWidgets('app boots into the kitchen scene', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MiCasaApp()));

    expect(find.text('KITCHEN RESTORED'), findsNothing);
    expect(find.byKey(const ValueKey('companionTap')), findsOneWidget);
  });
}
