class DepthEntry {
  const DepthEntry({required this.id, required this.floorY});

  final String id;
  final double floorY;
}

/// Given each prop's floor-contact Y, assigns Flame `priority` values so
/// smaller Y renders first (parent doc §19). Computed once at composition
/// time, not per frame. Ties break by input order for determinism.
Map<String, int> assignDepthPriorities(List<DepthEntry> entries) {
  final indexed = entries.asMap().entries.toList()
    ..sort((a, b) {
      final cmp = a.value.floorY.compareTo(b.value.floorY);
      return cmp != 0 ? cmp : a.key.compareTo(b.key);
    });

  return {
    for (var i = 0; i < indexed.length; i++) indexed[i].value.id: i,
  };
}
