// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entropy_state_dao.dart';

// ignore_for_file: type=lint
mixin _$EntropyStateDaoMixin on DatabaseAccessor<AppDatabase> {
  $RoomsTable get rooms => attachedDatabase.rooms;
  $ChoresTable get chores => attachedDatabase.chores;
  $EntropyStatesTable get entropyStates => attachedDatabase.entropyStates;
  EntropyStateDaoManager get managers => EntropyStateDaoManager(this);
}

class EntropyStateDaoManager {
  final _$EntropyStateDaoMixin _db;
  EntropyStateDaoManager(this._db);
  $$RoomsTableTableManager get rooms =>
      $$RoomsTableTableManager(_db.attachedDatabase, _db.rooms);
  $$ChoresTableTableManager get chores =>
      $$ChoresTableTableManager(_db.attachedDatabase, _db.chores);
  $$EntropyStatesTableTableManager get entropyStates =>
      $$EntropyStatesTableTableManager(_db.attachedDatabase, _db.entropyStates);
}
