import 'package:drift/drift.dart';

import '../simulation/kitchen_session.dart';
import '../simulation/models/task_definition.dart';
import 'database.dart';

/// The seam between the stored home and the simulation.
///
/// The simulation stays pure - it is handed history and hands back a session.
/// Nothing in `lib/simulation` knows this class exists.
///
/// Completions are the only durable record. The learned duration estimate and
/// the learned cadence are *derived* from that history on load rather than
/// stored alongside it, so there is exactly one source of truth and no way for
/// a cached number to drift out of agreement with the events it summarises.
class KitchenRepository {
  const KitchenRepository(this._db);

  final AppDatabase _db;

  static const roomId = 'kitchen';

  /// Creates the room and its chores on first launch.
  ///
  /// Content ids are used directly as chore ids, so the authored task
  /// `kitchen.dishes` and its stored history are the same key. Spec §5.2
  /// item 5: tasks are seeded, and removable, never configured up front.
  Future<void> ensureSeeded(List<TaskDefinition> tasks, DateTime now) async {
    final existing = await _db.roomsDao.getAllRooms();
    if (!existing.any((room) => room.id == roomId)) {
      await _db.roomsDao.insertRoom(
        RoomsCompanion.insert(
          id: roomId,
          roomTypeId: roomId,
          createdAt: now,
        ),
      );
    }

    final chores = await _db.choresDao.getChoresForRoom(roomId);
    final known = chores.map((chore) => chore.id).toSet();

    // Rungs get chore rows of their own (spec §3.7). They are not tasks - they
    // never nag from the room - but "put away one thing" is a real thing
    // someone really did, and it has to survive a relaunch like anything else.
    final ids = <String, String>{
      for (final task in tasks) ...{
        task.id: task.id,
        for (final rung in task.rungs) rung.id: task.id,
      }
    };

    for (final entry in ids.entries) {
      if (known.contains(entry.key)) continue;
      await _db.choresDao.insertChore(
        ChoresCompanion.insert(
          id: entry.key,
          roomId: roomId,
          taskDefinitionId: entry.value,
          createdAt: now,
        ),
      );
    }
  }

  /// Rebuilds [session] from what actually happened.
  ///
  /// A task with no history keeps its seeded values, so a newly added chore
  /// behaves like a first-launch one instead of reading as never-done-ever.
  Future<KitchenSession> restore(
    KitchenSessionEngine engine,
    KitchenSession session,
  ) async {
    var restored = session;

    for (final task in engine.tasks) {
      final completions =
          await _db.choreCompletionsDao.getCompletionHistory(task.id);
      if (completions.isNotEmpty) {
        final durations = await _durationsFor(task.id);
        restored = engine.withHistory(
          restored,
          taskId: task.id,
          completions: completions,
          durationsMinutes: durations,
        );
      }

      // Rung history is applied *after* the parent's, in the order it
      // happened, because partial credit compounds: two small acts since the
      // last real completion are worth more than one, and neither is worth a
      // finished chore. Rung completions are deliberately kept out of
      // `withHistory` - they are not evidence about the task's cadence.
      final rungs = {for (final rung in task.rungs) rung.id: rung};
      if (rungs.isEmpty) continue;

      final events = <({DateTime at, String rungId})>[];
      for (final rungId in rungs.keys) {
        for (final at in await _db.choreCompletionsDao
            .getCompletionHistory(rungId)) {
          events.add((at: at, rungId: rungId));
        }
      }
      events.sort((a, b) => a.at.compareTo(b.at));

      for (final event in events) {
        final last = restored.lastCompletedAt[task.id];
        if (last != null && !event.at.isAfter(last)) continue;
        restored = engine.withRungCompletion(
          restored,
          taskId: task.id,
          rung: rungs[event.rungId]!,
          at: event.at,
        );
      }

      for (final rungId in rungs.keys) {
        final durations = await _durationsFor(rungId);
        if (durations.isEmpty) continue;
        restored = engine.withRungEstimate(
          restored,
          rung: rungs[rungId]!,
          durationsMinutes: durations,
        );
      }
    }

    return restored;
  }

  /// Writes one completion. Called *after* the UI has already reacted -
  /// CLAUDE.md: DONE -> local state -> feedback -> then background work.
  Future<void> recordCompletion({
    required String taskId,
    required DateTime at,
    required double actualMinutes,
  }) async {
    await _db.choreCompletionsDao.recordCompletion(
      ChoreCompletionsCompanion.insert(
        id: '$taskId@${at.toIso8601String()}',
        choreId: taskId,
        completedAt: at,
        actualDurationMinutes: actualMinutes,
      ),
    );
  }

  Future<List<double>> _durationsFor(String choreId) async {
    final rows = await (_db.select(_db.choreCompletions)
          ..where((c) => c.choreId.equals(choreId))
          ..orderBy([(c) => OrderingTerm(expression: c.completedAt)]))
        .get();
    return rows.map((row) => row.actualDurationMinutes).toList();
  }
}
