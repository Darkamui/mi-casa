import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../simulation/adjacency_graph.dart';
import '../../simulation/combo_engine.dart';
import '../../simulation/content_loader.dart';
import '../../simulation/kitchen_session.dart';

export '../../simulation/kitchen_session.dart'
    show RunPhase, KitchenSession, KitchenSessionEngine;

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

/// Drives the kitchen. Every transition delegates to the pure engine; this
/// class only supplies the clock and holds the result.
class KitchenSceneController extends AsyncNotifier<KitchenSession> {
  late KitchenSessionEngine _engine;

  KitchenSessionEngine get engine => _engine;

  DateTime _now() => ref.read(clockProvider)();

  @override
  Future<KitchenSession> build() async {
    _engine = await ref.watch(kitchenEngineProvider.future);
    return _engine.seed(now: _now());
  }

  void _apply(KitchenSession Function(KitchenSession) transition) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(transition(current));
  }

  void offerQuest(String taskId) =>
      _apply((s) => _engine.offerQuest(s, taskId));

  void dismissQuest() => _apply(_engine.dismissQuest);

  void startRun() => _apply((s) => _engine.startRun(s, _now()));

  void completeTask() => _apply((s) => _engine.completeTask(s, _now()));

  void finishCelebration() => _apply(_engine.finishCelebration);

  void acceptCombo() => _apply((s) => _engine.acceptCombo(s, _now()));

  void declineCombo() => _apply(_engine.declineCombo);
}

final kitchenSessionProvider =
    AsyncNotifierProvider<KitchenSceneController, KitchenSession>(
  KitchenSceneController.new,
);
