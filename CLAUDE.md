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
  questionnaire. (Updated 2026-08-26: a title screen with a real menu
  — Enter House / Settings — now precedes play on every launch; it
  collects nothing and is not a wizard. See spec §2.3 and
  `docs/superpowers/specs/2026-08-26-title-screen-house-hub-design.md`.)
- **Verification is by feel, not enforcement.** Reward elapsed active
  time, not checkbox count. No task completes itself.
- **Voice input ships in Phase 0:** done/next/skip/pause/five-more-minutes,
  on-device only.
- **AI is a rules engine in Phase 0**, not a model call. Never a chat box.
- **Household multiplayer will be free**, never premium, when it ships.
- **Name is MiCasa.** (Originally drafted as "Hearthbound" — renamed;
  see `docs/micasa_spec.md` history if trademark context is needed. The
  direction doc still carries the old name in its filename.)
- **One finished illustration per room**, never a constructed set of
  furniture sprites. Neglect drains *vitality* (colour, warmth, ambient
  motion) — it never makes the room ugly. Direction doc §1, §7.

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

Flutter + Rive + Riverpod + Drift/SQLite. Local-first, no backend, no
login, no sync in Phase 0. (The direction doc lists Supabase/go_router/
RevenueCat — those are post-Phase-0 and out of scope here.)

**Rendering is plain Flutter, not a game engine.** See
`docs/hearthbound_interactive_storybook_direction.md` — the settled
direction is a *point-and-click interactive storybook*: one finished
illustration per room, plus invisible hotspots, a few state overlays, and
the companion, composed with `Stack`/`Positioned`/`Animated*`.

Superseded on 2026-08-24: the Flame engine runtime (`lib/presentation/
flame/`, 8 parallax layers, depth sorting) and the Godot→sprite pipeline
(`tools/asset_renderer/`). Both were removed from the room path.
`docs/superpowers/specs/2026-08-24-flame-kitchen-runtime-design.md` and
its plan describe the retired approach — do not implement from them.

Do not rebuild rooms out of individual furniture sprites. The painting
already encodes perspective, lighting, and occlusion; hand-compositing
props re-creates every problem it solved (see direction doc §21–22).

Note: `sqlite3_flutter_libs` is intentionally **not** a dependency — it's
EOL. Drift 2.32+ bundles SQLite automatically; use `NativeDatabase`
(`package:drift/native.dart`), not the deprecated `FlutterQueryExecutor`.

## Environment notes

- Flutter SDK lives at `C:\flutter` (installed via `git clone -b stable`,
  not the installer). Run `flutter doctor` if commands behave
  unexpectedly.
- Windows desktop and Android builds both work end to end (`flutter
  build windows --debug`, `flutter build apk --debug` have been
  verified). Web is unset up and out of scope — Chrome isn't installed
  and the project doesn't target web; ignore `flutter doctor`'s Chrome
  warning.
- Android SDK is at `%LOCALAPPDATA%\Android\sdk`, installed via
  Android Studio + manually added cmdline-tools (`sdkmanager` needs
  `JAVA_HOME` pointed at Android Studio's bundled JBR, e.g.
  `C:\Program Files\Android\Android Studio\jbr`, since no standalone JDK
  is installed). `flutter doctor` reports "Some Android licenses not
  accepted" — this is about unused legacy addon licenses (preview,
  ARM DBT, Google GDK/TV, Intel/MIPS system images), not the ones that
  matter; `android-sdk-license` is accepted and real builds succeed.
  `flutter doctor --android-licenses` and `sdkmanager --licenses` can't
  be driven interactively in this environment (piped stdin doesn't
  reach the prompt) — if it's ever needed, run it in an actual
  interactive terminal.
- `rive_native` applies its own Kotlin Gradle Plugin (KGP) directly,
  which the `flutter build apk` output flags as deprecated — a future
  Flutter version may refuse to build until upstream `rive_native`
  migrates to Built-in Kotlin. Not an issue today; worth checking for
  a `rive`/`rive_native` upgrade if Android builds ever start failing
  with a KGP-related error.
- Godot 4.7.1 lives at `C:\Godot\`. Two Windows binaries exist:
  `Godot_v4.7.1-stable_win64.exe` (GUI subsystem — use for interactive
  editor sessions) and `Godot_v4.7.1-stable_win64_console.exe` (console
  subsystem — **required** for `--headless` runs where `print()` output
  must reach the terminal; the GUI binary silently swallows it). Used by
  `tools/asset_renderer/` (see
  `docs/superpowers/plans/2026-08-24-godot-asset-renderer.md`).
