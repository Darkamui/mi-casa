# M0 — Wow Prototype Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. This project's owner has requested **inline execution** (superpowers:executing-plans), not subagent-driven-development, to avoid repeated full-context reads.

**Goal:** Build the spec's §5.1 "wow prototype" — one hardcoded kitchen
scene proving the core emotional beat (messy → tap creature → PLAY →
DONE → transformation) — as the first real screen in the app, before any
simulation engine, persistence, or content pipeline exists.

**Architecture:** A single `KitchenScene` widget assembled from small,
independently testable pieces (background painter, dish-pile painter,
companion widget, quest card, task prompt, particle burst), driven by one
Riverpod `Notifier<RunPhase>` that models the five-phase flow
(`idle → questOffered → running → celebrating → restored`). Everything
is procedural (`CustomPainter` shapes, no image assets) per the project
owner's explicit choice, since no illustration pipeline exists yet. No
`lib/simulation/`, no Drift, no `go_router` in this milestone — those
land in M1–M3.

**Tech Stack:** Flutter, `flutter_riverpod` (already a dependency),
`package:flutter/services.dart` for `HapticFeedback`/`SystemSound`. No
new dependencies.

**Spec:** `docs/micasa_spec.md` §5.1 (this milestone), §3.2–3.3 (quest
card / run-mode copy and control placement), §2.2 (no percentages),
§4.5 (text minimalism). Design doc:
`docs/superpowers/specs/2026-08-24-phase-0-roadmap-design.md` §2.2 M0.

## Global Constraints

- Framework is Flutter/Dart; no Flame in Phase 0 (spec §5.3) — this
  milestone uses `CustomPainter` exclusively for the world visuals.
- State management is Riverpod, kept separate from any future
  `lib/simulation/` game-state store (spec §5.3, CLAUDE.md architectural
  rule) — this milestone's `RunPhase` is presentation-layer UI state,
  not the real run/entropy system that M1 builds.
- `lib/simulation/` must never be imported from `lib/presentation/` and
  vice versa is fine, but this milestone does not touch
  `lib/simulation/` at all — verify no file created here lands outside
  `lib/presentation/`.
- Feedback never waits on I/O (spec §5.3, §3.3): on `DONE`, local state
  updates first, then haptic/sound/particles fire immediately — no
  network, no disk I/O exists in this milestone to violate this, but the
  ordering must still be local-state-then-effects.
- No percentages anywhere in UI copy or visuals (spec §2.2).
- All visuals are procedural placeholders (project owner decision, this
  session) — no image assets, no `assets/` entries, no `pubspec.yaml`
  asset declarations.
- Text stays minimal — reuse the spec's own copy verbatim where it gives
  exact strings: `"Put the dishes away"` (§5.1 step 3), `"Kitchen
  Rescue — 2 min"` styled after §3.2's quest-card format, `"KITCHEN
  RESTORED"` (§5.1 step 6, spec's own capitalization for the resolution
  beat per §4.1's `ROOM RESTORED` pattern).

---

### Task 1: Kitchen scene phase controller

**Files:**
- Create: `lib/presentation/scenes/kitchen_scene_controller.dart`
- Test: `test/presentation/scenes/kitchen_scene_controller_test.dart`

**Interfaces:**
- Produces: `enum RunPhase { idle, questOffered, running, celebrating, restored }`;
  `class KitchenSceneController extends Notifier<RunPhase>` with methods
  `tapCompanion()`, `startRun()`, `completeTask()`, `finishCelebration()`
  (each a no-op unless called from the correct preceding phase);
  `final kitchenSceneProvider = NotifierProvider<KitchenSceneController, RunPhase>(KitchenSceneController.new)`.
  Later tasks in this plan consume `kitchenSceneProvider` to read the
  current phase and call these four methods.

- [ ] **Step 1: Write the failing test**

