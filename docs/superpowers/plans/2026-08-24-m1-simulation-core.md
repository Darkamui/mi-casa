# M1 — Simulation Core Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. This project's owner has requested **inline execution** (superpowers:executing-plans), not subagent-driven-development, to avoid repeated full-context reads.

**Goal:** Build `lib/simulation/` — the pure, headless game-logic core:
task/room data models, the entropy/need-level engine (§3.8), adaptive
duration learning (§5.2 item 13), the physical-adjacency combo engine
(§3.5, §5.2 item 9 — "highest design priority"), and the in-session
momentum counter (§3.4, §5.2 item 10) — loading its content (room
types, tasks, adjacency edges) from data files in `content/`, not code.

**Architecture:** Every unit in this milestone is a pure function or a
small stateless/self-contained class over plain data — no Riverpod, no
widgets, no I/O in the logic itself. The one exception is `ContentLoader`,
which is split into pure parse functions (`parseRoomTypes`, `parseTasks`,
`parseAdjacencyEdges` — unit-tested with inline JSON strings, no asset
bundle needed) and thin async wrappers (`loadRoomTypes`, `loadTasks`,
`loadAdjacencyEdges`) that read the real files from `content/` via
`rootBundle` and hand the string to the pure parser. Nothing in this
milestone imports from `lib/presentation/`, and nothing in
`lib/presentation/` is touched — M1 is not wired into the M0 UI yet
(that wiring is M6, per the roadmap doc).

**Tech Stack:** Flutter/Dart only (`dart:convert` for JSON,
`package:flutter/services.dart` for `rootBundle` in the content loader's
I/O wrapper). No new pubspec dependencies — `drift` is already a
dependency but persistence is M2; this milestone holds all state in
plain Dart objects passed in and out of pure functions.

