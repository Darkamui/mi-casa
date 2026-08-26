import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/data/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('insertRoom then getAllRooms returns the inserted room', () async {
    await db.roomsDao.insertRoom(RoomsCompanion.insert(
      id: 'room-1',
      roomTypeId: 'kitchen',
      createdAt: DateTime(2026, 1, 1),
    ));

    final rooms = await db.roomsDao.getAllRooms();

    expect(rooms, hasLength(1));
    expect(rooms.single.roomTypeId, 'kitchen');
  });

  test('getAllRooms orders by sortOrder ascending', () async {
    await db.roomsDao.insertRoom(RoomsCompanion.insert(
      id: 'room-b',
      roomTypeId: 'bathroom',
      createdAt: DateTime(2026, 1, 1),
      sortOrder: const Value(1),
    ));
    await db.roomsDao.insertRoom(RoomsCompanion.insert(
      id: 'room-a',
      roomTypeId: 'kitchen',
      createdAt: DateTime(2026, 1, 1),
      sortOrder: const Value(0),
    ));

    final rooms = await db.roomsDao.getAllRooms();

    expect(rooms.map((r) => r.id).toList(), ['room-a', 'room-b']);
  });
}
