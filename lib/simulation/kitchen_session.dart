import 'combo_engine.dart';
import 'duration_learner.dart';
import 'entropy_engine.dart';
import 'models/adjacency_edge.dart';
import 'models/task_definition.dart';
import 'models/task_rung.dart';
import 'voice_grammar.dart';

/// Why the user said no (spec §3.7).
///
/// The five answers are not interchangeable, and treating them as one
/// "dismiss" is what turns an escape hatch into nagging. Two of them are
/// statements about the *task*, two about *this moment*, and one about the
/// *room* - and each deserves a different response.
enum NotThisReason {
  tooTired('Too tired'),
  takesTooLong('Takes too long'),
  dontFeelLikeIt("Don't feel like it"),
  cantRightNow("Can't right now"),
  notActuallyNeeded('Not actually needed');

  const NotThisReason(this.label);

  final String label;

  /// Whether this answer is evidence about the task rather than the moment.
  ///
  /// "Can't right now" is about the next ten minutes, not about the chore -
  /// counting it would walk someone down the ladder for being interrupted.
  bool get isAboutTheTask =>
      this == tooTired || this == takesTooLong || this == dontFeelLikeIt;
}

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
    this.activeRung,
    this.rejections = const {},
    this.extendedBy = Duration.zero,
    this.beforePhoto,
    this.afterPhoto,
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

  /// Which rung of [currentTaskId]'s ladder is in play, if any.
  ///
  /// An index rather than an id, and the *parent* stays in [currentTaskId]:
  /// entropy, adjacency and the room's hotspots all keep working on the real
  /// task while the user is offered a smaller version of it.
  final int? activeRung;

  /// Per task, how many times the user has said no *about the task itself*.
  ///
  /// Spec §3.7: "Repeated rejection triggers the downgrade ladder, not
  /// nagging." In-session only, like [momentum] - a no on Tuesday should not
  /// still be shrinking the offer on Friday.
  final Map<String, int> rejections;

  /// Time added to the current offer by "five more minutes" (spec §2.5).
  ///
  /// It moves the target, never the clock: [activeElapsed] still reports what
  /// really happened. Asking for longer is permission to keep going, not a
  /// way to make five minutes of work count as ten.
  final Duration extendedBy;

  /// Where the run's "before" picture lives, if one was taken (spec §2.4).
  ///
  /// A local path and nothing more. The simulation deliberately holds no
  /// image bytes and no notion of where the file came from - it only needs to
  /// know that a pair exists, so that the end of the run can show it.
  final String? beforePhoto;

  /// The matching "after", taken once the run is over.
  final String? afterPhoto;

  /// Whether there is a real two-image comparison to show.
  ///
  /// An "after" alone is not the honesty mechanic §2.4 is describing - the
  /// whole force of it is the pair.
  bool get hasComparison => beforePhoto != null && afterPhoto != null;

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
    int? activeRung,
    Map<String, int>? rejections,
    Duration? extendedBy,
    String? beforePhoto,
    String? afterPhoto,
    bool clearCurrentTask = false,
    bool clearComboOffer = false,
    bool clearTaskStartedAt = false,
    bool clearPausedAt = false,
    bool clearActiveRung = false,
    bool clearPhotos = false,
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
      activeRung: clearActiveRung ? null : activeRung ?? this.activeRung,
      rejections: rejections ?? this.rejections,
      extendedBy: extendedBy ?? this.extendedBy,
      beforePhoto: clearPhotos ? null : beforePhoto ?? this.beforePhoto,
      afterPhoto: clearPhotos ? null : afterPhoto ?? this.afterPhoto,
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

  /// The rung currently standing in for the offered task, if the ladder has
  /// been walked down. Null means the full task is on the table.
  TaskRung? activeRung(KitchenSession session) {
    final index = session.activeRung;
    final taskId = session.currentTaskId;
    if (index == null || taskId == null) return null;
    final rungs = taskById(taskId)?.rungs ?? const <TaskRung>[];
    return index < rungs.length ? rungs[index] : null;
  }

  /// What the offer or the run should actually be called right now.
  String? currentLabel(KitchenSession session) {
    final rung = activeRung(session);
    if (rung != null) return rung.label;
    final taskId = session.currentTaskId;
    return taskId == null ? null : taskById(taskId)?.label;
  }

  /// Minutes for whatever is currently on offer - rung and any granted
  /// extension included.
  double currentMinutes(KitchenSession session) {
    final rung = activeRung(session);
    final base = rung != null
        ? session.estimateMinutes[rung.id] ?? rung.durationMinutes
        : session.currentTaskId == null
            ? 2.0
            : offeredMinutes(session, session.currentTaskId!);
    return base + session.extendedBy.inSeconds / 60.0;
  }

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
      extendedBy: Duration.zero,
      clearComboOffer: true,
      clearActiveRung: true,
      // A new run is a new pair. Last run's photos stop being state the
      // moment this one opens - see [discardPhotos] for who deletes the file.
      clearPhotos: true,
    );
  }

  KitchenSession dismissQuest(KitchenSession session) {
    if (session.phase != RunPhase.questOffered) return session;
    return session.copyWith(
      phase: RunPhase.idle,
      clearCurrentTask: true,
      clearActiveRung: true,
    );
  }

  /// **NOT THIS** (spec §3.7). The no-penalty escape from every mission.
  ///
  /// Nothing here punishes: no streak breaks, no completion is recorded, the
  /// duration learner hears nothing. What changes is what gets offered *next*,
  /// and that depends entirely on which of the five answers was given:
  ///
  /// - "Not actually needed" is the user correcting the app about their home,
  ///   so the app believes them: the task stops asking, and its cadence slows.
  /// - "Can't right now" is about the next ten minutes, not the chore. It
  ///   closes the card and is forgotten.
  /// - The other three are evidence the task is too big, and repeated
  ///   rejection walks it down the ladder rather than asking again.
  KitchenSession notThis(
    KitchenSession session,
    NotThisReason reason,
    DateTime now,
  ) {
    if (session.phase != RunPhase.questOffered) return session;
    final id = session.currentTaskId;
    final task = id == null ? null : taskById(id);
    if (task == null || id == null) return session;
    final taskId = id;

    if (reason == NotThisReason.notActuallyNeeded) {
      return session.copyWith(
        phase: RunPhase.idle,
        // Stop nagging now, and expect it back later than before. This grants
        // no reward and records no completion - the room simply stops
        // claiming something the user has told us is untrue.
        lastCompletedAt: {...session.lastCompletedAt, taskId: now},
        risePerHour: {
          ...session.risePerHour,
          taskId: entropy.slowedCadence(
            session.risePerHour[taskId] ?? task.defaultRisePerHour,
          ),
        },
        clearCurrentTask: true,
        clearActiveRung: true,
      );
    }

    if (!reason.isAboutTheTask) return dismissQuest(session);

    final rejections = (session.rejections[taskId] ?? 0) + 1;
    final counted = {...session.rejections, taskId: rejections};

    // One no closes the card. A second is a pattern, and a pattern is what
    // the ladder is for. Once on the ladder every further no steps down
    // again - by then the user has said no three times and being asked the
    // same question a fourth is exactly the nagging §3.7 rules out.
    final nextRung = session.activeRung == null ? 0 : session.activeRung! + 1;
    final canDowngrade = rejections >= 2 && nextRung < task.rungs.length;

    if (!canDowngrade) {
      return session.copyWith(
        phase: RunPhase.idle,
        rejections: counted,
        clearCurrentTask: true,
        clearActiveRung: true,
      );
    }

    return session.copyWith(rejections: counted, activeRung: nextRung);
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
      clearActiveRung: true,
      activeBeforePause: Duration.zero,
      extendedBy: Duration.zero,
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
    final rung = activeRung(session);

    // A rung earns the same celebration as the task - §3.7's whole claim is
    // that the smallest rung is the most valuable thing in the system, and an
    // apologetic reward would contradict it. What it does not earn is the
    // task's *entropy*: the room only reports what actually happened.
    final credited = rung == null
        ? now
        : creditedTimestamp(
            lastCompletedAt: session.lastCompletedAt[taskId],
            now: now,
            credit: rung.credit,
          );

    // The estimate learns under whichever id was actually run. Finishing
    // "put away one thing" in twenty seconds is not evidence that the dishes
    // take twenty seconds.
    final learningId = rung?.id ?? taskId;

    return session.copyWith(
      phase: RunPhase.celebrating,
      lastCompletedAt: {...session.lastCompletedAt, taskId: credited},
      estimateMinutes: {
        ...session.estimateMinutes,
        learningId: learner.updateEstimate(
          currentEstimateMinutes: currentMinutes(session),
          actualMinutes: actualMinutes,
        ),
      },
      // A rung does not retire its parent: the dishes are still there, so the
      // combo engine must stay free to come back to them.
      completedThisRun:
          rung == null ? {...session.completedThisRun, taskId} : null,
      momentum: session.momentum + 1,
      runActive: session.runActive + active,
      activeBeforePause: Duration.zero,
      extendedBy: Duration.zero,
      clearTaskStartedAt: true,
      clearPausedAt: true,
      clearActiveRung: true,
    );
  }

  /// Where a task's clock lands after partial credit.
  ///
  /// Pulls [lastCompletedAt] forward by [credit] of the gap it had opened up,
  /// so the need drops by that share rather than to zero. Pure and public
  /// because the store replays rung history through it on load.
  DateTime creditedTimestamp({
    required DateTime? lastCompletedAt,
    required DateTime now,
    required double credit,
  }) {
    if (lastCompletedAt == null) return now;
    final gap = now.difference(lastCompletedAt);
    if (gap.isNegative) return lastCompletedAt;
    return lastCompletedAt.add(
      Duration(microseconds: (gap.inMicroseconds * credit.clamp(0.0, 1.0)).round()),
    );
  }

  /// Replays a rung's own duration history. Rungs learn like tasks do (spec
  /// §5.2 item 13) - they just learn about themselves.
  KitchenSession withRungEstimate(
    KitchenSession session, {
    required TaskRung rung,
    required List<double> durationsMinutes,
  }) {
    if (durationsMinutes.isEmpty) return session;
    var estimate = rung.durationMinutes;
    for (final actual in durationsMinutes) {
      estimate = learner.updateEstimate(
        currentEstimateMinutes: estimate,
        actualMinutes: actual,
      );
    }
    return session.copyWith(
      estimateMinutes: {...session.estimateMinutes, rung.id: estimate},
    );
  }

  /// Replays one stored rung completion. Used by the store on load so a rung
  /// finished yesterday still shows in today's room.
  KitchenSession withRungCompletion(
    KitchenSession session, {
    required String taskId,
    required TaskRung rung,
    required DateTime at,
  }) {
    if (taskById(taskId) == null) return session;
    return session.copyWith(
      lastCompletedAt: {
        ...session.lastCompletedAt,
        taskId: creditedTimestamp(
          lastCompletedAt: session.lastCompletedAt[taskId],
          now: at,
          credit: rung.credit,
        ),
      },
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
      extendedBy: Duration.zero,
      clearComboOffer: true,
      clearPausedAt: true,
      clearActiveRung: true,
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

  /// The optional "before" picture (spec §2.4).
  ///
  /// Only takeable while the offer is still open, which is the only moment
  /// that makes it true: once the first task is running, the room in the
  /// photograph is no longer the room before the work. Nothing in the run
  /// waits on this and nothing is withheld without it - a run with no photos
  /// plays exactly like a run with them.
  KitchenSession attachBeforePhoto(KitchenSession session, String path) {
    if (session.phase != RunPhase.questOffered) return session;
    return session.copyWith(beforePhoto: path);
  }

  /// The matching "after", offered once the run is over.
  ///
  /// Refused when there is no "before" to compare it against: §2.4 asks for a
  /// two-image slider, and a lone photograph of a clean kitchen makes none of
  /// the argument that the pair makes.
  KitchenSession attachAfterPhoto(KitchenSession session, String path) {
    if (session.phase != RunPhase.restored) return session;
    if (session.beforePhoto == null) return session;
    return session.copyWith(afterPhoto: path);
  }

  /// Throw the pair away.
  ///
  /// §2.4 puts these photos inside someone's home, local-only and never
  /// shared. Something that personal has to be as easy to destroy as it was
  /// to take, so this is a first-class transition rather than a settings
  /// screen. Deleting the files themselves belongs to whoever wrote them.
  KitchenSession discardPhotos(KitchenSession session) {
    if (session.beforePhoto == null && session.afterPhoto == null) {
      return session;
    }
    return session.copyWith(clearPhotos: true);
  }

  /// "Five more minutes" (spec §2.5). Moves the target, never the clock.
  KitchenSession extendRun(
    KitchenSession session, [
    Duration by = const Duration(minutes: 5),
  ]) {
    if (session.phase != RunPhase.running) return session;
    return session.copyWith(extendedBy: session.extendedBy + by);
  }

  /// Spoken commands (spec §2.5), resolved against whatever is on screen.
  ///
  /// The mapping lives here rather than in the widget for the usual reason -
  /// it is a rule, and rules are testable without a microphone - but also
  /// because the same word means different things in different phases. "Next"
  /// is PLAY on an open offer and YES on a combo, and a user with wet hands
  /// should not have to know which.
  ///
  /// Anything that does not apply right now returns the session untouched.
  /// Voice is an alternative set of hands, never an extra set of powers: it
  /// cannot reach a transition a tap could not.
  KitchenSession applyVoice(
    KitchenSession session,
    VoiceIntent intent,
    DateTime now,
  ) {
    switch (intent) {
      case VoiceIntent.done:
        return completeTask(session, now);
      case VoiceIntent.next:
        return switch (session.phase) {
          RunPhase.questOffered => startRun(session, now),
          RunPhase.comboOffered => acceptCombo(session, now),
          RunPhase.celebrating => finishCelebration(session),
          _ => session,
        };
      case VoiceIntent.skip:
        return switch (session.phase) {
          RunPhase.running => skipTask(session),
          RunPhase.questOffered => dismissQuest(session),
          RunPhase.comboOffered => declineCombo(session),
          _ => session,
        };
      case VoiceIntent.pause:
        return pauseRun(session, now);
      case VoiceIntent.resume:
        return resumeRun(session, now);
      case VoiceIntent.fiveMoreMinutes:
        return extendRun(session);
    }
  }
}
