import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/main.dart';
import 'package:micasa/presentation/screens/title_screen.dart';
import 'package:micasa/presentation/scenes/kitchen_scene_controller.dart';

void main() {
  testWidgets('app boots into the title screen', (tester) async {
    await tester.pumpWidget(ProviderScope(
      // No store: this test is about what the very first screen shows, and
      // opening a real database would drag path_provider in with it.
      overrides: [kitchenRepositoryProvider.overrideWithValue(null)],
      child: const MiCasaApp(),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(TitleScreen), findsOneWidget);
    expect(find.text('MiCasa'), findsOneWidget);
    expect(find.text('Enter House'), findsOneWidget);
  });
}
