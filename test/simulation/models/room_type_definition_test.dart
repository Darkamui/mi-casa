import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/simulation/models/room_type_definition.dart';

void main() {
  test('parses a room type definition from JSON', () {
    final roomType = RoomTypeDefinition.fromJson(const {
      'id': 'kitchen',
      'name': 'Kitchen',
      'taskIds': ['kitchen.dishes', 'kitchen.clear_counter'],
    });

    expect(roomType.id, 'kitchen');
    expect(roomType.name, 'Kitchen');
    expect(roomType.taskIds, ['kitchen.dishes', 'kitchen.clear_counter']);
  });
}
