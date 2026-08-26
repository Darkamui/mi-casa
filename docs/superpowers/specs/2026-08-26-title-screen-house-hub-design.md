# Title screen, house hub, and in-app menu — design

Date: 2026-08-26

## Why

The app currently opens directly into the kitchen with no framing around it
— no title, no sense of "a house" beyond the one room, no way to rename
anything or get back to a menu. This adds an app shell around the existing
kitchen experience: a title screen, a house hub (room selection), a
nameable household, and an in-app menu reachable from the room.

## Deliberate spec override

`docs/micasa_spec.md` §2.3 currently says the app opens directly into a
room with no screen before play. This design replaces that with a title
screen carrying a real menu (Enter House / Settings), on every launch —
approved explicitly by the product owner during brainstorming, overriding
the locked decision. §2.3 and the CLAUDE.md locked-decisions summary are
updated as part of this work so both stay accurate. Everything else in
§2.3 (no account, no permissions, no questionnaire, playable-not-configured
home building) is unchanged and still applies once the player is past the
title screen.

## Screens

### `TitleScreen`

- Animated branding: the companion sprite (`content/art/companion/
  companion_idle.png`, already shipped) with a small idle motion (sway/
  float), app name, on a simple gradient/background. Never fully static,
  matching the existing art-direction rule.
- Two actions: **Enter House** (primary, pushes `HouseScreen`) and
  **Settings** (secondary, opens the same menu sheet described below).
- Collects nothing. No text field, no toggles, no first-run branching —
  it looks identical on launch #1 and launch #100.

### `HouseScreen` (room hub)

- Reads room types from `content/rooms/room_types.json`, which gains an
  `"available"` boolean per entry (kitchen: `true`; new placeholder
  entries for Living Room, Bathroom, Bedroom: `false`). Missing the field
  means available, so the existing kitchen entry needs no edit.
- Renders one tile per room type. An available tile is tappable and
  pushes `KitchenScreen` for `kitchen` (other available ids would push
  their own room screen once one exists — out of scope here, there are
  none). An unavailable tile renders visually locked (dimmed, a lock
  icon, "Coming soon") and does nothing on tap.
- Locked tiles use a simple stylized icon + label, not full illustration
  — there is no art for those rooms yet, and painting placeholder art
  that will be thrown away isn't worth it.
- A house nameplate at the top shows the current household name
  (`Household.name`, default display "My Home" when null). Tapping it
  opens a single-field rename dialog, prefilled, Cancel/Save. Entirely
  optional — never appears unprompted, never blocks reaching a room.

### In-app menu (bottom sheet)

- A new icon in `KitchenScreen`'s existing HUD row (alongside
  `MuteButton`/`VoiceButton`) opens a `showModalBottomSheet`.
- Contents: household name (read-only here, editing stays on
  `HouseScreen` to avoid two rename entry points), the existing mute
  toggle (reuses `MuteButton`'s provider, not a second implementation),
  a momentum line reading from the same `kitchenSessionProvider` state
  already on screen, and a "Back to House" button that pops to
  `HouseScreen`.
- Purely a UI surface — no new simulation state, no new phase in
  `KitchenSession`.

## Data model

New Drift table `Household`, single row, fixed id `'default'`:

```dart
class Households extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

`HouseholdDao` with `watchHousehold()`, `getHousehold()`, and
`setName(String? name)` (upserting the single row, creating it with a
null name on first access if absent). `AppDatabase.schemaVersion` bumps
to 2; the migration only creates the new table (nothing to backfill).

## Content changes

`content/rooms/room_types.json` gains three placeholder entries
(`living_room`, `bathroom`, `bedroom`) with `"available": false` and no
`taskIds` (empty list — they're never loaded as playable rooms).
`RoomTypeDefinition` (or wherever `room_types.json` is parsed —
`content_loader.dart`/`models/room_type_definition.dart`) gains the
`available` field, defaulting to `true` when absent so the existing
kitchen entry and any tests referencing it don't need edits.

Adding a real fifth room later is still just: flip `available: true`,
add its room JSON — no code change, per the content-driven rule in
CLAUDE.md.

## Navigation

Plain `Navigator.push`/`pop`, matching the current single-`MaterialApp`
setup — no router package (`go_router` is explicitly post-Phase-0 per
CLAUDE.md). `main.dart`'s `home:` becomes `TitleScreen`.

## Testing

- `HouseholdDao`: a headless Drift test in `test/data/household_dao_test.dart`,
  following the pattern of the existing `test/data/rooms_dao_test.dart` —
  round-trip default row creation, name update, watch stream emits on
  change.
- `RoomTypeDefinition.available` parsing: extend
  `test/simulation/models/room_type_definition_test.dart` for the new
  field (default true, explicit false).
- Screens (`TitleScreen`, `HouseScreen`, menu sheet) are manual/visual
  verification — this is presentation-layer UI with no `lib/simulation/`
  logic, consistent with how `KitchenScreen` itself is tested (widget
  tests exist for sub-widgets, not the screen's navigation shell).

## Out of scope

- Any new playable room beyond kitchen (no art, no tasks, no hotspots
  for Living Room/Bathroom/Bedroom — they stay locked tiles).
- Save slots / multiple households — "Enter House" always goes to the
  one household row.
- Anything from spec §6/§7 (residents, themes, multiple homes, etc.).
