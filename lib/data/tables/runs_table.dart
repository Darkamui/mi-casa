import 'package:drift/drift.dart';

enum EnergyLevel { bareMinimum, quickRun, standardRun, letsFixThisPlace }

class Runs extends Table {
  TextColumn get id => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get energyLevel => textEnum<EnergyLevel>()();
  IntColumn get momentumChainLength => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
