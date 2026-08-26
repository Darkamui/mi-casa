import 'package:flutter/material.dart';

/// The offer shown after tapping a hotspot or the companion.
///
/// Direction doc §2: the tapped thing names the quest ("Dishes / ~4 min /
/// PLAY"), rather than the player drilling down a task tree.
class QuestCard extends StatelessWidget {
  const QuestCard({
    super.key,
    required this.onPlay,
    this.onDismiss,
    this.onNotThis,
    this.onBeforePhoto,
    this.hasBeforePhoto = false,
    this.title = 'Kitchen Rescue',
    this.minutes = 2,
    this.eyebrow = 'KITCHEN RESCUE',
  });

  final VoidCallback onPlay;

  /// Backs out of the offer. Declining must cost nothing - a player who
  /// taps something to see what it is should be able to put it back down.
  final VoidCallback? onDismiss;

  /// Asks for a smaller version of the same chore - spec §3.7's ladder.
  /// Distinct from [onDismiss]: closing the card is "not now", this is "not
  /// this much". One tap, and the next rung is offered.
  final VoidCallback? onNotThis;

  /// Takes the optional "before" (spec §2.4). Null on a device with no camera
  /// we can reach, and then nothing about photos is drawn at all.
  final VoidCallback? onBeforePhoto;

  /// Whether one has already been taken - the only acknowledgement it gets.
  /// A thumbnail here would turn an aside into a step.
  final bool hasBeforePhoto;

  final String title;
  final double minutes;

  /// Names what kind of offer this is - the room's rescue, a smaller version
  /// of it, or a setup quest (§3.6).
  final String eyebrow;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2B2B33),
      margin: const EdgeInsets.all(24),
      // The close button floats in the corner rather than sitting in the
      // layout: the card must stay sized to its own content, and anything
      // in a row with the eyebrow stretches it to the full screen width.
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  eyebrow,
                  style: const TextStyle(
                    color: Color(0xFFA9C7A0),
                    fontSize: 12,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 22),
                ),
                const SizedBox(height: 4),
                Text(
                  '~${minutes.round()} min',
                  style:
                      const TextStyle(color: Color(0xFF9A9AA6), fontSize: 14),
                ),
                if (onBeforePhoto != null) ...[
                  const SizedBox(height: 10),
                  // Quiet, and above PLAY because that is the only order in
                  // which it makes sense. It is never a step: PLAY works the
                  // same whether this was tapped or ignored (§2.4, optional).
                  TextButton.icon(
                    onPressed: hasBeforePhoto ? null : onBeforePhoto,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF9A9AA6),
                      disabledForegroundColor: const Color(0xFFA9C7A0),
                    ),
                    icon: Icon(
                      hasBeforePhoto ? Icons.check : Icons.photo_camera_outlined,
                      size: 16,
                    ),
                    label: Text(
                      hasBeforePhoto ? 'BEFORE TAKEN' : 'SNAP THE BEFORE',
                      style: const TextStyle(fontSize: 11, letterSpacing: 1.5),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton(onPressed: onPlay, child: const Text('PLAY')),
                if (onNotThis != null)
                  TextButton(
                    onPressed: onNotThis,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF9A9AA6),
                    ),
                    child: const Text('SOMETHING SMALLER'),
                  ),
              ],
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: SizedBox(
              width: 24,
              height: 24,
              child: IconButton(
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                iconSize: 14,
                tooltip: 'Not now',
                icon: const Icon(Icons.close, color: Color(0xFF9A9AA6)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
