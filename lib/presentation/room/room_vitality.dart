import 'dart:ui' show Color, ColorFilter;

import '../../simulation/entropy_engine.dart';

/// The coarse verbal states are owned by the pure simulation
/// (`NeedState`), not redeclared here. Spec §2 locks them: no percentages
/// ever reach the UI, only these words. The simulation maps its internal
/// float to one of these before anything is rendered; this file only says
/// how each one *looks*.
///
/// Presentation may import simulation. The reverse is forbidden
/// (CLAUDE.md), which is why the treatment table lives on this side.
typedef RoomVitality = NeedState;

/// The companion emotes shipped in `content/art/companion/`.
enum CompanionMood { idle, happy, excited, concerned, thinking, tired }

extension CompanionMoodAsset on CompanionMood {
  String get asset => 'content/art/companion/companion_$name.png';
}

/// How a vitality state is rendered.
///
/// Direction doc §7 — "Prefer Dormant -> Thriving Over Dirty -> Clean":
/// the virtual room never becomes ugly when the real room needs attention.
/// It loses *vitality* instead — colour drains, light cools, ambient motion
/// stops — and regains it when cared for. Every field here is a dimmer, not
/// a swap to uglier art.
class VitalityTreatment {
  const VitalityTreatment({
    required this.label,
    required this.saturation,
    required this.ambientTint,
    required this.tintStrength,
    required this.ambientSparkles,
    required this.companionMood,
  });

  /// The only vitality text the UI is allowed to show (spec §2).
  final String label;

  /// 1.0 = full colour, 0.0 = greyscale.
  final double saturation;

  /// Wash laid over the room — warm when cared for, cool when neglected.
  final Color ambientTint;

  /// Opacity of that wash, 0..1.
  final double tintStrength;

  /// Whether idle sparkle/dust-mote motion runs (doc §8).
  final bool ambientSparkles;

  final CompanionMood companionMood;
}

const Color _warmLight = Color(0xFFFFB25E);
const Color _coolLight = Color(0xFF4E6A9C);

const Map<NeedState, VitalityTreatment> kVitalityTreatments = {
  NeedState.thriving: VitalityTreatment(
    label: 'Thriving',
    saturation: 1.12,
    ambientTint: _warmLight,
    tintStrength: 0.10,
    ambientSparkles: true,
    companionMood: CompanionMood.excited,
  ),
  NeedState.comfortable: VitalityTreatment(
    label: 'Comfortable',
    saturation: 1.0,
    ambientTint: _warmLight,
    tintStrength: 0.04,
    ambientSparkles: true,
    companionMood: CompanionMood.happy,
  ),
  NeedState.slipping: VitalityTreatment(
    label: 'Slipping',
    saturation: 0.86,
    ambientTint: _coolLight,
    tintStrength: 0.05,
    ambientSparkles: false,
    companionMood: CompanionMood.idle,
  ),
  NeedState.struggling: VitalityTreatment(
    label: 'Struggling',
    saturation: 0.68,
    ambientTint: _coolLight,
    tintStrength: 0.12,
    ambientSparkles: false,
    companionMood: CompanionMood.concerned,
  ),
  NeedState.critical: VitalityTreatment(
    label: 'Critical',
    saturation: 0.52,
    ambientTint: _coolLight,
    tintStrength: 0.18,
    ambientSparkles: false,
    companionMood: CompanionMood.tired,
  ),
};

extension RoomVitalityTreatment on NeedState {
  VitalityTreatment get treatment => kVitalityTreatments[this]!;
}

/// Luminance-preserving saturation matrix. Values above 1 push colour past
/// its authored intensity, which is how `thriving` reads as *more* alive
/// than the base illustration rather than merely undimmed.
ColorFilter saturationFilter(double s) {
  const lumR = 0.2126, lumG = 0.7152, lumB = 0.0722;
  final iR = lumR * (1 - s), iG = lumG * (1 - s), iB = lumB * (1 - s);
  return ColorFilter.matrix(<double>[
    iR + s, iG, iB, 0, 0, //
    iR, iG + s, iB, 0, 0, //
    iR, iG, iB + s, 0, 0, //
    0, 0, 0, 1, 0,
  ]);
}
