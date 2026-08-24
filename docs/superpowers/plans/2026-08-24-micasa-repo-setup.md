# MiCasa Repo & Environment Setup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the empty `mi-casa` directory into a working, git-tracked Flutter project scaffold for MiCasa, with the product spec renamed and copied in, the simulation/presentation architectural boundary in place from the first commit, and a `CLAUDE.md` guardrail file so future sessions don't relitigate locked decisions.

**Architecture:** Flat repo layout — the Flutter project root *is* the repo root. `docs/` holds specs and plans alongside it. `lib/` splits into `simulation/` (pure, headless game logic) and `presentation/` (rendering/animation/audio), per the spec's non-negotiable architectural rule. `content/` holds room/task/adjacency/copy data files, kept out of code per the spec's "content-driven" requirement.

**Tech Stack:** Flutter (stable channel) + Dart, Riverpod (state), go_router (peripheral-screen routing only), Rive (state-driven animation), Drift + sqlite3_flutter_libs (local persistence). No Flame at this stage.

**Spec:** `docs/superpowers/specs/2026-08-24-micasa-project-setup-design.md` (this plan's design doc). Product/UX source of truth after Task 2: `docs/micasa_spec.md`.

## Global Constraints

- Stack is locked: Flutter + Rive + Riverpod + Drift/SQLite (design doc §2.4; spec §5.3). Do not substitute.
- No Flame added at this stage (spec §5.3) — only if a later wow-prototype spike proves plain Flutter + `CustomPainter` insufficient.
- Local-first, no backend, no network calls except optional future crash reporting (spec §5.3).
- `simulation/` code must never import from `presentation/` (design doc §2.4) — this is the architectural boundary the whole project's future testability depends on.
- Content-driven: room types, tasks, adjacency graph, degradation overlays, and copy live in `content/` data files, never hardcoded in Dart (spec §5.3).
- Package/bundle identifier: `com.micasa.app` (design doc §2.2).
- Scope is Phase 0 only (spec §5.2). Do not scaffold anything from spec §6/§7 (resources, upgrade trees, residents, themes, seasons, NFC, camera analysis, multiplayer).
- This plan stops at a scaffolded, buildable app. No wow-prototype code, no art, no Week-1 spikes (spec §5.4) — that's the next plan.

---

### Task 1: Install Flutter SDK and verify toolchain

**Files:** none (system-level; installs to `C:\flutter`, no repo files touched)

**Interfaces:**
- Produces: a `flutter` command usable via `C:\flutter\bin\flutter` (or bare `flutter` once PATH is persisted) for all later tasks.

- [ ] **Step 1: Clone the Flutter stable branch**

Run (PowerShell):
```powershell
git clone -b stable https://github.com/flutter/flutter.git C:/flutter
```

- [ ] **Step 2: Verify the toolchain for this session**

Run (PowerShell) — prepends Flutter to PATH for the current process and checks it resolves:
```powershell
$env:PATH = "C:\flutter\bin;" + $env:PATH
flutter --version
```
Expected: prints a Flutter/Dart version banner (stable channel), no errors.

- [ ] **Step 3: Persist PATH for future shells**

Run (PowerShell) — uses the .NET API rather than `setx` to avoid `setx`'s 1024-character truncation risk on long PATH values:
```powershell
[Environment]::SetEnvironmentVariable("Path", $env:Path, "User")
```

- [ ] **Step 4: Enable web support and run `flutter doctor`**

```powershell
flutter config --enable-web
flutter doctor
```
Expected: the "Flutter" and "Connected device" / web checks report OK. Android toolchain, Xcode, and Windows-desktop checks may report missing components (Android SDK, Visual Studio C++ workload) — that's expected and out of scope here; this plan only needs the core Dart/Flutter toolchain and web target working (see Task 8's rationale for why web is the smoke-test target).

- [ ] **Step 5: Precache web build artifacts**

```powershell
flutter precache --web
```
Expected: completes without error.

---

### Task 2: Initialize git and make the first commit

**Files:**
- Create: `.gitignore`

