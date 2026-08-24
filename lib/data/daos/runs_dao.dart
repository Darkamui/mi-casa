import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/runs_table.dart';

part 'runs_dao.g.dart';

@DriftAccessor(tables: [Runs])
class RunsDao extends DatabaseAccessor<AppDatabase> with _$RunsDaoMixin {
  RunsDao(super.db);

  Future<void> startRun(RunsCompanion run) => into(runs).insert(run);

  Future<void> endRun({
    required String runId,
    required DateTime endedAt,
    required int momentumChainLength,
  }) =>
      (update(runs)..where((r) => r.id.equals(runId))).write(
        RunsCompanion(
          endedAt: Value(endedAt),
          momentumChainLength: Value(momentumChainLength),
        ),
      );

  Future<List<Run>> getRunHistory() => (select(runs)
        ..orderBy([
          (r) => OrderingTerm(
                expression: r.startedAt,
                mode: OrderingMode.desc,
              )
        ]))
      .get();
}