```dart
// test/presentation/scenes/kitchen_scene_controller_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/scenes/kitchen_scene_controller.dart';

void main() {
  test('starts idle', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(kitchenSceneProvider), RunPhase.idle);
  });

  test('tapCompanion moves idle -> questOffered', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(kitchenSceneProvider.notifier).tapCompanion();

    expect(container.read(kitchenSceneProvider), RunPhase.questOffered);
  });

  test('startRun is ignored unless questOffered', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(kitchenSceneProvider.notifier).startRun();

    expect(container.read(kitchenSceneProvider), RunPhase.idle);
  });

  test('completeTask is ignored unless running', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(kitchenSceneProvider.notifier).completeTask();

    expect(container.read(kitchenSceneProvider), RunPhase.idle);
  });

  test('full happy path idle -> restored', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(kitchenSceneProvider.notifier);

    notifier.tapCompanion();
    notifier.startRun();
    notifier.completeTask();
    notifier.finishCelebration();

    expect(container.read(kitchenSceneProvider), RunPhase.restored);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/presentation/scenes/kitchen_scene_controller_test.dart`
Expected: FAIL — `kitchen_scene_controller.dart` does not exist yet
(import error).

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/presentation/scenes/kitchen_scene_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RunPhase { idle, questOffered, running, celebrating, restored }

class KitchenSceneController extends Notifier<RunPhase> {
  @override
  RunPhase build() => RunPhase.idle;

  void tapCompanion() {
    if (state != RunPhase.idle) return;
    state = RunPhase.questOffered;
  }

  void startRun() {
    if (state != RunPhase.questOffered) return;
    state = RunPhase.running;
  }

  void completeTask() {
    if (state != RunPhase.running) return;
    state = RunPhase.celebrating;
  }

  void finishCelebration() {
    if (state != RunPhase.celebrating) return;
    state = RunPhase.restored;
  }
}

final kitchenSceneProvider =
    NotifierProvider<KitchenSceneController, RunPhase>(
  KitchenSceneController.new,
);
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/presentation/scenes/kitchen_scene_controller_test.dart`
Expected: PASS (5 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/scenes/kitchen_scene_controller.dart test/presentation/scenes/kitchen_scene_controller_test.dart
git commit -m "feat(m0): add kitchen scene phase controller"
```

---

### Task 2: Background and dish-pile painters

**Files:**
- Create: `lib/presentation/scenes/kitchen_background_painter.dart`
- Create: `lib/presentation/scenes/dish_pile_painter.dart`
- Test: `test/presentation/scenes/kitchen_background_painter_test.dart`
- Test: `test/presentation/scenes/dish_pile_painter_test.dart`

**Interfaces:**
- Consumes: nothing from Task 1.
- Produces: `class KitchenBackgroundPainter extends CustomPainter` with
  constructor `KitchenBackgroundPainter({required bool restored})`;
  `class DishPilePainter extends CustomPainter` with a no-arg const
  constructor and a public `static const List<Offset> dishOffsets`
  (length 4). Task 6 consumes both painters directly.

- [ ] **Step 1: Write the failing tests**

```dart
// test/presentation/scenes/kitchen_background_painter_test.dart
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/scenes/kitchen_background_painter.dart';

void main() {
  test('shouldRepaint is true when restored flag changes', () {
    const messy = KitchenBackgroundPainter(restored: false);
    const clean = KitchenBackgroundPainter(restored: true);

    expect(messy.shouldRepaint(clean), isTrue);
  });

  test('shouldRepaint is false when restored flag is unchanged', () {
    const messyA = KitchenBackgroundPainter(restored: false);
    const messyB = KitchenBackgroundPainter(restored: false);

    expect(messyA.shouldRepaint(messyB), isFalse);
  });

  test('paint does not throw for either state', () {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    const KitchenBackgroundPainter(restored: false)
        .paint(canvas, const Size(300, 500));
    const KitchenBackgroundPainter(restored: true)
        .paint(canvas, const Size(300, 500));

    recorder.endRecording();
  });
}
```

```dart
// test/presentation/scenes/dish_pile_painter_test.dart
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/scenes/dish_pile_painter.dart';

void main() {
  test('has four dish offsets', () {
    expect(DishPilePainter.dishOffsets.length, 4);
  });

  test('shouldRepaint is always false (static content)', () {
    const a = DishPilePainter();
    const b = DishPilePainter();

    expect(a.shouldRepaint(b), isFalse);
  });

  test('paint does not throw', () {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    const DishPilePainter().paint(canvas, const Size(120, 80));

    recorder.endRecording();
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/presentation/scenes/kitchen_background_painter_test.dart test/presentation/scenes/dish_pile_painter_test.dart`
Expected: FAIL — files don't exist yet.

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/presentation/scenes/kitchen_background_painter.dart
import 'package:flutter/rendering.dart';

