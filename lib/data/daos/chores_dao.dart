import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/chores_table.dart';

part 'chores_dao.g.dart';

@DriftAccessor(tables: [Chores])
class ChoresDao extends DatabaseAccessor<AppDatabase> with _$ChoresDaoMixin {
  ChoresDao(super.db);

  Future<void> insertChore(ChoresCompanion chore) =>
      into(chores).insert(chore);

  Future<void> removeChore(String choreId) =>
      (update(chores)..where((c) => c.id.equals(choreId)))
          .write(const ChoresCompanion(isRemoved: Value(true)));

  Future<List<Chore>> getChoresForRoom(String roomId) =>
      (select(chores)..where((c) => c.roomId.equals(roomId))).get();

  Future<List<Chore>> getActiveChores() =>
      (select(chores)..where((c) => c.isRemoved.equals(false))).get();
}
