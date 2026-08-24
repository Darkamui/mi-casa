# MiCasa — Product & Implementation Spec

**Status:** v1.0 — consolidated from concept draft + visual direction, with product review changes applied.
**Audience:** implementation agent (Claude Code) and the developer.
**Read this first, in full, before writing any code.**

---

## 0. How to use this document

- Sections 1–4 are **locked decisions**. Do not renegotiate them mid-implementation.
- Section 5 is **Phase 0**, the only thing being built right now. Nothing outside it gets implemented.
- Sections 6–9 are **deferred design**. They exist so Phase 0 doesn't paint us into a corner. They are *not* a backlog to start working through.
- Section 10 lists **non-goals**. If a proposed feature appears there, refuse it.

---

## 1. Product definition

> **A beautiful interactive miniature world whose state is controlled by how you care for your real home.**

Not "a gamified chore app." Not "an RPG powered by chores." The chore manager is infrastructure underneath; the miniature world is the product the user falls in love with.

### The single hypothesis

Everything in this project exists to test one thing:

> **Does turning cleaning into a short, low-friction, momentum-driven run make people voluntarily start — and continue — chores they otherwise would not have started?**

The moat is **activation energy**, not task tracking. Competitors gamify the completion screen. We gamify the ten seconds *before starting* and the ninety seconds *after finishing*.

If a user will not do a second chore they did not plan to do, the concept fails and no amount of art, AI, or progression saves it.

### Positioning line

> **Your home is the game world.**

Alternate: *A game you progress by putting your phone down.*

---

## 2. Locked decisions

These resolve conflicts between the two source documents. Where they disagreed, the visual/UX document won.

### 2.1 Art direction: illustrated 2D, layered for depth

**Decided: hand-illustrated / storybook 2D with parallax layers.** Not 3D diorama.

Rationale: the 3D diorama has the broadest appeal *and* the highest asset cost *and* is where mediocre execution is most visible — mediocre 3D reads as "asset store," mediocre illustration still reads as "charming." Per-room asset count in 3D (clean state, 3–4 degradation states, lighting variants, props, NPC, companion animation, × themes × seasons) is a content pipeline, not a sprint.

Implementation approach:
- Rooms are composed of stacked sprite layers with slight parallax offset on device tilt / camera pan, so the scene *reads* as a diorama without a 3D pipeline.
- Degradation is expressed through **swappable overlay layers** (clutter, grime, particles, lighting tint), not separate full artworks. One base room + N overlays.
- Animation is cheap and constant: idle sway, flicker, drifting particles, companion wander. The scene must never be static.

### 2.2 No percentages in the UI

The concept draft used percentages everywhere (`Stability 74%`, `Tavern 46% → 79%`). **Remove all of them from the interface.**

Percentages may exist internally as float state. The user sees only:
- The room itself, visually.
- Coarse verbal states: *Thriving / Comfortable / Slipping / Struggling / Critical*.

If a change in room condition is not visible in the artwork, the change did not happen as far as the user is concerned.

### 2.3 Onboarding is playable, not configured

The concept draft's 5-step wizard (rooms → task editing → cleaning style → theme → first quest) is **rejected**. Use the playable version:

1. App opens directly into a beautiful, slightly messy room. No account. No permissions. No questionnaire.
2. The companion notices the user and walks to a dirty object.
   > Want to help?  `[ YES ]`
3. > Put one thing near you back where it belongs.
4. User does it physically. Presses **DONE**.
5. The object restores in-world. Light warms. Companion celebrates. Haptic. Music resolves.
   > **That's MiCasa.**
6. *Only then:*
   > Want to build your home?

Home setup is visual: a tiny empty floor plan with `+` slots. Tap `+`, pick a room type, the house assembles itself. No checkboxes.

**We do not reproduce the real floor plan.** The user names the areas they have; the game generates a plausible, attractive structure containing them. The world is an emotional representation, not a CAD model.

Account creation, if ever, happens after multiple sessions.

### 2.4 Verification is solved by feel, not enforcement