**Interfaces:**
- Produces: a git repository at the project root with tracked history; all later tasks each end in a commit.

- [ ] **Step 1: Write a minimal `.gitignore`**

This will be superseded/extended by Flutter's own generated `.gitignore` in Task 4; this first version just keeps OS cruft out of the initial commit.

```gitignore
# OS
.DS_Store
Thumbs.db

# Editors
.vscode/
.idea/
*.swp
```

- [ ] **Step 2: Initialize the repo and commit**

```bash
git init
git add .gitignore docs hearthbound_spec.md
git commit -m "Initial commit: spec and setup docs"
```
Expected: `git log --oneline` shows one commit; `git status` reports a clean tree.

---

### Task 3: Rename the spec from Hearthbound to MiCasa

**Files:**
- Create: `docs/micasa_spec.md`
- Delete: `hearthbound_spec.md`

**Interfaces:**
- Produces: `docs/micasa_spec.md` as the product/UX source of truth for all subsequent work.

- [ ] **Step 1: Copy with case-sensitive find/replace**

```bash
sed 's/Hearthbound/MiCasa/g; s/hearthbound/micasa/g' hearthbound_spec.md > docs/micasa_spec.md
```

- [ ] **Step 2: Verify no leftover references**

```bash
grep -i hearthbound docs/micasa_spec.md
```
Expected: no output (exit code 1 / no matches).

- [ ] **Step 3: Remove the old file**

```bash
rm hearthbound_spec.md
```

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "Rename spec: Hearthbound -> MiCasa"
```

---

### Task 4: Scaffold the Flutter project

**Files:**
- Create: `pubspec.yaml`, `lib/main.dart`, `test/widget_test.dart`, `android/`, `ios/`, `web/`, `.gitignore` (Flutter-generated, merges with Task 2's), and other standard `flutter create` output — all at repo root.

**Interfaces:**
- Produces: `pubspec.yaml` with `name: micasa`; a runnable default counter app at `lib/main.dart`.

- [ ] **Step 1: Run `flutter create` at the repo root**

```powershell
$env:PATH = "C:\flutter\bin;" + $env:PATH
flutter create --org com.micasa --project-name micasa .
```
Run from the repo root (`c:\Local\2026\mi-casa`). `flutter create` is safe to run in a non-empty directory — it only writes its own project files and will not touch `docs/`.

- [ ] **Step 2: Verify scaffold**

```powershell
flutter analyze
```
Expected: "No issues found!"

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "Scaffold Flutter project (flutter create)"
```

---

### Task 5: Add locked dependencies

**Files:**
- Modify: `pubspec.yaml`

**Interfaces:**
- Consumes: `pubspec.yaml` from Task 4.
- Produces: `flutter_riverpod`, `go_router`, `rive`, `drift`, `sqlite3_flutter_libs`, `path_provider`, `path` as resolved dependencies; `drift_dev`, `build_runner` as resolved dev dependencies — available for all later Dart code.

- [ ] **Step 1: Add runtime dependencies**

```powershell
flutter pub add flutter_riverpod go_router rive drift sqlite3_flutter_libs path_provider path
```
Using `flutter pub add` (not hand-edited version pins) so resolved versions are current and mutually compatible at install time.

- [ ] **Step 2: Add dev dependencies**

```powershell
flutter pub add --dev drift_dev build_runner
```

- [ ] **Step 3: Verify resolution**

```powershell
flutter pub get
flutter analyze
```
Expected: `pub get` completes with no version-solving errors; `flutter analyze` still reports "No issues found!".

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "Add locked dependencies: riverpod, go_router, rive, drift"
```

---

### Task 6: Create the simulation/presentation/data/content directory structure

**Files:**
- Create: `lib/simulation/README.md`
- Create: `lib/presentation/README.md`
- Create: `lib/data/README.md`
- Create: `content/rooms/README.md`
- Create: `content/tasks/README.md`
- Create: `content/adjacency/README.md`
- Create: `content/copy/README.md`

**Interfaces:**
- Produces: the directory boundary later feature work must respect — `lib/simulation/` never imports `lib/presentation/`, and vice versa is one-directional (presentation reads simulation state, not the other way around).

- [ ] **Step 1: `lib/simulation/README.md`**

```markdown
# simulation/

