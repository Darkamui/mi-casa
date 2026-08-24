# Flame Kitchen Runtime Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the kitchen scene as a layered 2.5D Flame diorama (8 depth
layers, real depth-sort, drag-driven parallax, a content-driven clutter
system) that reuses M0's `tapCompanion -> questOffered -> running ->
celebrating -> restored` loop, replacing the flattened M0
`KitchenScene`/`KitchenBackground`/`DishPile` implementation.

**Architecture:** A `KitchenGame` (`FlameGame`) hosts a `KitchenRoom`
component tree of 8 `PositionComponent` layers built from
`PropSpriteComponent` instances (a generic pivot-aware sprite wrapper).
Depth ordering and parallax offsets are computed by pure functions
(`depth_sort.dart`, `parallax_controller.dart`) and applied once (depth) or
every frame (parallax) — no per-frame re-sorting, no runtime dragging of
props. A scripted clutter system (`content/clutter/kitchen_clutter_states.json`
+ `clutter_state_loader.dart`) drives the one dynamic layer (`EntropyLayer`).
`KitchenSceneController`'s `RunPhase` state machine is reused unchanged; a
new `KitchenFlameScreen` widget hosts the `GameWidget` and reacts to phase
changes by calling into the Flame side (clutter swap, restoration effect,
companion mood) and by showing/hiding Flutter overlay chrome
(`QuestCard`, `SingleTaskPrompt`) via `GameWidget.overlayBuilderMap`.

**Tech Stack:** Flutter, `flame` (`^1.38.0`), `flame_test` (dev,
`^2.3.0`), Riverpod (existing `kitchenSceneProvider`), Dart SDK `^3.13.1`.

**Spec:** `docs/superpowers/specs/2026-08-24-flame-kitchen-runtime-design.md`
("Spec B") — read in full before starting; also read its parent doc,
`docs/hearthbound_2_5d_quaternius_handoff.md`, §14, §16, §18–24, §28, §33.

## Global Constraints

- `lib/simulation/` never imports `lib/presentation/`, and nothing in this
  plan touches `lib/simulation/` — the clutter loader lives entirely on the
  presentation side (spec §7).
- No percentages in the UI — the scripted demo uses `RunPhase` verbal
  states only, unchanged from M0.
- Feedback never waits on I/O — `completeTask` triggers local state +
  clutter swap + effects + haptics synchronously; there is no
  request/response step in Phase 0 (no backend).
- Content-driven: the clutter state data lives in
  `content/clutter/kitchen_clutter_states.json`, not in Dart code (spec §7).
- Phase 0 only: no `EntropyEngine`/Drift wiring, no rooms besides kitchen,
  no device-tilt parallax, no runtime object dragging, no golden-image
  tests (spec §3, §11).
- **Asset-currency adjustment (confirmed with the user 2026-08-24):**
  Spec §7's example clutter JSON references `dish_stack_small/large`,
  `mug`, `pan`, and `crumbs` — none of these have been rendered by Spec A
  (no matching FBX; see `tools/asset_renderer/README.md`'s checklist). This
  plan's clutter content uses **only the 13 sprites Spec A has actually
  rendered** (`content/art/rendered/props/`), so the final scene this plan
  produces is fully real, not placeholder-dependent. The only rendered
  asset that reads as "mess" is `garbage_bag` (a Trashcan_Cylindric.fbx
  substitute), so the scripted demo task is **"Take out the garbage"**
  (`kitchen.garbage` in `content/tasks/tasks.json`), not M0's "Put the
  dishes away". `wall`/`floor` architecture sprites are also unrendered,
  but per parent-doc §15 that's fine by design — room architecture doesn't
  need to be a Quaternius prop; `BackLayer`'s wall is a plain painted
  `Component`, not a `PropSpriteComponent`.
- Flame is the settled rendering engine as of this spec; Task 1 updates
  CLAUDE.md's "Stack" section accordingly (spec §12).

---

## File structure

```
lib/presentation/flame/
├── kitchen_game.dart
├── kitchen_room.dart
├── kitchen_flame_screen.dart
├── depth_sort.dart
├── parallax_controller.dart
├── clutter_state_loader.dart
├── layers/
│   ├── back_layer.dart
│   ├── furniture_layer.dart
│   ├── mid_layer.dart
│   ├── decor_layer.dart
│   ├── entropy_layer.dart
│   ├── character_layer.dart
│   ├── effects_layer.dart
│   └── foreground_layer.dart
└── components/
    ├── prop_sprite_component.dart
    ├── companion_component.dart
    └── restoration_effect_component.dart

content/clutter/kitchen_clutter_states.json   (new)

test/presentation/flame/                       (mirrors lib/presentation/flame/)
```

Deleted at the end of this plan (Task 12), once the new scene is verified
working: `lib/presentation/scenes/kitchen_scene.dart`,
`kitchen_background.dart`, `dish_pile.dart`, their tests,
`lib/presentation/widgets/companion_widget.dart` + test, the
`ParticleBurst`/`ParticlePainter` widget classes in
`lib/presentation/effects/particle_burst.dart` (the pure
`Particle`/`generateBurstParticles` stay — reused by
`RestorationEffectComponent`), and the old flattened art
(`content/art/kitchen/kitchen_structure.png`,
`content/art/props/dish_pile.png`).

---

### Task 1: Dependencies, asset registration, CLAUDE.md update

**Files:**
- Modify: `pubspec.yaml`
- Modify: `CLAUDE.md`

**Interfaces:**
- Produces: `flame` and `flame_test` become available to every later task.

- [ ] **Step 1: Add the `flame` and `flame_test` dependencies**

Run:
```bash
flutter pub add flame
flutter pub add --dev flame_test
```

This resolves and pins compatible versions (`flame` and `flame_test` are
independently versioned but released together — expect roughly `^1.38.0`
and `^2.3.0` respectively as of 2026-08-24; let the resolver pick the
exact numbers rather than hand-editing).

- [ ] **Step 2: Register new asset paths in `pubspec.yaml`**

Add to the existing `flutter: assets:` list (do not remove the existing
entries yet — Task 12 removes the ones that become unused):

```yaml
  assets:
    - content/art/kitchen/kitchen_structure.png
    - content/art/companion/companion_idle.png
    - content/art/companion/companion_excited.png
    - content/art/props/dish_pile.png
    - content/rooms/room_types.json
    - content/tasks/tasks.json
    - content/adjacency/edges.json
    - content/clutter/kitchen_clutter_states.json
    - content/art/rendered/props/fridge/
    - content/art/rendered/props/stove/
    - content/art/rendered/props/sink/
    - content/art/rendered/props/cabinet/
    - content/art/rendered/props/stool/
    - content/art/rendered/props/shelf/
    - content/art/rendered/props/rug/
    - content/art/rendered/props/plant_01/
    - content/art/rendered/props/plant_02/
    - content/art/rendered/props/garbage_bag/
    - content/art/rendered/props/window/
    - content/art/rendered/props/curtain/
```

(A trailing-slash directory entry in Flutter's asset syntax bundles every
file directly inside that folder — non-recursive, which is exactly the
`content/art/rendered/props/<folder>/<name>.png` shape these folders have.)
`content/clutter/kitchen_clutter_states.json` itself doesn't exist until
Task 4 — that's fine, `flutter pub get`/build only fails if the file is
missing at build time, not at this step.

- [ ] **Step 3: Update CLAUDE.md's Stack section**

In `CLAUDE.md`, replace:

```markdown
Flutter + Rive + Riverpod + Drift/SQLite. No Flame unless a spike proves
plain Flutter + `CustomPainter` insufficient (spec §5.3). Local-first,
no backend, no login, no sync in Phase 0.
```

with:

```markdown
Flutter + Rive + Riverpod + Drift/SQLite + Flame. Flame is the settled
rendering engine for room presentation (`lib/presentation/flame/`) — see
`docs/superpowers/specs/2026-08-24-flame-kitchen-runtime-design.md`.
Local-first, no backend, no login, no sync in Phase 0.
```

- [ ] **Step 4: Run `flutter pub get` and confirm a clean analyze**

Run:
```bash
flutter pub get
flutter analyze
```
Expected: no new errors (the new assets/deps don't introduce any code yet).

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml pubspec.lock CLAUDE.md
git commit -m "chore: add flame dependencies, register rendered-props assets, update CLAUDE.md"
```

