import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../effects/particle_burst.dart';
import 'ambient_life.dart';
import 'room_definition.dart';
import 'room_vitality.dart';

/// A completion to celebrate, at the point in the painting where it happened.
///
/// Carries its own id so a second completion at the same spot restarts the
/// burst instead of the framework reusing the finished one.
class RoomCelebration {
  const RoomCelebration({required this.id, required this.spot});

  final int id;

  /// Normalised 0..1 point in the painting.
  final ({double x, double y}) spot;
}

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
    this.showAffordances = true,
    this.celebration,
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

  /// Whether hotspots advertise themselves with a pulsing glow. Off while a
  /// quest card or task prompt is up, so the room goes quiet under a modal.
  final bool showAffordances;

  /// Non-null for the length of the celebration beat. Spec §4.1: completing
  /// something must produce a visible change, and it must happen where the
  /// work happened.
  final RoomCelebration? celebration;

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
        // Fill the window rather than letterbox it - up to the point where
        // filling it would start hiding the room. See [roomFrame]. Hotspots
        // and overlays resolve against this frame, so they stay locked to
        // the art at every size.
        final viewport = constraints.biggest;
        final frame = roomFrame(viewport, room.aspectRatio);
        final framed = frame.width < viewport.width - 0.5 ||
            frame.height < viewport.height - 0.5;

        return ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Whatever the painting does not reach is filled with the
              // painting itself, blurred back until it reads as the room's
              // own light rather than as empty screen.
              if (framed) _backdrop(treatment),
              OverflowBox(
                // The stack hands down tight constraints; without these the
                // frame cannot be smaller than the screen it sits in.
                minWidth: 0,
                minHeight: 0,
                maxWidth: frame.width,
                maxHeight: frame.height,
                child: SizedBox(
                  width: frame.width,
                  height: frame.height,
                  child: _scene(frame, treatment),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _scene(Size frame, VitalityTreatment treatment) => Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // The painting and its props take the vitality filter. The
          // affordances and the companion deliberately do not - a neglected
          // room must still be legible to tap. The colour comes back over a
          // beat rather than snapping. Spec §4.1 - the transformation *is*
          // the reward, and a reward that has already happened by the time
          // the eye arrives was never seen.
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween(
                begin: treatment.saturation,
                end: treatment.saturation,
              ),
              duration: const Duration(milliseconds: 1400),
              curve: Curves.easeOutCubic,
              builder: (context, saturation, child) => ColorFiltered(
                colorFilter: saturationFilter(saturation),
                child: child,
              ),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned.fill(
                    child: Image.asset(room.baseAsset, fit: BoxFit.cover),
                  ),
                  if (showDishPile)
                    _overlay(room.overlayById('dish_pile'), frame),
                  // Ambient wash: warm when cared for, cool when neglected
                  // (doc §7).
                  Positioned.fill(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 1400),
                      curve: Curves.easeOutCubic,
                      color: treatment.ambientTint
                          .withValues(alpha: treatment.tintStrength),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Above the painting, below everything you can touch.
          Positioned.fill(
            child: AmbientLife(
              treatment: treatment,
              lightSpot: room.lightSpot,
            ),
          ),
          if (celebration != null) _bloom(),
          _companion(frame, treatment),
          ..._hotspots(frame),
          if (celebration != null) _burst(celebration!, frame),
        ],
      );

  /// The painting again, blurred and dimmed, filling whatever the framed
  /// room leaves over.
  ///
  /// On a tall phone a 1.6:1 painting cannot fill the screen without most of
  /// it being cropped away (see [roomFrame]), so it is shown whole and the
  /// leftover space is lit by the room itself. It is the same illustration,
  /// not a second asset and not a composed background - direction doc §1.
  Widget _backdrop(VitalityTreatment treatment) => IgnorePointer(
        // Isolated: nothing here changes while the room animates, and a
        // full-screen blur is not something to re-rasterise every frame.
        child: RepaintBoundary(
          child: ColorFiltered(
            colorFilter: saturationFilter(treatment.saturation),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: 34,
                    sigmaY: 34,
                    tileMode: TileMode.clamp,
                  ),
                  child: Image.asset(room.baseAsset, fit: BoxFit.cover),
                ),
                // Pushed well back so the framed painting stays the subject.
                const ColoredBox(color: Color(0xB315131A)),
              ],
            ),
          ),
        ),
      );

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

  /// A warm swell of light across the whole room on completion - the
  /// "windows brighten" beat of §4.1, without needing a second painting.
  Widget _bloom() => Positioned.fill(
        child: IgnorePointer(
          child: _OneShotFade(
            key: ValueKey('bloom-${celebration!.id}'),
            duration: const Duration(milliseconds: 1200),
            builder: (t) => DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 0.9,
                  colors: [
                    const Color(0xFFFFE2A6).withValues(alpha: 0.30 * t),
                    const Color(0xFFFFD27D).withValues(alpha: 0.06 * t),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
        ),
      );

  Widget _burst(RoomCelebration celebration, Size frame) {
    // Proportional to the painting, like the companion: a burst sized in
    // fixed pixels swamps the room once the frame shrinks to fit a phone.
    final size = (frame.width * 0.14).clamp(96.0, 260.0);
    return Positioned(
      left: celebration.spot.x * frame.width - size / 2,
      top: celebration.spot.y * frame.height - size / 2,
      width: size,
      height: size,
      child: ParticleBurst(
        key: ValueKey('burst-${celebration.id}'),
        seed: celebration.id,
      ),
    );
  }

  Widget _companion(Size frame, VitalityTreatment treatment) {
    final mood = companionMood ?? treatment.companionMood;
    // Sized as a fraction of the frame so it stays in proportion with the
    // painted furniture at every window size. The fraction itself belongs to
    // the room, not to this widget - see [RoomDefinition.companionHeight].
    final height = frame.height * room.companionHeight;
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
    for (var i = 0; i < room.hotspots.length; i++) {
      final hotspot = room.hotspots[i];
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
              : showAffordances
                  // Staggered so the room shimmers in sequence rather than
                  // strobing in unison.
                  ? HotspotAffordance(phase: i / room.hotspots.length)
                  : const SizedBox.expand(),
        ),
      );
    }
  }
}