**Spec:** `docs/micasa_spec.md` §3.4 (Momentum), §3.5 (Combo / "one more
thing"), §3.8 (Entropy, not deadlines), §5.2 items 6/9/10/13, §5.3
(Technical direction — deterministic core, content-driven). Design doc:
`docs/superpowers/specs/2026-08-24-phase-0-roadmap-design.md` §2.2 M1.

## Global Constraints

- Every file created in this milestone lives under `lib/simulation/` or
  `content/`. Nothing here imports `package:flutter_riverpod` or
  anything from `lib/presentation/` (CLAUDE.md architectural rule,
  spec §5.3: "this package never imports from `lib/presentation/`").
- Task selection, entropy, and combo resolution are pure functions over
  state — no hidden mutable globals, no singletons. Every class takes
  its inputs as constructor/method parameters and returns plain values
  (spec §5.3: "Deterministic core").
- Room types, tasks, and adjacency edges live in `content/` as JSON data
  files, not Dart code (spec §5.3, CLAUDE.md: "Adding a room type must
  not require a code change" — adding a new kitchen task in this
  milestone means editing `content/tasks/tasks.json`, never touching a
  `.dart` file).
- No percentages surface anywhere a human reads them — `needLevel` is an
  internal `double`; the only thing this milestone exposes as
  human-facing is the `NeedState` enum (`thriving` / `comfortable` /
  `slipping` / `struggling` / `critical`), matching spec §2.2's exact
  five-state vocabulary. There is no UI in this milestone, but the enum
  values are the contract M3+ will render.
- Momentum is in-session only — `MomentumCounter` holds no persisted
  state and has no notion of "yesterday" (spec §3.4: "not across days").
- Reuse the spec's own copy verbatim in content data where it gives
  exact strings: `"Wipe it?"` for the counter→wipe-counter combo prompt
  (§3.5's own example), `"Put the dishes away"` for the seed kitchen
  task (§5.1 step 3).

---

### Task 1: Core data models

**Files:**
- Create: `lib/simulation/models/task_definition.dart`
- Create: `lib/simulation/models/room_type_definition.dart`
- Create: `lib/simulation/models/adjacency_edge.dart`
- Test: `test/simulation/models/task_definition_test.dart`
- Test: `test/simulation/models/room_type_definition_test.dart`
- Test: `test/simulation/models/adjacency_edge_test.dart`

**Interfaces:**
- Produces: `class TaskDefinition` with fields `String id`,
  `String roomTypeId`, `String label`, `double baseDurationMinutes`,
  `double defaultRisePerHour`, and `TaskDefinition.fromJson(Map<String,
  dynamic> json)`. `class RoomTypeDefinition` with fields `String id`,
  `String name`, `List<String> taskIds`, and
  `RoomTypeDefinition.fromJson(...)`. `class AdjacencyEdge` with fields
  `String fromTaskId`, `String toTaskId`, `String prompt`,
  `double estimatedMinutes`, and `AdjacencyEdge.fromJson(...)`. Tasks
  2–7 consume these three types and their `fromJson` constructors by
  these exact names.

- [ ] **Step 1: Write the failing test for `TaskDefinition`**

```dart
// test/simulation/models/task_definition_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/simulation/models/task_definition.dart';

void main() {
  test('parses a task definition from JSON', () {
    final task = TaskDefinition.fromJson(const {
      'id': 'kitchen.dishes',
      'roomTypeId': 'kitchen',
      'label': 'Put the dishes away',
      'baseDurationMinutes': 2.0,
      'defaultRisePerHour': 0.005952,
    });

    expect(task.id, 'kitchen.dishes');
    expect(task.roomTypeId, 'kitchen');
    expect(task.label, 'Put the dishes away');
    expect(task.baseDurationMinutes, 2.0);
    expect(task.defaultRisePerHour, 0.005952);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/simulation/models/task_definition_test.dart`
Expected: FAIL — `Error: Couldn't resolve the package 'micasa' in
'package:micasa/simulation/models/task_definition.dart'` (file doesn't
exist yet).

- [ ] **Step 3: Implement `TaskDefinition`**

```dart
// lib/simulation/models/task_definition.dart
class TaskDefinition {
  const TaskDefinition({
    required this.id,
    required this.roomTypeId,
    required this.label,
    required this.baseDurationMinutes,
    required this.defaultRisePerHour,
  });

  final String id;
  final String roomTypeId;
  final String label;
  final double baseDurationMinutes;
  final double defaultRisePerHour;

  factory TaskDefinition.fromJson(Map<String, dynamic> json) {
    return TaskDefinition(
      id: json['id'] as String,
      roomTypeId: json['roomTypeId'] as String,
      label: json['label'] as String,
      baseDurationMinutes: (json['baseDurationMinutes'] as num).toDouble(),
      defaultRisePerHour: (json['defaultRisePerHour'] as num).toDouble(),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/simulation/models/task_definition_test.dart`
Expected: PASS

- [ ] **Step 5: Write the failing test for `RoomTypeDefinition`**

```dart
// test/simulation/models/room_type_definition_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/simulation/models/room_type_definition.dart';

void main() {
  test('parses a room type definition from JSON', () {
    final roomType = RoomTypeDefinition.fromJson(const {
      'id': 'kitchen',
      'name': 'Kitchen',
      'taskIds': ['kitchen.dishes', 'kitchen.clear_counter'],
    });

    expect(roomType.id, 'kitchen');
    expect(roomType.name, 'Kitchen');
    expect(roomType.taskIds, ['kitchen.dishes', 'kitchen.clear_counter']);
  });
}
```

- [ ] **Step 6: Run test to verify it fails**

Run: `flutter test test/simulation/models/room_type_definition_test.dart`
Expected: FAIL — file doesn't exist yet.

- [ ] **Step 7: Implement `RoomTypeDefinition`**

```dart
// lib/simulation/models/room_type_definition.dart
class RoomTypeDefinition {
  const RoomTypeDefinition({
    required this.id,
    required this.name,
    required this.taskIds,
  });

  final String id;
  final String name;
  final List<String> taskIds;

  factory RoomTypeDefinition.fromJson(Map<String, dynamic> json) {
    return RoomTypeDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      taskIds: (json['taskIds'] as List).cast<String>(),
    );
  }
}
```

- [ ] **Step 8: Run test to verify it passes**

Run: `flutter test test/simulation/models/room_type_definition_test.dart`
Expected: PASS

- [ ] **Step 9: Write the failing test for `AdjacencyEdge`**

```dart
// test/simulation/models/adjacency_edge_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/simulation/models/adjacency_edge.dart';

void main() {
  test('parses an adjacency edge from JSON', () {
    final edge = AdjacencyEdge.fromJson(const {
      'fromTaskId': 'kitchen.clear_counter',
      'toTaskId': 'kitchen.wipe_counter',
      'prompt': 'Wipe it?',
      'estimatedMinutes': 2.0,
    });

    expect(edge.fromTaskId, 'kitchen.clear_counter');
    expect(edge.toTaskId, 'kitchen.wipe_counter');
    expect(edge.prompt, 'Wipe it?');
    expect(edge.estimatedMinutes, 2.0);
  });
}
```

- [ ] **Step 10: Run test to verify it fails**

Run: `flutter test test/simulation/models/adjacency_edge_test.dart`
Expected: FAIL — file doesn't exist yet.

- [ ] **Step 11: Implement `AdjacencyEdge`**

```dart
// lib/simulation/models/adjacency_edge.dart
class AdjacencyEdge {
  const AdjacencyEdge({
    required this.fromTaskId,
    required this.toTaskId,
    required this.prompt,
    required this.estimatedMinutes,
  });

  final String fromTaskId;
  final String toTaskId;
  final String prompt;
  final double estimatedMinutes;

  factory AdjacencyEdge.fromJson(Map<String, dynamic> json) {
    return AdjacencyEdge(
      fromTaskId: json['fromTaskId'] as String,
      toTaskId: json['toTaskId'] as String,
      prompt: json['prompt'] as String,
      estimatedMinutes: (json['estimatedMinutes'] as num).toDouble(),
    );
  }
}
```

- [ ] **Step 12: Run all three tests to verify they pass**

Run: `flutter test test/simulation/models/`
Expected: PASS (3 tests)

- [ ] **Step 13: Commit**

```bash
git add lib/simulation/models/ test/simulation/models/
git commit -m "feat(m1): add task, room type, and adjacency edge models"
```

---

### Task 2: Entropy / need-level engine

**Files:**
- Create: `lib/simulation/entropy_engine.dart`
- Test: `test/simulation/entropy_engine_test.dart`

**Interfaces:**
- Consumes: nothing from earlier tasks (works on plain `double`/
  `DateTime` values).
- Produces: `enum NeedState { thriving, comfortable, slipping,
  struggling, critical }`; `class EntropyEngine` with methods
  `double needLevel({required double risePerHour, required DateTime
  lastCompletedAt, required DateTime now})`, `NeedState
  verbalState(double needLevel)`, and `double learnedRisePerHour({
  required double defaultRisePerHour, required List<DateTime>
  completionHistory})`. Task 7's content integration and any future
  milestone that renders room condition consume `NeedState` and
  `EntropyEngine` by these exact names.

- [ ] **Step 1: Write the failing tests**

```dart
// test/simulation/entropy_engine_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/simulation/entropy_engine.dart';

void main() {
  const engine = EntropyEngine();

  test('needLevel is zero right after completion', () {
    final now = DateTime(2026, 1, 8, 12);

    final level = engine.needLevel(
      risePerHour: 1 / 168,
      lastCompletedAt: now,
      now: now,
    );

    expect(level, 0.0);
  });

  test('needLevel rises linearly with elapsed time', () {
    final last = DateTime(2026, 1, 1, 12);
    final now = last.add(const Duration(hours: 84));

    final level = engine.needLevel(
      risePerHour: 1 / 168,
      lastCompletedAt: last,
      now: now,
    );

    expect(level, closeTo(0.5, 0.0001));
  });

  test('needLevel clamps at 1.0 however long it has been', () {
    final last = DateTime(2026, 1, 1);
    final now = last.add(const Duration(days: 30));

    final level = engine.needLevel(
      risePerHour: 1 / 168,
      lastCompletedAt: last,
      now: now,
    );

    expect(level, 1.0);
  });

  test('verbalState maps need level to the five coarse states', () {
    expect(engine.verbalState(0.0), NeedState.thriving);
    expect(engine.verbalState(0.3), NeedState.comfortable);
    expect(engine.verbalState(0.5), NeedState.slipping);
    expect(engine.verbalState(0.7), NeedState.struggling);
    expect(engine.verbalState(0.9), NeedState.critical);
  });

  test('learnedRisePerHour falls back to default with under 2 data points', () {
    final rate = engine.learnedRisePerHour(
      defaultRisePerHour: 1 / 168,
      completionHistory: [DateTime(2026, 1, 1)],
    );

    expect(rate, 1 / 168);
  });

  test('learnedRisePerHour recalibrates to the median actual interval', () {
    final history = [
      DateTime(2026, 1, 1),
      DateTime(2026, 1, 10), // 9 days later
      DateTime(2026, 1, 22), // 12 days later
      DateTime(2026, 2, 1), // 10 days later
    ];

    final rate = engine.learnedRisePerHour(
      defaultRisePerHour: 1 / 168,
      completionHistory: history,
    );

    // Median interval is 10 days = 240 hours: needLevel should reach
    // 1.0 right around the cadence the user actually follows, not the
    // 7-day default (spec §3.8: "stops suggesting every 7").
    expect(rate, closeTo(1 / 240, 0.00001));
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/simulation/entropy_engine_test.dart`
Expected: FAIL — file doesn't exist yet.

- [ ] **Step 3: Implement the entropy engine**

```dart
// lib/simulation/entropy_engine.dart
enum NeedState { thriving, comfortable, slipping, struggling, critical }

class EntropyEngine {
  const EntropyEngine();

  double needLevel({
    required double risePerHour,
    required DateTime lastCompletedAt,
    required DateTime now,
  }) {
    final hoursElapsed = now.difference(lastCompletedAt).inMinutes / 60.0;
    final raw = hoursElapsed * risePerHour;
    return raw.clamp(0.0, 1.0);
  }

  NeedState verbalState(double needLevel) {
    if (needLevel < 0.2) return NeedState.thriving;
    if (needLevel < 0.4) return NeedState.comfortable;
    if (needLevel < 0.6) return NeedState.slipping;
    if (needLevel < 0.8) return NeedState.struggling;
    return NeedState.critical;
  }

  double learnedRisePerHour({
    required double defaultRisePerHour,
    required List<DateTime> completionHistory,
  }) {
    if (completionHistory.length < 2) return defaultRisePerHour;

    final sorted = [...completionHistory]..sort();
    final intervalsHours = <double>[
      for (var i = 1; i < sorted.length; i++)
        sorted[i].difference(sorted[i - 1]).inMinutes / 60.0,
    ];

    final medianHours = _median(intervalsHours);
    if (medianHours <= 0) return defaultRisePerHour;
    return 1.0 / medianHours;
  }

  double _median(List<double> values) {
    final sorted = [...values]..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length.isOdd) return sorted[mid];
    return (sorted[mid - 1] + sorted[mid]) / 2.0;
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/simulation/entropy_engine_test.dart`
Expected: PASS (6 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/simulation/entropy_engine.dart test/simulation/entropy_engine_test.dart
git commit -m "feat(m1): add entropy/need-level engine with cadence learning"
```

---

### Task 3: Adaptive duration learning

**Files:**
- Create: `lib/simulation/duration_learner.dart`
- Test: `test/simulation/duration_learner_test.dart`

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: `class DurationLearner` with constructor `const
  DurationLearner({double alpha = 0.3})` and method `double
  updateEstimate({required double currentEstimateMinutes, required
  double actualMinutes})`. No later task in this plan consumes this
  directly, but it is the §5.2 item 13 building block M5's run UI will
  call after each completed task.

- [ ] **Step 1: Write the failing tests**

```dart
// test/simulation/duration_learner_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/simulation/duration_learner.dart';

void main() {
  test('nudges the estimate toward the actual duration', () {
    const learner = DurationLearner();

    final updated = learner.updateEstimate(
      currentEstimateMinutes: 15.0,
      actualMinutes: 7.0,
    );

    expect(updated, closeTo(12.6, 0.0001));
  });

  test('repeated identical actuals converge on that duration', () {
    const learner = DurationLearner();
    var estimate = 15.0;

    for (var i = 0; i < 50; i++) {
      estimate = learner.updateEstimate(
        currentEstimateMinutes: estimate,
        actualMinutes: 7.0,
      );
    }

    expect(estimate, closeTo(7.0, 0.01));
  });

  test('an exact match leaves the estimate unchanged', () {
    const learner = DurationLearner();

    final updated = learner.updateEstimate(
      currentEstimateMinutes: 10.0,
      actualMinutes: 10.0,
    );

    expect(updated, 10.0);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/simulation/duration_learner_test.dart`
Expected: FAIL — file doesn't exist yet.

- [ ] **Step 3: Implement the duration learner**

```dart
// lib/simulation/duration_learner.dart
class DurationLearner {
  const DurationLearner({this.alpha = 0.3});

  /// How much weight the most recent actual duration carries, in
  /// [0, 1]. Higher reacts faster to new data; lower is more stable.
  final double alpha;

  double updateEstimate({
    required double currentEstimateMinutes,
    required double actualMinutes,
  }) {
    return currentEstimateMinutes +
        alpha * (actualMinutes - currentEstimateMinutes);
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/simulation/duration_learner_test.dart`
Expected: PASS (3 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/simulation/duration_learner.dart test/simulation/duration_learner_test.dart
git commit -m "feat(m1): add adaptive duration learning"
```

---

### Task 4: Adjacency graph and combo engine

**Files:**
- Create: `lib/simulation/adjacency_graph.dart`
- Create: `lib/simulation/combo_engine.dart`
- Test: `test/simulation/adjacency_graph_test.dart`
- Test: `test/simulation/combo_engine_test.dart`

**Interfaces:**
- Consumes: `AdjacencyEdge` from Task 1
  (`package:micasa/simulation/models/adjacency_edge.dart`).
- Produces: `class AdjacencyGraph` with constructor
  `AdjacencyGraph(List<AdjacencyEdge> edges)` and method
  `List<AdjacencyEdge> edgesFrom(String taskId)`; `class ComboEngine`
  with constructor `const ComboEngine(this.graph)` (field
  `final AdjacencyGraph graph`) and method `AdjacencyEdge?
  suggestNext(String completedTaskId, {required Set<String>
  completedThisRun})`. Task 7's integration test and any future
  milestone driving the post-completion "one more thing" prompt (§3.5)
  consume `ComboEngine.suggestNext` by this exact name.

- [ ] **Step 1: Write the failing test for `AdjacencyGraph`**

```dart
// test/simulation/adjacency_graph_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/simulation/adjacency_graph.dart';
import 'package:micasa/simulation/models/adjacency_edge.dart';

void main() {
  test('edgesFrom returns only edges starting at the given task', () {
    final graph = AdjacencyGraph(const [
      AdjacencyEdge(
        fromTaskId: 'kitchen.dishes',
        toTaskId: 'kitchen.clear_counter',
        prompt: 'Clear the counter?',
        estimatedMinutes: 2.0,
      ),
      AdjacencyEdge(
        fromTaskId: 'kitchen.garbage',
        toTaskId: 'kitchen.new_bag',
        prompt: 'Put in a new bag?',
        estimatedMinutes: 1.0,
      ),
    ]);

    final edges = graph.edgesFrom('kitchen.dishes');

    expect(edges, hasLength(1));
    expect(edges.single.toTaskId, 'kitchen.clear_counter');
  });

  test('edgesFrom returns an empty list for a task with no outgoing edges', () {
    final graph = AdjacencyGraph(const []);

    expect(graph.edgesFrom('kitchen.new_bag'), isEmpty);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/simulation/adjacency_graph_test.dart`
Expected: FAIL — file doesn't exist yet.

- [ ] **Step 3: Implement `AdjacencyGraph`**

```dart
// lib/simulation/adjacency_graph.dart
import 'models/adjacency_edge.dart';

class AdjacencyGraph {
  AdjacencyGraph(List<AdjacencyEdge> edges) : _edges = List.unmodifiable(edges);

  final List<AdjacencyEdge> _edges;

  List<AdjacencyEdge> edgesFrom(String taskId) {
    return _edges.where((edge) => edge.fromTaskId == taskId).toList();
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/simulation/adjacency_graph_test.dart`
Expected: PASS (2 tests)

- [ ] **Step 5: Write the failing tests for `ComboEngine`**

```dart
// test/simulation/combo_engine_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/simulation/adjacency_graph.dart';
import 'package:micasa/simulation/combo_engine.dart';
import 'package:micasa/simulation/models/adjacency_edge.dart';

void main() {
  test('suggestNext returns the only outgoing edge', () {
    final graph = AdjacencyGraph(const [
      AdjacencyEdge(
        fromTaskId: 'kitchen.dishes',
        toTaskId: 'kitchen.clear_counter',
        prompt: 'Clear the counter?',
        estimatedMinutes: 2.0,
      ),
    ]);
    final engine = ComboEngine(graph);

    final suggestion = engine.suggestNext('kitchen.dishes', completedThisRun: {});

    expect(suggestion?.toTaskId, 'kitchen.clear_counter');
  });

  test('suggestNext skips tasks already completed this run', () {
    final graph = AdjacencyGraph(const [
      AdjacencyEdge(
        fromTaskId: 'kitchen.dishes',
        toTaskId: 'kitchen.clear_counter',
        prompt: 'Clear the counter?',
        estimatedMinutes: 2.0,
      ),
    ]);
    final engine = ComboEngine(graph);

    final suggestion = engine.suggestNext(
      'kitchen.dishes',
      completedThisRun: {'kitchen.clear_counter'},
    );

    expect(suggestion, isNull);
  });

  test('suggestNext picks the lowest-friction option among several edges', () {
    final graph = AdjacencyGraph(const [
      AdjacencyEdge(
        fromTaskId: 'kitchen.garbage',
        toTaskId: 'kitchen.wipe_counter',
        prompt: 'Wipe the counter too?',
        estimatedMinutes: 5.0,
      ),
      AdjacencyEdge(
        fromTaskId: 'kitchen.garbage',
        toTaskId: 'kitchen.new_bag',
        prompt: 'Put in a new bag?',
        estimatedMinutes: 1.0,
      ),
    ]);
    final engine = ComboEngine(graph);

    final suggestion = engine.suggestNext('kitchen.garbage', completedThisRun: {});

    expect(suggestion?.toTaskId, 'kitchen.new_bag');
  });

  test('suggestNext returns null when there are no outgoing edges', () {
    final graph = AdjacencyGraph(const []);
    final engine = ComboEngine(graph);

    expect(engine.suggestNext('kitchen.new_bag', completedThisRun: {}), isNull);
  });
}
```

- [ ] **Step 6: Run tests to verify they fail**

Run: `flutter test test/simulation/combo_engine_test.dart`
Expected: FAIL — file doesn't exist yet.

- [ ] **Step 7: Implement `ComboEngine`**

```dart
// lib/simulation/combo_engine.dart
import 'adjacency_graph.dart';
import 'models/adjacency_edge.dart';

class ComboEngine {
  const ComboEngine(this.graph);

  final AdjacencyGraph graph;

  /// The lowest-friction (lowest [AdjacencyEdge.estimatedMinutes])
  /// adjacent action following [completedTaskId], excluding any task
  /// already finished this run. Null if nothing adjacent is left.
  AdjacencyEdge? suggestNext(
    String completedTaskId, {
    required Set<String> completedThisRun,
  }) {
    final candidates = graph
        .edgesFrom(completedTaskId)
        .where((edge) => !completedThisRun.contains(edge.toTaskId))
        .toList();

    if (candidates.isEmpty) return null;

    return candidates.reduce(
      (a, b) => a.estimatedMinutes <= b.estimatedMinutes ? a : b,
    );
  }
}
```

- [ ] **Step 8: Run tests to verify they pass**

Run: `flutter test test/simulation/combo_engine_test.dart`
Expected: PASS (4 tests)

- [ ] **Step 9: Commit**

```bash
git add lib/simulation/adjacency_graph.dart lib/simulation/combo_engine.dart test/simulation/adjacency_graph_test.dart test/simulation/combo_engine_test.dart
git commit -m "feat(m1): add adjacency graph and combo engine"
```

---

### Task 5: Momentum counter

**Files:**
- Create: `lib/simulation/momentum_counter.dart`
- Test: `test/simulation/momentum_counter_test.dart`

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: `class MomentumCounter` with getter `int chainLength` and
  methods `void recordCompletion()`, `void reset()`. A later milestone
  (M6) constructs one fresh `MomentumCounter` per run — this class has
  no persistence and no cross-run state, by design (spec §3.4).

- [ ] **Step 1: Write the failing tests**

```dart
// test/simulation/momentum_counter_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/simulation/momentum_counter.dart';

void main() {
  test('starts at zero', () {
    final momentum = MomentumCounter();

    expect(momentum.chainLength, 0);
  });

  test('recordCompletion increments the chain', () {
    final momentum = MomentumCounter();

    momentum.recordCompletion();
    momentum.recordCompletion();
    momentum.recordCompletion();
    momentum.recordCompletion();

    expect(momentum.chainLength, 4);
  });

  test('reset clears the chain back to zero', () {
    final momentum = MomentumCounter();
    momentum.recordCompletion();
    momentum.recordCompletion();

    momentum.reset();

    expect(momentum.chainLength, 0);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/simulation/momentum_counter_test.dart`
Expected: FAIL — file doesn't exist yet.

- [ ] **Step 3: Implement `MomentumCounter`**

```dart
// lib/simulation/momentum_counter.dart
class MomentumCounter {
  int _chainLength = 0;

  int get chainLength => _chainLength;

  void recordCompletion() {
    _chainLength += 1;
  }

  void reset() {
    _chainLength = 0;
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/simulation/momentum_counter_test.dart`
Expected: PASS (3 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/simulation/momentum_counter.dart test/simulation/momentum_counter_test.dart
git commit -m "feat(m1): add in-session momentum counter"
```

---

### Task 6: Content loader (parsing)

**Files:**
- Create: `lib/simulation/content_loader.dart`
- Test: `test/simulation/content_loader_test.dart`

**Interfaces:**
- Consumes: `TaskDefinition`, `RoomTypeDefinition`, `AdjacencyEdge` from
  Task 1.
- Produces: `class ContentLoader` with pure methods
  `List<RoomTypeDefinition> parseRoomTypes(String jsonSource)`,
  `List<TaskDefinition> parseTasks(String jsonSource)`,
  `List<AdjacencyEdge> parseAdjacencyEdges(String jsonSource)`, and
  async I/O wrappers `Future<List<RoomTypeDefinition>> loadRoomTypes()`,
  `Future<List<TaskDefinition>> loadTasks()`,
  `Future<List<AdjacencyEdge>> loadAdjacencyEdges()` that read from
  `content/rooms/room_types.json`, `content/tasks/tasks.json`, and
  `content/adjacency/edges.json` respectively via `rootBundle`. Task 7
  exercises the `load*` methods against the real content files.

- [ ] **Step 1: Write the failing tests for the pure parse methods**

```dart
// test/simulation/content_loader_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/simulation/content_loader.dart';

void main() {
  const loader = ContentLoader();

  test('parseRoomTypes parses a JSON array of room types', () {
    const source = '''
    [
      {"id": "kitchen", "name": "Kitchen", "taskIds": ["kitchen.dishes"]}
    ]
    ''';

    final result = loader.parseRoomTypes(source);

    expect(result, hasLength(1));
    expect(result.first.id, 'kitchen');
    expect(result.first.name, 'Kitchen');
    expect(result.first.taskIds, ['kitchen.dishes']);
  });

  test('parseTasks parses a JSON array of tasks', () {
    const source = '''
    [
      {
        "id": "kitchen.dishes",
        "roomTypeId": "kitchen",
        "label": "Put the dishes away",
        "baseDurationMinutes": 2.0,
        "defaultRisePerHour": 0.005952
      }
    ]
    ''';

    final result = loader.parseTasks(source);

    expect(result, hasLength(1));
    expect(result.first.id, 'kitchen.dishes');
    expect(result.first.label, 'Put the dishes away');
  });

  test('parseAdjacencyEdges parses a JSON array of edges', () {
    const source = '''
    [
      {
        "fromTaskId": "kitchen.dishes",
        "toTaskId": "kitchen.clear_counter",
        "prompt": "Clear the counter?",
        "estimatedMinutes": 2.0
      }
    ]
    ''';

    final result = loader.parseAdjacencyEdges(source);

    expect(result, hasLength(1));
    expect(result.first.fromTaskId, 'kitchen.dishes');
    expect(result.first.toTaskId, 'kitchen.clear_counter');
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/simulation/content_loader_test.dart`
Expected: FAIL — file doesn't exist yet.

- [ ] **Step 3: Implement `ContentLoader`**

```dart
// lib/simulation/content_loader.dart
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'models/adjacency_edge.dart';
import 'models/room_type_definition.dart';
import 'models/task_definition.dart';

class ContentLoader {
  const ContentLoader();

  List<RoomTypeDefinition> parseRoomTypes(String jsonSource) {
    final list = jsonDecode(jsonSource) as List<dynamic>;
    return list
        .map((e) => RoomTypeDefinition.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<TaskDefinition> parseTasks(String jsonSource) {
    final list = jsonDecode(jsonSource) as List<dynamic>;
    return list
        .map((e) => TaskDefinition.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<AdjacencyEdge> parseAdjacencyEdges(String jsonSource) {
    final list = jsonDecode(jsonSource) as List<dynamic>;
    return list
        .map((e) => AdjacencyEdge.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RoomTypeDefinition>> loadRoomTypes() async {
    final source = await rootBundle.loadString('content/rooms/room_types.json');
    return parseRoomTypes(source);
  }

  Future<List<TaskDefinition>> loadTasks() async {
    final source = await rootBundle.loadString('content/tasks/tasks.json');
    return parseTasks(source);
  }

  Future<List<AdjacencyEdge>> loadAdjacencyEdges() async {
    final source = await rootBundle.loadString('content/adjacency/edges.json');
    return parseAdjacencyEdges(source);
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/simulation/content_loader_test.dart`
Expected: PASS (3 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/simulation/content_loader.dart test/simulation/content_loader_test.dart
git commit -m "feat(m1): add content loader with pure JSON parsing"
```

---

### Task 7: Kitchen content data and end-to-end content integration

**Files:**
- Create: `content/rooms/room_types.json`
- Create: `content/tasks/tasks.json`
- Create: `content/adjacency/edges.json`
- Modify: `pubspec.yaml` (register the three new content files as
  assets)
- Test: `test/simulation/content_loader_integration_test.dart`

**Interfaces:**
- Consumes: `ContentLoader` (Task 6).
- Produces: the real Phase 0 kitchen content — five tasks
  (`kitchen.dishes`, `kitchen.clear_counter`, `kitchen.wipe_counter`,
  `kitchen.garbage`, `kitchen.new_bag`) and the four-edge combo chain
  spec §3.4 gives as its own example (dishes → clear counter → wipe
  counter → garbage → new bag). Later milestones (M5, M6) load this
  content by these exact IDs.

- [ ] **Step 1: Write the content data files**

```json
// content/rooms/room_types.json
[
  {
    "id": "kitchen",
    "name": "Kitchen",
    "taskIds": [
      "kitchen.dishes",
      "kitchen.clear_counter",
      "kitchen.wipe_counter",
      "kitchen.garbage",
      "kitchen.new_bag"
    ]
  }
]
```

```json
// content/tasks/tasks.json
[
  {
    "id": "kitchen.dishes",
    "roomTypeId": "kitchen",
    "label": "Put the dishes away",
    "baseDurationMinutes": 2.0,
    "defaultRisePerHour": 0.005952
  },
  {
    "id": "kitchen.clear_counter",
    "roomTypeId": "kitchen",
    "label": "Clear the counter",
    "baseDurationMinutes": 2.0,
    "defaultRisePerHour": 0.020833
  },
  {
    "id": "kitchen.wipe_counter",
    "roomTypeId": "kitchen",
    "label": "Wipe the counter",
    "baseDurationMinutes": 2.0,
    "defaultRisePerHour": 0.041667
  },
  {
    "id": "kitchen.garbage",
    "roomTypeId": "kitchen",
    "label": "Take out the garbage",
    "baseDurationMinutes": 3.0,
    "defaultRisePerHour": 0.013889
  },
  {
    "id": "kitchen.new_bag",
    "roomTypeId": "kitchen",
    "label": "Put in a new bag",
    "baseDurationMinutes": 1.0,
    "defaultRisePerHour": 0.013889
  }
]
```

```json
// content/adjacency/edges.json
[
  {
    "fromTaskId": "kitchen.dishes",
    "toTaskId": "kitchen.clear_counter",
    "prompt": "Clear the counter?",
    "estimatedMinutes": 2.0
  },
  {
    "fromTaskId": "kitchen.clear_counter",
    "toTaskId": "kitchen.wipe_counter",
    "prompt": "Wipe it?",
    "estimatedMinutes": 2.0
  },
  {
    "fromTaskId": "kitchen.wipe_counter",
    "toTaskId": "kitchen.garbage",
    "prompt": "Take out the garbage?",
    "estimatedMinutes": 3.0
  },
  {
    "fromTaskId": "kitchen.garbage",
    "toTaskId": "kitchen.new_bag",
    "prompt": "Put in a new bag?",
    "estimatedMinutes": 1.0
  }
]
```

- [ ] **Step 2: Register the content files in `pubspec.yaml`**

In the existing `flutter: assets:` list (`pubspec.yaml`, alongside the
`content/art/...` entries already there), add:

```yaml
    - content/rooms/room_types.json
    - content/tasks/tasks.json
    - content/adjacency/edges.json
```

- [ ] **Step 3: Write the failing integration test**

```dart
// test/simulation/content_loader_integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/simulation/content_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const loader = ContentLoader();

  test('loads the real kitchen room type from content/', () async {
    final roomTypes = await loader.loadRoomTypes();

    expect(roomTypes.any((r) => r.id == 'kitchen'), isTrue);
  });

  test('loads the real kitchen tasks from content/', () async {
    final tasks = await loader.loadTasks();

    expect(tasks.map((t) => t.id), containsAll(<String>[
      'kitchen.dishes',
      'kitchen.clear_counter',
      'kitchen.wipe_counter',
      'kitchen.garbage',
      'kitchen.new_bag',
    ]));
  });

  test('loads the real kitchen adjacency chain from content/', () async {
    final edges = await loader.loadAdjacencyEdges();

    expect(
      edges.any((e) =>
          e.fromTaskId == 'kitchen.dishes' &&
          e.toTaskId == 'kitchen.clear_counter'),
      isTrue,
    );
    expect(
      edges.any((e) =>
          e.fromTaskId == 'kitchen.garbage' &&
          e.toTaskId == 'kitchen.new_bag'),
      isTrue,
    );
  });

  test('every adjacency edge references tasks that actually exist', () async {
    final tasks = await loader.loadTasks();
    final edges = await loader.loadAdjacencyEdges();
    final taskIds = tasks.map((t) => t.id).toSet();

    for (final edge in edges) {
      expect(
        taskIds.contains(edge.fromTaskId),
        isTrue,
        reason: '${edge.fromTaskId} missing from tasks.json',
      );
      expect(
        taskIds.contains(edge.toTaskId),
        isTrue,
        reason: '${edge.toTaskId} missing from tasks.json',
      );
    }
  });

  test('every task belongs to a room type that lists it', () async {
    final tasks = await loader.loadTasks();
    final roomTypes = await loader.loadRoomTypes();
    final roomTaskIds = {
      for (final r in roomTypes) r.id: r.taskIds.toSet(),
    };

    for (final task in tasks) {
      final taskIds = roomTaskIds[task.roomTypeId];
      expect(
        taskIds, isNotNull,
        reason: '${task.roomTypeId} has no room_types.json entry',
      );
      expect(
        taskIds!.contains(task.id), isTrue,
        reason: '${task.id} missing from its room type\'s taskIds',
      );
    }
  });
}
```

- [ ] **Step 4: Run test to verify it fails**

Run: `flutter test test/simulation/content_loader_integration_test.dart`
Expected: FAIL — content files don't exist yet (`Unable to load asset`).

Note: if Step 1–2 were completed first, this step instead verifies
PASS immediately; run the test *before* creating the JSON files if you
want to see the genuine failure, or treat Steps 1–2 as part of this
same red state — either ordering is fine as long as you observe one
failing run before the content files exist.

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/simulation/content_loader_integration_test.dart`
Expected: PASS (5 tests)

- [ ] **Step 6: Commit**

```bash
git add content/rooms/room_types.json content/tasks/tasks.json content/adjacency/edges.json pubspec.yaml test/simulation/content_loader_integration_test.dart
git commit -m "feat(m1): add kitchen content data and content integration test"
```

---

### Task 8: Full suite, architectural boundary check, and final commit

**Files:** none created; verification only.

- [ ] **Step 1: Run the full automated test suite**

Run: `flutter test`
Expected: PASS, all tests from Tasks 1–7 green in addition to the
existing M0 suite (M1 adds 3 + 6 + 3 + 6 + 3 + 3 + 5 = 29 tests).

- [ ] **Step 2: Run static analysis**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Verify the architectural boundary**

Run: `grep -r "presentation" lib/simulation/`
Expected: no output — `lib/simulation/` must not reference
`lib/presentation/` anywhere (CLAUDE.md architectural rule).

- [ ] **Step 4: Spot-check the learned-cadence behavior against the spec's own example**

This is a manual sanity read, not a new test: open
`lib/simulation/entropy_engine.dart` and confirm
`learnedRisePerHour` recalibrates toward the user's actual median
interval rather than the seeded default — this is the concrete
mechanism behind spec §3.8's "if the user actually vacuums every 9–12
days, it stops suggesting every 7." Task 2's test suite already asserts
this numerically; this step is just tracing the code path once by eye
before moving on, since it is the piece of this milestone with the most
subtle behavior.

- [ ] **Step 5: Final commit**

If Steps 1–4 required any fixes, commit them:

```bash
git add -A
git commit -m "fix(m1): address issues found in final verification pass"
```

If no changes were needed, this step is a no-op — the milestone is
already fully committed from Tasks 1–7.

---

## Self-review notes

- **Spec coverage:** §3.8 (entropy + cadence learning) → Task 2. §5.2
  item 13 (adaptive duration) → Task 3. §3.5 (combo/adjacency,
  "highest design priority") → Task 4. §3.4 (in-session momentum) →
  Task 5. §5.3 content-driven requirement → Tasks 6–7. §2.2's five
  verbal states → the `NeedState` enum in Task 2. Persistence (Drift)
  and wiring into the M0 UI are explicitly **not** in this milestone —
  those are M2 and M6 respectively, per the roadmap doc.
- **Deviation flagged:** none. Every §5.2/§3.x item the roadmap doc
  assigns to M1 has a task; nothing from M2+ scope was pulled forward.
- **Placeholder scan:** no TBD/TODO markers; every step has concrete,
  runnable code and real content data.
- **Type consistency:** `TaskDefinition`, `RoomTypeDefinition`, and
  `AdjacencyEdge` (Task 1) are consumed by identical names/fields in
  Tasks 4, 6, and 7. `ComboEngine.suggestNext`'s signature is identical
  everywhere it's referenced. `NeedState`'s five values match spec
  §2.2's exact vocabulary and are used consistently across Task 2's
  tests.
