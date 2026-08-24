# Hearthbound — 2.5D Diorama Visual Direction & Asset Pipeline

## Status

**Decision: adopt a 2.5D / semi-3D visual direction while keeping the shipped app 2D.**

Hearthbound should **not become a full 3D game** at this stage.

The app remains:

- **Flutter** for the product/application layer
- **Flame** for the interactive home/room presentation
- **Rive** for selected UI/character-state animation
- **Riverpod** for application state
- **Drift + SQLite** for offline-first local persistence
- **Supabase** for cloud sync/auth/backend when needed

The major visual-production change is:

> Use **Quaternius 3D household/interior models as source assets**, convert them into consistently rendered 2D sprites, and assemble those sprites in Flame as a layered 2.5D diorama.

The runtime remains 2D.

---

# 1. Core Visual Idea

Hearthbound should look like a **small living illustrated dollhouse / diorama**.

The player sees beautifully composed rooms with:

- fixed art-directed camera angles
- subtle depth
- foreground/background separation
- soft parallax
- warm lighting
- animated props
- companion movement
- particles
- clutter appearing/disappearing
- visible room restoration

The visual target is **not**:

- flat productivity-app illustrations
- pixel art
- full free-camera 3D
- realistic architecture software
- side-scrolling parallax

The target is:

> **A polished cozy 2.5D miniature world built from 2D sprites derived from 3D source assets.**

---

# 2. Why 2.5D Instead of Full 3D

Hearthbound's core interaction is:

```text
OPEN APP
    ↓
see living home
    ↓
tap a room
    ↓
smooth zoom into room
    ↓
start chore run
    ↓
do real-world task
    ↓
tap DONE
    ↓
room visibly improves
```

The user is **not** currently intended to:

- walk a controllable avatar through the house
- freely rotate the camera
- navigate in first/third person
- inspect objects from arbitrary angles
- play a traditional 3D game

Full live 3D therefore adds major technical complexity without improving the core experience enough.

A fixed or tightly controlled camera is actually desirable because it lets every room be:

- composed intentionally
- readable at a glance
- visually polished
- predictable for UX
- easy to animate
- performant on mobile

---

# 3. Why Quaternius

Use **Quaternius Ultimate House Interior** or compatible Quaternius interior/furniture packs as the initial source library.

Quaternius gives us a large cohesive set of household models such as:

- refrigerators
- ovens/stoves
- sinks
- cabinets
- tables
- chairs
- stools
- couches
- beds
- desks
- shelves
- bathroom furniture
- lights
- plants
- decorations
- doors/windows
- general household props

This solves a major production problem:

> We no longer need to AI-generate every normal household object.

Instead of generating:

```text
fridge.png
sink.png
chair.png
bed.png
plant.png
```

individually and fighting style/perspective inconsistency, we use one cohesive 3D source library and render everything through the same art pipeline.

Quaternius effectively becomes the project's **base furniture catalog**.

---

# 4. Important: The Game Still Ships 2D Assets

Quaternius models are development-time source assets.

The runtime should normally **not load the original 3D models**.

Production pipeline:

```text
QUATERNIUS 3D MODEL
        ↓
standard Hearthbound render setup
        ↓
transparent 2D sprite
        ↓
Flutter / Flame asset library
```

Example:

```text
Fridge model
    ↓
fridge.png

Stove model
    ↓
stove.png

Sink model
    ↓
sink.png

Plant model
    ↓
plant_01.png
```

The final mobile app continues rendering ordinary 2D assets.

---

# 5. Asset Rendering Tool

A small development-only renderer should be created.

Preferred option given the current workflow:

> **Godot 4 utility project**

Godot is **not** being added to the shipped app.

It is only an internal asset-production tool.

Concept:

```text
Quaternius models
       ↓
Godot Asset Renderer
       ↓
PNG sprites
       ↓
Flutter project assets
```

The renderer should eventually support batch conversion.

---

# 6. Godot Renderer Scene

Suggested structure:

```text
AssetRenderer
├── ModelRoot
├── Camera3D
├── DirectionalLight3D
├── WorldEnvironment
├── SubViewport
└── RendererController
```

The renderer owns the Hearthbound visual rules.

Lock:

- camera angle
- projection
- lighting
- background transparency
- render resolution
- material treatment
- object scale rules
- shadow style

Every asset is rendered through this same scene.

---

# 7. Camera

Use an **orthographic or very low-perspective camera**.

Target visual:

- elevated 3/4 view
- readable front + side surfaces
- miniature/dollhouse feel
- no lens distortion
- no dramatic perspective

The exact angle should be tested visually, then **locked globally**.

Example conceptual angle:

