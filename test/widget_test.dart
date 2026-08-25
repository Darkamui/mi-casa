import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/main.dart';
import 'package:micasa/presentation/room/kitchen_room_view.dart';
import 'package:micasa/presentation/widgets/vitality_hud.dart';

void main() {
  testWidgets('app boots into the kitchen room', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MiCasaApp()));
    // Not pumpAndSettle: the hotspot affordances pulse forever by design,
    // so there is no steady state to settle into.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(KitchenRoomView), findsOneWidget);
    expect(find.byType(VitalityHud), findsOneWidget);
    // Coarse verbal state only (spec §2).
    expect(find.text('Slipping'), findsOneWidget);

    // The painting hides its own interaction points, so the only thing
    // making them discoverable is this marker. One per authored hotspot.
    expect(find.byType(HotspotAffordance), findsNWidgets(4));
  });
}
