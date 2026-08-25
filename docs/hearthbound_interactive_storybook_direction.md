# Hearthbound — Simplified Interactive Room Direction

## Status

**Decision: simplify the visual architecture.**

Do **not** build Hearthbound as:
- a fully modular furniture construction system
- a full 3D runtime
- a Quaternius-to-sprite production pipeline
- a large AI-generated layer system

Instead, build Hearthbound around:

> **Finished illustrated room backgrounds + interactive hotspots + a companion + a small set of state overlays + ready-made animation effects.**

The goal is to preserve a visually impressive, interactive experience without turning the project into an asset-production project.

## 1. Core Interaction Model

Use one finished illustration per room.

```text
rooms/
├── kitchen.png
├── living_room.png
├── bedroom.png
├── bathroom.png
├── office.png
└── entrance.png
```

The room itself is not constructed from dozens of individual furniture sprites.

Instead, invisible interactive zones are positioned over meaningful parts of the illustration.

```text
┌─────────────────────────────────────┐
│ [FRIDGE]     [STOVE]     [WINDOW]   │
│                                     │
│              [SINK]                 │
│                                     │
│        [ISLAND]                     │
│                         [FLOOR]      │
└─────────────────────────────────────┘
```

The user interacts directly with the illustrated environment.

## 2. Point-and-Click Adventure Model

The experience should behave more like a polished point-and-click adventure than a traditional task manager.

Tap sink:

```text
🍽️ Dishes
~4 min
[ START QUEST ]
```

Tap floor:

```text
🧹 Quick Sweep
~5 min
[ START QUEST ]
```

Tap plant:

```text
🌿 Water Plants
~2 min
[ START QUEST ]
```

Prefer:

```text
Kitchen
→ tap sink
→ start
```

over:

```text
Tasks
→ Kitchen
→ Cleaning
→ Sink
→ Dishes
```

## 3. Interactivity Comes From Effects, Not Asset Quantity

A room does not need:

```text
sink_clean.png
sink_normal.png
sink_dirty.png
sink_disaster.png
```

Instead, use the finished background and layer subtle interaction effects over relevant areas:

- glow
- pulse
- shimmer
- particles
- companion attention
- tiny contextual icon

Avoid visual clutter.

## 4. Task Completion Feedback

Completing a chore should feel highly satisfying even if the room background does not structurally change.

```text
DONE
 ↓
haptic
 ↓
wipe/sparkle animation
 ↓
completion sound
 ↓
companion celebrates
 ↓
warm light pulse
 ↓
particles
 ↓
XP/reward
```

The player's brain should still read:

> I affected this room.

## 5. Use Small State Overlays Where Necessary

If a task genuinely needs visible state, use a separate overlay sprite.

```text
kitchen.png
+ dish_pile.png
+ garbage_bag.png
+ crumbs.png
+ companion
```

The base room remains intact.

Only stateful objects change.

## 6. Do Not Build Full Dirty-Room Variants

Avoid:

```text
kitchen_clean.png
kitchen_normal.png
kitchen_messy.png
kitchen_disaster.png
```

Instead, make changes granular.

```text
Normal:
  dish_pile_small

Needs attention:
  dish_pile_large
  garbage_bag

Healthy:
  problem overlays hidden
  ambient animations active
```

## 7. Prefer “Dormant → Thriving” Over “Dirty → Clean”

The virtual home does not need to become ugly when the real room needs attention.

A better fantasy:

> **The virtual room loses vitality when neglected and becomes more alive when cared for.**

### Low vitality
- slightly reduced saturation
- cooler ambient tint
- fewer particles
- companion concerned/sleepy
- plants less vibrant
- decorative lights off
- reduced ambient motion

### Healthy
- full color
- warm lighting
- vibrant plants
- active companion
- subtle environmental motion
- richer music

### Thriving
- extra flowers
- sparkles
- ambient creatures
- richer lighting
- more companion activity
- cosmetic flourishes

## 8. Static Illustration Does Not Mean Static Experience

Each room can have a handful of lightweight animated elements:

```text
window → moving sunlight
curtain → subtle sway
plant → leaf movement
kettle → steam
lamp → glow
particles → dust motes/sparkles
companion → idle/move/sleep
```

Only a few animations are needed to make a room feel alive.

## 9. Companion as Navigation

The companion can direct the player without filling the room with UI.

It physically moves near the most relevant task.

User taps companion:

```text
⚔️ Kitchen Rescue
Dishes
~4 min
[ START ]
```

The companion becomes:
- guide
- navigation
- emotional feedback
- task recommendation system
- reward feedback

## 10. Asset Strategy

Instead of searching for modular game assets, search for:

> **cozy interior illustration packs**

Useful formats:
- PNG
- SVG
- EPS
- vector illustration sets
- high-resolution room illustrations

Finished illustrations are acceptable and often preferable.

## 11. SVG Is Especially Useful

Prefer SVG where practical.

It can allow:
- recoloring
- brightness changes
- opacity changes
- selective object manipulation
- scalable resolution

Potential state change:

```text
task complete
 ↓
lamp brighter
plant more saturated
window light warmer
```

## 12. Ready-Made Animation Assets

Use existing Rive/Lottie assets for generic effects:

- sparkle
- cleaning wipe
- confetti
- success burst
- reward reveal
- particles
- bouncing icons
- loading/progress feedback

Reserve custom work for distinctive Hearthbound content.

## 13. Revised Runtime Tech Stack

