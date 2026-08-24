# Kitchen Art Brief v2

Generation-ready spec for the kitchen's illustrated assets. Supersedes
the first pass: those assets (still in `content/art/`, kept for
reference) were each auto-cropped to their own content by the
generator, so `kitchen_back` (560×430), `kitchen_structure` (625×430),
and `kitchen_floor` (431×430) all came back different pixel sizes with
overlapping content (two different fridges, two different cabinets)
instead of stacking into one registered scene. This version exists to
prevent that from happening again — read **§0 before generating
anything**.

Written against `docs/micasa_spec.md` §2's locked decision:
**hand-illustrated 2D with parallax layers, not 3D / not flattened.**
Spec §5.3: parallax is a subtle tilt/pan offset between stacked layers
(spec line 53), not a side-scrolling diorama.

## §0. Why last time misaligned, and the fix

An AI image generator asked for "the wall and window, nothing else"
and asked separately for "the cabinets and sink, nothing else" has no
memory of the first image's exact camera distance, lens, or canvas —
it re-imagines the room from scratch each time, and typically returns
the tightest crop around whatever it drew. Two independently-imagined
crops of "a kitchen" do not line up.

**The fix: generate one locked reference image first (Asset 0), then
derive every other room layer FROM that same reference** — using the
tool's image-edit / inpaint-to-transparent feature on that exact file
(remove-background-except-X, or mask-and-erase), not a fresh
text-to-image prompt. If your tool has no edit/inpaint mode and can
only do fresh text-to-image generations, say so before starting —
the brief below still gives per-asset prompts, but flag that the
alignment risk is real and layers may need this decomposition redone
by hand (crop/reposition in an image editor against Asset 0) rather
than trusting the generator's crop.

**Canvas discipline (non-negotiable for every room layer, Assets 0–6):**
- Fixed canvas **1600×1000px**, no exceptions.
- **Do not let the tool auto-crop or trim the output.** If it returns
  a tightly-cropped image, pad it back out to 1600×1000 in an editor,
  positioning the content exactly where it sat in Asset 0 — don't
  recenter it.
- Everything not part of that layer's own content is transparent
  (alpha 0), not white/checkerboard-baked.

## §1. Style lock — paste this into every room-layer prompt unchanged

```
Warm cottagecore hand-illustrated storybook 2D style, soft painterly
shading, no outlines heavier than a fine ink line. Single warm
golden-hour light source from upper-left (through the window), soft
long shadows falling lower-right. Camera: static eye-level 3/4 view
of a kitchen corner, medium-wide lens (not fisheye, not telephoto),
composition matches the reference image exactly — same camera
position, same horizon line, same object scale. Canvas 1600x1000px,
transparent background (PNG-24 alpha) except for the elements
described below. No shadows or vignette baked onto the transparent
canvas edges.
```

---

## Asset 0 — Reference composite (generate first, do not skip)

**Purpose:** the locked "answer key" every other room layer gets
derived from. Never shipped in the app itself.

**Contents:** the *entire* kitchen corner, fully composed — wall,
window, upper shelves, hanging plants, cabinets, fridge, stove, sink
basin, island, floor, rug. Everything from Assets 1–6 combined into
one normal (non-transparent, full-color) image.

**Prompt:**
```
[paste §1 style lock, but drop "transparent background" — this one
is opaque]
A cozy kitchen corner: cream fridge with a few magnets on the left
wall, dark range hood above a gas stove with a green kettle, open
wood shelves above holding potted plants and jars, a window straight
ahead with gingham curtains and a garden view, a farmhouse sink with
a chrome faucet, dark green cabinets along the counter, a matching
kitchen island with two stools in the foreground, warm wood plank
floor with a small rug. Sink is clean and empty. 1600x1000px.
```

**Once generated:** this is your reference for every prompt below.
If your tool supports image-to-image editing, use *this exact file*
as the input for Assets 1–4 (mask out what shouldn't be in each
layer, erase to transparent) rather than describing the scene again
from text. If it doesn't, attach/reference this image alongside each
text prompt below so the model anchors to it.

---

## Asset 1 — `kitchen_back.png`

**Purpose:** the farthest layer — wall, window, upper shelving. Static
across all degradation states; loads once, never swapped.

**Grouped, not isolated:** wall + window + shelves + hanging plants
all belong in this one layer together (they're all at the same depth
plane). Do not isolate the window by itself.

**Explicitly exclude:** fridge, cabinets, stove, sink, island, floor,
rug — anything below counter height or in front of the counter line.
Those belong to Assets 2 and 3.

**Background:** transparent everywhere except the wall/window/shelf
content — including the lower third of the canvas, which will be
empty/transparent (that's where `kitchen_structure` and
`kitchen_floor` show through underneath).

