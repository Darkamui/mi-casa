# Phase 0 Implementation Roadmap — Design

**Status:** approved for planning
**Spec:** `docs/micasa_spec.md` (read in full before using this document)

## 1. Context

`docs/micasa_spec.md` §5 defines Phase 0 as the only thing to build right
now: 20 scope items (§5.2) proving the core hypothesis (§1) — that a
low-friction, momentum-driven run gets people to voluntarily do chores
they didn't plan to do. Sections 6–9 (resources, upgrade trees,
residents, achievements, themes, seasons, multiple homes, etc.) are
explicitly out of scope until Phase 0 clears its kill criteria (§5.5),
per this repo's `CLAUDE.md`.

The spec's own build-order guidance (§5.4) says to spike three technical
unknowns — adaptive audio stem sync, the native home-screen widget, and
custom haptic patterns — before any art or systems work. The project
owner has deferred all three spikes (audio and widget fully deferred,
haptics gets a light existence-check only, no dedicated spike). This
document proposes the resulting build order, following §5.1's own
fallback instruction instead: build the 30-second "wow prototype" first,
then layer systems under it.

This is a **sequencing document**, not a re-litigation of the spec. Every
milestone below maps to specific numbered items in spec §5.2; nothing
here adds or removes product scope beyond the two explicit deferrals
noted in §3.

## 2. Decisions

### 2.1 Build order rationale

Combo/adjacency resolution (§5.2 item 9, "highest design priority" per
the spec) moves early relative to art, because it is pure/headless logic
under the `lib/simulation/` boundary (CLAUDE.md architectural rule) and
does not need rendered rooms to exist or be tested. Persistence (Drift)
comes right after simulation, before any UI, so the simulation layer
never grows an implicit in-memory-only shortcut that later has to be
retrofitted onto SQLite.

The world shell (multi-room navigation, in-world menus) is pulled forward
to its own milestone (M3) rather than left implicit inside onboarding —
the spec is explicit (§3.1) that navigation is spatial and menus
(journal, mailbox, room long-press) live in the world itself, not a
dashboard. Skipping this milestone would leave onboarding dropping the
user into a single static kitchen scene with no way to reach settings,
stats, or other rooms.

### 2.2 Milestones

**M0 — Wow prototype (§5.1).**
One hardcoded kitchen scene. No Drift, no simulation engine. Messy
kitchen → tap creature → `PLAY` → `DONE` → dishes vanish, lighting
warms, particles, canned haptic (`HapticFeedback`, not the custom
patterns from §4.3), one non-adaptive music sting, "Kitchen restored."
Plain Flutter + `CustomPainter`; Rive for the companion if cheap to
integrate this early, plain sprite swap otherwise. This milestone's own
success gate, per spec: show it to people — if they don't smile at the
transformation, stop and fix that before anything else.

**M1 — Simulation core** (`lib/simulation/`, pure/headless).
Entropy/need-level engine (§3.8, §5.2 item 6), task and room models,
combo/adjacency graph resolution (§3.5, §5.2 item 9), momentum counter
(§3.4, §5.2 item 10), adaptive-duration learning (§5.2 item 13,
"finished in 7, it said 15"). Content-driven: loads room types, tasks,
and adjacency edges from `content/`. Per the architectural rule, this
package never imports from `lib/presentation/`; every function here is
unit-tested headlessly.

**M2 — Persistence (Drift/SQLite).**
Schema + DAOs for rooms, tasks, chores, entropy state, run history,
momentum. SQLite becomes the source of truth (spec §5.3) that M1's
simulation core reads and writes through — no in-memory-only shortcut
survives past this milestone.

