import 'package:drift/drift.dart';

import 'rooms_table.dart';

class Chores extends Table {
  TextColumn get id => text()();
  TextColumn get roomId => text().references(Rooms, #id)();
  TextColumn get taskDefinitionId => text()();
  BoolColumn get isRemoved => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