The entire economy runs on the user tapping DONE. This is the failure mode that plateaus every chore-RPG: once the reward is felt to be disconnected from the work, it loses weight and the fantasy dies quietly.

We do not police this. We make the reward *feel* earned:

- **Time is the honest signal.** Reward time spent in motion, not checkboxes ticked. A run's value scales with elapsed active time, not task count.
- **Before/after photo capture is in Phase 0**, optional, local-only, never uploaded, never shared by default. A two-image slider at run end is the single strongest honesty mechanic we have. It was deferred to "v0.3" in the source doc — that was wrong.
- No task ever completes itself, and no reward is ever granted for a task the user did not explicitly finish.

### 2.5 Voice input ships in Phase 0

Hands are wet, gloved, or full. This is the actual usability constraint, not a nice-to-have. Minimum viable set: **"done," "next," "skip," "pause," "five more minutes."** On-device speech recognition; no server round-trip.

### 2.6 AI is heuristics for now

The "what's the highest-value thing this person can realistically do right now?" recommender is a **rules engine** in Phase 0, not a model call. Per-user inference cost on a free tier damages unit economics before the feature earns anything.

AI is never a chat box. If a model is introduced later, it sits invisibly behind task selection and phrasing variety — never a `✨ Ask HearthAI anything!` button.

### 2.7 Household multiplayer will be free

When it ships, co-op is **not** premium. It is simultaneously the best retention mechanic and the only organic acquisition channel we have. Premium is cosmetics, extra themes, multiple homes, advanced maintenance tracking.

Never put basic chore functionality behind a subscription wall.

### 2.8 Name

`MiCasa` is a working title. **Trademark and app-store search must be cleared before any public asset carries it.** It sits close to several existing cozy-game titles.

---

## 3. Core loop

```
Open app  →  see living world  →  tap companion  →  pick energy level
   →  first task appears  →  phone goes down  →  do it  →  DONE
   →  combo prompt (physical adjacency)  →  repeat  →  run ends
   →  world visibly transforms
```

### 3.1 The world is the interface

Navigation is spatial, not tabbed. Tap kitchen → camera moves to kitchen. Tap garden → camera pans outside.

Inside a room, **objects are tasks**:
- Sink glowing → dishes
- Trash can wobbling → garbage
- Dust motes on floor → vacuuming
- Grimy stove → cleaning

The user taps the dirty counter. They never navigate `Tasks → Kitchen → Cleaning → Counter`.

Menus live in the world too: journal = stats, trophy shelf = achievements, mailbox = settings. Long-press a room → Edit / Tasks / Decorate.

### 3.2 Start a run

The Start Run affordance is **the companion**, not a button. It approaches the camera holding a quest card. Tap it:

> ⚔️ Kitchen Rescue — **8 min**  `PLAY`

Energy selection:
- 🫠 Bare minimum — 2–5 min
- 🙂 Quick run — 10 min
- ⚔️ Standard run — 20 min
- 🔥 Let's fix this place — 45+ min

Optional "where?" — anywhere, or a specific room.

### 3.3 Run mode ("put the phone down")

Once a run starts, the UI collapses to the minimum:

```
             QUEST

       Clear the counter

            02:21



         ┌─────────┐
         │  DONE   │
         └─────────┘

       Skip       Pause
```

- Controls live in the **lower half of the screen**. Large targets. One-handed.
- Gestures: swipe right = complete, swipe left = skip, swipe up = details.
- Completion is **one action**. Never `Open → Edit → Mark Complete → Confirm → Continue`.
- Timer is **visual first** — a candle burning down, a companion walking toward a destination, a wagon crossing a road. Exact digits appear subtly underneath, never dominant.

### 3.4 Momentum

Momentum is **within-session**, not across days. Completing physically adjacent actions builds a chain:

```
Dishwasher → clear counter → wipe counter → garbage → new bag
   🔥 x4
```

Rewards scale slightly, but the point is that the app **celebrates the chain**. Quitting at any moment loses nothing. Never `YOU FAILED TO COMPLETE YOUR DAILY GOAL.`

### 3.5 Combo / "one more thing"

