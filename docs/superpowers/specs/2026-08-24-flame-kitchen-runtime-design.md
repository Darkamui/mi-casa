# Flame Kitchen Runtime — Design

**Status:** approved for planning
**Parent doc:** `docs/hearthbound_2_5d_quaternius_handoff.md` (read in full —
this spec implements that doc's §14, §16, §18–§24, §28, and the relevant
parts of §33, "Spec B" of a two-spec split; the Godot asset-rendering side
is a separate spec, "Spec A":
`docs/superpowers/specs/2026-08-24-godot-asset-renderer-design.md`)

## 1. Context

The project is adopting a 2.5D diorama visual direction (see the parent
doc and Spec A). Spec A covers turning Quaternius 3D models into
consistently-rendered transparent PNG sprites. This spec covers the other
half: assembling those sprites into a living, interactive kitchen scene
in Flutter, using Flame as the rendering/composition engine.

### Decisions carried in from brainstorming (2026-08-24)

- **Full interaction loop, not just static composition.** This spec
  rebuilds the same tap → task → DONE → transformation loop M0 already
  proved (`lib/presentation/scenes/kitchen_scene.dart` and
  `kitchen_scene_controller.dart`), on the new Flame + layered-sprite
  foundation. This matches the parent doc's own §28 "Prototype Goal" —
  proving the interaction feels premium is the actual success criterion,
  not just proving the room looks good statically.
- **Scripted demo clutter state, not real data wiring.** The scene is
  driven by a hardcoded/scripted clutter state (see §4 below), not M1's
  `EntropyEngine` or M2's Drift DAOs. Wiring real entropy/persistence
  data into the visual layer is a later milestone (roughly the roadmap's
  M6). This mirrors the parent doc's own scoping advice (§27: "Build one
  excellent room first").
- **M0's kitchen is fully replaced.** `kitchen_scene.dart`,
  `kitchen_background.dart`, `dish_pile.dart`, and the flattened
  `content/art/kitchen/*.png` set become reference-only, per Spec A's
  same decision applied to the presentation layer. `companion_widget.dart`,
  `quest_card.dart`, `single_task_prompt.dart`, and `particle_burst.dart`
  are reused (in modified form — see §5) rather than replaced, since
  they're either pure UI chrome or map directly onto Flame components.
- **Flame is the settled rendering engine.** CLAUDE.md's prior "No Flame
  unless a spike proves plain Flutter + CustomPainter insufficient" is
  superseded. Updating CLAUDE.md to reflect this is part of this spec's
  own implementation (see §8).

## 2. Goal

Rebuild the kitchen scene as a layered 2.5D Flame diorama, composed from
individually-controllable sprite components rather than flattened room
images, with the same tap-companion → do-task → DONE → room-transforms
interaction loop M0 already validated — now backed by real depth sorting,
subtle parallax, and a content-driven clutter system.

## 3. Non-goals

- Wiring M1's `EntropyEngine` or M2's Drift DAOs into the scene. The
  clutter state is scripted/hardcoded this pass.
- Rooms other than the kitchen.
- Device-tilt-driven parallax (parent doc §18 explicitly makes tilt
  optional, not mandatory — drag is the primary trigger).
- Runtime object dragging or room-editing by the player.
- Golden-image/pixel-diff testing — visual correctness is validated by a
  human, same as Spec A's own approach.
- Rendering the actual sprite assets — that's Spec A's job. This spec's
  components work against placeholder sprites until Spec A produces real
  ones.

## 4. Dependency on Spec A

This spec's component architecture (layers, depth sort, parallax, state
machine, content loading) can be built and tested against placeholder
sprites (flat-color `Sprite`s generated in code) immediately — it does
not need to wait on Spec A.

