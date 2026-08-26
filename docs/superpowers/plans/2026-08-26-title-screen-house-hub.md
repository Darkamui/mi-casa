# Title Screen, House Hub & In-App Menu Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an app shell around the existing kitchen: a title screen, a
room-selection house hub, a nameable household, and an in-app menu reachable
from the room.

**Architecture:** A `Household` Drift table (single row) backs a nameable
house. `content/rooms/room_types.json` gains an `available` flag so the
house hub can render locked tiles for rooms with no content yet, with zero
code change required to unlock a room later. Three new screens
(`TitleScreen`, `HouseScreen`) plus one shared bottom sheet
(`showAppMenuSheet`) are added on top of the untouched `KitchenScreen`;
navigation is plain `Navigator.push`/`pop`.

**Tech Stack:** Flutter, Riverpod, Drift/SQLite (`NativeDatabase`), existing
`ContentLoader` for JSON content.

**Spec:** `docs/superpowers/specs/2026-08-26-title-screen-house-hub-design.md`

## Global Constraints

- No percentages anywhere in the UI (spec §2.2) — nothing here shows one.
- Content-driven: adding/unlocking a room type must not require a code
  change (CLAUDE.md) — room availability is a JSON flag, read generically.
- Local-first, no backend, no login, no sync in Phase 0 (CLAUDE.md) — the
  household name lives only in the local SQLite database.
- `lib/simulation/` stays pure and never imports from `lib/presentation/`
  (CLAUDE.md) — none of this work touches `lib/simulation/` logic, only
  `RoomTypeDefinition`'s JSON parsing.
- The title screen collects nothing and looks identical on every launch —
  it is explicitly not the rejected 5-step config wizard (spec §2.3).

---

### Task 1: Household data layer

**Files:**
- Create: `lib/data/tables/household_table.dart`
- Create: `lib/data/daos/household_dao.dart`
- Modify: `lib/data/database.dart`
- Test: `test/data/household_dao_test.dart`

**Interfaces:**
- Consumes: nothing new (follows the existing `RoomsDao`/`Rooms` pattern in
  `lib/data/daos/rooms_dao.dart` and `lib/data/tables/rooms_table.dart`).
- Produces: `Households` table, `Household` row class (Drift-generated),
  `HouseholdDao` with `Future<Household> getHousehold()`,
  `Stream<Household> watchHousehold()`, `Future<void> setName(String? name)`.
  `AppDatabase.householdDao` (Drift-generated accessor, same mechanism as
  `AppDatabase.roomsDao`).

- [ ] **Step 1: Write the failing test**

```dart
// test/data/household_dao_test.dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/data/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('getHousehold creates the default row on first access', () async {
    final household = await db.householdDao.getHousehold();

    expect(household.id, 'default');
    expect(household.name, isNull);
  });

  test('getHousehold does not duplicate the row on repeat calls', () async {
    await db.householdDao.getHousehold();
    await db.householdDao.getHousehold();

    final all = await db.select(db.households).get();
    expect(all, hasLength(1));
  });

  test('setName updates the household name', () async {
    await db.householdDao.setName('The Burrow');

    final household = await db.householdDao.getHousehold();
    expect(household.name, 'The Burrow');
  });

  test('watchHousehold emits after setName', () async {
    await db.householdDao.getHousehold();

    final future = db.householdDao.watchHousehold().skip(1).first;

    await db.householdDao.setName('Casa Nova');

    final updated = await future;
    expect(updated.name, 'Casa Nova');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/household_dao_test.dart`
Expected: FAIL to compile — `db.householdDao` and `db.households` don't
exist yet.

- [ ] **Step 3: Create the table**

```dart
// lib/data/tables/household_table.dart
import 'package:drift/drift.dart';

class Households extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

- [ ] **Step 4: Create the DAO**

```dart
// lib/data/daos/household_dao.dart
import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/household_table.dart';

part 'household_dao.g.dart';

const _defaultHouseholdId = 'default';

