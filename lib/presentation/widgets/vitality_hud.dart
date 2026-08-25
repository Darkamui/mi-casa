import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../room/room_vitality.dart';

/// The room's vitality readout.
///
/// Spec §2 forbids percentages: this shows the coarse verbal state as the
/// headline, and five pips - one per named state, filled up to the current
/// one - as the at-a-glance shape of it. Five discrete steps carry exactly
/// the information the five words do, which is the point; there is no
/// finer-grained number to leak.
///
/// Doc §7: the meter reads as life, not cleanliness. It warms and fills as
/// the room is cared for and cools and empties when it is neglected.
class VitalityHud extends StatelessWidget {
  const VitalityHud({super.key, required this.vitality, this.momentum = 0});

  final RoomVitality vitality;

  /// In-session chain length. Shown only while a chain is actually running -
  /// spec §5.2 item 10 is explicit that this is never a daily streak, so it
  /// must not sit there as a standing score to protect.
  final int momentum;

  @override
  Widget build(BuildContext context) {
    final treatment = vitality.treatment;
    // NeedState is ordered best -> worst, so invert for a "fuller is
    // healthier" meter.
    final states = RoomVitality.values;
    final filled = states.length - states.indexOf(vitality);
    final accent = _accentFor(vitality);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.fromLTRB(14, 10, 16, 10),
          decoration: BoxDecoration(
            color: const Color(0xFF16131A).withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Hearth(accent: accent, lit: treatment.ambientSparkles),
              const SizedBox(width: 12),
              Column(
                key: const ValueKey('vitality-body'),
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'KITCHEN',
                        style: TextStyle(
                          color: Color(0xFF9A94A6),
                          fontSize: 9,
                          letterSpacing: 2.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (momentum > 0) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.bolt_rounded,
                            size: 11, color: Color(0xFFFFCB6B)),
                        Text(
                          '$momentum',
                          style: const TextStyle(
                            color: Color(0xFFFFCB6B),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      treatment.label,
                      key: ValueKey(vitality),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.05,
                        letterSpacing: 0.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < states.length; i++)
                        AnimatedContainer(
                          duration: Duration(milliseconds: 320 + i * 60),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.only(right: 3),
                          width: i < filled ? 16 : 10,
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: i < filled
                                ? accent
                                : Colors.white.withValues(alpha: 0.16),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Warm and glowing while the room has life in it, cool and dim when not.
Color _accentFor(RoomVitality vitality) => switch (vitality) {
      RoomVitality.thriving => const Color(0xFFFFCB6B),
      RoomVitality.comfortable => const Color(0xFFE3B970),
      RoomVitality.slipping => const Color(0xFF8FA6C4),
      RoomVitality.struggling => const Color(0xFF7387A5),
      RoomVitality.critical => const Color(0xFF5E6C86),
    };

/// A small hearth glyph - the app's own mark rather than a borrowed icon.
class _Hearth extends StatelessWidget {
  const _Hearth({required this.accent, required this.lit});

  final Color accent;
  final bool lit;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: lit ? 0.22 : 0.10),
        boxShadow: lit
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.45),
                  blurRadius: 14,
                  spreadRadius: -2,
                )
              ]
            : null,
      ),
      child: Icon(
        lit ? Icons.local_fire_department_rounded : Icons.mode_night_rounded,
        size: 18,
        color: accent,
      ),
    );
  }
}
