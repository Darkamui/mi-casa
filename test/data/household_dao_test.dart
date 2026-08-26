import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/data/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('getHousehold creates the default row on first access', () async {
    final household = await db.householdDao.getHousehold();

    expect(household.id, 'default');
    expect(household.name, isNull);
  });

  test('getHousehold does not duplicate the row on repeat calls', () async {
    await db.householdDao.getHousehold();
    await db.householdDao.getHousehold();

    final all = await db.select(db.households).get();
    expect(all, hasLength(1));
  });

  test('setName updates the household name', () async {
    await db.householdDao.setName('The Burrow');

    final household = await db.householdDao.getHousehold();
    expect(household.name, 'The Burrow');
  });

  test('watchHousehold emits after setName', () async {
    await db.householdDao.getHousehold();

    final future = db.householdDao.watchHousehold().skip(1).first;

    await db.householdDao.setName('Casa Nova');

    final updated = await future;
    expect(updated.name, 'Casa Nova');
  });
}
