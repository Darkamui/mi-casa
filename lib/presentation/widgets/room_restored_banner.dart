import 'package:flutter/material.dart';

/// **ROOM RESTORED** (spec §4.1).
///
/// The end-of-run title card. It is deliberately a statement about the room
/// rather than about the user: no score, no tasks-completed tally, no "well
/// done" - the reward is that the place is better, and §2 forbids the
/// percentage or count that would otherwise creep in here.
class RoomRestoredBanner extends StatelessWidget {
  const RoomRestoredBanner({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onDismiss,
        behavior: HitTestBehavior.opaque,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, t, child) => Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, 14 * (1 - t)),
              child: child,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54,
                  height: 1,
                  color: const Color(0xFFFFCB6B).withValues(alpha: 0.7),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ROOM RESTORED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    letterSpacing: 6,
                    fontWeight: FontWeight.w300,
                    shadows: [
                      Shadow(color: Colors.black54, blurRadius: 12),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 54,
                  height: 1,
                  color: const Color(0xFFFFCB6B).withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