For this simplified version, **Flame is optional**.

The room can initially be built with normal Flutter:

```text
Flutter Stack
├── room background
├── sink hotspot
├── stove hotspot
├── floor hotspot
├── dish overlay
├── companion
├── Rive animation
└── completion effects
```

Useful primitives:
- `Stack`
- `Positioned`
- `GestureDetector`
- `AnimatedOpacity`
- `AnimatedScale`
- `AnimatedPositioned`
- `TweenAnimationBuilder`
- Rive
- Lottie

Flame can be introduced later if needed.

## 14. Keep the Existing Product Stack

```text
Flutter / Dart
├── Riverpod
├── go_router
├── Drift / SQLite
├── Rive
├── Lottie
└── optional Flame

Backend
└── Supabase
    ├── PostgreSQL
    ├── Auth
    ├── Realtime
    ├── Storage
    └── Edge Functions

Monetization
└── RevenueCat
```

## 15. Asset Budget for MVP

| Asset type | Approximate count |
|---|---:|
| Full room illustrations | 5–7 |
| Problem/state overlays | 10–15 |
| Companion base character | 1 |
| Companion emotional states | 4–6 |
| Generic completion/effect animations | ready-made |
| UI icons | ready-made |

Target roughly:

> **20–30 custom/static visual assets total**

rather than hundreds.

## 16. Suggested Room Set

```text
rooms/
├── kitchen
├── living_room
├── bedroom
├── bathroom
├── office
└── entrance
```

Optional later:

```text
laundry_room
garage
yard
basement
kids_room
balcony
```

## 17. Suggested State Overlay Library

```text
overlays/
├── dishes_small.png
├── dishes_large.png
├── mug.png
├── pan.png
├── laundry_pile.png
├── garbage_bag.png
├── papers.png
├── crumbs.png
├── dust.png
├── stain.png
├── sparkle.png
└── glow.png
```

Overlays can be reused across rooms.

## 18. Example Kitchen Scene

Base:

```text
kitchen.png
```

Interactive hotspots:

```text
sink
stove
counter
floor
fridge
plant
trash
```

Possible overlays:

```text
dish_pile
mug
garbage_bag
crumbs
```

Companion states:

```text
idle
concerned
happy
excited
```

Effects:

```text
wipe
sparkle
light pulse
XP burst
```

## 19. Example User Flow

```text
OPEN APP
 ↓
kitchen illustration appears
 ↓
ambient animation
 ↓
companion sits near sink
 ↓
user taps companion
 ↓
"Kitchen Rescue — Dishes — 4 min"
 ↓
START
 ↓
minimal chore-run UI
 ↓
user completes real dishes
 ↓
DONE
 ↓
dish overlay fades
 ↓
sparkle wipe over sink
 ↓
warm lighting pulse
 ↓
companion jumps
 ↓
haptic + sound
 ↓
Kitchen vitality increases
```

## 20. Visual Progression

Progression should enhance the existing room rather than require completely new scenes.

Possible upgrades:
- stronger ambient lighting
- new decorative plants
- new lamp
- more particles
- seasonal decoration
- companion accessories
- alternate artwork
- decorative overlays
- wallpaper/recolor variants

Avoid requiring a new custom room image for every tier.

## 21. Why This Is Better

This preserves:
- beautiful visual presentation
- interactive home
- spatial UX
- companion personality
- satisfying task completion
- room progression
- game-like feedback

while avoiding:
- 3D asset conversion
- Blender/Godot rendering pipelines
- hundreds of furniture sprites
- AI-generated layer decomposition
- modular room-building tools
- complex depth sorting
- extensive art production

Most engineering effort stays focused on **software interaction and UX**.

## 22. What to Stop Doing

Do not spend more time on:
- AI-generating full parallax layer sets
- manually cutting generated asset sheets
- searching specifically for “2D game furniture packs”
- converting large 3D libraries into sprites
- building full modular room architecture for MVP
- creating four entire cleanliness variants per room

## 23. What AI Should Still Generate

Good candidates:
- companion
- dust monster
- magical sparkle effects
- dirty dish pile
- laundry pile
- event decorations
- collectibles
- reward illustrations
- custom room hero art if no suitable pack exists

Avoid AI for every ordinary household object.

## 24. MVP Prototype Priority

Build one polished kitchen first.

Required:

```text
1 finished kitchen illustration
1 companion
3–5 hotspots
1 dish overlay
1 completion animation
1 room vitality state
sound
haptics
```

Prototype:

```text
tap companion
 ↓
start dishes task
 ↓
complete task
 ↓
dish overlay disappears
 ↓
sink sparkles
 ↓
room becomes warmer
 ↓
companion celebrates
```

## 25. Definition of Success

The approach succeeds if:
- the room looks premium immediately
- interaction points are intuitive
- opening the app feels like entering a world
- completion feedback is satisfying
- rooms can be added without weeks of asset work
- the project does not require an art-production pipeline
- state can change through overlays/effects
- the companion makes the room feel alive
- most engineering effort remains in Flutter/product logic

# Final Direction

The strongest simplified concept is:

> **A point-and-click interactive storybook home.**

Each room is a beautiful finished illustration.

Flutter overlays:
- interaction hotspots
- state props
- companion animation
- subtle environmental motion
- task-completion effects

The central principle is:

> **Use software to make a small amount of artwork feel interactive, rather than creating a huge amount of artwork to simulate interactivity.**
