import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'models/adjacency_edge.dart';
import 'models/room_type_definition.dart';
import 'models/task_definition.dart';

class ContentLoader {
  const ContentLoader();

  List<RoomTypeDefinition> parseRoomTypes(String jsonSource) {
    final list = jsonDecode(jsonSource) as List<dynamic>;
    return list
        .map((e) => RoomTypeDefinition.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<TaskDefinition> parseTasks(String jsonSource) {
    final list = jsonDecode(jsonSource) as List<dynamic>;
    return list
        .map((e) => TaskDefinition.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<AdjacencyEdge> parseAdjacencyEdges(String jsonSource) {
    final list = jsonDecode(jsonSource) as List<dynamic>;
    return list
        .map((e) => AdjacencyEdge.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RoomTypeDefinition>> loadRoomTypes() async {
    final source = await rootBundle.loadString('content/rooms/room_types.json');
    return parseRoomTypes(source);
  }

  Future<List<TaskDefinition>> loadTasks() async {
    final source = await rootBundle.loadString('content/tasks/tasks.json');
    return parseTasks(source);
  }

  Future<List<AdjacencyEdge>> loadAdjacencyEdges() async {
    final source = await rootBundle.loadString('content/adjacency/edges.json');
    return parseAdjacencyEdges(source);
  }
}
