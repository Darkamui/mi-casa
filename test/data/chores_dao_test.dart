import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/data/database.dart';
import 'package:micasa/data/tables/chores_table.dart';
import 'package:micasa/data/tables/rooms_table.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedRoom(String id) => db.roomsDao.insertRoom(
        RoomsCompanion.insert(
          id: id,
          roomTypeId: 'kitchen',
          createdAt: DateTime(2026, 1, 1),
        ),
      );

  test('insertChore then getChoresForRoom returns it', () async {
    await seedRoom('room-1');
    await db.choresDao.insertChore(ChoresCompanion.insert(
      id: 'chore-1',
      roomId: 'room-1',
      taskDefinitionId: 'kitchen.dishes',
      createdAt: DateTime(2026, 1, 1),
    ));

    final chores = await db.choresDao.getChoresForRoom('room-1');

    expect(chores, hasLength(1));
    expect(chores.single.taskDefinitionId, 'kitchen.dishes');
  });

  test('removeChore soft-deletes so it is excluded from getActiveChores', () async {
    await seedRoom('room-1');
    await db.choresDao.insertChore(ChoresCompanion.insert(
      id: 'chore-1',
      roomId: 'room-1',
      taskDefinitionId: 'kitchen.dishes',
      createdAt: DateTime(2026, 1, 1),
    ));

    await db.choresDao.removeChore('chore-1');

    final active = await db.choresDao.getActiveChores();
    final forRoom = await db.choresDao.getChoresForRoom('room-1');

    expect(active, isEmpty);
    expect(forRoom.single.isRemoved, isTrue);
  });

  test('inserting a chore for a nonexistent room fails the foreign key', () async {
    expect(
      () => db.choresDao.insertChore(ChoresCompanion.insert(
        id: 'chore-orphan',
        roomId: 'no-such-room',
        taskDefinitionId: 'kitchen.dishes',
        createdAt: DateTime(2026, 1, 1),
      )),
      throwsException,
    );
  });
}
