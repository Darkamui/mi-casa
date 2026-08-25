import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/main.dart';
import 'package:micasa/presentation/room/kitchen_room_view.dart';

void main() {
  testWidgets('app boots into the kitchen room', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MiCasaApp()));
    await tester.pumpAndSettle();

    expect(find.byType(KitchenRoomView), findsOneWidget);
    // Coarse verbal state only (spec §2).
    expect(find.text('Slipping'), findsOneWidget);
  });
}