After each completion, the engine looks for the lowest-friction adjacent action — exploiting **physical context**, not addiction.

```
🔥 x3

Counter's clear.

✨ Wipe it?
~2 min

[ DO IT ]      [ END RUN ]
```

Adjacency is a **property of the task data** (location, dependency, "user is already holding X"). This is the mechanism the whole hypothesis rests on. It gets the most design attention of anything in Phase 0.

### 3.6 Setup quests count

Preparatory actions are valid gameplay and award small rewards: bring supplies into the bathroom, take the vacuum out of the closet, put the laundry basket beside the washer, put the garbage bag by the door.

Getting ready is part of doing the chore, and it removes tomorrow's activation barrier.

### 3.7 "Not this"

Every mission has a no-penalty escape:

> 😒 **NOT THIS** → Too tired / Takes too long / Don't feel like it / Can't right now / Not actually needed

Repeated rejection triggers the **downgrade ladder**, not nagging:

```
Vacuum upstairs
   → Vacuum only the visible hallway
      → Bring the vacuum upstairs
```

The last rung sounds absurd and is the most valuable thing in the system.

### 3.8 Entropy, not deadlines

No red OVERDUE badges. Each task carries a hidden **need level** that rises over time and is expressed *visually in the room*.

The app learns real cadence. If the user actually vacuums every 9–12 days, it stops suggesting every 7. The objective is:

> Maintain the home with the least unnecessary work.

Not: obey arbitrary recurring reminders.

### 3.9 Comfortable zone

The home has a global condition, but **100% is explicitly not the goal.** There is a comfortable band; inside it the app says:

> Your home is in good shape. Nothing needs you right now.

This prevents the product becoming compulsive optimization.

### 3.10 Beautiful empty states

When nothing needs doing, never show "No tasks available." Show: house peaceful, birds outside, residents relaxed, calm music, companion asleep.

> Everything's comfortable.
> **Enjoy it.**

**The app never manufactures work to generate engagement.**

---

## 4. Feedback layer

This is not polish applied at the end. It *is* the product. Budget accordingly.

### 4.1 Transformation is the reward

Completing a run must produce a visible change. Before: grey light, clutter, dust, wilted plant, dead fireplace, sleepy NPC. After: dust blows away, windows brighten, fireplace ignites, plant perks up, NPC opens the shutters, companion celebrates, music gains an instrument.

Then: **ROOM RESTORED.**

Unlocks are physical, never a toast: the chair *drops into the room* and an NPC walks over and sits on it. Never `Congratulations! You unlocked Chair #12.`

### 4.2 Adaptive music

The user builds the song by cleaning. Quiet instrumental at run start → percussion on task 1 → bass on task 2 → melody at x4 → full arrangement resolves at room restoration → fades naturally.

Implement as **synchronized stems**: the separate instrument tracks of one piece of music — pad, drums, bass, melody — written to the same tempo, key, and length, exported individually.

Two rules make this work:

- **All stems play from the start of the run, simultaneously, with inactive ones at zero volume.** You never start or stop a file mid-run; you ramp volume on tracks that never stopped. Starting `drums.ogg` at the moment the user taps DONE lands it wherever it lands — offbeat, and audibly wrong.
- **Transitions are quantized to the bar line.** Read the master clock, compute time until the next musical boundary, schedule the volume ramp for then. The delay is up to ~2 seconds and nobody notices it. What they notice is that the drums arrived *on the beat*, which reads as the game responding musically rather than mechanically.

The requirement this places on the stack: parallel decoders must not drift. A few milliseconds of divergence between bass and drums is audible as flam or phasing, and it accumulates over a 20-minute run. This rules out any audio layer that treats players as independent instances.

**Fallback if the spike (§5.4) fails:** pre-render the layer combinations as 4–5 full mixes and crossfade between them at bar boundaries. Less flexible, far simpler, and most players will not tell the difference. Do not let this system block Phase 0.

Never hard-cut tracks.

### 4.3 Haptics

