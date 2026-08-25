import 'dart:convert';
import 'dart:ui' show Rect, Size;

/// A tappable region of the room illustration (direction doc §1/§2).
///
/// The room is one finished painting, so interaction points are invisible
/// zones positioned over meaningful parts of it rather than separate
/// sprites. Areas are normalised 0..1 against the room frame so the same
/// data works at any render size.
class RoomHotspot {
  const RoomHotspot({
    required this.id,
    required this.label,
    required this.taskId,
    required this.area,
  });

  final String id;
  final String label;

  /// The task in `content/tasks/tasks.json` this zone offers.
  final String taskId;

  /// Normalised rect within the room frame.
  final Rect area;

  factory RoomHotspot.fromJson(Map<String, dynamic> json) => RoomHotspot(
        id: json['id'] as String,
        label: json['label'] as String,
        taskId: json['taskId'] as String,
        area: _rectFrom(json['area'] as List<dynamic>, 'hotspot ${json['id']}'),
      );

  /// This zone's pixel rect inside a room frame of [frame].
  Rect resolve(Size frame) => Rect.fromLTWH(
        area.left * frame.width,
        area.top * frame.height,
        area.width * frame.width,
        area.height * frame.height,
      );
}

/// A small state prop drawn over the base illustration (doc §5) — the base
/// room is never swapped out, only stateful objects appear and disappear.
class RoomOverlay {
  const RoomOverlay({
    required this.id,
    required this.asset,
    required this.area,
  });

  final String id;
  final String asset;
  final Rect area;

  factory RoomOverlay.fromJson(Map<String, dynamic> json) => RoomOverlay(
        id: json['id'] as String,
        asset: json['asset'] as String,
        area: _rectFrom(json['area'] as List<dynamic>, 'overlay ${json['id']}'),
      );

  Rect resolve(Size frame) => Rect.fromLTWH(
        area.left * frame.width,
        area.top * frame.height,
        area.width * frame.width,
        area.height * frame.height,
      );
}

/// A room, as authored in `content/rooms/*.json`.
///
/// CLAUDE.md's content-driven rule applies: adding a room must not require
/// a code change, so layer paths, hotspots, and overlay placement all live
/// in data.
class RoomDefinition {
  const RoomDefinition({
    required this.id,
    required this.aspectRatio,
    required this.baseAsset,
    required this.overlays,
    required this.hotspots,
    required this.companionSpot,
    this.companionHeight = 0.26,
  });

  final String id;

  /// Width / height of the painting. The frame letterboxes to this rather
  /// than distorting, so every normalised area below stays true to the art.
  final double aspectRatio;

  /// The one finished illustration this room is (direction doc §1). Not a
  /// stack of registered layers, not a set of furniture sprites — the
  /// painting already encodes perspective, lighting, and occlusion.
  final String baseAsset;

  final List<RoomOverlay> overlays;
  final List<RoomHotspot> hotspots;

  /// Where the companion stands, normalised, as its bottom-centre point.
  final ({double x, double y}) companionSpot;

  /// How tall the companion stands, as a fraction of the frame height.
  ///
  /// Data, not code: it is a statement about *this* painting's scale. A
  /// portrait room is far taller than a landscape one at the same width, so
  /// a single hardcoded fraction makes the companion either a mouse or a
  /// bear depending on which illustration is loaded.
  final double companionHeight;

  factory RoomDefinition.fromJson(Map<String, dynamic> json) {
    final spot = json['companionSpot'] as List<dynamic>;
    return RoomDefinition(
      id: json['id'] as String,
      aspectRatio: (json['aspectRatio'] as num).toDouble(),
      baseAsset: json['base'] as String,
      overlays: (json['overlays'] as List<dynamic>? ?? const [])
          .map((e) => RoomOverlay.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      hotspots: (json['hotspots'] as List<dynamic>)
          .map((e) => RoomHotspot.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      companionSpot: (
        x: (spot[0] as num).toDouble(),
        y: (spot[1] as num).toDouble()
      ),
      companionHeight:
          (json['companionHeight'] as num?)?.toDouble() ?? 0.26,
    );
  }

  static RoomDefinition parse(String source) =>
      RoomDefinition.fromJson(jsonDecode(source) as Map<String, dynamic>);

  RoomOverlay? overlayById(String id) {
    for (final overlay in overlays) {
      if (overlay.id == id) return overlay;
    }
    return null;
  }

  RoomHotspot? hotspotById(String id) {
    for (final hotspot in hotspots) {
      if (hotspot.id == id) return hotspot;
    }
    return null;
  }

  /// Where in the painting a task lives - so a completion can be celebrated
  /// at the sink rather than in the middle of the screen.
  RoomHotspot? hotspotForTask(String taskId) {
    for (final hotspot in hotspots) {
      if (hotspot.taskId == taskId) return hotspot;
    }
    return null;
  }
}

Rect _rectFrom(List<dynamic> values, String what) {
  if (values.length != 4) {
    throw FormatException('$what: area must be [left, top, width, height]');
  }
  final v = values.map((e) => (e as num).toDouble()).toList();
  return Rect.fromLTWH(v[0], v[1], v[2], v[3]);
}
