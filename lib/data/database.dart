import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/chore_completions_dao.dart';
import 'daos/chores_dao.dart';
import 'daos/entropy_state_dao.dart';
import 'daos/household_dao.dart';
import 'daos/rooms_dao.dart';
import 'daos/runs_dao.dart';
import 'tables/chore_completions_table.dart';
import 'tables/chores_table.dart';
import 'tables/entropy_state_table.dart';
import 'tables/household_table.dart';
import 'tables/rooms_table.dart';
import 'tables/runs_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Rooms, Chores, ChoreCompletions, EntropyStates, Runs, Households],
  daos: [
    RoomsDao,
    ChoresDao,
    ChoreCompletionsDao,
    EntropyStateDao,
    RunsDao,
    HouseholdDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.open() : this(_openConnection());

  @override
  int get schemaVersion => 2;

  /// Store timestamps as ISO-8601 text rather than unix seconds.
  ///
  /// The integer format drops the UTC flag: a UTC `DateTime` written and read
  /// back comes out as a *local* one for the same instant. Everything then
  /// still compares equal by moment but not by value, and the codebase ends
  /// up quietly mixing the two kinds. Entropy is measured in elapsed hours
  /// across days-long gaps, so this is not a difference worth carrying.
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

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'micasa.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
