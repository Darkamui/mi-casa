import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/data/database.dart';
import 'package:micasa/data/tables/chore_completions_table.dart';
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

  test('getCompletionHistory returns timestamps in chronological order', () async {
    await seedChore('chore-1');
    await db.choreCompletionsDao.recordCompletion(
      ChoreCompletionsCompanion.insert(
        id: 'comp-2',
        choreId: 'chore-1',
        completedAt: DateTime(2026, 1, 10),
        actualDurationMinutes: 5.0,
      ),
    );
    await db.choreCompletionsDao.recordCompletion(
      ChoreCompletionsCompanion.insert(
        id: 'comp-1',
        choreId: 'chore-1',
        completedAt: DateTime(2026, 1, 1),
        actualDurationMinutes: 3.0,
      ),
    );

    final history = await db.choreCompletionsDao.getCompletionHistory('chore-1');

    expect(history, [DateTime(2026, 1, 1), DateTime(2026, 1, 10)]);
  });

  test('getRecentCompletions returns most recent first, limited', () async {
    await seedChore('chore-1');
    for (var day = 1; day <= 3; day++) {
      await db.choreCompletionsDao.recordCompletion(
        ChoreCompletionsCompanion.insert(
          id: 'comp-$day',
          choreId: 'chore-1',
          completedAt: DateTime(2026, 1, day),
          actualDurationMinutes: 2.0,
        ),
      );
    }

    final recent = await db.choreCompletionsDao.getRecentCompletions(2);

    expect(recent.map((c) => c.id).toList(), ['comp-3', 'comp-2']);
  });
}
