// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chores_dao.dart';

// ignore_for_file: type=lint
mixin _$ChoresDaoMixin on DatabaseAccessor<AppDatabase> {
  $RoomsTable get rooms => attachedDatabase.rooms;
  $ChoresTable get chores => attachedDatabase.chores;
  ChoresDaoManager get managers => ChoresDaoManager(this);
}

class ChoresDaoManager {
  final _$ChoresDaoMixin _db;
  ChoresDaoManager(this._db);
  $$RoomsTableTableManager get rooms =>
      $$RoomsTableTableManager(_db.attachedDatabase, _db.rooms);
  $$ChoresTableTableManager get chores =>
      $$ChoresTableTableManager(_db.attachedDatabase, _db.chores);
}