/// The single household row. There is only ever one - Phase 0 has no
/// multiple-homes concept (spec §7, deferred).
@DriftAccessor(tables: [Households])
class HouseholdDao extends DatabaseAccessor<AppDatabase>
    with _$HouseholdDaoMixin {
  HouseholdDao(super.db);

  Future<Household> getHousehold() async {
    final existing = await (select(households)
          ..where((h) => h.id.equals(_defaultHouseholdId)))
        .getSingleOrNull();
    if (existing != null) return existing;

    await into(households).insert(
      HouseholdsCompanion.insert(
        id: _defaultHouseholdId,
        createdAt: DateTime.now(),
      ),
    );
    return (select(households)
          ..where((h) => h.id.equals(_defaultHouseholdId)))
        .getSingle();
  }

  Stream<Household> watchHousehold() => (select(households)
        ..where((h) => h.id.equals(_defaultHouseholdId)))
      .watchSingle();

  Future<void> setName(String? name) async {
    await getHousehold();
    await (update(households)
          ..where((h) => h.id.equals(_defaultHouseholdId)))
        .write(HouseholdsCompanion(name: Value(name)));
  }
}
```

- [ ] **Step 5: Wire the table/DAO into `AppDatabase` and bump the schema**

Modify `lib/data/database.dart`:

```dart
import 'daos/household_dao.dart';
import 'tables/household_table.dart';
// ...existing imports...