```text
             CAMERA
                ↘

              object
             ╱     ╲
```

Once accepted, furniture should not be rendered from arbitrary angles.

Consistency is more important than realism.

---

# 8. Multiple Orientations

Some furniture will need several orientations.

Do not create them independently.

Use the same 3D model and render controlled rotations.

Example:

```text
chair_000.png
chair_045.png
chair_090.png
chair_135.png
```

Or, if fewer variants are sufficient:

```text
chair_left.png
chair_right.png
```

Same for:

- beds
- couches
- tables
- cabinets
- chairs
- stools
- shelves
- kitchen appliances where necessary

This is a major advantage of retaining the original 3D source.

---

# 9. Hearthbound Rendering Style

Raw Quaternius models should **not necessarily be rendered exactly as-is**.

The renderer should create a coherent Hearthbound visual identity.

Target:

- cozy
- stylized
- miniature
- soft
- premium mobile-game look
- warm
- readable
- not photorealistic

Recommended treatment:

- warm directional key light
- soft ambient/fill light
- soft shadows
- reduced harsh specular reflections
- slightly simplified materials
- controlled saturation
- cohesive palette
- optional subtle toon/painterly shading
- optional very fine edge treatment
- transparent background

Do not add heavy cartoon outlines.

Do not attempt photorealism.

---

# 10. Lighting Direction

Keep a consistent global lighting rule.

Recommended:

> Warm light from upper-left/front-left with softer shadows falling lower-right.

Rooms may have secondary environmental lighting, but furniture assets must feel like they belong to the same world.

If shadows are likely to conflict with runtime placement, render:

```text
object_color.png
object_shadow.png
```

separately.

This allows Flame to control or suppress shadows independently.

---

# 11. Sprite Output

For isolated furniture:

```text
assets/world/props/
├── fridge/
│   ├── fridge_000.png
│   └── fridge_090.png
│
├── stove/
├── sink/
├── chair/
├── table/
├── plants/
└── decor/
```

Requirements:

- PNG
- real alpha transparency
- generous padding
- no clipping
- consistent pivot rules
- consistent scale convention

Do not use baked checkerboards.

---

# 12. Standardize Scale

A scale system must be defined before rendering the entire library.

For example:

```text
1 Godot world meter
        ↓
X sprite pixels
```

More importantly, relative real-world scale must remain believable:

```text
fridge > chair
bed > side table
sofa > armchair
plant sizes vary intentionally
```

The batch renderer should automatically:

1. calculate model bounds
2. place the model on a common virtual ground plane
3. preserve relative scale
4. render into a predictable padded canvas

Do **not** independently normalize every object to fill the image.

That would make a mug the same apparent size as a refrigerator.

---

# 13. Pivot Rules

Every object requires a predictable pivot.

Default:

> **bottom-center where the object contacts the floor**

Example:

```text
      FRIDGE
       │  │
       │  │
       │  │
       └──┘
         ▲
       pivot
```

Wall-mounted assets may use a different explicit anchor.

Store pivot metadata if necessary.

This is important for:

- placement
- depth sorting
- animation
- scaling
- room editing

---

# 14. Runtime Scene Composition in Flame

Do not return to large monolithic room images.

Rooms should now be assembled from components.

Example:

```text
KitchenRoom
│
├── BackLayer
│   ├── wall
│   ├── window
│   └── curtains
│
├── FurnitureLayer
│   ├── fridge
│   ├── stove
│   ├── cabinets
│   ├── sink
│   └── shelves
│
├── MidLayer
│   ├── island
│   ├── table
│   └── stools
│
├── DecorLayer
│   ├── plants
│   ├── rug
│   ├── jars
│   └── pictures
│
├── EntropyLayer
│   ├── dishes
│   ├── mug
│   ├── crumbs
│   ├── trash
│   └── clutter
│
├── CharacterLayer
│   └── companion
│
├── EffectsLayer
│   ├── particles
│   ├── sparkles
│   └── restoration FX
│
└── ForegroundLayer
```

This is preferable to:

```text
kitchen_back.png
kitchen_structure.png
kitchen_clutter_normal.png
...
```

because individual objects can now change independently.

---

# 15. Room Backgrounds

Not everything needs to be an isolated Quaternius prop.

Room architecture can be assembled from:

- flat wall surfaces
- floor surfaces
- window sprites
- trim
- doors
- curtains
- structural decorative elements

These may be:

- generated procedurally
- simple painted textures
- rendered from 3D
- manually authored

The critical requirement is visual consistency with the furniture.

---

# 16. Entropy / Mess System

Do **not** search for or generate full "dirty kitchen" or "messy bedroom" scenes.

The clean/dirty transformation should be programmatic.

Example:

