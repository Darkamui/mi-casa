import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/entropy_state_table.dart';

part 'entropy_state_dao.g.dart';

@DriftAccessor(tables: [EntropyStates])
class EntropyStateDao extends DatabaseAccessor<AppDatabase>
    with _$EntropyStateDaoMixin {
  EntropyStateDao(super.db);

  Future<void> upsertState(EntropyStatesCompanion state) =>
      into(entropyStates).insertOnConflictUpdate(state);

  Future<EntropyState?> getState(String choreId) =>
      (select(entropyStates)..where((e) => e.choreId.equals(choreId)))
          .getSingleOrNull();
}