@DriftDatabase(
  tables: [Rooms, Chores, ChoreCompletions, EntropyStates, Runs, Households],
  daos: [RoomsDao, ChoresDao, ChoreCompletionsDao, EntropyStateDao, RunsDao, HouseholdDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.open() : this(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(households);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  // ...rest unchanged...
}
```

- [ ] **Step 6: Generate Drift code**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: generates/updates `lib/data/database.g.dart` and creates
`lib/data/daos/household_dao.g.dart` with no errors.

- [ ] **Step 7: Run test to verify it passes**

Run: `flutter test test/data/household_dao_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 8: Commit**

```bash
git add lib/data/tables/household_table.dart lib/data/daos/household_dao.dart lib/data/daos/household_dao.g.dart lib/data/database.dart lib/data/database.g.dart test/data/household_dao_test.dart
git commit -m "feat: add Household table and DAO"
```

---

### Task 2: Room type availability flag

**Files:**
- Modify: `lib/simulation/models/room_type_definition.dart`
- Modify: `content/rooms/room_types.json`
- Test: `test/simulation/models/room_type_definition_test.dart`

**Interfaces:**
- Consumes: nothing new.
- Produces: `RoomTypeDefinition.available` (`bool`, defaults to `true`
  when the JSON key is absent). `content/rooms/room_types.json` gains
  `living_room`, `bathroom`, `bedroom` entries with `"available": false`.

- [ ] **Step 1: Write the failing tests**

Add to `test/simulation/models/room_type_definition_test.dart` (existing
file — keep the existing test, add these two):

```dart
  test('defaults available to true when the field is absent', () {
    final roomType = RoomTypeDefinition.fromJson(const {
      'id': 'kitchen',
      'name': 'Kitchen',
      'taskIds': <String>[],
    });

    expect(roomType.available, isTrue);
  });

  test('parses available: false', () {
    final roomType = RoomTypeDefinition.fromJson(const {
      'id': 'bathroom',
      'name': 'Bathroom',
      'taskIds': <String>[],
      'available': false,
    });

    expect(roomType.available, isFalse);
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/simulation/models/room_type_definition_test.dart`
Expected: FAIL — `available` is not a defined getter on
`RoomTypeDefinition`.

- [ ] **Step 3: Add the field**

```dart
// lib/simulation/models/room_type_definition.dart
class RoomTypeDefinition {
  const RoomTypeDefinition({
    required this.id,
    required this.name,
    required this.taskIds,
    this.available = true,
  });

  final String id;
  final String name;
  final List<String> taskIds;
  final bool available;

  factory RoomTypeDefinition.fromJson(Map<String, dynamic> json) {
    return RoomTypeDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      taskIds: (json['taskIds'] as List).cast<String>(),
      available: json['available'] as bool? ?? true,
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/simulation/models/room_type_definition_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Add the locked placeholder room types to content**

```json
[
  {
    "id": "kitchen",
    "name": "Kitchen",
    "taskIds": [
      "kitchen.dishes",
      "kitchen.clear_counter",
      "kitchen.wipe_counter",
      "kitchen.garbage",
      "kitchen.new_bag"
    ]
  },
  {
    "id": "living_room",
    "name": "Living Room",
    "taskIds": [],
    "available": false
  },
  {
    "id": "bathroom",
    "name": "Bathroom",
    "taskIds": [],
    "available": false
  },
  {
    "id": "bedroom",
    "name": "Bedroom",
    "taskIds": [],
    "available": false
  }
]
```

Replace the full contents of `content/rooms/room_types.json` with the JSON
above.

- [ ] **Step 6: Run the full test suite to confirm nothing else broke**

Run: `flutter test`
Expected: PASS — in particular
`test/simulation/content_loader_integration_test.dart` and
`test/simulation/content_loader_test.dart`, which read this file.

- [ ] **Step 7: Commit**

```bash
git add lib/simulation/models/room_type_definition.dart content/rooms/room_types.json test/simulation/models/room_type_definition_test.dart
git commit -m "feat: add room type availability flag"
```

---

### Task 3: House providers

**Files:**
- Create: `lib/presentation/house/house_providers.dart`

**Interfaces:**
- Consumes: `ContentLoader.loadRoomTypes()` (Task 2's
  `lib/simulation/content_loader.dart`, unchanged), `databaseProvider` from
  `lib/presentation/scenes/kitchen_scene_controller.dart:42`,
  `AppDatabase.householdDao` (Task 1).
- Produces: `roomTypesProvider` (`FutureProvider<List<RoomTypeDefinition>>`),
  `householdProvider` (`StreamProvider<Household>`) — both consumed by
  Tasks 4-6.

- [ ] **Step 1: Create the providers file**

```dart
// lib/presentation/house/house_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../simulation/content_loader.dart';
import '../../simulation/models/room_type_definition.dart';
import '../scenes/kitchen_scene_controller.dart' show databaseProvider;

/// Room types available in the house hub (spec §2.3 step 1a).
/// Content-driven — unlocking a room is a `content/rooms/room_types.json`
/// edit only, never a code change.
final roomTypesProvider = FutureProvider<List<RoomTypeDefinition>>(
  (ref) => const ContentLoader().loadRoomTypes(),
);

/// The single household row, created on first access.
final householdProvider = StreamProvider<Household>((ref) async* {
  final dao = ref.watch(databaseProvider).householdDao;
  await dao.getHousehold();
  yield* dao.watchHousehold();
});
```

- [ ] **Step 2: Confirm it compiles**

Run: `flutter analyze lib/presentation/house/house_providers.dart`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/house/house_providers.dart
git commit -m "feat: add house hub providers"
```

---

### Task 4: Shared app menu sheet

**Files:**
- Create: `lib/presentation/house/app_menu_sheet.dart`

**Interfaces:**
- Consumes: `householdProvider` (Task 3), `mutedProvider` and
  `roomAudioProvider` via the existing `MuteButton` widget
  (`lib/presentation/widgets/mute_button.dart`), `kitchenSessionProvider`
  from `lib/presentation/scenes/kitchen_scene_controller.dart`.
- Produces: `Future<void> showAppMenuSheet(BuildContext context, {bool showBackToHouse = false})`,
  consumed by Task 5 (`TitleScreen`) and Task 7 (`KitchenScreen`).

- [ ] **Step 1: Create the sheet**

```dart
// lib/presentation/house/app_menu_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'house_providers.dart';
import '../scenes/kitchen_scene_controller.dart';
import '../widgets/mute_button.dart';

/// The one settings/menu surface in the app - opened from the title
/// screen's Settings button and from a HUD icon inside [KitchenScreen].
/// [showBackToHouse] is true only when there is a room screen underneath to
/// pop back past.
Future<void> showAppMenuSheet(
  BuildContext context, {
  bool showBackToHouse = false,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1E1B22),
    builder: (context) => _AppMenuSheet(showBackToHouse: showBackToHouse),
  );
}

class _AppMenuSheet extends ConsumerWidget {
  const _AppMenuSheet({required this.showBackToHouse});

  final bool showBackToHouse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final household = ref.watch(householdProvider).valueOrNull;
    final momentum =
        ref.watch(kitchenSessionProvider).valueOrNull?.momentum;
    final name = (household?.name?.trim().isNotEmpty ?? false)
        ? household!.name!
        : 'My Home';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                MuteButton(),
                SizedBox(width: 8),
                Text('Sound', style: TextStyle(color: Colors.white70)),
              ],
            ),
            if (momentum != null) ...[
              const SizedBox(height: 16),
              Text(
                'Momentum: $momentum',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            if (showBackToHouse) ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Back to House'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Confirm it compiles**

Run: `flutter analyze lib/presentation/house/app_menu_sheet.dart`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/house/app_menu_sheet.dart
git commit -m "feat: add shared app menu sheet"
```

---

### Task 5: House hub screen

**Files:**
- Create: `lib/presentation/screens/house_screen.dart`

**Interfaces:**
- Consumes: `roomTypesProvider`, `householdProvider` (Task 3),
  `databaseProvider` (`lib/presentation/scenes/kitchen_scene_controller.dart`),
  `KitchenScreen` (`lib/presentation/screens/kitchen_screen.dart`,
  unmodified until Task 7).
- Produces: `HouseScreen` widget, pushed by `TitleScreen` (Task 6).

- [ ] **Step 1: Create the screen**

```dart
// lib/presentation/screens/house_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../simulation/models/room_type_definition.dart';
import '../house/house_providers.dart';
import '../scenes/kitchen_scene_controller.dart' show databaseProvider;
import 'kitchen_screen.dart';

/// The house hub (room selection), reached only after "Enter House" on the
/// title screen (spec §2.3 step 1a). Room availability is content-driven -
/// unlocking a room later is a `content/rooms/room_types.json` edit, never
/// a code change here.
class HouseScreen extends ConsumerWidget {
  const HouseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomTypes = ref.watch(roomTypesProvider);
    final household = ref.watch(householdProvider).valueOrNull;
    final name = (household?.name?.trim().isNotEmpty ?? false)
        ? household!.name!
        : 'My Home';

    return Scaffold(
      backgroundColor: const Color(0xFF1E1B22),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _renameHousehold(context, ref, household?.name),
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: switch (roomTypes) {
                AsyncData(value: final types) => _tiles(types),
                AsyncError(:final error) => Center(
                    child: Text(
                      'Could not load rooms.\n$error',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _tiles(List<RoomTypeDefinition> types) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(24),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [for (final type in types) _RoomTile(type: type)],
    );
  }

  Future<void> _renameHousehold(
    BuildContext context,
    WidgetRef ref,
    String? current,
  ) async {
    final controller = TextEditingController(text: current ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Name your home'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == null) return;
    final trimmed = result.trim();
    await ref
        .read(databaseProvider)
        .householdDao
        .setName(trimmed.isEmpty ? null : trimmed);
  }
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({required this.type});

  final RoomTypeDefinition type;

  @override
  Widget build(BuildContext context) {
    final locked = !type.available;
    return Opacity(
      opacity: locked ? 0.45 : 1,
      child: Material(
        color: const Color(0xFF2A2530),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: locked ? null : () => _open(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  locked ? Icons.lock_outline : _iconFor(type.id),
                  color: Colors.white70,
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(type.name, style: const TextStyle(color: Colors.white)),
                if (locked) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Coming soon',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String id) => switch (id) {
        'kitchen' => Icons.kitchen_outlined,
        _ => Icons.door_front_door_outlined,
      };

  void _open(BuildContext context) {
    if (type.id != 'kitchen') return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const KitchenScreen()),
    );
  }
}
```

- [ ] **Step 2: Confirm it compiles**

Run: `flutter analyze lib/presentation/screens/house_screen.dart`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/screens/house_screen.dart
git commit -m "feat: add house hub screen"
```

---

### Task 6: Title screen

**Files:**
- Create: `lib/presentation/screens/title_screen.dart`

**Interfaces:**
- Consumes: `HouseScreen` (Task 5), `showAppMenuSheet` (Task 4),
  `content/art/companion/companion_idle.png` (already bundled per
  `pubspec.yaml`).
- Produces: `TitleScreen` widget, wired as the app's `home` in Task 7.

- [ ] **Step 1: Create the screen**

```dart
// lib/presentation/screens/title_screen.dart
import 'package:flutter/material.dart';

import '../house/app_menu_sheet.dart';
import 'house_screen.dart';

/// The very first thing a launch shows (spec §2.3, updated 2026-08-26).
///
/// Collects nothing - no field, no toggle, no first-run branching. It
/// looks identical on launch #1 and launch #100; this is a title screen
/// with a real menu, not the rejected 5-step config wizard.
class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1B22),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, -8 * _controller.value),
                child: child,
              ),
              child: Image.asset(
                'content/art/companion/companion_idle.png',
                height: 160,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'MiCasa',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HouseScreen()),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                child: Text('Enter House'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => showAppMenuSheet(context),
              child: const Text(
                'Settings',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Confirm it compiles**

Run: `flutter analyze lib/presentation/screens/title_screen.dart`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/screens/title_screen.dart
git commit -m "feat: add title screen"
```

---

### Task 7: Wire it all together

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/presentation/screens/kitchen_screen.dart`

**Interfaces:**
- Consumes: `TitleScreen` (Task 6), `showAppMenuSheet` (Task 4).
- Produces: the app now launches into `TitleScreen`; `KitchenScreen`'s HUD
  gains a menu icon.

- [ ] **Step 1: Point `main.dart` at the title screen**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/screens/title_screen.dart';

void main() {
  runApp(const ProviderScope(child: MiCasaApp()));
}

class MiCasaApp extends StatelessWidget {
  const MiCasaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'MiCasa',
      debugShowCheckedModeBanner: false,
      home: TitleScreen(),
    );
  }
}
```

- [ ] **Step 2: Add the menu icon to `KitchenScreen`'s HUD**

In `lib/presentation/screens/kitchen_screen.dart`, add the import:

```dart
import '../house/app_menu_sheet.dart';
```

Then in the `_room` method (around `lib/presentation/screens/kitchen_screen.dart:236-244`), change:

```dart
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VitalityHud(vitality: vitality, momentum: state.momentum),
                  const Spacer(),
                  const MuteButton(),
                  const VoiceButton(),
                ],
              ),
