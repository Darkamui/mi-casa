// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chore_completions_dao.dart';

// ignore_for_file: type=lint
mixin _$ChoreCompletionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $RoomsTable get rooms => attachedDatabase.rooms;
  $ChoresTable get chores => attachedDatabase.chores;
  $ChoreCompletionsTable get choreCompletions =>
      attachedDatabase.choreCompletions;
  ChoreCompletionsDaoManager get managers => ChoreCompletionsDaoManager(this);
}

class ChoreCompletionsDaoManager {
  final _$ChoreCompletionsDaoMixin _db;
  ChoreCompletionsDaoManager(this._db);
  $$RoomsTableTableManager get rooms =>
      $$RoomsTableTableManager(_db.attachedDatabase, _db.rooms);
  $$ChoresTableTableManager get chores =>
      $$ChoresTableTableManager(_db.attachedDatabase, _db.chores);
  $$ChoreCompletionsTableTableManager get choreCompletions =>
      $$ChoreCompletionsTableTableManager(
        _db.attachedDatabase,
        _db.choreCompletions,
      );
}
