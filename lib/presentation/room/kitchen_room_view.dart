import 'package:flutter/material.dart';

import 'room_definition.dart';
import 'room_vitality.dart';

/// The interactive storybook room (direction doc §1, §13).
///
/// One finished illustration, plus invisible hotspots, plus a small number
/// of state overlays and a companion. Deliberately plain Flutter: `Stack`,
/// `Positioned`, `AnimatedOpacity`. There is no game engine, no per-prop
/// sprite composition, and no depth sorting — the painting already encodes
/// all of that.
class KitchenRoomView extends StatelessWidget {
  const KitchenRoomView({
    super.key,
    required this.room,
    required this.vitality,
    required this.showDishPile,
    required this.companionMood,
    this.onHotspotTap,
    this.onCompanionTap,
    this.debugShowHotspots = false,
  });

  final RoomDefinition room;
  final RoomVitality vitality;
  final bool showDishPile;

  /// Overrides the vitality's own mood — used so the companion can react
  /// to a moment (celebrating) without the room changing state.
  final CompanionMood? companionMood;

  final void Function(RoomHotspot hotspot)? onHotspotTap;
  final VoidCallback? onCompanionTap;

  /// Paints the hotspot rects. Development aid for tuning the JSON areas
  /// against the illustration.
  final bool debugShowHotspots;

  @override
  Widget build(BuildContext context) {
    final treatment = vitality.treatment;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Letterbox rather than distort: every hotspot and overlay area is
        // authored against the painting's own proportions.
        final frame = _fitFrame(constraints.biggest, room.aspectRatio);

        return Center(
          child: SizedBox(
            width: frame.width,
            height: frame.height,
            child: ColorFiltered(
              colorFilter: saturationFilter(treatment.saturation),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned.fill(
                    child: Image.asset(room.baseAsset, fit: BoxFit.cover),
                  ),
                  if (showDishPile) _overlay(room.overlayById('dish_pile'), frame),
                  _companion(frame, treatment),
                  ..._hotspots(frame),
                  // Ambient wash sits above the art but below nothing
                  // interactive - IgnorePointer keeps taps reaching through.
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        color: treatment.ambientTint
                            .withValues(alpha: treatment.tintStrength),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _overlay(RoomOverlay? overlay, Size frame) {
    if (overlay == null) return const SizedBox.shrink();
    final rect = overlay.resolve(frame);
    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: IgnorePointer(
        child: Image.asset(overlay.asset, fit: BoxFit.contain),
      ),
    );
  }

  Widget _companion(Size frame, VitalityTreatment treatment) {
    final mood = companionMood ?? treatment.companionMood;
    // Sized as a fraction of the frame so it stays in proportion with the
    // painted furniture at every window size.
    final height = frame.height * 0.26;
    return Positioned(
      left: room.companionSpot.x * frame.width - height * 0.5,
      top: room.companionSpot.y * frame.height - height,
      height: height,
      child: GestureDetector(
        onTap: onCompanionTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Image.asset(
            mood.asset,
            key: ValueKey(mood),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Iterable<Widget> _hotspots(Size frame) sync* {
    for (final hotspot in room.hotspots) {
      final rect = hotspot.resolve(frame);
      yield Positioned(
        left: rect.left,
        top: rect.top,
        width: rect.width,
        height: rect.height,
        child: GestureDetector(
          onTap: onHotspotTap == null ? null : () => onHotspotTap!(hotspot),
          behavior: HitTestBehavior.opaque,
          child: debugShowHotspots
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.cyanAccent, width: 2),
                    color: Colors.cyanAccent.withValues(alpha: 0.15),
                  ),
                  child: Center(
                    child: Text(
                      hotspot.id,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11, shadows: [
                        Shadow(color: Colors.black, blurRadius: 3),
                      ]),
                    ),
                  ),
                )
              : const SizedBox.expand(),
        ),
      );
    }
  }
}

/// Largest box of [aspectRatio] that fits inside [available].
Size _fitFrame(Size available, double aspectRatio) {
  final width = available.width;
  final height = available.height;
  if (width / height > aspectRatio) {
    return Size(height * aspectRatio, height);
  }
  return Size(width, width / aspectRatio);
}
