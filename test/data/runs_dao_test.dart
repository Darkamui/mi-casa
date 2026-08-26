import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/data/database.dart';
import 'package:micasa/data/tables/runs_table.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('startRun then endRun updates endedAt and momentumChainLength',
      () async {
    await db.runsDao.startRun(RunsCompanion.insert(
      id: 'run-1',
      startedAt: DateTime(2026, 1, 1, 9),
      energyLevel: EnergyLevel.quickRun,
    ));

    await db.runsDao.endRun(
      runId: 'run-1',
      endedAt: DateTime(2026, 1, 1, 9, 20),
      momentumChainLength: 3,
    );

    final history = await db.runsDao.getRunHistory();
    expect(history, hasLength(1));
    expect(history.first.endedAt, DateTime(2026, 1, 1, 9, 20));
    expect(history.first.momentumChainLength, 3);
    expect(history.first.energyLevel, EnergyLevel.quickRun);
  });

  test('getRunHistory orders most recent first', () async {
    await db.runsDao.startRun(RunsCompanion.insert(
      id: 'run-1',
      startedAt: DateTime(2026, 1, 1, 9),
      energyLevel: EnergyLevel.standardRun,
    ));
    await db.runsDao.startRun(RunsCompanion.insert(
      id: 'run-2',
      startedAt: DateTime(2026, 1, 2, 9),
      energyLevel: EnergyLevel.bareMinimum,
    ));

    final history = await db.runsDao.getRunHistory();

    expect(history, hasLength(2));
    expect(history.first.id, 'run-2');
    expect(history.last.id, 'run-1');
  });
}