class KitchenBackgroundPainter extends CustomPainter {
  final bool restored;
  const KitchenBackgroundPainter({required this.restored});

  @override
  void paint(Canvas canvas, Size size) {
    final wallColor =
        restored ? const Color(0xFFF3E1C4) : const Color(0xFF8A8F98);
    final floorColor =
        restored ? const Color(0xFFB98356) : const Color(0xFF6B6B6B);
    final counterColor =
        restored ? const Color(0xFFDCC7A0) : const Color(0xFF4E4E4E);
    final sinkColor =
        restored ? const Color(0xFFEFEFEF) : const Color(0xFF3A3A3A);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.7),
      Paint()..color = wallColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.7, size.width, size.height * 0.3),
      Paint()..color = floorColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.55,
          size.width * 0.35, size.height * 0.15),
      Paint()..color = counterColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(
          size.width * 0.15, size.height * 0.5, size.width * 0.2, size.height * 0.1),
      Paint()..color = sinkColor,
    );
  }

  @override
  bool shouldRepaint(covariant KitchenBackgroundPainter oldDelegate) =>
      oldDelegate.restored != restored;
}
```

```dart
// lib/presentation/scenes/dish_pile_painter.dart
import 'package:flutter/rendering.dart';

class DishPilePainter extends CustomPainter {
  const DishPilePainter();

  static const List<Offset> dishOffsets = [
    Offset(0.0, 0.0),
    Offset(0.4, -0.1),
    Offset(0.2, 0.15),
    Offset(-0.3, 0.05),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFDCD3C3);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.35;

    for (final offset in dishOffsets) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center +
              Offset(offset.dx * size.width * 0.3, offset.dy * size.height * 0.3),
          width: radius,
          height: radius * 0.5,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DishPilePainter oldDelegate) => false;
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/presentation/scenes/kitchen_background_painter_test.dart test/presentation/scenes/dish_pile_painter_test.dart`
Expected: PASS (6 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/scenes/kitchen_background_painter.dart lib/presentation/scenes/dish_pile_painter.dart test/presentation/scenes/kitchen_background_painter_test.dart test/presentation/scenes/dish_pile_painter_test.dart
git commit -m "feat(m0): add procedural kitchen background and dish-pile painters"
```

---

### Task 3: Companion widget

**Files:**
- Create: `lib/presentation/widgets/companion_widget.dart`
- Test: `test/presentation/widgets/companion_widget_test.dart`

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: `enum CompanionMood { idle, celebrating }`;
  `class CompanionWidget extends StatefulWidget` with constructor
  `CompanionWidget({required CompanionMood mood, required VoidCallback onTap})`;
  tap target carries `key: const ValueKey('companionTap')`. Task 6
  consumes this widget and its `onTap` callback.

- [ ] **Step 1: Write the failing test**

```dart
// test/presentation/widgets/companion_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/widgets/companion_widget.dart';

void main() {
  testWidgets('tapping the companion invokes onTap', (tester) async {
    var tapped = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CompanionWidget(
          mood: CompanionMood.idle,
          onTap: () => tapped = true,
        ),
      ),
    ));

    await tester.tap(find.byKey(const ValueKey('companionTap')));

    expect(tapped, isTrue);
  });

  testWidgets('builds without error in celebrating mood', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CompanionWidget(
          mood: CompanionMood.celebrating,
          onTap: () {},
        ),
      ),
    ));

    expect(find.byKey(const ValueKey('companionTap')), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/presentation/widgets/companion_widget_test.dart`
Expected: FAIL — file doesn't exist yet.

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/presentation/widgets/companion_widget.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

enum CompanionMood { idle, celebrating }

class CompanionWidget extends StatefulWidget {
  final CompanionMood mood;
  final VoidCallback onTap;

