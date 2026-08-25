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
    required this.risePerHour,
    required this.completedThisRun,
    required this.taskStartedAt,
    required this.momentum,
    this.pausedAt,
    this.activeBeforePause = Duration.zero,
    this.runActive = Duration.zero,
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

  /// Per task, how fast its need actually rises.
  ///
  /// Starts at the authored default and moves to the user's real cadence once
  /// there is history to learn from. Spec §3.8: "If the user actually vacuums
  /// every 9-12 days, it stops suggesting every 7."
  final Map<String, double> risePerHour;

  /// Reset at the start of each run - the combo engine uses it to avoid
  /// suggesting something already done.
  final Set<String> completedThisRun;

  /// When the *current active segment* began - not when the task was first
  /// opened. Pausing and resuming restarts it.
  final DateTime? taskStartedAt;

  /// In-session chain length. Spec §5.2 item 10: never a daily streak.
  final int momentum;

  /// Non-null while paused. A paused run is stopped, not slowed: no time
  /// accrues, so walking away mid-task cannot inflate what the app believes
  /// the user did.
  final DateTime? pausedAt;

  /// Active time already banked on the current task, across earlier segments.
  final Duration activeBeforePause;

  /// Active time banked by tasks already finished in this run.
  ///
  /// Spec §2.4: "Reward time spent in motion, not checkboxes ticked. A run's
  /// value scales with elapsed active time, not task count." This is the
  /// number that sentence is about, so it has to be tracked honestly even
  /// though nothing spends it yet.
  final Duration runActive;

  KitchenSession copyWith({
    RunPhase? phase,
    String? currentTaskId,
    AdjacencyEdge? comboOffer,
    Map<String, DateTime>? lastCompletedAt,
    Map<String, double>? estimateMinutes,
    Map<String, double>? risePerHour,
    Set<String>? completedThisRun,
    DateTime? taskStartedAt,
    int? momentum,
    DateTime? pausedAt,
    Duration? activeBeforePause,
    Duration? runActive,
    bool clearCurrentTask = false,
    bool clearComboOffer = false,
    bool clearTaskStartedAt = false,
    bool clearPausedAt = false,
  }) {
    return KitchenSession(
      phase: phase ?? this.phase,
      currentTaskId: clearCurrentTask ? null : currentTaskId ?? this.currentTaskId,
      comboOffer: clearComboOffer ? null : comboOffer ?? this.comboOffer,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      estimateMinutes: estimateMinutes ?? this.estimateMinutes,
      risePerHour: risePerHour ?? this.risePerHour,
      completedThisRun: completedThisRun ?? this.completedThisRun,
      taskStartedAt:
          clearTaskStartedAt ? null : taskStartedAt ?? this.taskStartedAt,
      momentum: momentum ?? this.momentum,
      pausedAt: clearPausedAt ? null : pausedAt ?? this.pausedAt,
      activeBeforePause: activeBeforePause ?? this.activeBeforePause,
      runActive: runActive ?? this.runActive,
    );
  }

  bool get isPaused => pausedAt != null;
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
      risePerHour: {
        for (final task in tasks) task.id: task.defaultRisePerHour
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
      risePerHour: session.risePerHour[taskId] ?? task.defaultRisePerHour,
      lastCompletedAt: last,
      now: now,
    );
  }

  /// Fold a task's real completion history back into the session.
  ///
  /// Pure, and takes the history as an argument: the simulation still knows
  /// nothing about where it was stored. Both learned values are derived from
  /// history rather than carried as separate mutable state, so replaying the
  /// same history always gives the same room.
  KitchenSession withHistory(
    KitchenSession session, {
    required String taskId,
    required List<DateTime> completions,
    required List<double> durationsMinutes,
  }) {
    final task = taskById(taskId);
    if (task == null || completions.isEmpty) return session;

    var estimate = task.baseDurationMinutes;
    for (final actual in durationsMinutes) {
      estimate = learner.updateEstimate(
        currentEstimateMinutes: estimate,
        actualMinutes: actual,
      );
    }

    final sorted = [...completions]..sort();
    return session.copyWith(
      lastCompletedAt: {...session.lastCompletedAt, taskId: sorted.last},
      estimateMinutes: {...session.estimateMinutes, taskId: estimate},
      risePerHour: {
        ...session.risePerHour,
        taskId: entropy.learnedRisePerHour(
          defaultRisePerHour: task.defaultRisePerHour,
          completionHistory: sorted,
        ),
      },
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
    return session.copyWith(
      phase: RunPhase.running,
      taskStartedAt: now,
      activeBeforePause: Duration.zero,
      runActive: Duration.zero,
      clearPausedAt: true,
    );
  }

  /// Time actually spent in motion on the current task.
  ///
  /// The timer reads from this rather than from wall-clock elapsed, so a
  /// paused run genuinely stops. Spec §2.4 makes time the honest signal;
  /// a clock that keeps running while the phone is face-down on the sofa
  /// would make it a dishonest one.
  Duration activeElapsed(KitchenSession session, DateTime now) {
    final startedAt = session.taskStartedAt;
    if (startedAt == null || session.isPaused) return session.activeBeforePause;
    final segment = now.difference(startedAt);
    return session.activeBeforePause +
        (segment.isNegative ? Duration.zero : segment);
  }

  /// Active time across the whole run, including the task in play.
  Duration runElapsed(KitchenSession session, DateTime now) =>
      session.runActive + activeElapsed(session, now);

  KitchenSession pauseRun(KitchenSession session, DateTime now) {
    if (session.phase != RunPhase.running || session.isPaused) return session;
    return session.copyWith(
      pausedAt: now,
      activeBeforePause: activeElapsed(session, now),
      clearTaskStartedAt: true,
    );
  }

  KitchenSession resumeRun(KitchenSession session, DateTime now) {
    if (session.phase != RunPhase.running || !session.isPaused) return session;
    return session.copyWith(taskStartedAt: now, clearPausedAt: true);
  }

  /// Spec §3.7: leaving a task carries no penalty and grants no reward. The
  /// completion is not recorded, so the estimate learns nothing from it - an
  /// abandoned task is not evidence about how long the task takes.
  KitchenSession skipTask(KitchenSession session) {
    if (session.phase != RunPhase.running) return session;
    return session.copyWith(
      phase: session.momentum > 0 ? RunPhase.restored : RunPhase.idle,
      clearCurrentTask: true,
      clearTaskStartedAt: true,
      clearPausedAt: true,
      activeBeforePause: Duration.zero,
    );
  }

  /// DONE. Records the completion, learns from how long it really took, and
  /// moves straight to celebrating - no I/O in between (CLAUDE.md).
  KitchenSession completeTask(KitchenSession session, DateTime now) {
    if (session.phase != RunPhase.running) return session;
    final taskId = session.currentTaskId;
    if (taskId == null) return session;

    // Learn from time in motion, not from wall clock: a task someone paused
    // for an hour did not take an hour.
    final active = activeElapsed(session, now);
    final actualMinutes = active.inSeconds / 60.0;

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
      runActive: session.runActive + active,
      activeBeforePause: Duration.zero,
      clearTaskStartedAt: true,
      clearPausedAt: true,
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
      // A new task's clock starts at zero; the run's total keeps counting.
      activeBeforePause: Duration.zero,
      clearComboOffer: true,
      clearPausedAt: true,
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
