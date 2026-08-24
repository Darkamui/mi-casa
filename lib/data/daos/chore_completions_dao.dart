import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/chore_completions_table.dart';

part 'chore_completions_dao.g.dart';

@DriftAccessor(tables: [ChoreCompletions])
class ChoreCompletionsDao extends DatabaseAccessor<AppDatabase>
    with _$ChoreCompletionsDaoMixin {
  ChoreCompletionsDao(super.db);

  Future<void> recordCompletion(ChoreCompletionsCompanion completion) =>
      into(choreCompletions).insert(completion);

  Future<List<DateTime>> getCompletionHistory(String choreId) async {
    final rows = await (select(choreCompletions)
          ..where((c) => c.choreId.equals(choreId))
          ..orderBy([(c) => OrderingTerm(expression: c.completedAt)]))
        .get();
    return rows.map((r) => r.completedAt).toList();
  }

  Future<List<ChoreCompletion>> getRecentCompletions(int limit) =>
      (select(choreCompletions)
            ..orderBy([
              (c) => OrderingTerm(
                    expression: c.completedAt,
                    mode: OrderingMode.desc,
                  )
            ])
            ..limit(limit))
          .get();
}
