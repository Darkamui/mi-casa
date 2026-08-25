import 'combo_engine.dart';
import 'duration_learner.dart';
import 'entropy_engine.dart';
import 'models/adjacency_edge.dart';
import 'models/task_definition.dart';

/// Where a run currently is.
///
/// `comboOffered` is the one that matters (spec §5.2 item 9, "highest design
/// priority"): finishing a task does not end the run, it offers the next
/// physically-adjacent thing.
enum RunPhase {
  idle,
  questOffered,
  running,
  celebrating,
  comboOffered,
  restored,
}

/// Everything true about the kitchen right now.
///
/// Immutable, and carries no clock of its own - every transition takes `now`
/// as an argument so the whole engine is deterministic under test.
class KitchenSession {
  const KitchenSession({
    required this.phase,
    required this.currentTaskId,
    required this.comboOffer,
    required this.lastCompletedAt,
    required this.estimateMinutes,
    required this.completedThisRun,
    required this.taskStartedAt,
    required this.momentum,
  });

  final RunPhase phase;

  /// The task being offered or run. Null when idle or restored.
  final String? currentTaskId;

  /// The adjacent task suggested after a completion, if any.
  final AdjacencyEdge? comboOffer;

  /// Per task, when it was last finished. Drives entropy.
  final Map<String, DateTime> lastCompletedAt;

  /// Per task, the current learned duration estimate.
  final Map<String, double> estimateMinutes;

  /// Reset at the start of each run - the combo engine uses it to avoid
  /// suggesting something already done.
  final Set<String> completedThisRun;

  final DateTime? taskStartedAt;

  /// In-session chain length. Spec §5.2 item 10: never a daily streak.
  final int momentum;

  KitchenSession copyWith({
    RunPhase? phase,
    String? currentTaskId,
    AdjacencyEdge? comboOffer,
    Map<String, DateTime>? lastCompletedAt,
    Map<String, double>? estimateMinutes,
    Set<String>? completedThisRun,
    DateTime? taskStartedAt,
    int? momentum,
    bool clearCurrentTask = false,
    bool clearComboOffer = false,
    bool clearTaskStartedAt = false,
  }) {
    return KitchenSession(
      phase: phase ?? this.phase,
      currentTaskId: clearCurrentTask ? null : currentTaskId ?? this.currentTaskId,
      comboOffer: clearComboOffer ? null : comboOffer ?? this.comboOffer,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      estimateMinutes: estimateMinutes ?? this.estimateMinutes,
      completedThisRun: completedThisRun ?? this.completedThisRun,
      taskStartedAt:
          clearTaskStartedAt ? null : taskStartedAt ?? this.taskStartedAt,
      momentum: momentum ?? this.momentum,
    );
  }
}

/// Pure rules over [KitchenSession].
///
/// CLAUDE.md: simulation never imports presentation, and task selection,
/// entropy, and combo resolution are pure functions over state. This is the
/// piece that had been missing - the engines all existed, but nothing
/// composed them into a playable loop.
class KitchenSessionEngine {
  const KitchenSessionEngine({
    required this.tasks,
    required this.comboEngine,
    this.entropy = const EntropyEngine(),
    this.learner = const DurationLearner(),
  });

  final List<TaskDefinition> tasks;
  final ComboEngine comboEngine;
  final EntropyEngine entropy;
  final DurationLearner learner;

