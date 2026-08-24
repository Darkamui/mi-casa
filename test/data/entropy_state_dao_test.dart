import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/data/database.dart';
import 'package:micasa/data/tables/chores_table.dart';
import 'package:micasa/data/tables/entropy_state_table.dart';
import 'package:micasa/data/tables/rooms_table.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedChore(String choreId) async {
    await db.roomsDao.insertRoom(RoomsCompanion.insert(
      id: 'room-1',
      roomTypeId: 'kitchen',
      createdAt: DateTime(2026, 1, 1),
    ));
    await db.choresDao.insertChore(ChoresCompanion.insert(
      id: choreId,
      roomId: 'room-1',
      taskDefinitionId: 'kitchen.dishes',
      createdAt: DateTime(2026, 1, 1),
    ));
  }

  test('getState returns null when no state has been recorded', () async {
    await seedChore('chore-1');

    final state = await db.entropyStateDao.getState('chore-1');

    expect(state, isNull);
  });

  test('upsertState inserts new state then updates it on conflict', () async {
    await seedChore('chore-1');

    await db.entropyStateDao.upsertState(EntropyStatesCompanion.insert(
      choreId: 'chore-1',
      lastCompletedAt: Value(DateTime(2026, 1, 1)),
      learnedRisePerHour: const Value(0.02),
    ));

    var state = await db.entropyStateDao.getState('chore-1');
    expect(state!.learnedRisePerHour, 0.02);

    await db.entropyStateDao.upsertState(EntropyStatesCompanion.insert(
      choreId: 'chore-1',
      lastCompletedAt: Value(DateTime(2026, 1, 5)),
      learnedRisePerHour: const Value(0.05),
    ));

    state = await db.entropyStateDao.getState('chore-1');
    expect(state!.learnedRisePerHour, 0.05);
    expect(state.lastCompletedAt, DateTime(2026, 1, 5));
  });
}