## Clean kitchen

```text
sink = clean
counter = clean
floor = clean
```

## Normal

```text
sink:
  dish_stack_small
```

## Messy

```text
sink:
  dish_stack_large

counter:
  mug
  pan
  paper
```

## Disaster

```text
sink:
  dish_stack_large

counter:
  mug
  pan
  dirty_plate
  food_spot

floor:
  garbage_bag
  crumbs
  debris
```

This is much more interactive and scalable.

---

# 17. AI Asset Generation Becomes Secondary

AI image generation should no longer be responsible for the whole environment.

Use AI only for assets that benefit from uniqueness.

Good AI candidates:

- Hearthbound companion
- dust creatures
- magical effects
- special reward items
- unique clutter
- dirty dish piles
- stains
- crumbs
- unusual plants
- collectible decorations
- UI illustrations
- event-specific props

Bad AI candidates:

- generic chair
- generic refrigerator
- generic table
- generic bed
- generic cabinet
- generic couch

Use the asset library for normal household objects.

---

# 18. Parallax

The final room should feel dimensional.

Use subtle layer movement.

Example only:

```text
background     0.15x
back furniture 0.30x
mid furniture  0.50x
characters     0.65x
foreground     0.80x
```

The exact values must be subtle.

The user should think:

> "This little room has depth."

Not:

> "The sprites are sliding around."

Parallax may react to:

- tiny drag movement
- camera motion
- optional device tilt

Do not make device tilt mandatory.

---

# 19. Depth Sorting

Use each object's floor-contact position/pivot for depth sorting where appropriate.

Conceptually:

```text
smaller screen Y
       ↓
render earlier

larger screen Y
       ↓
render later
```

This allows:

```text
chair behind table
companion in front of table
plant behind couch
```

without manually managing every render order.

Explicit layer overrides can still exist for architectural objects.

---

# 20. Room Camera Behaviour

Rooms should use art-directed camera motion.

Allowed:

- subtle pan
- subtle zoom
- focus on a chore/object
- zoom from house → room
- tiny parallax shift

Avoid:

- unrestricted camera rotation
- player-controlled orbit camera
- large perspective changes
- FPS-style navigation

The room is a composed diorama.

---

# 21. Object Interaction

Because furniture becomes individual components, the world can react directly.

Examples:

```text
tap sink
→ sink highlights
→ dishes wobble
→ "Wash dishes — 4 min"
```

```text
complete task
→ dish pile shrinks/fades
→ sink sparkles
→ companion celebrates
```

```text
water plant
→ leaves perk up
→ subtle particles
```

```text
take trash out
→ garbage bag disappears
→ room lighting slightly warms
```

This is one of the main reasons for switching to component-based room construction.

---

# 22. Room Restoration

A room's transformation should be mostly driven by object state.

Example:

```text
Before
├── dishes visible
├── garbage visible
├── plant drooping
├── low ambient life
└── companion concerned

After
├── clutter removed
├── plant restored
├── brighter ambience
├── particles
├── companion happy
└── room animation
```

Avoid reducing feedback to:

```text
Kitchen 63% → 78%
```

The user should **see the result**.

---

# 23. Animation Strategy

Not every furniture sprite needs animation.

Use animation selectively.

Good candidates:

- companion
- plants
- curtains
- hanging objects
- kettle steam
- lights
- fireplace
- dust
- sparkles
- clutter disappearance
- reward objects
- room restoration

Static furniture can remain static.

Motion should make the world feel alive without becoming visually noisy.

---

# 24. Companion

The companion remains a unique Hearthbound asset rather than a Quaternius model unless a later art test proves otherwise.

Recommended representation:

- high-quality 2D illustrated or Rive character
- same visual palette as room
- several emotional states
- positioned within the Flame world
- bottom-center pivot
- reacts to room/task state

Example states:

```text
idle
happy
excited
concerned
thinking
tired
```

---

# 25. Room Customization

The Quaternius source library makes future customization substantially easier.

Example:

```text
Player unlocks:
  couch_A
  couch_B
  couch_C
```

All are rendered using the same Hearthbound pipeline.

Flame swaps the sprite.

Possible future systems:

- furniture upgrades
- room themes
- recolors
- seasonal variants
- collectible decor
- cosmetic progression

This supports the original product fantasy:

> Real-world chores improve and personalize the player's digital home.

---

# 26. Color Variants

Because original source models remain available, variants can be generated systematically.

Example:

```text
cabinet_green.png
cabinet_cream.png
cabinet_blue.png
```

Prefer controlled material variants from the renderer instead of manual hue-shifting where possible.

This keeps materials visually coherent.

---

# 27. Do Not Render the Entire Quaternius Library Immediately