**Prompt:**
```
[paste §1 style lock]
Using the reference image as the exact camera match: isolate ONLY
the back wall, the window with gingham curtains and garden view, the
open wood shelves with potted plants and jars. Erase/omit the
fridge, cabinets, stove, sink, island, and floor entirely — leave
those areas fully transparent. Keep every remaining element in the
exact same pixel position as the reference.
```

---

## Asset 2 — `kitchen_structure.png`

**Purpose:** the built-in furniture layer — cabinets, fridge, stove,
sink basin, island frame. Static across all degradation states.

**Grouped, not isolated:** all counter-height furniture together, same
depth plane.

**Explicitly exclude:** wall/window/shelves (Asset 1), floor/rug
(Asset 3), any dishes/mess/clutter (Asset 4 — the sink basin itself
is part of the structure, but it must be drawn **empty**, no dishes).

**Background:** transparent above the counter line (where the wall
layer will show through) and below the cabinet kickboards (where the
floor layer will show through).

**Prompt:**
```
[paste §1 style lock]
Using the reference image as the exact camera match: isolate ONLY
the built-in furniture — cream fridge, dark range hood, gas stove
with kettle, dark green cabinets, farmhouse sink basin with faucet
(empty, no dishes), and the kitchen island with stools. Erase/omit
the wall, window, shelves, and floor/rug entirely — leave those areas
fully transparent. Keep every remaining element in the exact same
pixel position as the reference.
```

---

## Asset 3 — `kitchen_floor.png`

**Purpose:** floorboards and rug. Static across all degradation states.

**Explicitly exclude:** everything at or above counter height —
no cabinets, no furniture legs poking in from other layers.

**Background:** transparent everywhere except the floor/rug strip at
the bottom of the frame.

**Prompt:**
```
[paste §1 style lock]
Using the reference image as the exact camera match: isolate ONLY
the wood plank floor and the small rug. Erase/omit every piece of
furniture, cabinetry, and the wall entirely — leave those areas fully
transparent. Keep the floor in the exact same pixel position as the
reference.
```

---

## Asset 4 — `kitchen_clutter_pristine.png`

**Purpose:** the swappable mess layer, state 1 of 4. This is the
"just cleaned" state — near-invisible, maybe a faint clean-shine or
literally nothing.

**Contents:** minimal to none. If truly empty, this can be an all-
transparent 1600×1000 canvas (still export it, so the app always has
a layer to swap to).

**Prompt:**
```
[paste §1 style lock]
Using the reference image as the exact camera match: a fully
transparent 1600x1000 canvas, or at most a very faint clean sparkle/
shine near the sink basin. No dishes, no mess, no trash.
```

---

## Asset 5 — `kitchen_clutter_normal.png`

**Purpose:** the swappable mess layer, state 2 of 4. Day-to-day
lived-in mess — this is the state M0's single task ("put the dishes
away") starts from and clears.

