import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'room_definition.dart';

/// Loads a room's authored layout from `content/rooms/`.
class RoomDefinitionLoader {
  const RoomDefinitionLoader();

  Future<RoomDefinition> load(String roomId) async {
    final source = await rootBundle.loadString('content/rooms/${roomId}_room.json');
    return RoomDefinition.parse(source);
  }
}

final roomDefinitionProvider = FutureProvider.family<RoomDefinition, String>(
  (ref, roomId) => const RoomDefinitionLoader().load(roomId),
);