  const CompanionWidget({super.key, required this.mood, required this.onTap});

  @override
  State<CompanionWidget> createState() => _CompanionWidgetState();
}

class _CompanionWidgetState extends State<CompanionWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const ValueKey('companionTap'),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _bounceController,
        builder: (context, child) {
          final bounce = widget.mood == CompanionMood.celebrating
              ? 0.0
              : math.sin(_bounceController.value * math.pi) * 6;
          return Transform.translate(offset: Offset(0, -bounce), child: child);
        },
        child: CustomPaint(
          size: const Size(64, 64),
          painter:
              CompanionPainter(celebrating: widget.mood == CompanionMood.celebrating),
        ),
      ),
    );
  }
}

class CompanionPainter extends CustomPainter {
  final bool celebrating;
  const CompanionPainter({required this.celebrating});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = const Color(0xFFE8A33D);
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.shortestSide / 2, bodyPaint);

    final eyePaint = Paint()..color = Colors.black;
    final eyeOffset = size.shortestSide * 0.15;
    final eyeRadius = celebrating ? size.shortestSide * 0.05 : size.shortestSide * 0.04;
    canvas.drawCircle(center + Offset(-eyeOffset, -eyeOffset * 0.3), eyeRadius, eyePaint);
    canvas.drawCircle(center + Offset(eyeOffset, -eyeOffset * 0.3), eyeRadius, eyePaint);

    if (celebrating) {
      final armPaint = Paint()
        ..color = const Color(0xFFE8A33D)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke;
      canvas.drawLine(center + Offset(-eyeOffset * 2, 0),
          center + Offset(-eyeOffset * 3, -eyeOffset * 2), armPaint);
      canvas.drawLine(center + Offset(eyeOffset * 2, 0),
          center + Offset(eyeOffset * 3, -eyeOffset * 2), armPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CompanionPainter oldDelegate) =>
      oldDelegate.celebrating != celebrating;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/presentation/widgets/companion_widget_test.dart`
Expected: PASS (2 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/widgets/companion_widget.dart test/presentation/widgets/companion_widget_test.dart
git commit -m "feat(m0): add procedural companion widget"
```

---

### Task 4: Quest card and single-task prompt

**Files:**
- Create: `lib/presentation/widgets/quest_card.dart`
- Create: `lib/presentation/widgets/single_task_prompt.dart`
- Test: `test/presentation/widgets/quest_card_test.dart`
- Test: `test/presentation/widgets/single_task_prompt_test.dart`

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: `class QuestCard extends StatelessWidget` with constructor
  `QuestCard({required VoidCallback onPlay})`, rendering a button
  labelled `'PLAY'`; `class SingleTaskPrompt extends StatelessWidget`
  with constructor `SingleTaskPrompt({required VoidCallback onDone})`,
  rendering the text `'Put the dishes away'` and a button labelled
  `'DONE'`. Task 6 consumes both, wiring `onPlay` to
  `KitchenSceneController.startRun` and `onDone` to
  `KitchenSceneController.completeTask`.

- [ ] **Step 1: Write the failing tests**

```dart
// test/presentation/widgets/quest_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/widgets/quest_card.dart';

void main() {
  testWidgets('tapping PLAY invokes onPlay', (tester) async {
    var played = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: QuestCard(onPlay: () => played = true)),
    ));

    await tester.tap(find.text('PLAY'));

    expect(played, isTrue);
  });
}
```

```dart
// test/presentation/widgets/single_task_prompt_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/widgets/single_task_prompt.dart';

void main() {
  testWidgets('shows the task copy and invokes onDone', (tester) async {
    var done = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SingleTaskPrompt(onDone: () => done = true)),
    ));

    expect(find.text('Put the dishes away'), findsOneWidget);

    await tester.tap(find.text('DONE'));

    expect(done, isTrue);
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/presentation/widgets/quest_card_test.dart test/presentation/widgets/single_task_prompt_test.dart`
Expected: FAIL — files don't exist yet.

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/presentation/widgets/quest_card.dart
import 'package:flutter/material.dart';

class QuestCard extends StatelessWidget {
  final VoidCallback onPlay;
  const QuestCard({super.key, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2B2B33),
      margin: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Kitchen Rescue — 2 min',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onPlay, child: const Text('PLAY')),
          ],
        ),
      ),
    );
  }
}
```

```dart
// lib/presentation/widgets/single_task_prompt.dart
import 'package:flutter/material.dart';