/// Runs 0 -> 1 -> 0 once and stops. Used for beats that must not loop.
class _OneShotFade extends StatefulWidget {
  const _OneShotFade({
    super.key,
    required this.duration,
    required this.builder,
  });

  final Duration duration;
  final Widget Function(double t) builder;

  @override
  State<_OneShotFade> createState() => _OneShotFadeState();
}

class _OneShotFadeState extends State<_OneShotFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        // Quick swell, slower settle.
        final eased = t < 0.3
            ? Curves.easeOut.transform(t / 0.3)
            : 1 - Curves.easeInOut.transform((t - 0.3) / 0.7);
        return widget.builder(eased.clamp(0.0, 1.0));
      },
    );
  }
}

/// The "you can touch this" marker that sits over a hotspot.
///
/// Direction doc §2: interaction points are invisible zones over a finished
/// painting, so without a hint the only discoverable one is whatever the
/// state overlay happens to draw. This is a soft breathing glow with an
/// expanding ring - readable at a glance, and quiet enough not to fight the
/// illustration.
class HotspotAffordance extends StatefulWidget {
  const HotspotAffordance({super.key, this.phase = 0});

  /// 0..1 offset into the pulse cycle, so sibling hotspots stagger.
  final double phase;

  @override
  State<HotspotAffordance> createState() => _HotspotAffordanceState();
}

class _HotspotAffordanceState extends State<HotspotAffordance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward(from: widget.phase.clamp(0.0, 1.0));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => CustomPaint(
            size: const Size.square(64),
            painter: _AffordancePainter(_controller.value),
          ),
        ),
      ),
    );
  }
}

class _AffordancePainter extends CustomPainter {
  const _AffordancePainter(this.t);

  /// 0..1 through the pulse cycle.
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    const warm = Color(0xFFFFE6A8);

    // The ring sweeps outward and fades; the dot breathes underneath it.
    final ringT = Curves.easeOut.transform(t);
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = warm.withValues(alpha: (1 - ringT) * 0.55);
    canvas.drawCircle(centre, 6 + ringT * 16, ringPaint);

    final breathe = 0.5 + 0.5 * math.sin(t * 2 * math.pi);
    canvas.drawCircle(
      centre,
      5.5,
      Paint()
        ..color = warm.withValues(alpha: 0.35 + breathe * 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(
      centre,
      3,
      Paint()..color = Colors.white.withValues(alpha: 0.6 + breathe * 0.35),
    );
  }

  @override
  bool shouldRepaint(_AffordancePainter oldDelegate) => oldDelegate.t != t;
}

/// How much of the painting may be cropped away to fill the screen.
///
/// Tuned against the kitchen's own hotspots: the bin sits at x 0.03 and the
/// back counter runs to x 1.0, so anything past a quarter starts eating
/// tappable room rather than margin.
const _maxCrop = 0.25;

/// Where the painting sits inside [available].
///
/// Cover while the crop stays small - letterbox bars around a nearly
/// matching window frame the painting like a video and break the illusion
/// that you are looking into a room. But cover has a cliff: a 1.6:1 painting
/// on a 19.5:9 phone held upright keeps under a third of its width, which
/// reads as an aggressive zoom into a corner of the kitchen and puts two of
/// the four hotspots off-screen entirely.
///
/// So past [_maxCrop] the rule flips and the whole painting is shown. What
/// it does not cover is filled by the room's own blurred light rather than
/// by bars.
Size roomFrame(Size available, double aspectRatio) {
  final cover = coverFrame(available, aspectRatio);
  final crop = math.max(
    1 - available.width / cover.width,
    1 - available.height / cover.height,
  );
  if (crop <= _maxCrop) return cover;
  return containFrame(available, aspectRatio);
}

/// Smallest box of [aspectRatio] that fully covers [available].
Size coverFrame(Size available, double aspectRatio) {
  final width = available.width;
  final height = available.height;
  if (width / height > aspectRatio) {
    // Viewport is wider than the art - match width, overflow vertically.
    return Size(width, width / aspectRatio);
  }
  return Size(height * aspectRatio, height);
}

/// Largest box of [aspectRatio] that fits inside [available].
Size containFrame(Size available, double aspectRatio) {
  final width = available.width;
  final height = available.height;
  if (width / height > aspectRatio) {
    return Size(height * aspectRatio, height);
  }
  return Size(width, width / aspectRatio);
}