Looking at a real assembled scene, however, needs at least a handful of
Spec A's rendered PNGs — fridge, stove, sink, a dish stack — per Spec A's
own "Relationship to Spec B" section. The implementation plan for this
spec sequences component-building-against-placeholders before
swap-in-real-sprites, and the final visual validation step (parent doc
§28's actual success check) waits on Spec A having rendered at least that
minimum set.

## 5. New dependencies

Added to `pubspec.yaml`:

- **`flame`** — the game engine: `FlameGame`, `Component`,
  `PositionComponent`, `SpriteComponent`, tap/drag input, the
  `GameWidget` used to host the game inside the normal Flutter widget
  tree.
- **`flame_test`** (dev dependency) — `FlameTester`/`testWithFlameGame`,
  used to test component wiring headlessly, without a real device or
  rendering.

## 6. Component architecture

```
lib/presentation/flame/
├── kitchen_game.dart              — FlameGame subclass; owns the World,
│                                     camera, drag input
├── kitchen_room.dart              — root Component; builds the 8 layers
│                                     as children, in order
├── layers/
│   ├── back_layer.dart            — wall, window, curtain
│   ├── furniture_layer.dart       — fridge, stove, cabinets, sink, shelves
│   ├── mid_layer.dart             — island, table, stools
│   ├── decor_layer.dart           — plants, rug, jars, pictures
│   ├── entropy_layer.dart         — dishes, mug, crumbs, trash — driven
│   │                                 by the scripted clutter state
│   ├── character_layer.dart       — companion
│   ├── effects_layer.dart         — particles, restoration FX
│   └── foreground_layer.dart      — empty for kitchen initially, kept
│                                     for convention/future rooms
├── components/
│   ├── prop_sprite_component.dart — generic SpriteComponent wrapper:
│   │                                 floor-contact pivot anchor, exposes
│   │                                 floorY for depth sort
│   └── companion_component.dart   — Flame version of the companion:
│                                     moods, tap handling, lives in
│                                     CharacterLayer
├── clutter_state_loader.dart      — loads content/clutter/kitchen_clutter_states.json
├── depth_sort.dart                — pure function: List<(id, floorY)> ->
│                                     priority assignment
└── parallax_controller.dart       — pure function: drag delta + per-layer
                                      rate -> clamped offset
```

`PropSpriteComponent` is the one reusable building block — every
furniture/decor/entropy sprite is an instance of it, configured with an
asset path and a pivot mode (`floorContact` default, matching Spec A's
pivot convention; `verticalCenter` for wall-mounted assets like the
window/picture/curtain). `KitchenRoom` composes the 8 layers; each layer
is a `PositionComponent` holding a list of `PropSpriteComponent`s (or, for
`CharacterLayer`, the single `CompanionComponent`; for `EffectsLayer`,
particle/restoration components).

### Depth sorting

Computed once at composition time, not per-frame — Phase 0 has no
runtime object dragging, so priorities don't need to be recomputed every
tick. `depth_sort.dart` is a pure function, same testing philosophy as
`lib/simulation/`: given each prop's floor-contact Y, assign Flame
`priority` values so smaller Y renders first (parent doc §19). Layer
order gives coarse control; depth-sort refines ordering within and across
layers where the doc calls for it (companion in front of table, chair
behind table, etc.).

### Parallax

Subtle and drag-driven (not device tilt). `KitchenGame` tracks a small
drag-offset vector from pan gestures on the `GameWidget`.
`parallax_controller.dart` is a pure function mapping (drag offset,
per-layer rate — the parent doc's §18 example table: background 0.15x,
back furniture 0.30x, mid furniture 0.50x, characters 0.65x, foreground
0.80x) to a clamped per-layer render offset, testable without a running
Flame instance. Offset springs back to zero on release.

## 7. Scripted clutter state

Per CLAUDE.md's content-driven rule, the clean→disaster composition from
parent-doc §16 is data, not code — new file
`content/clutter/kitchen_clutter_states.json`, sibling to the existing
`content/rooms/room_types.json` pattern:

```json
{
  "pristine": [],
  "normal": [
    { "layer": "entropy", "sprite": "dish_stack_small", "anchor": "sink" }
  ],
  "messy": [
    { "layer": "entropy", "sprite": "dish_stack_large", "anchor": "sink" },
    { "layer": "entropy", "sprite": "mug", "anchor": "counter" },
    { "layer": "entropy", "sprite": "pan", "anchor": "counter" }
  ],
  "disaster": [
    { "layer": "entropy", "sprite": "dish_stack_large", "anchor": "sink" },
    { "layer": "entropy", "sprite": "garbage_bag", "anchor": "floor" },
    { "layer": "entropy", "sprite": "crumbs", "anchor": "floor" }
  ]
}
```

`clutter_state_loader.dart` parses this file — parallel in shape to
`lib/simulation/content_loader.dart`, but living in `lib/presentation/`
since it maps state names directly to sprite asset names, which
`lib/simulation/` must never know about (the architectural boundary in
CLAUDE.md is unaffected: `lib/simulation/` still never imports
`lib/presentation/`, and this loader lives entirely on the presentation
side). `anchor` keys resolve to fixed placement points defined alongside
the kitchen layout — hardcoded per-anchor `Offset`s for now, since Phase
0 has exactly one room layout.

## 8. Interaction and state machine

M0's `RunPhase` enum and `KitchenSceneController`
(`idle → questOffered → running → celebrating → restored`) already match
the parent doc's §28 flow exactly and are reused as-is, just re-hosted.
The scripted demo starts at a fixed non-pristine clutter state (e.g.
`"messy"`) instead of starting clean, so there's visible mess for the
player to clear:

- `tapCompanion` → `questOffered`: unchanged behavior, still a Flutter
  overlay (`QuestCard`) shown via `GameWidget`'s `overlayBuilderMap`.
- `startRun` → `running`: unchanged, `SingleTaskPrompt` overlay.
- `completeTask` → `celebrating`: **new behavior** — `EntropyLayer` swaps
  the active clutter state straight to `pristine` (the scripted demo
  models a single task — "clean the kitchen" — not per-object task
  tracking, so completion clears everything at once), `EffectsLayer`
  plays a restoration burst positioned at the relevant anchor (e.g. the
  sink), `CharacterLayer`'s `CompanionComponent` mood flips to
  celebrating.
- `finishCelebration` → `restored`: unchanged timing/haptic pattern from
  M0 (`HapticFeedback.mediumImpact()`, `SystemSound.play`, delayed
  transition).

## 9. Companion and effects treatment

`CompanionWidget` (currently a Flutter `Positioned` widget with a
`GestureDetector`) becomes `CompanionComponent`, a Flame component living
in `CharacterLayer` — so it participates in depth-sort and parallax like
the parent doc requires ("positioned within the Flame world," §24). It
keeps its existing mood parameter (idle/celebrating for this pass — the
doc's full 6-state repertoire — idle/happy/excited/concerned/
thinking/tired — stays available as existing companion art assets but
isn't all wired to scene events yet); the tap target becomes Flame's tap
detection instead of a Flutter `GestureDetector`.

`ParticleBurst` similarly moves into `EffectsLayer` as a Flame component
instead of a `Stack`-positioned Flutter widget — it needs a world
position (at the restoration anchor), not a screen position.

`QuestCard` and `SingleTaskPrompt` stay pure Flutter overlays — they're
UI chrome (cards, buttons, text), not diorama objects, and Flame's
overlay system exists precisely for this split between world content and
UI chrome.

## 10. Testing strategy

- **Pure functions** (`depth_sort.dart`, `parallax_controller.dart`,
  `clutter_state_loader.dart`'s parsing logic) get plain `flutter_test`
  unit tests, no Flame runtime involved — same pattern already
  established for `lib/simulation/`.
- **Flame components** (`PropSpriteComponent`, `CompanionComponent`,
  layer composition, `KitchenRoom`) get component tests via
  `flame_test`'s `FlameTester`/`testWithFlameGame`, verifying children
  are added correctly, priorities are assigned as expected, and taps
  route to the right callback — without a real device or rendered
  output.
- **State machine** (`KitchenSceneController`): the existing
  `kitchen_scene_controller_test.dart` pattern extends to cover the new
  clutter-state transition on `completeTask`.
- **No golden-image/pixel tests** this pass. Visual correctness is a
  human check, per Spec A's own validation approach (look at a few
  assembled results together) — not automatable without real rendered
  sprites regardless.
- **Placeholder sprites during development:** before Spec A renders real
  PNGs, `PropSpriteComponent` tests and early manual runs use flat-color
  `Sprite`s generated in code (e.g. `Sprite` backed by a solid-color
  `Image`) — never fake image files — so component wiring can be
  verified before art exists.

## 11. Out of scope / deferred

- Real M1/M2 data wiring (`EntropyEngine`, Drift DAOs) — scripted state
  only, this pass. Becomes its own milestone later (roadmap's M6-ish
  territory).
- Rooms other than kitchen.
- Device-tilt parallax (parent doc explicitly makes it optional).
- Runtime object dragging/repositioning by the player (depth-sort is
  computed once at composition, not per-frame).
- Clutter states beyond the 4 in parent-doc §16
  (`pristine`/`normal`/`messy`/`disaster`) — that set is enough to prove
  the pipeline.
- Full 6-state companion mood wiring (concerned/thinking/tired stay
  unused this pass, though the art assets already exist).
- Color/material variant swapping (parent doc §26) — a Spec A concern if
  it ever happens, not this spec's.

## 12. CLAUDE.md update

As part of this spec's own implementation (not deferred elsewhere), the
"Stack" section's line —

> No Flame unless a spike proves plain Flutter + `CustomPainter`
> insufficient (spec §5.3).

— gets replaced with something reflecting Flame as the settled rendering
engine for room presentation, consistent with the parent doc's §1 and
§30 ("Current Tech Stack Remains Valid" / Flame is already listed there).
