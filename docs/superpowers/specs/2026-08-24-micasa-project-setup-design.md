# MiCasa — Repo & Environment Setup Design

**Status:** approved, ready for implementation planning.
**Scope:** this document designs the *repo scaffolding and dev environment prep* for the MiCasa project. It does not revise product or UX decisions — those are locked in `docs/micasa_spec.md` (renamed from the original `hearthbound_spec.md`; content unchanged except the name).

---

## 1. Context

This is a brand-new, empty repository (no git, no code, no SDKs installed). The product/UX spec already exists in full detail and is locked (see `docs/micasa_spec.md` §1–4, with Phase 0 scope locked in §5). App name is **MiCasa**, not "Hearthbound" — Hearthbound was a working title that needs trademark clearance the product doesn't have; the rename removes that risk from all shipped/dev-visible surfaces.

Nothing about the tech stack or product decisions is being reconsidered here — confirmed with the project owner. This doc exists only to make the scaffolding decisions the product spec doesn't cover: repo layout, SDK setup, directory structure, and persistent guardrails for future implementation sessions.

## 2. Decisions

### 2.1 Repo layout: flat, not monorepo

The Flutter project root **is** the repo root (`pubspec.yaml` at top level). `docs/` sits alongside it for specs. Rejected alternative: an `app/` subfolder reserving root for future non-Flutter pieces — rejected because Phase 0 has no backend, no website, no second app (spec §5.3: "no backend in Phase 0"). A monorepo shell would sit empty and add navigation friction for no present benefit. The native widget code required by §5.4 (SwiftUI/WidgetKit, Jetpack Glance) lives inside `ios/` and `android/` under the single Flutter project, which is standard Flutter practice, not a reason to split the repo.

### 2.2 Naming & identifiers

- App/project name: `micasa`
- Reverse-domain identifier: `com.micasa.app` (placeholder org `com.micasa`; can be changed before any store submission)
- Spec file: `docs/micasa_spec.md` — full text of the original spec with every instance of "Hearthbound"/"hearthbound" replaced with "MiCasa"/"micasa". No other content changes. Old root-level `hearthbound_spec.md` is removed once the renamed copy exists.

### 2.3 Toolchain

Flutter SDK (stable channel) installed on this machine, verified via `flutter doctor`. This is a prerequisite for `flutter create` and everything downstream; it was previously missing.

### 2.4 Directory structure

Per spec §5.3's architectural rule — *"Flutter owns the product. The world layer owns the world. The world is a renderer of application state, never the canonical store."* — the boundary between simulation and presentation must exist from the first commit, not be retrofitted:

```
lib/
  simulation/     # entropy engine, task selection, combo resolution,
                   # adaptive-duration learning — pure functions over state,
                   # testable headlessly, zero imports from presentation/
  presentation/    # scenes, animation (Rive), audio (stems), widgets
  data/            # Drift schema + DAOs (SQLite, local-first, source of truth)
  ...              # (app entrypoint, routing, providers — standard Flutter layout)
content/
  rooms/           # room types, degradation overlays — data files, not code
  tasks/           # seeded default tasks per room type
  adjacency/        # combo/adjacency graph (hand-authored per spec §11.5)
  copy/            # user-facing text/phrasing variety
```

Dependencies added at scaffold time: `riverpod` (state), `go_router` (peripheral-screen routing only — spatial world navigation is camera state, not routes, per §5.3), `rive` (state-driven animation), `drift` + `sqlite3_flutter_libs` (local persistence). **No Flame** — per §5.3, add only if the wow prototype proves plain Flutter + `CustomPainter` insufficient.

### 2.5 `CLAUDE.md`

A root-level file capturing, for any future implementation session:
- The locked decisions in spec §2 (art direction, no percentages, playable onboarding, feel-based verification, voice input, heuristics-not-ML, free multiplayer, name)
- The simulation/presentation architectural boundary (§2.4 above) as a hard rule
- "Feedback never waits on I/O" (§5.3) as a hard rule
- Current phase boundary: **Phase 0 only** (spec §5.2 scope table). §6/§7 (resources, upgrade trees, residents, themes, seasons, etc.) are explicitly out of scope until Phase 0 passes its kill criteria (§5.5).
- Pointer to `docs/micasa_spec.md` as the source of truth.

This exists so later sessions (which won't have this conversation's context) don't relitigate settled decisions or accidentally start building deferred-scope features.

### 2.6 Version control

`git init`, a standard Flutter/Dart `.gitignore` (build artifacts, `.dart_tool/`, IDE files, etc.), initial commit containing the scaffolded project.

## 3. Out of scope for this setup step

No wow-prototype code, no art assets, no Week-1 spikes (spec §5.4: adaptive audio, home-screen widget, haptics). Those are the next task, after this scaffolding exists. This step ends at: a `flutter create`-generated app that builds and runs, with the directory structure, docs, and guardrails above in place — nothing more.

## 4. Success criteria

- `flutter doctor` reports a working setup.
- `flutter run` (or `flutter build`) succeeds on the freshly scaffolded project.
- `docs/micasa_spec.md` exists with all naming updated; `hearthbound_spec.md` is gone.
- `lib/simulation/`, `lib/presentation/`, `lib/data/`, and `content/` exist (may be near-empty beyond placeholders — this step scaffolds structure, not features).
- `CLAUDE.md` exists and accurately reflects §2 and the phase boundary.
- Repo is a git repository with one initial commit.
