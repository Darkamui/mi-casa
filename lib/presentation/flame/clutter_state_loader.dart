import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class ClutterEntry {
  const ClutterEntry({
    required this.layer,
    required this.sprite,
    required this.anchor,
  });

  final String layer;
  final String sprite;
  final String anchor;

  factory ClutterEntry.fromJson(Map<String, dynamic> json) => ClutterEntry(
        layer: json['layer'] as String,
        sprite: json['sprite'] as String,
        anchor: json['anchor'] as String,
      );
}

/// Parallel in shape to lib/simulation/content_loader.dart, but living in
/// lib/presentation/ since it maps state names directly to sprite asset
/// names, which lib/simulation/ must never know about.
class ClutterStateLoader {
  const ClutterStateLoader();

  Map<String, List<ClutterEntry>> parseClutterStates(String jsonSource) {
    final map = jsonDecode(jsonSource) as Map<String, dynamic>;
    return map.map(
      (state, entries) => MapEntry(
        state,
        (entries as List<dynamic>)
            .map((e) => ClutterEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
  }

  Future<Map<String, List<ClutterEntry>>> loadClutterStates() async {
    final source = await rootBundle
        .loadString('content/clutter/kitchen_clutter_states.json');
    return parseClutterStates(source);
  }
}
