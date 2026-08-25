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
    this.title = 'Kitchen Rescue',
    this.minutes = 2,
  });

  final VoidCallback onPlay;

  /// Backs out of the offer. Declining must cost nothing - a player who
  /// taps something to see what it is should be able to put it back down.
  final VoidCallback? onDismiss;

  final String title;
  final double minutes;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2B2B33),
      margin: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 8, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 32),
                const Expanded(
                  child: Text(
                    'KITCHEN RESCUE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFA9C7A0),
                      fontSize: 12,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    onPressed: onDismiss,
                    padding: EdgeInsets.zero,
                    iconSize: 18,
                    tooltip: 'Not now',
                    icon: const Icon(Icons.close, color: Color(0xFF9A9AA6)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: onPlay, child: const Text('PLAY')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