**M3 — App shell & onboarding** (§2.3, §3.1, §3.10, §5.2 items 1/2/4).
Playable onboarding (companion notices → first task → `DONE` → "That's
MiCasa" → home setup) ends by dropping the user into a **persistent,
multi-room home view**, not just the kitchen — camera-based navigation
between rooms, other room types at reduced fidelity relative to the
kitchen. Companion has baseline presence/wander across the whole home,
independent of any run. In-world menu affordances wired to real
peripheral screens via `go_router`: **Journal** (stats — time played,
tasks completed, momentum history, no percentages per §2.2) and
**Mailbox** (settings — voice toggle, photo-capture toggle, notification
preferences). Long-press a room → **Edit / Tasks / Decorate** bottom
sheet. Beautiful empty state (§3.10) when nothing needs doing.

*Trophy shelf is explicitly excluded* — spec §3.1 lists it as an example
in-world menu object, but achievements are §6 deferred content per
CLAUDE.md's phase discipline. The object, if present at all, is inert
with no function in Phase 0.

**M4 — Full kitchen art pipeline** (§5.2 item 3, §2.1).
Formalizes M0's hardcoded scene into the real, content-driven thing: one
base room + 4 degradation overlays (clutter, grime, particles, lighting
tint), independent composed object layers (sink, counter, stove, trash,
plant) each with its own cleanliness state, parallax by layer rate per
§5.3. Reusable pattern for every other room type added later.

**M5 — Run flow** (§5.2 items 5/7/8/11/12, §3.2–3.3, §3.6–3.7).
Launched from the M3 shell by tapping the companion while standing in a
room. Energy-level selection with **four run-duration tiers** (§3.2,
confirmed over the narrower three-tier reading in §5.2's table): Bare
minimum 2–5 min, Quick run 10 min, Standard run 20 min, Let's fix this
place 45+ min. One-task-at-a-time run UI, visual timer, one-tap `DONE`,
swipe gestures (right = complete, left = skip, up = details). "Not
this" + downgrade ladder (§3.7). Setup quests count as valid gameplay
(§3.6). Seeded default tasks per room type, removable but not required
to configure.

**M6 — Combo & momentum integration** (§3.4–3.5, §5.2 items 9/10).
Wires M1's simulation engine into M5's run UI: post-completion adjacency
prompts ("Counter's clear. Wipe it?"), momentum chain display
(in-session only, no daily streaks).

**M7 — Feedback layer** (§4.1, §4.3–4.5, §5.2 items 14/16).
Room transformation sequence — the spec's "non-negotiable quality bar"
payoff. Haptics via Flutter's canned `HapticFeedback` (task complete,
combo, etc.) rather than the custom escalating patterns in §4.3 — this
is the "light check, deferrable" call on the haptics spike; richer
platform-channel patterns are a later add if they turn out to matter.
Motion/juice pass per §4.4.

**M8 — Placeholder music** (§5.2 item 15 — *deferred, tracked*).
A single ambient track, or a simple two-state (calm/active) crossfade,
stands in for the full 4-stem adaptive system in §4.2. The synchronized-
stem implementation is explicitly not built in this pass; §4.2's own
fallback (pre-rendered mixes, crossfaded at bar boundaries) is the
natural next step if adaptive music is revisited, without needing the
dedicated §5.4 spike first.

**M9 — Voice input** (§2.5, §5.2 item 17).
`done` / `next` / `skip` / `pause` / `five more minutes`, on-device only.
Per spec's own instruction, this gets a light availability check, not a
deep spike.

**M10 — Photo capture** (§2.4, §5.2 item 18).
Optional before/after photo, local-only, never uploaded. Two-image
slider at run end.

**M11 — Companion behaviors** (§5.2 item 19).
Richer Rive-driven wander/react/celebrate behaviors, building on M3's
baseline world presence. No needs, no guilt, cannot die.

**M12 — Home-screen widget** (§5.4, §5.2 item 20 — *deferred, tracked*).
SwiftUI/WidgetKit + Jetpack Glance, written twice, sharing state via app
groups / shared prefs. Deferred per the project owner's call — not
load-bearing for the §5.5 kill criteria, which are about the core loop,
not the widget. Revisit after the core loop is validated with real
users.

## 3. Deferred-but-tracked scope

Two Phase 0 scope items are intentionally not built in this pass, per
explicit project-owner decision rather than spec default:

- **Item 15, adaptive music stems** → M8 ships a placeholder instead;
  the §5.4 audio spike is not run.
- **Item 20, home-screen widget** → M12 is deferred to after initial
  user validation; the §5.4 widget spike is not run.

Both remain in this document as named milestones (not deleted) so they
stay visible as intentional deferrals, not omissions.

## 4. Out of scope

Everything in spec §6 (resources, upgrade trees, residents, boss
chores, raids, achievements, co-op) and §7 (themes, seasons, NFC, camera
analysis, smart-home hooks, multiple homes) — unchanged from CLAUDE.md.
Trophy shelf / achievements specifically called out in M3 above as an
example of this boundary in practice.

## 5. Success criteria

- M0 passes its own smile test before M1 begins.
- Each milestone M1 onward produces a working, independently testable
  slice — `lib/simulation/` tests pass headlessly after M1; a real
  on-device build exercises each subsequent milestone.
- The full stack (M0–M11, M12 deferred) satisfies spec §5.2 items 1–14,
  16–19 plus the two tracked deferrals, ready for the §5.5 real-user
  evaluation.
