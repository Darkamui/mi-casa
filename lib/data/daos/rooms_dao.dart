import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/rooms_table.dart';

part 'rooms_dao.g.dart';

@DriftAccessor(tables: [Rooms])
class RoomsDao extends DatabaseAccessor<AppDatabase> with _$RoomsDaoMixin {
  RoomsDao(super.db);

  Future<void> insertRoom(RoomsCompanion room) => into(rooms).insert(room);

  Future<List<Room>> getAllRooms() => (select(rooms)
        ..orderBy([(r) => OrderingTerm(expression: r.sortOrder)]))
      .get();

  Stream<List<Room>> watchAllRooms() => (select(rooms)
        ..orderBy([(r) => OrderingTerm(expression: r.sortOrder)]))
      .watch();
}