  TaskDefinition? taskById(String id) {
    for (final task in tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  /// A first-open kitchen with no history yet.
  ///
  /// Phase 0 has no persistence, so the room has to start somewhere. Seeding
  /// every task the same number of hours back means the opening state falls
  /// out of each task's own decay rate rather than being hardcoded - a task
  /// that rots fast reads worse than one that does not, which is the whole
  /// point of the entropy engine.
  KitchenSession seed({
    required DateTime now,
    // Roughly "since yesterday evening": far enough back that the daily
    // tasks are visibly asking for attention, not so far that everything is
    // pinned at Critical and the room has nothing left to lose.
    double hoursSinceCompletion = 16,
  }) {
    final since = now.subtract(
      Duration(minutes: (hoursSinceCompletion * 60).round()),
    );
    return KitchenSession(
      phase: RunPhase.idle,
      currentTaskId: null,
      comboOffer: null,
      lastCompletedAt: {for (final task in tasks) task.id: since},
      estimateMinutes: {
        for (final task in tasks) task.id: task.baseDurationMinutes
      },
      completedThisRun: const {},
      taskStartedAt: null,
      momentum: 0,
    );
  }

  double needLevel(KitchenSession session, String taskId, DateTime now) {
    final task = taskById(taskId);
    final last = session.lastCompletedAt[taskId];
    if (task == null || last == null) return 0;
    return entropy.needLevel(
      risePerHour: task.defaultRisePerHour,
      lastCompletedAt: last,
      now: now,
    );
  }

  /// The room's overall state: the mean of what it is carrying.
  ///
  /// Mean rather than worst, so one long-neglected task cannot pin the whole
  /// room at Critical and make every other completion feel like it did
  /// nothing.
  NeedState vitality(KitchenSession session, DateTime now) {
    if (tasks.isEmpty) return NeedState.thriving;
    final total = tasks.fold<double>(
      0,
      (sum, task) => sum + needLevel(session, task.id, now),
    );
    return entropy.verbalState(total / tasks.length);
  }

  /// The dish overlay is not decoration - it appears when the dishes
  /// themselves have actually slipped (doc §5).
  bool showsDishPile(KitchenSession session, DateTime now) {
    if (session.phase == RunPhase.celebrating) return false;
    final state = entropy.verbalState(
      needLevel(session, 'kitchen.dishes', now),
    );
    return state.index >= NeedState.slipping.index;
  }

  /// Minutes to offer for [taskId] - the learned estimate, not the authored
  /// one. Spec §5.2 item 13.
  double offeredMinutes(KitchenSession session, String taskId) =>
      session.estimateMinutes[taskId] ??
      taskById(taskId)?.baseDurationMinutes ??
      2;

  KitchenSession offerQuest(KitchenSession session, String taskId) {
    if (session.phase != RunPhase.idle && session.phase != RunPhase.restored) {
      return session;
    }
    if (taskById(taskId) == null) return session;
    return session.copyWith(
      phase: RunPhase.questOffered,
      currentTaskId: taskId,
      // A fresh run: nothing has been chained yet.
      completedThisRun: const {},
      momentum: 0,
      clearComboOffer: true,
    );
  }

  KitchenSession dismissQuest(KitchenSession session) {
    if (session.phase != RunPhase.questOffered) return session;
    return session.copyWith(phase: RunPhase.idle, clearCurrentTask: true);
  }

  KitchenSession startRun(KitchenSession session, DateTime now) {
    if (session.phase != RunPhase.questOffered) return session;
    return session.copyWith(phase: RunPhase.running, taskStartedAt: now);
  }

  /// DONE. Records the completion, learns from how long it really took, and
  /// moves straight to celebrating - no I/O in between (CLAUDE.md).
  KitchenSession completeTask(KitchenSession session, DateTime now) {
    if (session.phase != RunPhase.running) return session;
    final taskId = session.currentTaskId;
    if (taskId == null) return session;

    final startedAt = session.taskStartedAt ?? now;
    final actualMinutes = now.difference(startedAt).inSeconds / 60.0;

    return session.copyWith(
      phase: RunPhase.celebrating,
      lastCompletedAt: {...session.lastCompletedAt, taskId: now},
      estimateMinutes: {
        ...session.estimateMinutes,
        taskId: learner.updateEstimate(
          currentEstimateMinutes: offeredMinutes(session, taskId),
          actualMinutes: actualMinutes,
        ),
      },
      completedThisRun: {...session.completedThisRun, taskId},
      momentum: session.momentum + 1,
      clearTaskStartedAt: true,
    );
  }

  /// The combo moment: what is physically next to what you just finished?
  KitchenSession finishCelebration(KitchenSession session) {
    if (session.phase != RunPhase.celebrating) return session;
    final taskId = session.currentTaskId;
    final next = taskId == null
        ? null
        : comboEngine.suggestNext(
            taskId,
            completedThisRun: session.completedThisRun,
          );

    if (next == null) {
      return session.copyWith(
        phase: RunPhase.restored,
        clearCurrentTask: true,
        clearComboOffer: true,
      );
    }
    return session.copyWith(phase: RunPhase.comboOffered, comboOffer: next);
  }

  KitchenSession acceptCombo(KitchenSession session, DateTime now) {
    if (session.phase != RunPhase.comboOffered) return session;
    final offer = session.comboOffer;
    if (offer == null) return session;
    return session.copyWith(
      phase: RunPhase.running,
      currentTaskId: offer.toTaskId,
      taskStartedAt: now,
      clearComboOffer: true,
    );
  }

  /// Declining a combo ends the run warmly, not as a failure. Spec §3.7 -
  /// there is no penalty for stopping.
  KitchenSession declineCombo(KitchenSession session) {
    if (session.phase != RunPhase.comboOffered) return session;
    return session.copyWith(
      phase: RunPhase.restored,
      clearCurrentTask: true,
      clearComboOffer: true,
    );
  }
}