Start small.

For the first kitchen prototype, render only the objects required for a convincing scene.

Suggested initial set:

```text
KITCHEN

architecture
├── wall
├── floor
├── window
└── curtain

furniture
├── fridge
├── stove
├── sink
├── cabinet variants
├── island/table
├── stool
└── shelf

decor
├── rug
├── plant_01
├── plant_02
├── jars
├── kettle
└── picture

entropy
├── dish_stack_small
├── dish_stack_large
├── mug
├── pan
├── crumbs
└── garbage_bag
```

Build one excellent room first.

If the aesthetic works, scale up the rendering pipeline.

---

# 28. Prototype Goal

Before backend work or a large asset import, prove this:

```text
OPEN KITCHEN
      ↓
beautiful 2.5D room
      ↓
subtle living animation
      ↓
tap companion
      ↓
"2-minute rescue?"
      ↓
task starts
      ↓
user taps DONE
      ↓
dish stack disappears
      ↓
sink restoration effect
      ↓
lighting/particles improve
      ↓
companion celebrates
```

This interaction should feel premium.

If it does not, iterate on:

- camera
- rendering
- lighting
- sprite scale
- parallax
- animation
- sound
- haptics

before building more rooms.

---

# 29. Updated Architecture

## Development

```text
        Quaternius
        3D models
            │
            ▼
    Godot Asset Renderer
            │
     ┌──────┴──────┐
     ▼             ▼
 color sprites   shadow sprites
     │             │
     └──────┬──────┘
            ▼
      2D asset library
```

## Runtime

```text
             Flutter
                │
    ┌───────────┼────────────┐
    │           │            │
  normal UI   Riverpod      services
    │
    ▼
   Flame
    │
    ▼
2.5D room composition
    │
    ├── architecture sprites
    ├── furniture sprites
    ├── decor sprites
    ├── clutter sprites
    ├── companion
    ├── particles
    └── parallax
```

Godot is **not bundled with the app**.

---

# 30. Current Tech Stack Remains Valid

No fundamental runtime stack change is required.

Continue with:

```text
Flutter / Dart
├── Flame
├── Rive
├── Riverpod
├── go_router
├── Drift / SQLite
├── local notifications
└── platform integrations

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

The main change is **asset production and room composition**, not the application architecture.

---

# 31. What NOT to Do

Do not:

- switch the whole app to Godot merely because source assets are 3D
- embed live Godot 3D inside Flutter
- use Unity for the current concept
- introduce unrestricted 3D camera controls
- build rooms as one giant flattened image
- AI-generate every normal furniture item
- independently generate full clean/messy/disaster room images
- normalize every object to the same visual size
- auto-crop sprites without preserving useful pivot/padding
- render every Quaternius model before validating the visual direction

---

# 32. When Full 3D Should Be Reconsidered

Only reconsider a full 3D runtime if Hearthbound evolves into a product where users are expected to:

- freely rotate the whole house
- move furniture arbitrarily
- decorate rooms spatially
- explore rooms from multiple angles
- navigate an avatar through the house
- treat the digital dollhouse itself as a major gameplay system

If that becomes the product, a **Godot-first runtime architecture** should be evaluated.

Do not force full 3D into Flutter/Flame.

For the current product vision, stay 2.5D.

---

# 33. Implementation Priority for the Current AI

Treat this document as the new visual-production direction.

Recommended next actions:

1. **Stop investing in AI-generated full kitchen layer sets.**
2. Keep any useful existing concept art strictly as visual reference.
3. Download/import the selected Quaternius interior source pack.
4. Create a tiny Godot 4 development-only render utility.
5. Establish one approved:
   - orthographic camera
   - lighting setup
   - material treatment
   - transparent render format
   - scaling convention
   - pivot convention
6. Render approximately 10–20 kitchen assets.
7. Import those PNGs into the Flutter project.
8. Build the kitchen from individual Flame components.
9. Add depth ordering.
10. Add subtle parallax.
11. Add one clutter state.
12. Add task-completion transformation.
13. Evaluate the result visually before scaling the asset library.

---

# 34. Definition of Success

The approach succeeds if:

- the room looks cohesive despite being assembled from many sprites
- users perceive depth without needing a live 3D renderer
- furniture can be moved/swapped independently
- clutter can appear/disappear independently
- room state can change visually in real time
- the camera remains beautifully composed
- app performance remains lightweight
- normal Flutter UI remains easy to build
- creating a new room becomes mostly composition rather than custom illustration

The central principle is:

> **Use 3D as an asset factory, not as the runtime.**

And the visual goal is:

> **A living 2.5D miniature home whose individual objects respond to the user's real-world chores.**
