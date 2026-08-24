# Kitchen Art Brief

Generation-ready spec for replacing M0's procedural (`CustomPainter`)
kitchen placeholders with real illustrated assets. Written 2026-08-24
against `docs/micasa_spec.md` §2's locked decision: **hand-illustrated
2D with parallax layers, not 3D / not flattened.** Spec §5.3 confirms
the parallax model is subtle — a tilt/pan offset between stacked
layers (spec line 53), not a side-scrolling diorama.

Source reference sheet: `example-sheet.png` (repo root) — style
direction is good (warm cottagecore palette, isolated props, 4-tier
room states, 6-emote companion). The one issue: the hero kitchen shot
and room-state thumbnails on that sheet are flattened single images,
which can't parallax. This brief specifies the decomposed version.

## General conventions (applies to everything below)

- **Format:** PNG-24 with alpha transparency. No baked shadows or
  vignette that would clash once layers are composited live.
- **Canvas:** every layer within a set uses the same fixed canvas size
  and camera framing (e.g. 2400×1600, 3:2), so layers align when
  stacked. Nothing should shift between layers except what's actually
  meant to move independently.
- **Lighting:** one consistent light direction/warmth baked across all
  layers of a room. Mismatched lighting between layers reads as wrong
  immediately once they're composited.

## 1. Kitchen background — depth layers, not one flat image

Decompose the room into layers that are mostly **static across
degradation states**, plus one swappable clutter layer that carries
all the mess:

| Layer | Contents | Varies by state? |
|---|---|---|
| `kitchen_back` | wall, window, upper shelves, hanging plants | No — 1 image, reused always |
| `kitchen_structure` | cabinets, fridge, stove, sink basin, island frame | No — 1 image, reused always |
| `kitchen_floor` | floor boards, rug | No — 1 image, reused always |
| `kitchen_clutter_{state}` | dishes in/around sink, counter mess, trash, floor debris — everything that actually changes | **Yes** — 4 variants: `pristine` (empty/near-invisible), `normal`, `messy`, `disaster` |

3 static images + 4 clutter overlays = 7 images total for the whole
kitchen, instead of 4 fully-flattened rooms — and it's what actually
makes parallax and degradation-as-overlay work.

## 2. Companion — 6-emote set, formatted for swapping

Idle / Happy / Excited / Concerned / Thinking / Tired covers more than
M0 needs today, which is good runway for later milestones.

- Each mood as its own transparent PNG, same canvas size, same pivot
  point (bottom-center of the character), so swapping frames doesn't
  make it jump.
- No ground shadow baked in if it's a separate blob — that's drawn/
  managed in code so it can respond to state.

## 3. Missing from the reference sheet: a standalone dish-pile prop

Need a dirty-dishes-in-sink prop, isolated on transparent background,
sized to sit inside the `kitchen_structure` sink basin. This replaces
M0's placeholder `DishPilePainter` directly.

## 4. Task icons — no changes needed

The existing 8-icon set (wash dishes, wipe counter, take out trash,
sweep floor, do laundry, clean stove, organize, water plants) is
consistent and ready to use as-is once the content-driven task list
(M1+) is built.

## Naming convention

```
content/art/kitchen/kitchen_back.png
content/art/kitchen/kitchen_structure.png
content/art/kitchen/kitchen_floor.png
content/art/kitchen/kitchen_clutter_pristine.png
content/art/kitchen/kitchen_clutter_normal.png
content/art/kitchen/kitchen_clutter_messy.png
content/art/kitchen/kitchen_clutter_disaster.png
content/art/companion/companion_idle.png
content/art/companion/companion_happy.png
content/art/companion/companion_excited.png
content/art/companion/companion_concerned.png
content/art/companion/companion_thinking.png
content/art/companion/companion_tired.png
content/art/props/dish_pile.png
```

Mirrors CLAUDE.md's content-driven rule: room art lives alongside room
data in `content/`, not as code.

## Priority — what unblocks something now vs later

1. **Now (M0 visual swap-in):** `kitchen_back`, `kitchen_structure`,
   `kitchen_floor`, `kitchen_clutter_pristine`, `kitchen_clutter_normal`,
   `companion_idle`, `companion_excited` (or `_happy`), `dish_pile`.
   That's the full set needed to make M0 look real.
2. **Later:** `kitchen_clutter_messy` / `_disaster` and the remaining
   companion emotes — not load-bearing until the entropy/degradation
   system (a later milestone) actually uses more than two states.
