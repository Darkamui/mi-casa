import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/kitchen_repository.dart';
import '../../simulation/adjacency_graph.dart';
import '../../simulation/combo_engine.dart';
import '../../simulation/content_loader.dart';
import '../../simulation/kitchen_session.dart';

export '../../simulation/kitchen_session.dart'
    show RunPhase, KitchenSession, KitchenSessionEngine, NotThisReason;

/// The clock, as a dependency. Overriding this is how a test drives entropy
/// forward without waiting for real hours to pass.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Builds the pure engine from the content files.
///
/// The engine knows nothing about Riverpod, the asset bundle, or the clock -
/// this is the seam where all three are supplied.
final kitchenEngineProvider = FutureProvider<KitchenSessionEngine>((ref) async {
  const loader = ContentLoader();
  final tasks = await loader.loadTasks();
  final edges = await loader.loadAdjacencyEdges();

  return KitchenSessionEngine(
    tasks: tasks.where((task) => task.roomTypeId == 'kitchen').toList(),
    comboEngine: ComboEngine(AdjacencyGraph(edges)),
  );
});

/// The open database, closed with the provider.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});

/// Overridden in tests with a repository over an in-memory database - or with
/// null, for widget tests that have no business touching disk.
final kitchenRepositoryProvider = Provider<KitchenRepository?>(
  (ref) => KitchenRepository(ref.watch(databaseProvider)),
);

/// Drives the kitchen. Every transition delegates to the pure engine; this
/// class only supplies the clock, the store, and holds the result.
class KitchenSceneController extends AsyncNotifier<KitchenSession> {
  late KitchenSessionEngine _engine;
  KitchenRepository? _repository;

  KitchenSessionEngine get engine => _engine;

  DateTime _now() => ref.read(clockProvider)();

  @override
  Future<KitchenSession> build() async {
    _engine = await ref.watch(kitchenEngineProvider.future);
    _repository = ref.watch(kitchenRepositoryProvider);

    final now = _now();
    final seeded = _engine.seed(now: now);

    final repository = _repository;
    if (repository == null) return seeded;

    await repository.ensureSeeded(_engine.tasks, now);
    return repository.restore(_engine, seeded);
  }

  void _apply(KitchenSession Function(KitchenSession) transition) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(transition(current));
  }

  void offerQuest(String taskId) =>
      _apply((s) => _engine.offerQuest(s, taskId));

  void dismissQuest() => _apply(_engine.dismissQuest);

  /// NOT THIS (spec §3.7). No write, because nothing happened - the only
  /// record a rejection leaves is what the app offers next.
  void notThis(NotThisReason reason) =>
      _apply((s) => _engine.notThis(s, reason, _now()));

  void startRun() => _apply((s) => _engine.startRun(s, _now()));

  /// DONE.
  ///
  /// The state update is synchronous and lands first; the write is fired off
  /// afterwards and nothing waits on it (CLAUDE.md: DONE -> local state ->
  /// feedback -> then background work, never DONE -> request -> spinner).
  void completeTask() {
    final before = state.valueOrNull;
    if (before == null || before.phase != RunPhase.running) return;

    final now = _now();
    final active = _engine.activeElapsed(before, now);
    // A rung is stored under its own id: it is a different act from the task
    // it stands in for, and the estimate it teaches belongs to itself.
    final taskId =
        _engine.activeRung(before)?.id ?? before.currentTaskId;

    _apply((s) => _engine.completeTask(s, now));

    if (taskId == null) return;
    final write = _repository?.recordCompletion(
      taskId: taskId,
      at: now,
      actualMinutes: active.inSeconds / 60.0,
    );
    if (write != null) unawaited(write);
  }

  void pauseRun() => _apply((s) => _engine.pauseRun(s, _now()));

  void resumeRun() => _apply((s) => _engine.resumeRun(s, _now()));

  void skipTask() => _apply(_engine.skipTask);

  /// Active time on the task in play, read live by the run timer.
  Duration activeElapsed() {
    final current = state.valueOrNull;
    if (current == null) return Duration.zero;
    return _engine.activeElapsed(current, _now());
  }

  void finishCelebration() => _apply(_engine.finishCelebration);

  void acceptCombo() => _apply((s) => _engine.acceptCombo(s, _now()));

  void declineCombo() => _apply(_engine.declineCombo);
}

final kitchenSessionProvider =
    AsyncNotifierProvider<KitchenSceneController, KitchenSession>(
  KitchenSceneController.new,
);