Distinct, learnable patterns:
- Task complete → short crisp tap
- Combo → double tap
- Rare find → small escalating pattern
- Boss complete → strong satisfying impact

### 4.4 Motion

Every interaction has a physical response. Tap a room → it reacts, camera zooms. Complete a chore → button snaps, particle burst, haptic. Build a combo → the UI itself becomes subtly more energetic.

### 4.5 Text minimalism

The app should be nearly comprehensible without reading. Never:

> Would you like to perform another task in the kitchen in order to increase your momentum multiplier?

### 4.6 No F2P clutter

The home screen carries no XP bars, currencies, badges, energy meters, level numbers, resource counters, or popups. The world is primary; game systems are contextual and appear only where relevant.

### 4.7 Progressive disclosure

A day-one user sees: house, companion, start run, rooms. That's all.
After the first run: *You found Timber.* → crafting appears.
Later: *Your first resident arrived.* → residents appear.
Later: *You've restored three rooms.* → upgrades appear.

The interface grows with the player.

---

## 5. Phase 0 — build only this

**Goal: test the hypothesis in section 1 with real users. Nothing else.**

Do not build resources, upgrade trees, residents, achievements, themes, multiplayer, seasons, NFC, or camera analysis. They are in section 6 so we don't architect ourselves out of them, not so we can start them.

### 5.1 The wow prototype comes first

Before any systems work, build one 30-second interaction end to end:

1. A beautiful, messy illustrated kitchen. A tiny creature struggles with a pile of dishes.
2. User taps the creature → *2-minute rescue?*
3. `PLAY` → *Put the dishes away.*
4. User presses **DONE**.
5. Dishes vanish, lighting warms, creature celebrates, fireplace ignites, particles, haptic, music resolves.
6. **Kitchen restored.**

Show it to people. If they smile at step 5, continue. If they don't, stop and fix that before building anything else.

### 5.2 Phase 0 scope

| # | Item | Notes |
|---|---|---|
| 1 | Playable onboarding | §2.3 exactly. No account, no wizard. |
| 2 | Visual home setup | Tap `+` slots. 3–6 room types. |
| 3 | **One** fully art-complete room | Kitchen. Clean + 4 degradation overlays. |
| 4 | Other rooms at reduced fidelity | Consistent style, fewer states. |
| 5 | Seeded default tasks per room type | User can remove, not required to configure. |
| 6 | Entropy / need-level engine | Internal floats → coarse verbal states + visual overlays. |
| 7 | Runs: 5 / 10 / 20 min | Companion-initiated. §3.2–3.3. |
| 8 | One-task-at-a-time run UI | Visual timer, one-tap DONE, gestures. |
| 9 | Combo engine | Physical-adjacency graph. **Highest design priority.** |
| 10 | Momentum counter | In-session only. No daily streaks. |
| 11 | "Not this" + downgrade ladder | §3.7. |
| 12 | Setup quests | §3.6. |
| 13 | Adaptive duration learning | "You finished in 7, it said 15." |
| 14 | Room transformation sequence | §4.1. The payoff. Non-negotiable quality bar. |
| 15 | Adaptive music stems | §4.2. Minimum 4 layers. |
| 16 | Haptics | §4.3. |
| 17 | Voice: done/next/skip/pause/+5 | On-device. §2.5. |
| 18 | Optional before/after photo | Local only. Never uploaded. §2.4. |
| 19 | Companion | Wanders, reacts, celebrates. No needs, no guilt, cannot die. |
| 20 | Home-screen widget | Shows the tiny home + companion + one cue. Tap → launch recommended run. |

XP exists as a quiet number. **No resource types in Phase 0.** No upgrade tree.

### 5.3 Technical direction

**Framework: Flutter / Dart.** MiCasa is roughly **40% game, 60% polished mobile product**. A game engine makes the world easy and the product miserable (forms, text fields, accessibility, deep links, subscriptions, mobile lifecycle); a pure app framework makes the world hard. Flutter is the least-bad split, and the peripheral 60% is where most of the actual screens live.

The governing architectural idea:

> **Flutter owns the product. The world layer owns the world. The world is a renderer of application state, never the canonical store.**