**Contents:** a small stack of dirty dishes sitting IN the sink basin
(matching Asset 2's sink position exactly), maybe one item on the
counter beside it. Nothing on the floor yet.

**Explicitly exclude:** everything already in Assets 1–3 (don't
redraw the sink, cabinets, etc. — only the dishes/mess sitting on top
of them).

**Background:** transparent except the dish/mess shapes.

**Prompt:**
```
[paste §1 style lock]
Using the reference image as the exact camera match: isolate ONLY a
modest stack of dirty dishes, mugs, and a pan sitting inside the sink
basin (same position as the reference's sink), plus one stray mug on
the counter beside it. Nothing else — no sink, cabinets, fridge, or
floor, leave those fully transparent. Position the dishes exactly
where they'd physically sit inside the reference's sink basin.
```

---

## Asset 6 — `kitchen_clutter_messy.png` *(later — not needed for M0)*

**Purpose:** state 3 of 4. Escalates Asset 5: sink overflowing,
counter clutter spreading, a few crumbs/spots on the counter.

**Prompt:**
```
[paste §1 style lock]
Using the reference image as the exact camera match: isolate ONLY an
overflowing pile of dirty dishes and pans in and around the sink
basin, plus scattered mugs/utensils on the counter and a few food
spots on the counter surface. Nothing else — leave sink, cabinets,
fridge, and floor fully transparent. Position everything exactly
where it would physically sit against the reference's counter/sink.
```

---

## Asset 7 — `kitchen_clutter_disaster.png` *(later — not needed for M0)*

**Purpose:** state 4 of 4, the worst state. Escalates Asset 6: trash
overflowing, debris landing on the floor too.

**Prompt:**
```
[paste §1 style lock]
Using the reference image as the exact camera match: isolate ONLY a
disaster-level pile of dirty dishes/pans overflowing the sink and
counter, an overflowing trash can beside the island, and a few
pieces of food debris on the floor near the island. Nothing else —
leave sink, cabinets, fridge, and floor fully transparent otherwise.
Position everything exactly where it would physically sit against
the reference's layout.
```

---

## Asset 8 — `props/dish_pile.png`

**Purpose:** standalone prop, composited independently of the clutter
layers (this is the one that fades/shrinks away on task completion in
M0's current code).

**Isolated, not grouped:** just the dish pile, nothing else — no sink,
no counter, no background of any kind.

**Canvas:** does not need to match the 1600×1000 room canvas (it's
positioned and scaled by code, not stacked pixel-for-pixel). Use a
square-ish canvas sized to the content, e.g. 800×600, generous
transparent margin on all sides so it doesn't get clipped when
scaled.

**Prompt:**
```
Warm cottagecore hand-illustrated storybook 2D style, soft painterly
shading, matching the lighting and line-weight of [attach Asset 5 or
the reference]. A pile of dirty dishes, mugs, and a pan sitting
loosely in/around a sink basin edge, isolated on a fully transparent
background — no sink, no counter, no wall, no floor, nothing but the
dish pile itself. Generous transparent padding on all sides.
```

---

## Asset 9 — `companion/companion_idle.png`

**Purpose:** the companion creature's default/resting pose.

**Isolated, not grouped:** character only, nothing else.

**Canvas:** fixed **800×800px** square for the whole 6-emote set (see
Assets 9–14), so swapping moods doesn't visibly jump. Pivot point is
bottom-center of the character — leave consistent transparent margin
above/around so the character's feet sit at roughly the same
vertical position across all six.

**Background:** fully transparent. No ground shadow baked in — that's
drawn in code so it can respond to state.

**Prompt:**
```
Warm cottagecore hand-illustrated storybook 2D style, soft painterly
shading, matching the palette of [attach the reference kitchen
image]. A small fox-like companion creature with a green bandana,
sitting calmly, neutral pleasant expression, front-facing 3/4 pose.
Fully transparent background, no ground shadow, no props. Character
centered with generous padding, feet positioned at roughly 85% down
the frame. Canvas 800x800px.
```

---

## Asset 10 — `companion/companion_excited.png`

**Purpose:** celebration pose, used when a task completes. This is
the other mood M0 actually uses today.

**Prompt:**
```
[same style/canvas/background instructions as Asset 9]
Same companion creature, same bandana, now mid-jump with both front
paws raised, big open-mouth happy expression, small sparkle
accents beside it. Fully transparent background, no ground shadow.
Canvas 800x800px, same character scale and pivot as companion_idle.
```

---

## Assets 11–14 — remaining companion moods *(later — not needed for M0)*

Same style/canvas/background/pivot instructions as Assets 9–10 each
time. Vary only the pose/expression:

- `companion_happy.png` — content mid-smile, relaxed stance, tail up.
- `companion_concerned.png` — ears back, slightly hunched, worried
  expression, one paw raised.
- `companion_thinking.png` — head tilted, one paw near chin, curious
  expression.
- `companion_tired.png` — sitting low, half-closed eyes, small yawn
  or drooping ears.

---

## Naming convention

```
content/art/kitchen/kitchen_back.png          (Asset 1)
content/art/kitchen/kitchen_structure.png      (Asset 2)
content/art/kitchen/kitchen_floor.png          (Asset 3)
content/art/kitchen/kitchen_clutter_pristine.png (Asset 4)
content/art/kitchen/kitchen_clutter_normal.png   (Asset 5)
content/art/kitchen/kitchen_clutter_messy.png    (Asset 6, later)
content/art/kitchen/kitchen_clutter_disaster.png (Asset 7, later)
content/art/props/dish_pile.png                (Asset 8)
content/art/companion/companion_idle.png       (Asset 9)
content/art/companion/companion_excited.png    (Asset 10)
content/art/companion/companion_happy.png      (Asset 11, later)
content/art/companion/companion_concerned.png  (Asset 12, later)
content/art/companion/companion_thinking.png   (Asset 13, later)
content/art/companion/companion_tired.png      (Asset 14, later)
```

The Asset 0 reference composite is not part of this list — it's a
working file, not a shipped asset. Keep it alongside the others
(e.g. `content/art/kitchen/_reference.png`) for whenever the clutter
layers (Assets 6–7) get made later, so they still match.

## Task icons — no changes needed

The existing 8-icon set (wash dishes, wipe counter, take out trash,
sweep floor, do laundry, clean stove, organize, water plants) from
the first art pass is consistent and ready to use as-is once the
content-driven task list (M1+) is built.

## Priority — what's needed to close out M0

**Now:** Assets 0 (reference, not shipped) → 1 → 2 → 3 → 4 → 5 → 8 →
9 → 10. That's the full set needed to make M0's single hardcoded task
loop look real with working parallax layers.

**Later:** Assets 6, 7, 11–14 — not load-bearing until the
entropy/degradation system (a later milestone) actually uses more
than two clutter states or more than two companion moods.
