import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../simulation/content_loader.dart';
import '../../simulation/models/room_type_definition.dart';
import '../scenes/kitchen_scene_controller.dart' show databaseProvider;

/// Room types available in the house hub (spec §2.3 step 1a).
/// Content-driven — unlocking a room is a `content/rooms/room_types.json`
/// edit only, never a code change.
final roomTypesProvider = FutureProvider<List<RoomTypeDefinition>>(
  (ref) => const ContentLoader().loadRoomTypes(),
);

/// The single household row, created on first access.
final householdProvider = StreamProvider<Household>((ref) async* {
  final dao = ref.watch(databaseProvider).householdDao;
  await dao.getHousehold();
  yield* dao.watchHousehold();
});
