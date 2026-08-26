import 'package:drift/drift.dart';

class Rooms extends Table {
  TextColumn get id => text()();
  TextColumn get roomTypeId => text()();
  TextColumn get name => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
