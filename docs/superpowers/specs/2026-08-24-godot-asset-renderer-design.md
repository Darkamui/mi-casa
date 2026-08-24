# Godot Asset Renderer — Design

**Status:** approved for planning
**Parent doc:** `docs/hearthbound_2_5d_quaternius_handoff.md` (read in full —
this spec implements that doc's §5–§13 and §27, "Spec A" of a two-spec
split; the Flame/Flutter runtime side is a separate spec, "Spec B",
brainstormed independently)

## 1. Context

The project is adopting a 2.5D diorama visual direction: Quaternius 3D
household models (`content/art/Ultimate House Interior Pack - June
2020/`, already imported) become the source library for room props,
rendered through one locked camera/lighting/material setup into
consistent, transparent 2D PNG sprites. Those sprites are what the
shipped Flutter app actually loads — the 3D pipeline is a
development-time tool only, never bundled with the app.

This spec covers **only the rendering tool and its output
conventions** — a Godot 4 project that turns one Quaternius model into
one correctly-scaled, correctly-pivoted, transparent PNG at a time.
Assembling those PNGs into a living Flutter/Flame room is out of scope
here (Spec B).

### Decisions carried in from brainstorming (2026-08-24)

- **Flame is now the settled rendering engine** for the Flutter app,
  superseding CLAUDE.md's prior "no Flame without a spike" guardrail.
  CLAUDE.md gets updated to reflect this as part of Spec B's
  implementation (not this one, which doesn't touch the Flutter app).
- **Supabase / RevenueCat stay deferred** past Phase 0. CLAUDE.md's
  local-first/no-backend Phase 0 rule is unchanged by this doc.
- **M0's existing hardcoded kitchen is fully replaced**, not kept
  running in parallel. The existing AI-generated `content/art/kitchen_*.png`
  set becomes reference-only, per the parent doc's own guidance
  (§33 step 2).
- **Tool ownership split:** this spec's deliverable (the Godot project,
  scene rig, and conventions) is built by the implementer. Actually
  opening Godot, placing each model, and clicking export is a human
  task — a GUI 3D viewport isn't something to drive headlessly. The
  spec's job is to make that human task as close to mechanical as
  possible: open project, drag in model, hit export, repeat.
- **Scope: kitchen only, ~20 assets, single-model-at-a-time export.**
  Batch automation is explicitly deferred until the pipeline is proven
  on one room (parent doc §27, §33 step 6).

## 2. Goal

Produce one Godot 4 utility project that renders any single Quaternius
FBX model into a transparent-background PNG sprite, with camera angle,
lighting, material treatment, scale, and pivot locked identically
across every asset — so the resulting sprite library looks like it
belongs to one cohesive world, not twenty independent renders.

## 3. Non-goals

- Batch/scripted conversion of multiple models in one run.
- Rendering rooms other than the kitchen.
- Any Flutter/Flame/Dart code — that's Spec B.
- Photorealistic or heavily stylized (toon-outline) rendering — the
  parent doc explicitly asks for neither.
- Color/material variant generation (parent doc §26) — noted as a
  future extension of this same tool, not built now.

## 4. Project structure

```
tools/asset_renderer/                  (Godot 4 project, not shipped)
├── project.godot
├── models/                            (imported FBX files, git-ignored
│                                        or symlinked from content/art/)
├── scenes/
│   └── asset_renderer.tscn
│       ├── ModelRoot (Node3D)         — one model placed here at a time
│       ├── Camera3D                   — fixed orthographic rig
│       ├── DirectionalLight3D         — warm key light
│       ├── WorldEnvironment           — soft ambient fill, transparent bg
│       └── SubViewport                — offscreen render target, alpha on
├── scripts/
│   └── renderer_controller.gd         — auto-fit framing + export action
└── README.md                          — the human workflow (§7 below)
```

Output PNGs are written directly into the Flutter project's content
tree, at:

```
content/art/rendered/props/
├── fridge/fridge_000.png
├── stove/stove_000.png
├── sink/sink_000.png
├── cabinet/cabinet_000.png
├── cabinet/cabinet_045.png            (second orientation, same model)
├── island/island_000.png
├── stool/stool_000.png
├── shelf/shelf_000.png
├── rug/rug_000.png
├── plant/plant_01_000.png
├── plant/plant_02_000.png
├── jar/jar_000.png
├── kettle/kettle_000.png
├── picture/picture_000.png
├── dish_stack/dish_stack_small_000.png
├── dish_stack/dish_stack_large_000.png
├── mug/mug_000.png
├── pan/pan_000.png
├── crumbs/crumbs_000.png
├── garbage_bag/garbage_bag_000.png
├── wall/wall_000.png
├── floor/floor_000.png
├── window/window_000.png
└── curtain/curtain_000.png
```

