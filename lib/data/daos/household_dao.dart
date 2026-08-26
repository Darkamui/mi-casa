import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/household_table.dart';

part 'household_dao.g.dart';

const _defaultHouseholdId = 'default';

/// The single household row. There is only ever one - Phase 0 has no
/// multiple-homes concept (spec §7, deferred).
@DriftAccessor(tables: [Households])
class HouseholdDao extends DatabaseAccessor<AppDatabase>
    with _$HouseholdDaoMixin {
  HouseholdDao(super.db);

  Future<Household> getHousehold() async {
    final existing = await (select(households)
          ..where((h) => h.id.equals(_defaultHouseholdId)))
        .getSingleOrNull();
    if (existing != null) return existing;

    await into(households).insert(
      HouseholdsCompanion.insert(
        id: _defaultHouseholdId,
        createdAt: DateTime.now(),
      ),
    );
    return (select(households)
          ..where((h) => h.id.equals(_defaultHouseholdId)))
        .getSingle();
  }

  Stream<Household> watchHousehold() => (select(households)
        ..where((h) => h.id.equals(_defaultHouseholdId)))
      .watchSingle();

  Future<void> setName(String? name) async {
    await getHousehold();
    await (update(households)
          ..where((h) => h.id.equals(_defaultHouseholdId)))
        .write(HouseholdsCompanion(name: Value(name)));
  }
}