```

to:

```dart
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VitalityHud(vitality: vitality, momentum: state.momentum),
                  const Spacer(),
                  IconButton(
                    onPressed: () =>
                        showAppMenuSheet(context, showBackToHouse: true),
                    tooltip: 'Menu',
                    icon: const Icon(Icons.menu, color: Colors.white70),
                  ),
                  const MuteButton(),
                  const VoiceButton(),
                ],
              ),
```

- [ ] **Step 3: Run the full test suite**

Run: `flutter test`
Expected: PASS — every existing test (including
`test/presentation/room_fills_the_screen_test.dart` and
`test/widget_test.dart`) still passes since `KitchenScreen` itself is
unchanged in structure, only its HUD row gained one icon.

- [ ] **Step 4: Manual verification**

Run: `flutter run -d windows` (or the platform in use)
Expected: App opens on the title screen with the idle-swaying companion and
"MiCasa" title. Tapping "Enter House" shows the house hub with a "My Home"
nameplate, a tappable Kitchen tile, and three locked ("Coming soon") tiles.
Tapping the nameplate opens a rename dialog; saving a name updates the
nameplate immediately. Tapping the Kitchen tile enters the existing kitchen
experience unchanged. The new menu icon in the kitchen's HUD opens the
sheet with the household name, mute toggle, momentum, and "Back to House",
which returns to the house hub.

- [ ] **Step 5: Commit**

```bash
git add lib/main.dart lib/presentation/screens/kitchen_screen.dart
git commit -m "feat: wire title screen, house hub, and menu into the app"
```

---

## Self-Review Notes

- **Spec coverage:** title screen (Task 6/7), house hub with locked tiles
  (Task 5), nameable household (Tasks 1, 5), in-app menu (Tasks 4, 7),
  content-driven room availability (Task 2) — all covered. Out-of-scope
  items (new playable rooms, save slots) are explicitly excluded per the
  spec's "Out of scope" section and not present in any task.
- **Type consistency:** `RoomTypeDefinition.available`, `Household`/
  `HouseholdDao.getHousehold`/`watchHousehold`/`setName`, `roomTypesProvider`,
  `householdProvider`, and `showAppMenuSheet(context, {showBackToHouse})`
  are each defined once (Tasks 1-4) and used with matching names/signatures
  in every later task.
- **No placeholders:** every step above has literal code, not a
  description of code.