This is the full initial kitchen asset checklist (parent doc §27),
kept here as the literal task list for Spec A's implementation plan.
Multi-orientation assets (chairs, cabinets, etc.) get a second render
pass with the model rotated in `ModelRoot`, exported under a
`_045`/`_090` suffix — same convention, no separate tooling.

## 5. Locked render conventions

These are configured once on the scene/script and never touched per-asset:

- **Camera:** orthographic projection, fixed elevated 3/4 angle (exact
  degrees tuned visually during implementation, then hard-locked —
  no per-asset camera changes, ever).
- **Lighting:** single `DirectionalLight3D` as warm key light from
  upper-left/front-left, soft ambient fill from `WorldEnvironment`,
  soft shadows. If a given asset's shadow reads badly composited
  later, the controller supports an optional second export pass with
  the light disabled, written as `<name>_shadow.png` alongside the
  `<name>_color.png` — this is a per-asset *option* the human invokes,
  not a default.
- **Material treatment:** reduced specular harshness, controlled
  saturation, no cartoon outline, no photorealism push. Applied via a
  shared environment/material override so it's consistent without
  per-model tweaking.
- **Background:** fully transparent (`SubViewport` alpha enabled, no
  baked checkerboard).
- **Scale:** `RendererController` computes each model's AABB on load
  and frames it against a shared virtual ground plane, so relative
  real-world scale is preserved automatically (fridge renders larger
  than a mug without hand-tuning either).
- **Pivot:** bottom-center, where the object meets the ground plane —
  the controller aligns the model's floor-contact point to a fixed
  canvas anchor before export. Wall-mounted assets (picture, window,
  curtain) use a documented alternate anchor (vertical-center) instead,
  called out explicitly in the README per-asset.
- **Padding:** the export canvas is larger than the tightest bounding
  box by a fixed margin, so nothing clips and downstream compositing
  in Flame has breathing room.

## 6. `RendererController` responsibilities

A single GDScript attached to the render scene:

1. On a model being placed under `ModelRoot`, compute its AABB.
2. Position/scale the camera framing so the model sits correctly on
   the shared ground plane at the locked angle (this is the "auto-fit"
   step — it adjusts *framing*, never the locked camera angle itself).
3. Align the model so its floor-contact point lands on the canvas
   pivot anchor.
4. On export trigger (a button in-editor, or a keyboard shortcut), render
   the `SubViewport` to an `Image` and save it as PNG to a path built
   from a name/orientation the human types into an export field.

No batch queue, no CLI — this is an in-editor tool a person drives
interactively, per the confirmed single-model-at-a-time scope.

## 7. Human workflow (goes in the tool's README)

1. Open `tools/asset_renderer` in Godot 4.
2. Import the target FBX from the Quaternius pack (drag from
   `content/art/Ultimate House Interior Pack - June 2020/FBX/` into
   the Godot project, or reference it directly if Godot's importer
   handles external paths).
3. Instance it under `ModelRoot` in the render scene.
4. Confirm framing looks correct in the viewport (it should, via
   auto-fit — this is a sanity check, not manual adjustment).
5. Type the export name (e.g. `fridge`, `cabinet_045`) and trigger
   export.
6. Remove the model from `ModelRoot`, repeat for the next asset on the
   checklist (§4 above).
7. For assets needing a second orientation, re-instance the same
   model, rotate it in `ModelRoot`, export under the `_045`/`_090`
   suffix.

## 8. Validation

No automated tests — this is a visual authoring tool, not application
logic. Validation is manual: render the first 2–3 assets (e.g. fridge,
stove, mug), view them together, confirm scale relative to each other
reads correctly, pivot/floor-contact aligns, lighting direction and
warmth match the target mood, background is cleanly transparent. Only
once that check passes does the rest of the kitchen checklist get
rendered.

## 9. Relationship to Spec B

Spec B (Flame runtime + room composition) consumes this spec's output
folder (`content/art/rendered/props/<name>/<name>_<orientation>.png`)
and its pivot convention (bottom-center floor contact, alternate
vertical-center for wall-mounted) as a fixed interface. Spec B can be
designed against this interface before every asset is rendered, but
its Flutter/Flame implementation work needs at least a handful of real
rendered sprites (fridge, stove, sink, a dish stack) to build and look
at the first assembled scene against.

## 10. Out of scope / deferred

- Batch conversion of the full Quaternius library (parent doc §5,
  "should eventually support batch conversion" — not now).
- Non-kitchen rooms.
- Color/material variant rendering (parent doc §26).
- Any Flutter, Flame, or Dart code.
