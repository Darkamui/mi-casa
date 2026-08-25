import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/flame/components/companion_component.dart';
import 'package:micasa/presentation/flame/kitchen_flame_screen.dart';
import 'package:micasa/presentation/flame/kitchen_game.dart';
import 'package:micasa/presentation/scenes/kitchen_scene_controller.dart';

void main() {
  // The default AutomatedTestWidgetsFlutterBinding runs test bodies inside
  // a FakeAsync zone, which never observes the real native callback that
  // resolves image decoding (Sprite.load) — GameWidget's internal asset
  // loading would hang forever. LiveTestWidgetsFlutterBinding uses the
  // real clock instead, so real asset loading completes normally.
  LiveTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full loop: tap companion -> PLAY -> DONE -> restored',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: KitchenFlameScreen())),
    );
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(find.byType(GameWidget<KitchenGame>), findsOneWidget);
    expect(find.text('KITCHEN RESTORED'), findsNothing);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(KitchenFlameScreen)),
    );
    final notifier = container.read(kitchenSceneProvider.notifier);
    final game = tester
        .widget<GameWidget<KitchenGame>>(find.byType(GameWidget<KitchenGame>))
        .game!;

    notifier.tapCompanion();
    await tester.pump();
    expect(find.text('Kitchen Rescue — 2 min'), findsOneWidget);

    await tester.tap(find.text('PLAY'));
    await tester.pump();
    expect(find.text('Take out the garbage'), findsOneWidget);
    expect(game.kitchenRoom.entropyLayer.children.length, 1);

    await tester.tap(find.text('DONE'));
    await tester.pump();

    expect(game.kitchenRoom.entropyLayer.children.length, 0);
    expect(game.kitchenRoom.characterLayer.companion.mood,
        CompanionMood.celebrating);

    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('KITCHEN RESTORED'), findsOneWidget);
  });
}
