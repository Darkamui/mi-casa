// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'household_dao.dart';

// ignore_for_file: type=lint
mixin _$HouseholdDaoMixin on DatabaseAccessor<AppDatabase> {
  $HouseholdsTable get households => attachedDatabase.households;
  HouseholdDaoManager get managers => HouseholdDaoManager(this);
}

class HouseholdDaoManager {
  final _$HouseholdDaoMixin _db;
  HouseholdDaoManager(this._db);
  $$HouseholdsTableTableManager get households =>
      $$HouseholdsTableTableManager(_db.attachedDatabase, _db.households);
}
