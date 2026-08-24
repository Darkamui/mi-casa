import 'package:drift/drift.dart';

import 'chores_table.dart';

class ChoreCompletions extends Table {
  TextColumn get id => text()();
  TextColumn get choreId => text().references(Chores, #id)();
  DateTimeColumn get completedAt => dateTime()();
  RealColumn get actualDurationMinutes => real()();

  @override
  Set<Column> get primaryKey => {id};
}
