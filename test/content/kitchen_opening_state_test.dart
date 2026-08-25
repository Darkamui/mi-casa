import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/simulation/adjacency_graph.dart';
import 'package:micasa/simulation/combo_engine.dart';
import 'package:micasa/simulation/content_loader.dart';
import 'package:micasa/simulation/entropy_engine.dart';
import 'package:micasa/simulation/kitchen_session.dart';
import 'package:micasa/simulation/models/task_definition.dart';

/// Guards the *tuned numbers* in `tasks.json`, which nothing else does.
///
/// `kitchen_session_test.dart` deliberately uses invented rates so tuning
/// cannot break its rules - which means a wrong rate in the shipped content
/// produces a green suite and an incoherent room. That is exactly what
/// happened: dishes were authored at a 7-day decay, so the app opened
/// reading "Slipping" over a spotless sink.
void main() {
  const loader = ContentLoader();
  late List<TaskDefinition> tasks;
  late KitchenSessionEngine engine;

  final now = DateTime.utc(2026, 8, 24, 20);

  setUpAll(() {
    tasks = loader
        .parseTasks(File('content/tasks/tasks.json').readAsStringSync())
        .where((t) => t.roomTypeId == 'kitchen')
        .toList();
    final edges = loader
        .parseAdjacencyEdges(File('content/adjacency/edges.json').readAsStringSync());
    engine = KitchenSessionEngine(
      tasks: tasks,
      comboEngine: ComboEngine(AdjacencyGraph(edges)),
    );
  });

  test('no kitchen task takes longer than four days to fully decay', () {
    // A chore nobody notices for most of a week has nothing to do with the
    // daily rhythm this game is built around, and a task that decays that
    // slowly can never drive a visual. Catches transposed digits.
    for (final task in tasks) {
      final days = 1 / task.defaultRisePerHour / 24;
      expect(days, lessThanOrEqualTo(4.0),
          reason: '${task.id} takes ${days.toStringAsFixed(1)} days to decay');
    }
  });

  test('the room opens somewhere with room to move in both directions', () {
    final vitality = engine.vitality(engine.seed(now: now), now);

    // Opening at Thriving leaves nothing to do; opening at Critical means
    // neglect can no longer register.
    expect(vitality, isNot(NeedState.thriving));
    expect(vitality, isNot(NeedState.critical));
  });

  test('the opening HUD and the opening painting agree', () {
    // The dish pile is the room's only state overlay. If the HUD says the
    // kitchen needs attention while the art shows a clean sink, the player
    // is being told two different things.
    final session = engine.seed(now: now);
    final vitality = engine.vitality(session, now);

    expect(vitality.index, greaterThanOrEqualTo(NeedState.slipping.index));
    expect(engine.showsDishPile(session, now), isTrue,
        reason: 'the room reads as ${vitality.name} but shows nothing wrong');
  });
}
