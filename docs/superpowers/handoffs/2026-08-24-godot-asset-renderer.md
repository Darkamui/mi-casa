# Handoff: Godot Asset Renderer plan — status and next steps

## Status: merged

`docs/superpowers/plans/2026-08-24-godot-asset-renderer.md` — all 7 tasks
done, whole-branch review done, fix wave applied, scoped re-review clean.
The SDD workspace (`.superpowers/sdd/2026-08-24-godot-asset-renderer/`)
was deleted per the subagent-driven-development skill's convention
("final review clean: delete this plan's workspace") — there is nothing
left to resume there.

**PR:** https://github.com/Darkamui/mi-casa/pull/3 — merged into
`master` as commit `8254f1b`. Source branch
`worktree-godot-asset-renderer` (forked from `master` at `6e7ec65`) has
been deleted on the remote; its tip was `1e44ec1`.

## What shipped

- `tools/asset_renderer/` — a Godot 4 dev-time GUI tool. Human drives the
  editor interactively (import FBX → place under `ModelRoot` → Play →
  type export name → Export PNG). Pure AABB/pivot/framing math lives in
  `scripts/renderer_math.gd` (headlessly tested); scene/signal wiring in
  `scripts/renderer_controller.gd`.
- `content/art/rendered/props/` — 13 rendered kitchen sprites, committed.
  This is a **fixed interface** the future Flutter kitchen presentation
  layer will consume. That work is "Spec B" —
  `docs/superpowers/specs/2026-08-24-flame-kitchen-runtime-design.md`,
  status "approved for planning" — see "Next step" below.
- Three escape-hatch checkboxes in the tool's UI for framing exceptions:
  Wall mount, Floor covering (rug/carpet), Key light off (shadow pass).
  All three are now documented in `tools/asset_renderer/README.md`.

## What's deliberately deferred (not blockers, logged and documented)

**11 kitchen checklist items have no matching FBX** anywhere in
`content/art/Ultimate House Interior Pack - June 2020/FBX/`: `mug`,
`island`, `jar`, `kettle`, `picture`, `dish_stack_small`,
`dish_stack_large`, `pan`, `crumbs`, `wall`, `floor`. Documented per-row
in `tools/asset_renderer/README.md`'s checklist table (status column).
Per the carried-forward standing instruction, the user is generating
proper art assets separately — these likely get resolved from that
pipeline rather than the Quaternius pack. Re-run the tool's normal
workflow for each once a source model exists; no code change needed.

**From the final whole-branch review** (found 1 Critical — fixed — + 7
Important + 10 Minor; the review report itself was deleted with the SDD
workspace, but the substance is preserved in commit messages `1936f99`
and `1e44ec1`). Fixed before merge: the critical scene/gitignored-FBX bug
(with a regression-guard test), an AABB-timing bug in live model
placement, and two README documentation gaps. **Explicitly deferred as
backlog, not fixed:**

- Emit a machine-readable manifest alongside each PNG recording pivot
  pixel, pivot mode, ortho size, and source FBX — the review's
  highest-leverage recommendation for making the Spec B interface
  self-describing instead of tribal knowledge (README table + code
  comments only, today).
- Extract `align_current_model`'s camera-placement math out of
  `renderer_controller.gd` into `renderer_math.gd` as a pure, testable
  function — flagged as high-value since this exact logic regressed
  five separate times during implementation and currently has zero
  direct test coverage (the pure math functions it calls are tested;
  the composition that picks camera size/position per pivot mode is
  not).
- `_folder_for()` (the function that defines the on-disk folder
  interface) should be static and live in `renderer_math.gd` per the
  branch's own pure/impure split rule; currently untested.
- Export has no guard against an empty/degenerate `ModelRoot` (silently
  writes a fully-transparent PNG) and prints a false "exported" success
  message on save failure.
- Several Minor polish items: wall-mode has no clip-detection margin
  check, hardcoded viewport aspect assumption in the floor-covering
  branch, duplicated 8-corner AABB enumeration, Wall-mount + Floor-
  covering checkboxes can both be checked simultaneously (meaningless
  combination), uncropped 1024² canvas per sprite (~4MB decoded each).

None of these affect correctness of what's already rendered and
committed — they're real follow-up work, not silent gaps.

## Next step

The Godot Asset Renderer was scaffolding/infrastructure for a larger
piece of work: rebuilding the kitchen scene in Flutter using Flame +
these rendered sprites as layered components. That work already has an
**approved spec** — "Spec B",
`docs/superpowers/specs/2026-08-24-flame-kitchen-runtime-design.md`,
status "approved for planning". It defines the full component
architecture (`lib/presentation/flame/` — `KitchenGame`, `KitchenRoom`, 8
layers, `PropSpriteComponent`, depth-sort, parallax, scripted clutter
state loaded from `content/clutter/kitchen_clutter_states.json`), reuses
M0's `KitchenSceneController` state machine as-is, and calls for the
CLAUDE.md "no Flame" line to be updated as part of its own
implementation. **What's missing is the implementation plan** — no
task-by-task breakdown exists yet in `docs/superpowers/plans/`, and no
worktree/branch/code has started against it.

Next action: write the implementation plan for Spec B via
`superpowers:writing-plans`, reading the spec in full first — not a
fresh `superpowers:brainstorming` pass, since the spec is already
approved. Before planning, worth confirming with the user that the spec
is still current given their separate art-generation work in the interim
(spec §4 notes the final visual-validation step waits on Spec A having
rendered "at least a handful" of PNGs — fridge, stove, sink, a dish
stack — which this branch's 13 rendered sprites now satisfy, though 11
checklist items, listed above, are still unrendered). Also worth
reconciling against `docs/superpowers/plans/2026-08-24-m0-wow-prototype.md`
and its completed implementation on `worktree-m0-wow-prototype` — Spec B
explicitly says "M0's kitchen is fully replaced" (§1), so that
plan/branch becomes reference-only once Spec B's plan executes.

## Where to look if you need more detail than this handoff

- `docs/superpowers/plans/2026-08-24-godot-asset-renderer.md` — the
  finished plan, all 7 tasks.
- `docs/superpowers/specs/2026-08-24-godot-asset-renderer-design.md` —
  the spec it implemented.
- `tools/asset_renderer/README.md` — current, accurate tool docs
  (workflow, checklist status, all three checkbox escape hatches).
- `git log --oneline 6e7ec65..1e44ec1` — full commit history for the
  merged branch, 18 commits, descriptive messages throughout.
- PR #3 on GitHub — https://github.com/Darkamui/mi-casa/pull/3
