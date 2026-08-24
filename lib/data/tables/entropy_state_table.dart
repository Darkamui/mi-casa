import 'package:drift/drift.dart';

import 'chores_table.dart';

class EntropyStates extends Table {
  TextColumn get choreId => text().references(Chores, #id)();
  DateTimeColumn get lastCompletedAt => dateTime().nullable()();
  RealColumn get learnedRisePerHour => real().nullable()();

  @override
  Set<Column> get primaryKey => {choreId};
}