Pure game logic: entropy engine, task selection, combo/adjacency resolution,
adaptive-duration learning. Functions here take state in and return state
out — no Flutter widgets, no rendering, no audio, no imports from
`presentation/`. This is what stays headlessly testable (spec §5.3).
```

- [ ] **Step 2: `lib/presentation/README.md`**

```markdown
# presentation/

Scenes, animation (Rive), audio (stems), and widgets. Reads simulation
state to decide what to render; never writes simulation state directly.
The world is a renderer of application state, never the canonical store
(spec §5.3).
```

- [ ] **Step 3: `lib/data/README.md`**

```markdown
# data/

Drift schema and DAOs. SQLite is the source of truth (spec §5.3) —
local-first, no backend, no sync in Phase 0.
```

- [ ] **Step 4: `content/rooms/README.md`**

```markdown
# content/rooms/

Room type definitions and degradation-overlay data (clutter, grime,
particles, lighting tint) as data files, not code (spec §2.1, §5.3).
Adding a room type must not require a code change.
```

- [ ] **Step 5: `content/tasks/README.md`**

```markdown
# content/tasks/

Seeded default tasks per room type (spec §5.2 item 5). User can remove
tasks; not required to configure them.
```

- [ ] **Step 6: `content/adjacency/README.md`**

```markdown
# content/adjacency/

The physical-adjacency graph driving the combo engine (spec §3.5, §5.2
item 9 — highest design priority in Phase 0). Hand-authored to start,
per spec §11 open question 5.
```

- [ ] **Step 7: `content/copy/README.md`**

```markdown
# content/copy/

User-facing text and phrasing variety. Kept out of Dart source so tone
and wording can change without a code change (spec §4.5, §5.3).
```

- [ ] **Step 8: Commit**

```bash
git add lib/simulation lib/presentation lib/data content
git commit -m "Establish simulation/presentation/data/content directory boundary"
```

---

### Task 7: Write `CLAUDE.md`

**Files:**
- Create: `CLAUDE.md`

**Interfaces:**
- Produces: the guardrail file read at the start of every future session in this repo.

- [ ] **Step 1: Write the file**

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "Add CLAUDE.md guardrails"
```

---

### Task 8: Verify the scaffold

**Files:** none (verification only)

**Interfaces:**
- Consumes: the complete scaffold from Tasks 1–7.

- [ ] **Step 1: Static analysis**

```powershell
flutter analyze
```
Expected: "No issues found!"

- [ ] **Step 2: Run the default test suite**

```powershell
flutter test
```
Expected: the default `test/widget_test.dart` (counter increment test) passes. `flutter test` runs on the host Dart VM and does not require a device/platform toolchain, so it's a valid compile-and-run smoke test without needing Android SDK, Xcode, or the Windows desktop C++ workload installed.

Note on scope: this plan verifies the scaffold compiles and its tests run, not a full on-device build. Android SDK (with license acceptance) and/or the Windows desktop C++ workload are heavier installs appropriate for when device/emulator testing actually starts — not part of repo prep. If you want a full platform build verified now, say so and it can be added as a follow-up task.

- [ ] **Step 3: Confirm git state**

```bash
git log --oneline
git status
```
Expected: 6 commits (Tasks 2–7), clean working tree.

---

## Self-review notes

- **Spec coverage:** every design-doc §2 decision has a task (SDK: Task 1; rename: Task 3; scaffold: Task 4; stack deps: Task 5; directory boundary: Task 6; CLAUDE.md: Task 7; git: Task 2; verification: Task 8).
- **Deviation flagged:** design doc's success criterion "`flutter run` (or `flutter build`) succeeds" is satisfied here via `flutter analyze` + `flutter test` rather than a full platform build, to avoid requiring Android SDK / Xcode / Windows C++ workload installs as part of repo prep. Called out explicitly in Task 8 rather than silently substituted.
- **No placeholders:** all commands and file contents are literal; no TBD/TODO.