Locked now:

- **Flutter + Rive + Riverpod + Drift/SQLite.** Rive handles state-driven animation — companion reactions, quest cards, reward reveals — where a state machine is genuinely the right model. Riverpod keeps game state (`home`, `rooms`, `chores`, `companion`, `currentRun`) strictly separate from UI state (`selectedRoom`, `activeSheet`, `onboarding`). Drift is locked early because migrating off the local schema later is painful.
- **Local-first, no backend in Phase 0.** SQLite is the source of truth. No login. No sync. No network calls except optional crash reporting.
- **Feedback never waits on I/O.** DONE → local state update → animation, haptic, sound, particles → *then* any background work. Never DONE → request → spinner → response → animation. This is an architectural rule from day one, not an optimization.

Deliberately **not** decided yet — these are Phase 1 decisions being made today with zero information, and naming them now invites premature integration: backend/sync vendor, auth, push infrastructure, payments, analytics. Phase 0 has nothing to sync and nothing to sell.

**Start without Flame.** The world is layered sprites with state swaps, a parallax pan between rooms, and particles — that is a `CustomPainter` and a widget stack. Flame buys a camera and a particle system in exchange for a dependency with a history of disruptive API rewrites across majors, plus a second lifecycle that fights Rive overlays sitting on top. Build the wow prototype in plain Flutter + Rive. Add Flame only on hitting something genuinely impractical without it. If it is added, Rive stays in the Flutter overlay layer — do not embed Rive inside Flame.

- **Rooms are composed, never single images.** A room is a background, a floor, and independent object components (sink, counter, stove, trash, plant), each with its own cleanliness state driving its own sprite/overlay. Completing a chore sets one object's state; room-level restoration triggers when enough objects cross threshold. This is what makes the visual system scale past one room.
- **Parallax by layer rate.** Background 2px → wall 4px → furniture 8px → character 10px → foreground/particles 12px on camera pan. This produces the faux-3D diorama read that §2.1 is buying.
- **Room navigation is camera state, not routes.** Use go_router for the peripheral screens; do not force the spatial world into the router.
- **Atlas sprites and verify Impeller on a mid-range Android early.** Layered parallax plus particles plus a Rive overlay is where the frame budget disappears.
- **Deterministic core.** Task selection, entropy, and combo resolution must be pure functions over state, testable headlessly without the render layer. Write these tests.
- **Content-driven.** Room types, tasks, adjacency edges, degradation overlays, and copy all live in data files, not code. Adding a room type must not require a code change.
- **Separate the layers.** `simulation/` (entropy, selection, learning) knows nothing about `presentation/` (scenes, animation, audio). The whole reason section 2.1 could be reversed later is this boundary.

### 5.4 Week-1 spike — do this before any art or systems work

Three Phase 0 requirements are not free in Flutter and are currently invisible in the plan. Spike all three before committing to the framework or commissioning assets. Timebox: one week.

| Spike | Question | Notes |
|---|---|---|
| **Adaptive audio** | Can 4 stems hold sync on a mid-range Android, under load, for 20 minutes, with bar-quantized volume ramps? | The largest unknown. `flutter_soloud` or a native audio path — `audioplayers` will drift. Load means: particles drawing, Rive animating, timer running. Failure → fall back to pre-rendered mixes (§4.2), do not fight it. |
| **Home-screen widget** | How much native work is the tiny-home widget? | Flutter cannot render it. This is SwiftUI/WidgetKit and Jetpack Glance, written twice, sharing state via app groups / shared prefs. Real work, previously unscoped. |
| **Haptics** | Can the four distinct patterns in §4.3 be produced? | Flutter's `HapticFeedback` is four canned taps — too coarse for escalating patterns. Needs Core Haptics on iOS and a custom vibration-pattern channel on Android. |

On-device speech (§2.5) is the fourth platform-channel item but is lower risk; verify availability, don't spike deeply.

If the audio spike fails *and* the fallback feels flat in the wow prototype, that is real information about the stack — the emotional core would be fighting the framework, and Unity or Godot solve stem sync natively. §5.3's simulation/presentation boundary is what keeps that reversal survivable.