class SingleTaskPrompt extends StatelessWidget {
  final VoidCallback onDone;
  const SingleTaskPrompt({super.key, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Put the dishes away',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(minimumSize: const Size(160, 56)),
              child: const Text('DONE'),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/presentation/widgets/quest_card_test.dart test/presentation/widgets/single_task_prompt_test.dart`
Expected: PASS (2 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/widgets/quest_card.dart lib/presentation/widgets/single_task_prompt.dart test/presentation/widgets/quest_card_test.dart test/presentation/widgets/single_task_prompt_test.dart
git commit -m "feat(m0): add quest card and single-task prompt widgets"
```

---

### Task 5: Particle burst effect

**Files:**
- Create: `lib/presentation/effects/particle_burst.dart`
- Test: `test/presentation/effects/particle_burst_test.dart`

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: `class Particle` (fields `direction`, `speed`, `color`);
  `List<Particle> generateBurstParticles({int count = 24, required int seed})`
  (deterministic for a fixed seed); `class ParticleBurst extends StatefulWidget`
  with constructor `ParticleBurst({required bool active})`. Task 6
  consumes `ParticleBurst`, toggling `active` when the phase becomes
  `RunPhase.celebrating`.

- [ ] **Step 1: Write the failing test**

```dart
// test/presentation/effects/particle_burst_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/effects/particle_burst.dart';

void main() {
  test('generates the requested particle count', () {
    final particles = generateBurstParticles(count: 10, seed: 1);

    expect(particles.length, 10);
  });

  test('is deterministic for a fixed seed', () {
    final a = generateBurstParticles(count: 5, seed: 42);
    final b = generateBurstParticles(count: 5, seed: 42);

    for (var i = 0; i < a.length; i++) {
      expect(a[i].direction, b[i].direction);
      expect(a[i].speed, b[i].speed);
      expect(a[i].color, b[i].color);
    }
  });

  testWidgets('builds without error when inactive and active', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: ParticleBurst(active: false)),
    ));
    expect(find.byType(ParticleBurst), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: ParticleBurst(active: true)),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(ParticleBurst), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/presentation/effects/particle_burst_test.dart`
Expected: FAIL — file doesn't exist yet.

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/presentation/effects/particle_burst.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

class Particle {
  final Offset direction;
  final double speed;
  final Color color;
  const Particle({required this.direction, required this.speed, required this.color});
}

List<Particle> generateBurstParticles({int count = 24, required int seed}) {
  final random = math.Random(seed);
  const colors = [Color(0xFFFFD27D), Color(0xFFFFF3C4), Color(0xFFFFB870)];

  return List.generate(count, (i) {
    final angle = random.nextDouble() * 2 * math.pi;
    return Particle(
      direction: Offset(math.cos(angle), math.sin(angle)),
      speed: 40 + random.nextDouble() * 60,
      color: colors[random.nextInt(colors.length)],
    );
  });
}

class ParticleBurst extends StatefulWidget {
  final bool active;
  const ParticleBurst({super.key, required this.active});

  @override
  State<ParticleBurst> createState() => _ParticleBurstState();
}

class _ParticleBurstState extends State<ParticleBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  List<Particle> _particles = const [];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    if (widget.active) _fire();
  }

  @override
  void didUpdateWidget(covariant ParticleBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) _fire();
  }