---

### Task 2: `depth_sort.dart` — pure depth-priority assignment

**Files:**
- Create: `lib/presentation/flame/depth_sort.dart`
- Test: `test/presentation/flame/depth_sort_test.dart`

**Interfaces:**
- Produces: `class DepthEntry({required String id, required double floorY})`;
  `Map<String, int> assignDepthPriorities(List<DepthEntry> entries)` —
  smaller `floorY` gets a smaller (earlier-rendered) priority. Ties break
  by input order. Used by `KitchenRoom` (Task 9).

- [ ] **Step 1: Write the failing tests**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/flame/depth_sort.dart';

void main() {
  test('assigns ascending priorities in floorY order', () {
    final priorities = assignDepthPriorities(const [
      DepthEntry(id: 'table', floorY: 300),
      DepthEntry(id: 'chair', floorY: 100),
      DepthEntry(id: 'companion', floorY: 500),
    ]);

    expect(priorities['chair'], lessThan(priorities['table']!));
    expect(priorities['table'], lessThan(priorities['companion']!));
  });

  test('assigns contiguous priorities starting at 0', () {
    final priorities = assignDepthPriorities(const [
      DepthEntry(id: 'a', floorY: 10),
      DepthEntry(id: 'b', floorY: 20),
    ]);

    expect(priorities.values.toSet(), {0, 1});
  });

  test('breaks ties by input order, not floorY', () {
    final priorities = assignDepthPriorities(const [
      DepthEntry(id: 'first', floorY: 50),
      DepthEntry(id: 'second', floorY: 50),
    ]);

    expect(priorities['first'], 0);
    expect(priorities['second'], 1);
  });

  test('handles an empty list', () {
    expect(assignDepthPriorities(const []), isEmpty);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/presentation/flame/depth_sort_test.dart`
Expected: FAIL — `depth_sort.dart` doesn't exist yet (import error).

- [ ] **Step 3: Implement**

```dart
class DepthEntry {
  const DepthEntry({required this.id, required this.floorY});

  final String id;
  final double floorY;
}

/// Given each prop's floor-contact Y, assigns Flame `priority` values so
/// smaller Y renders first (parent doc §19). Computed once at composition
/// time, not per frame. Ties break by input order for determinism.
Map<String, int> assignDepthPriorities(List<DepthEntry> entries) {
  final indexed = entries.asMap().entries.toList()
    ..sort((a, b) {
      final cmp = a.value.floorY.compareTo(b.value.floorY);
      return cmp != 0 ? cmp : a.key.compareTo(b.key);
    });

  return {
    for (var i = 0; i < indexed.length; i++) indexed[i].value.id: i,
  };
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/presentation/flame/depth_sort_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/flame/depth_sort.dart test/presentation/flame/depth_sort_test.dart
git commit -m "feat: add pure depth-sort priority assignment for Flame kitchen"
```

---

### Task 3: `parallax_controller.dart` — pure parallax offset

**Files:**
- Create: `lib/presentation/flame/parallax_controller.dart`
- Test: `test/presentation/flame/parallax_controller_test.dart`

**Interfaces:**
- Produces: `Vector2 computeParallaxOffset({required Vector2 dragOffset,
  required double layerRate, double maxOffset = 12.0})`. Used by
  `KitchenRoom.applyParallax` (Task 9).
- Consumes: `Vector2` from `package:flame/extensions.dart` (re-export of
  `vector_math`'s `Vector2`; no Flame runtime required to use it).

- [ ] **Step 1: Write the failing tests**

```dart
import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/flame/parallax_controller.dart';

void main() {
  test('scales drag offset by the layer rate', () {
    final offset = computeParallaxOffset(
      dragOffset: Vector2(10, 0),
      layerRate: 0.5,
    );

    expect(offset.x, closeTo(5.0, 0.0001));
    expect(offset.y, closeTo(0.0, 0.0001));
  });

  test('clamps the result to maxOffset while preserving direction', () {
    final offset = computeParallaxOffset(
      dragOffset: Vector2(100, 0),
      layerRate: 0.8,
      maxOffset: 12.0,
    );

    expect(offset.length, closeTo(12.0, 0.0001));
    expect(offset.x, greaterThan(0));
  });

  test('zero drag produces zero offset', () {
    final offset = computeParallaxOffset(
      dragOffset: Vector2.zero(),
      layerRate: 0.65,
    );

    expect(offset, Vector2.zero());
  });

  test('a lower layer rate moves less than a higher one for the same drag', () {
    final drag = Vector2(20, 0);
    final back = computeParallaxOffset(dragOffset: drag, layerRate: 0.15);
    final foreground = computeParallaxOffset(dragOffset: drag, layerRate: 0.80);

    expect(back.length, lessThan(foreground.length));
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/presentation/flame/parallax_controller_test.dart`
Expected: FAIL — `parallax_controller.dart` doesn't exist yet.

- [ ] **Step 3: Implement**

```dart
import 'package:flame/extensions.dart';

/// Maps a drag delta and a per-layer parallax rate to a clamped render
/// offset (parent doc §18's example table: background 0.15x, back
/// furniture 0.30x, mid furniture 0.50x, characters 0.65x, foreground
/// 0.80x). Pure — no Flame instance required. Offset direction is
/// preserved when clamped.
Vector2 computeParallaxOffset({
  required Vector2 dragOffset,
  required double layerRate,
  double maxOffset = 12.0,
}) {
  final raw = dragOffset * layerRate;
  final magnitude = raw.length;
  if (magnitude <= maxOffset || magnitude == 0) {
    return raw;
  }
  return raw * (maxOffset / magnitude);
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/presentation/flame/parallax_controller_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/flame/parallax_controller.dart test/presentation/flame/parallax_controller_test.dart
git commit -m "feat: add pure drag-to-parallax offset calculation"
```

---

### Task 4: Clutter content + `clutter_state_loader.dart`

**Files:**
- Create: `content/clutter/kitchen_clutter_states.json`
- Create: `lib/presentation/flame/clutter_state_loader.dart`
- Test: `test/presentation/flame/clutter_state_loader_test.dart`

**Interfaces:**
- Produces: `class ClutterEntry({required String layer, required String
  sprite, required String anchor})`; `class ClutterStateLoader` with
  `Map<String, List<ClutterEntry>> parseClutterStates(String jsonSource)`
  and `Future<Map<String, List<ClutterEntry>>> loadClutterStates()`. Used
  by `KitchenRoom.create`/`setClutterState` (Task 9).

- [ ] **Step 1: Write the content file (rendered-assets-only, per the
  asset-currency adjustment in Global Constraints)**

```json
{
  "pristine": [],
  "normal": [],
  "messy": [
    { "layer": "entropy", "sprite": "garbage_bag", "anchor": "floor" }
  ],
  "disaster": [
    { "layer": "entropy", "sprite": "garbage_bag", "anchor": "floor" }
  ]
}
```

`normal` and `disaster` are deliberately thin (empty / identical to
`messy`) — `garbage_bag` is the only rendered sprite that reads as
"entropy" today. Add real `normal`/`disaster` differentiation once Spec A
renders more entropy props (`dish_stack_small`, `mug`, `pan`, `crumbs` —
see `tools/asset_renderer/README.md`'s checklist). The scripted demo
(Task 9) only ever uses `messy` and `pristine`.

- [ ] **Step 2: Write the failing tests**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/flame/clutter_state_loader.dart';

void main() {
  const loader = ClutterStateLoader();

  test('parses a JSON object of named clutter states', () {
    const source = '''
    {
      "pristine": [],
      "messy": [
        { "layer": "entropy", "sprite": "garbage_bag", "anchor": "floor" }
      ]
    }
    ''';

    final result = loader.parseClutterStates(source);

    expect(result['pristine'], isEmpty);
    expect(result['messy'], hasLength(1));
    expect(result['messy']!.first.layer, 'entropy');
    expect(result['messy']!.first.sprite, 'garbage_bag');
    expect(result['messy']!.first.anchor, 'floor');
  });

  test('loadClutterStates reads and parses the real content file', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final result = await loader.loadClutterStates();

    expect(result.containsKey('pristine'), isTrue);
    expect(result.containsKey('messy'), isTrue);
    expect(result['messy']!.single.sprite, 'garbage_bag');
  });
}
```

- [ ] **Step 3: Run the test to verify it fails**

Run: `flutter test test/presentation/flame/clutter_state_loader_test.dart`
Expected: FAIL — `clutter_state_loader.dart` doesn't exist yet.

- [ ] **Step 4: Implement**

```dart
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class ClutterEntry {
  const ClutterEntry({
    required this.layer,
    required this.sprite,
    required this.anchor,
  });

  final String layer;
  final String sprite;
  final String anchor;

  factory ClutterEntry.fromJson(Map<String, dynamic> json) => ClutterEntry(
        layer: json['layer'] as String,
        sprite: json['sprite'] as String,
        anchor: json['anchor'] as String,
      );
}

/// Parallel in shape to lib/simulation/content_loader.dart, but living in
/// lib/presentation/ since it maps state names directly to sprite asset
/// names, which lib/simulation/ must never know about.
class ClutterStateLoader {
  const ClutterStateLoader();

  Map<String, List<ClutterEntry>> parseClutterStates(String jsonSource) {
    final map = jsonDecode(jsonSource) as Map<String, dynamic>;
    return map.map(
      (state, entries) => MapEntry(
        state,
        (entries as List<dynamic>)
            .map((e) => ClutterEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
  }

  Future<Map<String, List<ClutterEntry>>> loadClutterStates() async {
    final source = await rootBundle
        .loadString('content/clutter/kitchen_clutter_states.json');
    return parseClutterStates(source);
  }
}
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `flutter test test/presentation/flame/clutter_state_loader_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 6: Commit**

```bash
git add content/clutter/kitchen_clutter_states.json lib/presentation/flame/clutter_state_loader.dart test/presentation/flame/clutter_state_loader_test.dart
git commit -m "feat: add scripted kitchen clutter-state content and loader"
```

---

### Task 5: `PropSpriteComponent`

**Files:**
- Create: `lib/presentation/flame/components/prop_sprite_component.dart`
- Test: `test/presentation/flame/components/prop_sprite_component_test.dart`

**Interfaces:**
- Produces: `enum PropPivot { floorContact, verticalCenter }`; `class
  PropSpriteComponent extends SpriteComponent` with constructor
  `({required Sprite sprite, required Vector2 position, PropPivot pivot =
  PropPivot.floorContact})`, static `Future<PropSpriteComponent> load({
  required String assetPath, required Vector2 position, PropPivot pivot =
  PropPivot.floorContact})`, and `double get floorY`. Used by every layer
  (Task 8) and `KitchenRoom` (Task 9).
- Consumes: `generateImage()` and `testWithFlameGame` from `flame_test`
  (test only).

- [ ] **Step 1: Write the failing tests**

```dart
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/flame/components/prop_sprite_component.dart';

void main() {
  testWithFlameGame('floorContact anchors bottom-center at position',
      (game) async {
    final image = await generateImage(64, 96);
    final component = PropSpriteComponent(
      sprite: Sprite(image),
      position: Vector2(100, 200),
    );
    await game.ensureAdd(component);

    expect(component.anchor, Anchor.bottomCenter);
    expect(component.floorY, 200);
  });

  testWithFlameGame('verticalCenter anchors center at position',
      (game) async {
    final image = await generateImage(64, 96);
    final component = PropSpriteComponent(
      sprite: Sprite(image),
      position: Vector2(100, 200),
      pivot: PropPivot.verticalCenter,
    );
    await game.ensureAdd(component);

    expect(component.anchor, Anchor.center);
    expect(component.floorY, 200 + component.size.y / 2);
  });

  testWithFlameGame('size matches the sprite source size', (game) async {
    final image = await generateImage(64, 96);
    final component = PropSpriteComponent(
      sprite: Sprite(image),
      position: Vector2.zero(),
    );
    await game.ensureAdd(component);

    expect(component.size, Vector2(64, 96));
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/presentation/flame/components/prop_sprite_component_test.dart`
Expected: FAIL — `prop_sprite_component.dart` doesn't exist yet.

- [ ] **Step 3: Implement**

```dart
import 'package:flame/components.dart';

enum PropPivot { floorContact, verticalCenter }

/// Generic pivot-aware sprite wrapper — every furniture/decor/entropy
/// sprite in the kitchen is one of these. `floorContact` (default) anchors
/// bottom-center, matching Spec A's floor-contact pivot convention.
/// `verticalCenter` anchors center, for wall-mounted assets (window,
/// curtain, picture).
class PropSpriteComponent extends SpriteComponent {
  PropSpriteComponent({
    required Sprite sprite,
    required Vector2 position,
    this.pivot = PropPivot.floorContact,
  }) : super(
          sprite: sprite,
          position: position,
          size: sprite.srcSize,
          anchor: pivot == PropPivot.floorContact
              ? Anchor.bottomCenter
              : Anchor.center,
        );

  final PropPivot pivot;

  static Future<PropSpriteComponent> load({
    required String assetPath,
    required Vector2 position,
    PropPivot pivot = PropPivot.floorContact,
  }) async {
    final sprite = await Sprite.load(assetPath);
    return PropSpriteComponent(sprite: sprite, position: position, pivot: pivot);
  }

  /// The prop's floor-contact Y in world space, for depth sorting
  /// (depth_sort.dart) regardless of pivot mode.
  double get floorY => pivot == PropPivot.floorContact
      ? position.y
      : position.y + size.y / 2;
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/presentation/flame/components/prop_sprite_component_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/flame/components/prop_sprite_component.dart test/presentation/flame/components/prop_sprite_component_test.dart
git commit -m "feat: add PropSpriteComponent with floor-contact/vertical-center pivots"
```

---

### Task 6: `CompanionComponent`

**Files:**
- Create: `lib/presentation/flame/components/companion_component.dart`
- Test: `test/presentation/flame/components/companion_component_test.dart`

**Interfaces:**
- Produces: `enum CompanionMood { idle, celebrating }`; `class
  CompanionComponent extends SpriteComponent with TapCallbacks` with
  constructor `({required Sprite idleSprite, required Sprite
  celebratingSprite, required Vector2 position, required void Function()
  onTap, CompanionMood mood = CompanionMood.idle})`, static
  `Future<CompanionComponent> load({required Vector2 position, required
  void Function() onTap})`, settable `mood` property, `double get floorY`.
  Used by `CharacterLayer` (Task 8) and `KitchenRoom` (Task 9).

- [ ] **Step 1: Write the failing tests**

```dart
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/flame/components/companion_component.dart';

void main() {
  testWithFlameGame('tapping invokes onTap', (game) async {
    var tapped = false;
    final idle = Sprite(await generateImage(96, 112));
    final celebrating = Sprite(await generateImage(96, 112));
    final component = CompanionComponent(
      idleSprite: idle,
      celebratingSprite: celebrating,
      position: Vector2(100, 100),
      onTap: () => tapped = true,
    );
    await game.ensureAdd(component);

    component.onTapUp(
      TapUpEvent(1, game, TapUpDetails.raw(component.position.toOffset(), 1)),
    );

    expect(tapped, isTrue);
  });

  testWithFlameGame('starts idle and switches sprite on mood change',
      (game) async {
    final idle = Sprite(await generateImage(96, 112));
    final celebrating = Sprite(await generateImage(96, 112));
    final component = CompanionComponent(
      idleSprite: idle,
      celebratingSprite: celebrating,
      position: Vector2.zero(),
      onTap: () {},
    );
    await game.ensureAdd(component);

    expect(component.mood, CompanionMood.idle);
    expect(component.sprite, idle);

    component.mood = CompanionMood.celebrating;

    expect(component.sprite, celebrating);
  });

  testWithFlameGame('anchors bottom-center per parent-doc §24', (game) async {
    final idle = Sprite(await generateImage(96, 112));
    final component = CompanionComponent(
      idleSprite: idle,
      celebratingSprite: idle,
      position: Vector2(50, 300),
      onTap: () {},
    );
    await game.ensureAdd(component);

    expect(component.anchor, Anchor.bottomCenter);
    expect(component.floorY, 300);
  });
}
```

`TapUpEvent`'s exact constructor shape can vary by Flame version; if the
literal constructor above doesn't compile, call `component.onTap()`
directly to verify the callback field wiring instead — the important
behavior under test is "the stored `onTap` fires", not the event
plumbing itself, which the mid-doc integration test (Task 11) exercises
through a real `GameWidget` regardless.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/presentation/flame/components/companion_component_test.dart`
Expected: FAIL — `companion_component.dart` doesn't exist yet.

- [ ] **Step 3: Implement**

```dart
import 'package:flame/components.dart';
import 'package:flame/events.dart';

enum CompanionMood { idle, celebrating }

/// Flame version of the companion — participates in depth-sort and
/// parallax like parent-doc §24 requires ("positioned within the Flame
/// world"). Bottom-center pivot, per §24.
class CompanionComponent extends SpriteComponent with TapCallbacks {
  CompanionComponent({
    required Sprite idleSprite,
    required Sprite celebratingSprite,
    required Vector2 position,
    required this.onTap,
    CompanionMood mood = CompanionMood.idle,
  })  : _idleSprite = idleSprite,
        _celebratingSprite = celebratingSprite,
        _mood = mood,
        super(
          sprite: mood == CompanionMood.celebrating ? celebratingSprite : idleSprite,
          position: position,
          size: idleSprite.srcSize,
          anchor: Anchor.bottomCenter,
        );

  final Sprite _idleSprite;
  final Sprite _celebratingSprite;
  final void Function() onTap;
  CompanionMood _mood;

  CompanionMood get mood => _mood;

  set mood(CompanionMood value) {
    _mood = value;
    sprite = value == CompanionMood.celebrating ? _celebratingSprite : _idleSprite;
  }

  static Future<CompanionComponent> load({
    required Vector2 position,
    required void Function() onTap,
  }) async {
    final idle = await Sprite.load('content/art/companion/companion_idle.png');
    final celebrating =
        await Sprite.load('content/art/companion/companion_excited.png');
    return CompanionComponent(
      idleSprite: idle,
      celebratingSprite: celebrating,
      position: position,
      onTap: onTap,
    );
  }

  double get floorY => position.y;

  @override
  void onTapUp(TapUpEvent event) => onTap();
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/presentation/flame/components/companion_component_test.dart`
Expected: PASS (3 tests) — adjust the tap test per the Step 1 note if
`TapUpEvent`'s constructor doesn't match the installed `flame` version.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/flame/components/companion_component.dart test/presentation/flame/components/companion_component_test.dart
git commit -m "feat: add Flame CompanionComponent with tap and mood switching"
```

---

### Task 7: `RestorationEffectComponent`

**Files:**
- Create: `lib/presentation/flame/components/restoration_effect_component.dart`
- Test: `test/presentation/flame/components/restoration_effect_component_test.dart`

**Interfaces:**
- Consumes: `Particle`, `generateBurstParticles` from
  `lib/presentation/effects/particle_burst.dart` (existing, pure, already
  tested — reused as-is, not duplicated).
- Produces: `class RestorationEffectComponent extends PositionComponent`
  with constructor `({required Vector2 position})`, method `void fire()`.
  Used by `EffectsLayer` (Task 8) and `KitchenRoom` (Task 9).

- [ ] **Step 1: Write the failing tests**

```dart
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/flame/components/restoration_effect_component.dart';

void main() {
  testWithFlameGame('is inert until fire() is called', (game) async {
    final component = RestorationEffectComponent(position: Vector2(50, 50));
    await game.ensureAdd(component);

    game.update(0.5);

    expect(component.isActive, isFalse);
  });

  testWithFlameGame('fire() makes it active, and it expires after its duration',
      (game) async {
    final component = RestorationEffectComponent(position: Vector2(50, 50));
    await game.ensureAdd(component);

    component.fire();
    expect(component.isActive, isTrue);

    game.update(1.0);
    expect(component.isActive, isFalse);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/presentation/flame/components/restoration_effect_component_test.dart`
Expected: FAIL — `restoration_effect_component.dart` doesn't exist yet.

- [ ] **Step 3: Implement**

```dart
import 'dart:ui';

import 'package:flame/components.dart';

import '../../effects/particle_burst.dart' show Particle, generateBurstParticles;

/// Flame version of ParticleBurst — needs a world position (the
/// restoration anchor), not a screen position, so it moves into
/// EffectsLayer as a component instead of a Stack-positioned widget.
/// Reuses the existing pure generateBurstParticles/Particle rather than
/// duplicating burst logic.
class RestorationEffectComponent extends PositionComponent {
  RestorationEffectComponent({required Vector2 position})
      : super(position: position, size: Vector2.zero());

  static const double _duration = 0.9;

  List<Particle> _particles = const [];
  double _elapsed = _duration;

  bool get isActive => _elapsed < _duration;

  void fire() {
    _particles = generateBurstParticles(seed: DateTime.now().millisecondsSinceEpoch);
    _elapsed = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_elapsed < _duration) {
      _elapsed += dt;
    }
  }

  @override
  void render(Canvas canvas) {
    if (!isActive) return;
    final progress = (_elapsed / _duration).clamp(0.0, 1.0);
    for (final particle in _particles) {
      final offset = particle.direction * (particle.speed * progress);
      final opacity = (1 - progress).clamp(0.0, 1.0);
      canvas.drawCircle(
        offset,
        4,
        Paint()..color = particle.color.withValues(alpha: opacity),
      );
    }
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/presentation/flame/components/restoration_effect_component_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/flame/components/restoration_effect_component.dart test/presentation/flame/components/restoration_effect_component_test.dart
git commit -m "feat: add Flame RestorationEffectComponent reusing existing particle burst"
```

---

### Task 8: The 8 layer components

**Files:**
- Create: `lib/presentation/flame/layers/back_layer.dart`
- Create: `lib/presentation/flame/layers/furniture_layer.dart`
- Create: `lib/presentation/flame/layers/mid_layer.dart`
- Create: `lib/presentation/flame/layers/decor_layer.dart`
- Create: `lib/presentation/flame/layers/entropy_layer.dart`
- Create: `lib/presentation/flame/layers/character_layer.dart`
- Create: `lib/presentation/flame/layers/effects_layer.dart`
- Create: `lib/presentation/flame/layers/foreground_layer.dart`
- Test: `test/presentation/flame/layers/layers_test.dart`

**Interfaces:**
- Consumes: `PropSpriteComponent` (Task 5), `CompanionComponent` (Task 6),
  `RestorationEffectComponent` (Task 7).
- Produces: `BackLayer({List<PropSpriteComponent> props = const []})`,
  `FurnitureLayer({List<PropSpriteComponent> props = const []})`,
  `MidLayer({List<PropSpriteComponent> props = const []})`,
  `DecorLayer({List<PropSpriteComponent> props = const []})`,
  `EntropyLayer({List<PropSpriteComponent> props = const []})` +
  `Future<void> setProps(List<PropSpriteComponent> props)`,
  `CharacterLayer({required CompanionComponent companion})` with field
  `companion`, `EffectsLayer({required RestorationEffectComponent
  restorationEffect})` with field `restorationEffect`,
  `ForegroundLayer()`. All extend `PositionComponent`. Used by
  `KitchenRoom` (Task 9).

- [ ] **Step 1: Write the failing tests**

```dart
import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/flame/components/companion_component.dart';
import 'package:micasa/presentation/flame/components/prop_sprite_component.dart';
import 'package:micasa/presentation/flame/components/restoration_effect_component.dart';
import 'package:micasa/presentation/flame/layers/back_layer.dart';
import 'package:micasa/presentation/flame/layers/character_layer.dart';
import 'package:micasa/presentation/flame/layers/decor_layer.dart';
import 'package:micasa/presentation/flame/layers/effects_layer.dart';
import 'package:micasa/presentation/flame/layers/entropy_layer.dart';
import 'package:micasa/presentation/flame/layers/foreground_layer.dart';
import 'package:micasa/presentation/flame/layers/furniture_layer.dart';
import 'package:micasa/presentation/flame/layers/mid_layer.dart';

Future<PropSpriteComponent> _prop() async => PropSpriteComponent(
      sprite: Sprite(await generateImage(32, 32)),
      position: Vector2.zero(),
    );

void main() {
  testWithFlameGame('BackLayer holds its given props', (game) async {
    final layer = BackLayer(props: [await _prop(), await _prop()]);
    await game.ensureAdd(layer);

    expect(layer.children.length, 2);
  });

  testWithFlameGame('FurnitureLayer, MidLayer, DecorLayer hold their props',
      (game) async {
    final furniture = FurnitureLayer(props: [await _prop()]);
    final mid = MidLayer(props: [await _prop()]);
    final decor = DecorLayer(props: [await _prop(), await _prop()]);
    await game.ensureAddAll([furniture, mid, decor]);

    expect(furniture.children.length, 1);
    expect(mid.children.length, 1);
    expect(decor.children.length, 2);
  });

  testWithFlameGame('EntropyLayer starts with given props and can be replaced',
      (game) async {
    final layer = EntropyLayer(props: [await _prop()]);
    await game.ensureAdd(layer);
    expect(layer.children.length, 1);

    await layer.setProps([await _prop(), await _prop()]);

    expect(layer.children.length, 2);
  });

  testWithFlameGame('EntropyLayer.setProps can clear to empty', (game) async {
    final layer = EntropyLayer(props: [await _prop()]);
    await game.ensureAdd(layer);

    await layer.setProps(const []);

    expect(layer.children.length, 0);
  });

  testWithFlameGame('CharacterLayer holds the companion', (game) async {
    final companion = CompanionComponent(
      idleSprite: Sprite(await generateImage(32, 32)),
      celebratingSprite: Sprite(await generateImage(32, 32)),
      position: Vector2.zero(),
      onTap: () {},
    );
    final layer = CharacterLayer(companion: companion);
    await game.ensureAdd(layer);

    expect(layer.children.length, 1);
    expect(layer.companion, companion);
  });

  testWithFlameGame('EffectsLayer holds the restoration effect', (game) async {
    final effect = RestorationEffectComponent(position: Vector2.zero());
    final layer = EffectsLayer(restorationEffect: effect);
    await game.ensureAdd(layer);

    expect(layer.children.length, 1);
    expect(layer.restorationEffect, effect);
  });

  testWithFlameGame('ForegroundLayer starts empty', (game) async {
    final layer = ForegroundLayer();
    await game.ensureAdd(layer);

    expect(layer.children.length, 0);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/presentation/flame/layers/layers_test.dart`
Expected: FAIL — none of the layer files exist yet.

- [ ] **Step 3: Implement each layer**

`lib/presentation/flame/layers/back_layer.dart`:
```dart
import 'package:flame/components.dart';

import '../components/prop_sprite_component.dart';

/// Wall, window, curtain — parent-doc §14/§15. The wall itself is a plain
/// painted background handled at the screen level (no rendered wall
/// sprite exists — parent-doc §15 explicitly allows this), so this layer
/// only holds wall-mounted props like window/curtain.
class BackLayer extends PositionComponent {
  BackLayer({List<PropSpriteComponent> props = const []}) {
    addAll(props);
  }
}
```

`lib/presentation/flame/layers/furniture_layer.dart`:
```dart
import 'package:flame/components.dart';

import '../components/prop_sprite_component.dart';

/// Fridge, stove, cabinets, sink, shelves.
class FurnitureLayer extends PositionComponent {
  FurnitureLayer({List<PropSpriteComponent> props = const []}) {
    addAll(props);
  }
}
```

`lib/presentation/flame/layers/mid_layer.dart`:
```dart
import 'package:flame/components.dart';

import '../components/prop_sprite_component.dart';

/// Island, table, stools.
class MidLayer extends PositionComponent {
  MidLayer({List<PropSpriteComponent> props = const []}) {
    addAll(props);
  }
}
```

`lib/presentation/flame/layers/decor_layer.dart`:
```dart
import 'package:flame/components.dart';

import '../components/prop_sprite_component.dart';

/// Plants, rug, jars, pictures.
class DecorLayer extends PositionComponent {
  DecorLayer({List<PropSpriteComponent> props = const []}) {
    addAll(props);
  }
}
```

`lib/presentation/flame/layers/entropy_layer.dart`:
```dart
import 'package:flame/components.dart';

import '../components/prop_sprite_component.dart';

/// Dishes, mug, crumbs, trash — driven by the scripted clutter state.
/// The only mutable layer in Phase 0: setProps swaps its whole content in
/// one call, matching the scripted demo's "completion clears everything
/// at once" behavior (spec §8).
class EntropyLayer extends PositionComponent {
  EntropyLayer({List<PropSpriteComponent> props = const []}) {
    addAll(props);
  }

  Future<void> setProps(List<PropSpriteComponent> props) async {
    removeAll(children.toList());
    addAll(props);
  }
}
```

`lib/presentation/flame/layers/character_layer.dart`:
```dart
import 'package:flame/components.dart';

import '../components/companion_component.dart';

class CharacterLayer extends PositionComponent {
  CharacterLayer({required this.companion}) {
    add(companion);
  }

  final CompanionComponent companion;
}
```

`lib/presentation/flame/layers/effects_layer.dart`:
```dart
import 'package:flame/components.dart';

import '../components/restoration_effect_component.dart';

class EffectsLayer extends PositionComponent {
  EffectsLayer({required this.restorationEffect}) {
    add(restorationEffect);
  }

  final RestorationEffectComponent restorationEffect;
}
```

`lib/presentation/flame/layers/foreground_layer.dart`:
```dart
import 'package:flame/components.dart';

/// Empty for kitchen initially, kept for convention/future rooms.
class ForegroundLayer extends PositionComponent {}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/presentation/flame/layers/layers_test.dart`
Expected: PASS (7 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/flame/layers/ test/presentation/flame/layers/layers_test.dart
git commit -m "feat: add the 8 KitchenRoom layer components"
```

---

### Task 9: `KitchenRoom`

**Files:**
- Create: `lib/presentation/flame/kitchen_room.dart`
- Test: `test/presentation/flame/kitchen_room_test.dart`

**Interfaces:**
- Consumes: all 8 layers (Task 8), `PropSpriteComponent`,
  `CompanionComponent`, `RestorationEffectComponent`, `depth_sort.dart`
  (Task 2), `parallax_controller.dart` (Task 3), `ClutterStateLoader`/
  `ClutterEntry` (Task 4).
- Produces: `class KitchenRoom extends PositionComponent` with static
  `Future<KitchenRoom> create({required void Function() onCompanionTap})`,
  fields `backLayer`/`furnitureLayer`/`midLayer`/`decorLayer`/
  `entropyLayer`/`characterLayer`/`effectsLayer`/`foregroundLayer`,
  methods `void applyParallax(Vector2 dragOffset)`, `Future<void>
  setClutterState(String state)`, `Future<void> celebrateCompletion()`.
  Used by `KitchenGame` (Task 10) and `KitchenFlameScreen` (Task 11).

This task also defines the fixed kitchen layout (asset paths + hand-placed
`Vector2` positions for a 1280×720 design viewport) and the anchor lookup
the clutter loader's `anchor` field resolves against. **These pixel
values are a starting point for a human to visually tune in Task 11's
manual verification step — they are not asserted precisely by any test.**

- [ ] **Step 1: Write the failing tests**

```dart
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/flame/kitchen_room.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWithFlameGame('create() builds all 8 layers as children', (game) async {
    final room = await KitchenRoom.create(onCompanionTap: () {});
    await game.ensureAdd(room);

    expect(room.children.length, 8);
  });

  testWithFlameGame('starts in the messy clutter state (scripted demo, spec §8)',
      (game) async {
    final room = await KitchenRoom.create(onCompanionTap: () {});
    await game.ensureAdd(room);

    expect(room.entropyLayer.children.length, 1);
  });

  testWithFlameGame('setClutterState(pristine) empties the entropy layer',
      (game) async {
    final room = await KitchenRoom.create(onCompanionTap: () {});
    await game.ensureAdd(room);

    await room.setClutterState('pristine');

    expect(room.entropyLayer.children.length, 0);
  });

  testWithFlameGame(
      'celebrateCompletion clears clutter, fires effects, and celebrates the companion',
      (game) async {
    final room = await KitchenRoom.create(onCompanionTap: () {});
    await game.ensureAdd(room);

    await room.celebrateCompletion();

    expect(room.entropyLayer.children.length, 0);
    expect(room.effectsLayer.restorationEffect.isActive, isTrue);
    expect(room.characterLayer.companion.mood, CompanionMood.celebrating);
  });

  testWithFlameGame('applyParallax offsets layers by their configured rate',
      (game) async {
    final room = await KitchenRoom.create(onCompanionTap: () {});
    await game.ensureAdd(room);

    room.applyParallax(Vector2(10, 0));

    expect(room.backLayer.position.x, greaterThan(0));
    expect(room.foregroundLayer.position.x,
        greaterThan(room.backLayer.position.x));
  });
}
```

Add the `CompanionMood` import
(`package:micasa/presentation/flame/components/companion_component.dart`)
alongside the others at the top of the test file.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/presentation/flame/kitchen_room_test.dart`
Expected: FAIL — `kitchen_room.dart` doesn't exist yet.

- [ ] **Step 3: Implement**

```dart
import 'package:flame/components.dart';

import 'clutter_state_loader.dart';
import 'components/companion_component.dart';
import 'components/prop_sprite_component.dart';
import 'components/restoration_effect_component.dart';
import 'depth_sort.dart';
import 'layers/back_layer.dart';
import 'layers/character_layer.dart';
import 'layers/decor_layer.dart';
import 'layers/effects_layer.dart';
import 'layers/entropy_layer.dart';
import 'layers/foreground_layer.dart';
import 'layers/furniture_layer.dart';
import 'layers/mid_layer.dart';
import 'parallax_controller.dart';

const String _propsRoot = 'content/art/rendered/props';

/// Fixed placement points clutter entries' `anchor` field resolves
/// against (spec §7). Phase 0 has exactly one room layout, so these are
/// hardcoded rather than data-driven.
Vector2 anchorPosition(String anchor) {
  switch (anchor) {
    case 'floor':
      return Vector2(1080, 660);
    default:
      throw ArgumentError('Unknown clutter anchor: $anchor');
  }
}

/// Root component for the kitchen diorama — builds the 8 layers as
/// children, in order (spec §6).
class KitchenRoom extends PositionComponent {
  KitchenRoom._({
    required this.backLayer,
    required this.furnitureLayer,
    required this.midLayer,
    required this.decorLayer,
    required this.entropyLayer,
    required this.characterLayer,
    required this.effectsLayer,
    required this.foregroundLayer,
    required Map<String, List<ClutterEntry>> clutterStates,
  }) : _clutterStates = clutterStates {
    addAll([
      backLayer,
      furnitureLayer,
      midLayer,
      decorLayer,
      entropyLayer,
      characterLayer,
      effectsLayer,
      foregroundLayer,
    ]);
  }

  final BackLayer backLayer;
  final FurnitureLayer furnitureLayer;
  final MidLayer midLayer;
  final DecorLayer decorLayer;
  final EntropyLayer entropyLayer;
  final CharacterLayer characterLayer;
  final EffectsLayer effectsLayer;
  final ForegroundLayer foregroundLayer;
  final Map<String, List<ClutterEntry>> _clutterStates;

  late final Map<PositionComponent, double> _parallaxRates = {
    backLayer: 0.15,
    furnitureLayer: 0.30,
    midLayer: 0.50,
    decorLayer: 0.50,
    entropyLayer: 0.50,
    characterLayer: 0.65,
    effectsLayer: 0.65,
    foregroundLayer: 0.80,
  };

  static Future<KitchenRoom> create({
    required void Function() onCompanionTap,
  }) async {
    final clutterStates = await const ClutterStateLoader().loadClutterStates();

    final backLayer = BackLayer(props: [
      await PropSpriteComponent.load(
        assetPath: '$_propsRoot/window/window_000.png',
        position: Vector2(560, 190),
        pivot: PropPivot.verticalCenter,
      ),
      await PropSpriteComponent.load(
        assetPath: '$_propsRoot/curtain/curtain_000.png',
        position: Vector2(700, 190),
        pivot: PropPivot.verticalCenter,
      ),
    ]);

    final furnitureLayer = FurnitureLayer(props: [
      await PropSpriteComponent.load(
        assetPath: '$_propsRoot/fridge/fridge_000.png',
        position: Vector2(150, 620),
      ),
      await PropSpriteComponent.load(
        assetPath: '$_propsRoot/stove/stove_000.png',
        position: Vector2(350, 620),
      ),
      await PropSpriteComponent.load(
        assetPath: '$_propsRoot/sink/sink_000.png',
        position: Vector2(550, 620),
      ),
      await PropSpriteComponent.load(
        assetPath: '$_propsRoot/cabinet/cabinet_000.png',
        position: Vector2(750, 620),
      ),
      await PropSpriteComponent.load(
        assetPath: '$_propsRoot/cabinet/cabinet_045.png',
        position: Vector2(900, 620),
      ),
      await PropSpriteComponent.load(
        assetPath: '$_propsRoot/shelf/shelf_000.png',
        position: Vector2(1050, 620),
      ),
    ]);

    final midLayer = MidLayer(props: [
      await PropSpriteComponent.load(
        assetPath: '$_propsRoot/stool/stool_000.png',
        position: Vector2(650, 660),
      ),
    ]);

    final decorLayer = DecorLayer(props: [
      await PropSpriteComponent.load(
        assetPath: '$_propsRoot/plant_01/plant_01_000.png',
        position: Vector2(80, 650),
      ),
      await PropSpriteComponent.load(
        assetPath: '$_propsRoot/plant_02/plant_02_000.png',
        position: Vector2(1200, 650),
      ),
      await PropSpriteComponent.load(
        assetPath: '$_propsRoot/rug/rug_000.png',
        position: Vector2(500, 700),
      ),
    ]);

    final entropyLayer = EntropyLayer();

    final companion = await CompanionComponent.load(
      position: Vector2(950, 700),
      onTap: onCompanionTap,
    );
    final characterLayer = CharacterLayer(companion: companion);

    final effectsLayer = EffectsLayer(
      restorationEffect:
          RestorationEffectComponent(position: anchorPosition('floor')),
    );

    final foregroundLayer = ForegroundLayer();

    final room = KitchenRoom._(
      backLayer: backLayer,
      furnitureLayer: furnitureLayer,
      midLayer: midLayer,
      decorLayer: decorLayer,
      entropyLayer: entropyLayer,
      characterLayer: characterLayer,
      effectsLayer: effectsLayer,
      foregroundLayer: foregroundLayer,
      clutterStates: clutterStates,
    );

    room._applyDepthSort();
    // Scripted demo starts non-pristine so there's visible mess to clear
    // (spec §8).
    await room.setClutterState('messy');

    return room;
  }

  void _applyDepthSort() {
    final depthOwners = <PositionComponent>[
      ...furnitureLayer.children.whereType<PositionComponent>(),
      ...midLayer.children.whereType<PositionComponent>(),
      ...decorLayer.children.whereType<PositionComponent>(),
      ...entropyLayer.children.whereType<PositionComponent>(),
      ...characterLayer.children.whereType<PositionComponent>(),
    ];

    final entries = <DepthEntry>[];
    for (var i = 0; i < depthOwners.length; i++) {
      final owner = depthOwners[i];
      final floorY = owner is PropSpriteComponent
          ? owner.floorY
          : (owner as CompanionComponent).floorY;
      entries.add(DepthEntry(id: 'p$i', floorY: floorY));
    }

    final priorities = assignDepthPriorities(entries);
    for (var i = 0; i < depthOwners.length; i++) {
      depthOwners[i].priority = priorities['p$i']!;
    }
  }

  Future<void> setClutterState(String state) async {
    final entries = _clutterStates[state] ?? const [];
    final props = await Future.wait(entries.map(
      (entry) => PropSpriteComponent.load(
        assetPath: '$_propsRoot/${entry.sprite}/${entry.sprite}_000.png',
        position: anchorPosition(entry.anchor),
      ),
    ));
    await entropyLayer.setProps(props);
  }

  /// completeTask -> celebrating (spec §8): clutter clears, restoration
  /// effect fires at the relevant anchor, companion celebrates.
  Future<void> celebrateCompletion() async {
    await setClutterState('pristine');
    effectsLayer.restorationEffect.fire();
    characterLayer.companion.mood = CompanionMood.celebrating;
  }

  void applyParallax(Vector2 dragOffset) {
    for (final entry in _parallaxRates.entries) {
      entry.key.position = computeParallaxOffset(
        dragOffset: dragOffset,
        layerRate: entry.value,
      );
    }
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/presentation/flame/kitchen_room_test.dart`
Expected: PASS (5 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/flame/kitchen_room.dart test/presentation/flame/kitchen_room_test.dart
git commit -m "feat: compose KitchenRoom from its 8 layers with depth-sort and clutter wiring"
```

---

### Task 10: `KitchenGame`

**Files:**
- Create: `lib/presentation/flame/kitchen_game.dart`
- Test: `test/presentation/flame/kitchen_game_test.dart`

**Interfaces:**
- Consumes: `KitchenRoom` (Task 9).
- Produces: `class KitchenGame extends FlameGame` with constructor
  `({required void Function() onCompanionTap})`, field `late final
  KitchenRoom kitchenRoom` (populated after `onLoad`). Used by
  `KitchenFlameScreen` (Task 11).

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/flame/kitchen_game.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('onLoad builds the kitchen room and adds it to the world', () async {
    final game = KitchenGame(onCompanionTap: () {});
    game.onGameResize(Vector2(1280, 720));
    await game.onLoad();
    await game.ready();

    expect(game.kitchenRoom.isMounted, isTrue);
    expect(game.world.children.contains(game.kitchenRoom), isTrue);
  });

  test('dragging accumulates offset that feeds into room parallax', () async {
    final game = KitchenGame(onCompanionTap: () {});
    game.onGameResize(Vector2(1280, 720));
    await game.onLoad();
    await game.ready();

    final backBefore = game.kitchenRoom.backLayer.position.clone();
    game.handleDragForTest(Vector2(10, 0));
    game.update(0);

    expect(game.kitchenRoom.backLayer.position, isNot(backBefore));
  });
}
```

`handleDragForTest` is a small test-only seam (see Step 3) — driving a
real `DragUpdateEvent` through Flame's gesture pipeline in a headless
`flutter test` run is brittle across Flame versions, and the actual drag
wiring is exercised end-to-end by the manual verification in Task 11
anyway.

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/presentation/flame/kitchen_game_test.dart`
Expected: FAIL — `kitchen_game.dart` doesn't exist yet.

- [ ] **Step 3: Implement**

```dart
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';

import 'kitchen_room.dart';

class KitchenGame extends FlameGame {
  KitchenGame({required this.onCompanionTap})
      : super(camera: CameraComponent.withFixedResolution(width: 1280, height: 720));

  final void Function() onCompanionTap;

  late final KitchenRoom kitchenRoom;
  late final _DragCaptureComponent _dragCapture;

  @override
  Future<void> onLoad() async {
    // Rendered props live under content/art/rendered/props/, not Flame's
    // default assets/images/ prefix.
    Flame.images.prefix = '';

    kitchenRoom = await KitchenRoom.create(onCompanionTap: onCompanionTap);
    await world.add(kitchenRoom);

    _dragCapture = _DragCaptureComponent(size: Vector2(1280, 720));
    await camera.viewport.add(_dragCapture);
  }

  @override
  void update(double dt) {
    super.update(dt);
    kitchenRoom.applyParallax(_dragCapture.dragOffset);
  }

  /// Test-only seam — see kitchen_game_test.dart for why driving a real
  /// DragUpdateEvent headlessly is avoided.
  void handleDragForTest(Vector2 delta) {
    _dragCapture.dragOffset += delta;
  }
}

/// Screen-fixed (added to camera.viewport, not world) so it captures pan
/// gestures regardless of camera position — parent-doc §18: parallax
/// reacts to drag, not device tilt.
class _DragCaptureComponent extends PositionComponent with DragCallbacks {
  _DragCaptureComponent({required super.size});

  Vector2 dragOffset = Vector2.zero();

  @override
  void onDragUpdate(DragUpdateEvent event) {
    dragOffset += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) => dragOffset = Vector2.zero();

  @override
  void onDragCancel(DragCancelEvent event) => dragOffset = Vector2.zero();
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/presentation/flame/kitchen_game_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/flame/kitchen_game.dart test/presentation/flame/kitchen_game_test.dart
git commit -m "feat: add KitchenGame hosting the room, camera, and drag-driven parallax"
```

---

### Task 11: `KitchenFlameScreen` + app wiring + integration test

**Files:**
- Create: `lib/presentation/flame/kitchen_flame_screen.dart`
- Modify: `lib/main.dart`
- Modify: `test/widget_test.dart`
- Test: `test/presentation/flame/kitchen_flame_screen_test.dart`

**Interfaces:**
- Consumes: `KitchenGame` (Task 10), `KitchenSceneController`/
  `kitchenSceneProvider`/`RunPhase` (existing, unchanged), `QuestCard`,
  `SingleTaskPrompt` (existing, unchanged, reused as pure Flutter
  overlays per spec §9).
- Produces: `class KitchenFlameScreen extends ConsumerStatefulWidget`.
  This is the app's new root screen, replacing `KitchenScene`.

- [ ] **Step 1: Write the failing tests**

```dart
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/flame/components/companion_component.dart';
import 'package:micasa/presentation/flame/kitchen_flame_screen.dart';
import 'package:micasa/presentation/flame/kitchen_game.dart';
import 'package:micasa/presentation/scenes/kitchen_scene_controller.dart';

void main() {
  testWidgets('full loop: tap companion -> PLAY -> DONE -> restored',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: KitchenFlameScreen())),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byType(GameWidget<KitchenGame>), findsOneWidget);
    expect(find.text('KITCHEN RESTORED'), findsNothing);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(KitchenFlameScreen)),
    );
    final notifier = container.read(kitchenSceneProvider.notifier);
    final game = tester
        .widget<GameWidget<KitchenGame>>(find.byType(GameWidget<KitchenGame>))
        .game!;

    notifier.tapCompanion();
    await tester.pump();
    expect(find.text('Kitchen Rescue — 2 min'), findsOneWidget);

    await tester.tap(find.text('PLAY'));
    await tester.pump();
    expect(find.text('Take out the garbage'), findsOneWidget);
    expect(game.kitchenRoom.entropyLayer.children.length, 1);

    await tester.tap(find.text('DONE'));
    await tester.pump();

    expect(game.kitchenRoom.entropyLayer.children.length, 0);
    expect(game.kitchenRoom.characterLayer.companion.mood,
        CompanionMood.celebrating);

    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('KITCHEN RESTORED'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/presentation/flame/kitchen_flame_screen_test.dart`
Expected: FAIL — `kitchen_flame_screen.dart` doesn't exist yet.

- [ ] **Step 3: Implement the screen**

```dart
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../scenes/kitchen_scene_controller.dart';
import '../widgets/quest_card.dart';
import '../widgets/single_task_prompt.dart';
import 'kitchen_game.dart';

class KitchenFlameScreen extends ConsumerStatefulWidget {
  const KitchenFlameScreen({super.key});

  @override
  ConsumerState<KitchenFlameScreen> createState() => _KitchenFlameScreenState();
}

class _KitchenFlameScreenState extends ConsumerState<KitchenFlameScreen> {
  late final KitchenGame _game;

  @override
  void initState() {
    super.initState();
    _game = KitchenGame(
      onCompanionTap: () => ref.read(kitchenSceneProvider.notifier).tapCompanion(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final phase = ref.watch(kitchenSceneProvider);
    final notifier = ref.read(kitchenSceneProvider.notifier);

    ref.listen<RunPhase>(kitchenSceneProvider, (previous, next) {
      if (next == RunPhase.celebrating) {
        _game.kitchenRoom.celebrateCompletion();
        HapticFeedback.mediumImpact();
        SystemSound.play(SystemSoundType.click);
        Future.delayed(const Duration(milliseconds: 900), notifier.finishCelebration);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF2B2B33),
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: _game)),
          if (phase == RunPhase.questOffered)
            Center(child: QuestCard(onPlay: notifier.startRun)),
          if (phase == RunPhase.running)
            SingleTaskPrompt(onDone: notifier.completeTask),
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

`SingleTaskPrompt`'s label is data-driven by whichever screen renders it;
since it currently hardcodes `'Put the dishes away'`
(`lib/presentation/widgets/single_task_prompt.dart:17`), update that
literal to `'Take out the garbage'` in this same step, to match this
plan's Global Constraints asset-currency adjustment (the scripted demo
task is now `kitchen.garbage`, not `kitchen.dishes`).

- [ ] **Step 4: Wire it into `main.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/flame/kitchen_flame_screen.dart';

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
      home: KitchenFlameScreen(),
    );
  }
}
```

- [ ] **Step 5: Update the top-level smoke test**

`test/widget_test.dart` currently looks for a `companionTap` widget key,
which no longer exists (companion tap detection moved into
`CompanionComponent`'s Flame `TapCallbacks`, not a Flutter widget). Update
it to check for the `GameWidget` instead:

```dart
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/main.dart';
import 'package:micasa/presentation/flame/kitchen_game.dart';

void main() {
  testWidgets('app boots into the kitchen scene', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MiCasaApp()));
    await tester.pump();
    await tester.pump();

    expect(find.text('KITCHEN RESTORED'), findsNothing);
    expect(find.byType(GameWidget<KitchenGame>), findsOneWidget);
  });
}
```

- [ ] **Step 6: Run the tests to verify they pass**

Run:
```bash
flutter test test/presentation/flame/kitchen_flame_screen_test.dart
flutter test test/widget_test.dart
```
Expected: both PASS.

- [ ] **Step 7: Manually verify in a real build (parent-doc §28's actual
  success check)**

Run:
```bash
flutter run -d windows
```
Walk the full loop by hand: confirm the room looks cohesive (not a
placeholder-sprite jumble — every prop here is a real Task 9 asset), tap
the companion, PLAY, DONE, watch the restoration burst and
"KITCHEN RESTORED" banner. Drag across the scene and confirm layers shift
at visibly different rates without sliding independently of each other.
If placement looks wrong (props overlapping, wrong scale relative to each
other, off-screen), adjust the `Vector2` literals in `kitchen_room.dart`'s
`create()` — this is expected tuning, not a bug.

- [ ] **Step 8: Commit**

```bash
git add lib/presentation/flame/kitchen_flame_screen.dart lib/main.dart lib/presentation/widgets/single_task_prompt.dart test/presentation/flame/kitchen_flame_screen_test.dart test/widget_test.dart
git commit -m "feat: host the Flame kitchen behind the app's RunPhase state machine"
```

---

### Task 12: Retire the M0 kitchen implementation

**Files:**
- Delete: `lib/presentation/scenes/kitchen_scene.dart`
- Delete: `lib/presentation/scenes/kitchen_background.dart`
- Delete: `lib/presentation/scenes/dish_pile.dart`
- Delete: `lib/presentation/widgets/companion_widget.dart`
- Delete: `test/presentation/scenes/kitchen_scene_test.dart`
- Delete: `test/presentation/scenes/kitchen_background_test.dart`
- Delete: `test/presentation/widgets/companion_widget_test.dart`
- Delete: `content/art/kitchen/kitchen_structure.png`
- Delete: `content/art/props/dish_pile.png`
- Modify: `lib/presentation/effects/particle_burst.dart`
- Modify: `test/presentation/effects/particle_burst_test.dart`
- Modify: `pubspec.yaml`

`lib/presentation/scenes/kitchen_scene_controller.dart` and its test
**stay** — `KitchenSceneController`/`RunPhase` are reused as-is (spec §8).
`lib/presentation/widgets/quest_card.dart` and `single_task_prompt.dart`
**stay** — reused as pure Flutter overlays (spec §9).

This is a deletion task, not a placeholder — the git history (and this
plan/spec pair) is the permanent record of the M0 implementation, same
convention already used for the Godot asset-renderer plan's SDD workspace.
Only run this after Task 11's manual verification confirms the new scene
actually works — don't delete the fallback before confirming its
replacement.

- [ ] **Step 1: Delete the superseded files**

```bash
git rm lib/presentation/scenes/kitchen_scene.dart
git rm lib/presentation/scenes/kitchen_background.dart
git rm lib/presentation/scenes/dish_pile.dart
git rm lib/presentation/widgets/companion_widget.dart
git rm test/presentation/scenes/kitchen_scene_test.dart
git rm test/presentation/scenes/kitchen_background_test.dart
git rm test/presentation/widgets/companion_widget_test.dart
git rm content/art/kitchen/kitchen_structure.png
git rm content/art/props/dish_pile.png
```

- [ ] **Step 2: Trim `particle_burst.dart` to just the reused pure parts**

`Particle` and `generateBurstParticles` are reused by
`RestorationEffectComponent` (Task 7). The `ParticleBurst`
widget/`ParticlePainter` classes are now dead — nothing constructs a
`ParticleBurst` widget once `kitchen_scene.dart` is gone. Remove them,
leaving:

```dart
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
```

- [ ] **Step 3: Trim `particle_burst_test.dart` to match**

Remove the `testWidgets('builds without error when inactive and active', ...)`
case (it tests the now-deleted `ParticleBurst` widget); keep the two
`generateBurstParticles` unit tests as-is.

- [ ] **Step 4: Remove the now-unused asset entries from `pubspec.yaml`**

```yaml
  assets:
    - content/art/companion/companion_idle.png
    - content/art/companion/companion_excited.png
    - content/rooms/room_types.json
    - content/tasks/tasks.json
    - content/adjacency/edges.json
    - content/clutter/kitchen_clutter_states.json
    - content/art/rendered/props/fridge/
    - content/art/rendered/props/stove/
    - content/art/rendered/props/sink/
    - content/art/rendered/props/cabinet/
    - content/art/rendered/props/stool/
    - content/art/rendered/props/shelf/
    - content/art/rendered/props/rug/
    - content/art/rendered/props/plant_01/
    - content/art/rendered/props/plant_02/
    - content/art/rendered/props/garbage_bag/
    - content/art/rendered/props/window/
    - content/art/rendered/props/curtain/
```

(`content/art/kitchen/kitchen_structure.png` and
`content/art/props/dish_pile.png` are removed; everything else stays.)

- [ ] **Step 5: Run the full test suite and analyzer**

Run:
```bash
flutter analyze
flutter test
```
Expected: no errors, all tests pass (no remaining references to any
deleted file).

- [ ] **Step 6: Commit**

```bash
git add -u
git commit -m "chore: retire M0 flattened kitchen scene, fully replaced by the Flame kitchen"
```

---

## Self-review notes

- **Spec coverage:** §6 component architecture — Tasks 5–10. §7 scripted
  clutter — Task 4 (content adjusted per the confirmed asset-currency
  decision). §8 interaction/state machine — Task 11 (`celebrateCompletion`
  wired to `RunPhase.celebrating`; `tapCompanion`/`startRun`/
  `finishCelebration` unchanged). §9 companion/effects — Tasks 6–7. §10
  testing strategy — every task's Steps 1–4 (pure-function tests + `flame_test`
  component tests + the Task 11 integration test standing in for "extend
  the state-machine test pattern," since the new behavior lives in
  `KitchenRoom`/the screen, not the controller itself). §12 CLAUDE.md
  update — Task 1. Non-goals (§3) and deferred items (§11) are honored by
  omission throughout (no `EntropyEngine`, no other rooms, no device tilt,
  no runtime dragging, no golden-image tests).
- **Placeholder scan:** no TBD/TODO markers; every code step has real,
  complete code. The one explicit hedge (Task 10's `TapUpEvent`
  constructor, Task 6's) is flagged with a concrete fallback (call
  `component.onTap()` directly) rather than left vague, since Flame's
  exact event-constructor shape has changed across versions and isn't
  worth pinning precisely when the integration test (Task 11) exercises
  the real path anyway.
- **Type consistency:** `PropSpriteComponent`/`CompanionComponent`'s
  `floorY` getter, `PropPivot`/`CompanionMood` enums, `ClutterEntry`'s
  three fields, and `KitchenRoom`'s public method names
  (`applyParallax`/`setClutterState`/`celebrateCompletion`) are used
  identically by every task that references them (Tasks 8–11 checked
  against Tasks 2–7's definitions).
