import 'package:flame/game.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/main.dart';
import 'package:micasa/presentation/flame/kitchen_game.dart';

void main() {
  // See test/presentation/flame/kitchen_flame_screen_test.dart for why the
  // live binding is required: the default FakeAsync-backed binding never
  // observes the real callback that resolves Sprite.load's image decoding.
  LiveTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app boots into the kitchen scene', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MiCasaApp()));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(find.text('KITCHEN RESTORED'), findsNothing);
    expect(find.byType(GameWidget<KitchenGame>), findsOneWidget);
  });
}