  void _fire() {
    _particles = generateBurstParticles(seed: DateTime.now().millisecondsSinceEpoch);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: ParticlePainter(particles: _particles, progress: _controller.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  const ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (final particle in particles) {
      final distance = particle.speed * progress;
      final position = center + particle.direction * distance;
      final opacity = (1 - progress).clamp(0.0, 1.0);
      canvas.drawCircle(position, 4, Paint()..color = particle.color.withValues(alpha: opacity));
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/presentation/effects/particle_burst_test.dart`
Expected: PASS (3 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/effects/particle_burst.dart test/presentation/effects/particle_burst_test.dart
git commit -m "feat(m0): add procedural particle burst effect"
```

---

### Task 6: Assemble KitchenScene

**Files:**
- Create: `lib/presentation/scenes/kitchen_scene.dart`
- Test: `test/presentation/scenes/kitchen_scene_test.dart`

**Interfaces:**
- Consumes: `kitchenSceneProvider`, `RunPhase` (Task 1);
  `KitchenBackgroundPainter`, `DishPilePainter` (Task 2);
  `CompanionWidget`, `CompanionMood` (Task 3); `QuestCard`,
  `SingleTaskPrompt` (Task 4); `ParticleBurst` (Task 5).
- Produces: `class KitchenScene extends ConsumerWidget` — the full M0
  screen. Task 7 consumes this as the app's `home`.

- [ ] **Step 1: Write the failing test**

```dart
// test/presentation/scenes/kitchen_scene_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/scenes/kitchen_scene.dart';

void main() {
  testWidgets('full M0 flow: tap companion -> PLAY -> DONE -> restored',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: KitchenScene())),
    );

    expect(find.text('KITCHEN RESTORED'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('companionTap')));
    await tester.pump();
    expect(find.text('PLAY'), findsOneWidget);

    await tester.tap(find.text('PLAY'));
    await tester.pump();
    expect(find.text('Put the dishes away'), findsOneWidget);

    await tester.tap(find.text('DONE'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('KITCHEN RESTORED'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/presentation/scenes/kitchen_scene_test.dart`
Expected: FAIL — file doesn't exist yet.

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/presentation/scenes/kitchen_scene.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../effects/particle_burst.dart';
import '../widgets/companion_widget.dart';
import '../widgets/quest_card.dart';
import '../widgets/single_task_prompt.dart';
import 'dish_pile_painter.dart';
import 'kitchen_background_painter.dart';
import 'kitchen_scene_controller.dart';

class KitchenScene extends ConsumerWidget {
  const KitchenScene({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(kitchenSceneProvider);
    final notifier = ref.read(kitchenSceneProvider.notifier);

    ref.listen<RunPhase>(kitchenSceneProvider, (previous, next) {
      if (next == RunPhase.celebrating) {
        HapticFeedback.mediumImpact();
        SystemSound.play(SystemSoundType.click);
        Future.delayed(const Duration(milliseconds: 900), notifier.finishCelebration);
      }
    });

    final restored = phase == RunPhase.celebrating || phase == RunPhase.restored;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: KitchenBackgroundPainter(restored: restored)),
          ),
          Center(
            child: AnimatedOpacity(
              opacity: restored ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 500),
              child: AnimatedScale(
                scale: restored ? 0.6 : 1.0,
                duration: const Duration(milliseconds: 500),
                child: const SizedBox(
                  width: 120,
                  height: 80,
                  child: CustomPaint(painter: DishPilePainter()),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: 40,
            child: CompanionWidget(
              mood: phase == RunPhase.celebrating
                  ? CompanionMood.celebrating
                  : CompanionMood.idle,
              onTap: notifier.tapCompanion,
            ),
          ),
          if (phase == RunPhase.questOffered)
            Center(child: QuestCard(onPlay: notifier.startRun)),
          if (phase == RunPhase.running) SingleTaskPrompt(onDone: notifier.completeTask),
          Positioned.fill(child: ParticleBurst(active: phase == RunPhase.celebrating)),
          if (phase == RunPhase.restored)
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 64),
                child: Text(
                  'KITCHEN RESTORED',
                  style: TextStyle(
                      color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/presentation/scenes/kitchen_scene_test.dart`
Expected: PASS (1 test)

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/scenes/kitchen_scene.dart test/presentation/scenes/kitchen_scene_test.dart
git commit -m "feat(m0): assemble KitchenScene from prototype pieces"
```

---

### Task 7: Wire into the app entry point

**Files:**
- Modify: `lib/main.dart`
- Modify: `test/widget_test.dart`

**Interfaces:**
- Consumes: `KitchenScene` (Task 6).
- Produces: `MiCasaApp`, the app's root widget, wrapped in
  `ProviderScope` so every provider in this plan resolves at runtime.

- [ ] **Step 1: Write the failing test**

Replace the default counter-app smoke test with one matching the new
app shell:

```dart
// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/main.dart';

void main() {
  testWidgets('app boots into the kitchen scene', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MiCasaApp()));

    expect(find.text('KITCHEN RESTORED'), findsNothing);
    expect(find.byKey(const ValueKey('companionTap')), findsOneWidget);
  });
}
```

`MiCasaApp` itself does not embed `ProviderScope` — `main()` wraps it at
the `runApp` call site, so the test wraps it the same way.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widget_test.dart`
Expected: FAIL — `MiCasaApp` does not exist yet in `lib/main.dart`
(current file still has the default counter app).

- [ ] **Step 3: Write minimal implementation**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/scenes/kitchen_scene.dart';

void main() {
  runApp(const ProviderScope(child: MiCasaApp()));
}

class MiCasaApp extends StatelessWidget {
  const MiCasaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'MiCasa',
      debugShowCheckedModeBanner: false,
      home: KitchenScene(),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widget_test.dart`
Expected: PASS (1 test)

- [ ] **Step 5: Commit**

```bash
git add lib/main.dart test/widget_test.dart
git commit -m "feat(m0): boot app directly into the kitchen scene"
```

---

### Task 8: Full suite, manual verification, and final commit

**Files:** none created; verification only.

- [ ] **Step 1: Run the full automated test suite**

Run: `flutter test`
Expected: PASS, all tests from Tasks 1–7 green (20 tests total: 5 + 6 + 2 + 2 + 3 + 1 + 1).

- [ ] **Step 2: Run static analysis**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Manual verification on a real device**

Run: `flutter run -d windows` (or `-d <android-device-id>` from
`flutter devices`).

Walk the actual flow: tap the companion → confirm the quest card
appears with "Kitchen Rescue — 2 min" and a `PLAY` button → tap `PLAY`
→ confirm "Put the dishes away" and a `DONE` button appear → tap `DONE`
→ confirm the dish pile fades and shrinks away, the background shifts
from grey/dark tones to warm tones, a haptic pulse fires (on a physical
Android device — Windows desktop has no haptic feedback and will
silently no-op there), a click sound plays, particles burst outward
from the companion's approximate position, and "KITCHEN RESTORED"
appears.

This is the actual spec §5.1 gate: if this sequence doesn't read as
satisfying even in placeholder-shape form, flag it before moving on to
M1 — the timing/choreography (delays, animation durations) is cheap to
tune now, in this task, rather than after more milestones are stacked
on top.

- [ ] **Step 4: Final commit**

If Step 3 prompted any tuning changes (durations, colors, layout),
commit them:

```bash
git add -A
git commit -m "polish(m0): tune wow-prototype timing after manual pass"
```

If no changes were needed, this step is a no-op — the milestone is
already fully committed from Tasks 1–7.

---

## Self-review notes

- **Spec coverage:** §5.1's six-step interaction is covered end to end
  (Task 6 wires all pieces; Task 8 verifies against the spec's own
  numbered list). §3.2/§3.3 copy conventions (quest card duration
  format, one-tap `DONE`, gestures optional at this scale) are honored
  where they apply to a single hardcoded task; full gesture support
  (swipe complete/skip) is explicitly **not** in scope for M0 — that
  belongs to M5's real run UI, since M0 has only one task and no skip
  path to gesture toward.
- **Deviation flagged:** `SystemSound.play(SystemSoundType.click)`
  stands in for "music resolves" (§5.1 step 5) rather than a real audio
  file, since M0 has no audio asset pipeline and the real adaptive-music
  system is explicitly deferred (M8 in the roadmap design doc). This is
  a placeholder, not a cut corner — M8 replaces it.
- **Placeholder scan:** no TBD/TODO markers; every step has concrete
  code.
- **Type consistency:** `RunPhase`, `CompanionMood`, and all widget
  constructor signatures are used identically across the tasks that
  produce them and the ones (Task 6) that consume them.