### 5.5 Kill criteria

Evaluate with 15–25 real users over 3 weeks. Stop or pivot if:

- Users do **not** accept combo prompts at a meaningfully higher rate than they would start an equivalent unplanned task cold. *This is the hypothesis. If it fails, stop.*
- Median time from app open → physically beginning a chore exceeds **15 seconds**.
- Week-2 sessions drop below 40% of week-1 sessions.
- Users describe the app to others as "a timer with nice art."

### 5.6 Primary metric

Not tasks logged. Not DAU.

> **Time from app open → physically beginning a chore. Target: under 15 seconds.**

Secondary: **unplanned tasks per run** (combo acceptance rate). This is the hypothesis made measurable.

---

## 6. Deferred — Phase 1 (only if Phase 0 passes)

Resources tied to activity type (Essence / Cloth / Provisions / Parts / Relics / Nature / Knowledge) → per-room upgrade trees → residents with room-state-aware dialogue → boss chores for long-neglected tasks → procedural raids (Blitz, Room Rescue, Wanderer, Boss Fight, Reset, Night Closing) → interruptible multi-phase chores (laundry) → life-shaped achievements (*Giant Slayer: complete a task postponed over a month*) → household co-op with effort-weighted fairness and emergent roles → invisible-work tracking (bills, scheduling, supplies, meal planning).

## 7. Deferred — Phase 2

Additional visual themes → seasonal content → "home memory" maintenance model (filters, appliances, repair history) → NFC stations → camera room analysis → smart-home hooks → multiple homes.

## 8. The month-3 problem — unresolved, decide before Phase 1

Restoring a room is a one-time emotional payoff. The second restoration of the same kitchen is visually identical and flat. Re-dirtying a room the user just cleaned risks reading as manufactured work — precisely what §3.9 and §3.10 forbid.

Neither source document addressed steady state, and steady state is where retention actually lives.

Before Phase 1 begins, pick **one** primary long-term driver and commit:

- **(a) Construction** — the home visibly grows and changes shape over months.
- **(b) Inhabitants** — residents accumulate, interact, and give the home social life.
- **(c) Collection** — cosmetics, discoveries, and lore fragments.

"All three, later" means none. Phase 0 must not assume any of them.

## 9. Monetization (not implemented in Phase 0)

**Free:** one home, all core rooms and tasks, runs, basic progression, one visual world, companion, recommendations, **household co-op**.

**Premium:** additional world themes, seasonal cosmetic packs, advanced home-maintenance tracking, multiple homes, richer statistics, deeper customization.

No purchasable XP. No loot boxes. No ads. Drops cannot be bought — that is what keeps surprise genuine.

---

## 10. Non-goals — refuse these

- Social feed, follower counts, public leaderboards
- Guilt notifications, mandatory daily streaks, "streak lost" screens
- A wall of overdue tasks in red
- Energy systems that block play
- Purchasable XP, loot boxes, ads between chores
- Intentionally addictive infinite loops
- Long onboarding configuration
- A chat-box AI assistant
- Percentages as primary UI (§2.2)
- Any dashboard as the landing screen — the flow is **World → Action**, never **Analytics → Menus → Task**
- Manufacturing work to drive engagement

Notification frequency stays low, and notifications have personality:

> 🍳 The kitchen could use a little love. 8-minute rescue available.
> 🐈 Pip found a dust monster under the couch.

Never: *You have 4 overdue chores.*

---

## 11. Open questions

1. Trademark clearance on "MiCasa."
2. Week-1 spike outcomes (§5.4): stem sync, widget, haptics. Stem sync is the largest technical unknown in the project.
3. Whether Flame is needed at all (§5.3) — decide from the wow prototype, not in advance.
4. §8 long-term driver.
5. Combo adjacency data model: hand-authored graph vs. learned from co-occurrence. Start hand-authored.
6. How the run's reward scales with *time in motion* rather than task count (§2.4) without becoming exploitable by idling.
