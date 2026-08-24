# MiCasa

Source of truth for product/UX: `docs/micasa_spec.md`. Read it in full
before implementing anything. This file is a guardrail summary, not a
replacement for it.

## Locked decisions (spec §2) — do not renegotiate mid-implementation

- **Art direction:** illustrated 2D, layered sprites with parallax, not 3D.
- **No percentages in the UI.** Coarse verbal states only (Thriving /
  Comfortable / Slipping / Struggling / Critical). Floats may exist
  internally.
- **Onboarding is playable, not configured.** No account, no wizard, no
  questionnaire on first open.
- **Verification is by feel, not enforcement.** Reward elapsed active
  time, not checkbox count. No task completes itself.
- **Voice input ships in Phase 0:** done/next/skip/pause/five-more-minutes,
  on-device only.
- **AI is a rules engine in Phase 0**, not a model call. Never a chat box.
- **Household multiplayer will be free**, never premium, when it ships.
- **Name is MiCasa.** (Originally drafted as "Hearthbound" — renamed;
  see `docs/micasa_spec.md` history if trademark context is needed.)

## Architectural rule (non-negotiable)

`lib/simulation/` (entropy, task selection, combo resolution, adaptive
learning) is pure and headlessly testable. It never imports from
`lib/presentation/`. The world is a renderer of application state, never
the canonical store. Task selection, entropy, and combo resolution must
be pure functions over state — write tests for them without the render
layer.

**Feedback never waits on I/O.** DONE -> local state update -> animation,
haptic, sound, particles -> *then* any background work. Never DONE ->
request -> spinner -> response -> animation.

## Content-driven

Room types, tasks, adjacency edges, degradation overlays, and copy live
in `content/` as data files, not code. Adding a room type must not
require a code change.

## Current phase: Phase 0 only

Build only what's in spec §5.2. Do **not** implement anything from §6
(resources, upgrade trees, residents, boss chores, raids, achievements,
co-op) or §7 (themes, seasons, NFC, camera analysis, smart-home hooks,
multiple homes) until Phase 0 passes its kill criteria (spec §5.5).

## Stack

Flutter + Rive + Riverpod + Drift/SQLite. No Flame unless a spike proves
plain Flutter + `CustomPainter` insufficient (spec §5.3). Local-first,
no backend, no login, no sync in Phase 0.

Note: `sqlite3_flutter_libs` is intentionally **not** a dependency — it's
EOL. Drift 2.32+ bundles SQLite automatically; use `NativeDatabase`
(`package:drift/native.dart`), not the deprecated `FlutterQueryExecutor`.

## Environment notes

- Flutter SDK lives at `C:\flutter` (installed via `git clone -b stable`,
  not the installer). Run `flutter doctor` if commands behave
  unexpectedly.
- Android SDK and Chrome are not installed on this machine — Android and
  web build/run targets are unavailable until those are set up. Windows
  desktop (Visual Studio + C++ workload) is available.
- Windows Developer Mode may not be enabled, which blocks the plugin
  symlink step required for `flutter build windows` / `flutter run -d
  windows`. `flutter analyze` and `flutter test` work regardless.
