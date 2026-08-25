import 'package:flutter/material.dart';

/// The offer shown after tapping a hotspot or the companion.
///
/// Direction doc §2: the tapped thing names the quest ("Dishes / ~4 min /
/// START"), rather than the player drilling down a task tree.
class QuestCard extends StatelessWidget {
  const QuestCard({
    super.key,
    required this.onPlay,
    this.title = 'Kitchen Rescue',
    this.minutes = 2,
  });

  final VoidCallback onPlay;
  final String title;
  final double minutes;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2B2B33),
      margin: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'KITCHEN RESCUE',
              style: TextStyle(
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
              style: const TextStyle(color: Color(0xFF9A9AA6), fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onPlay, child: const Text('PLAY')),
          ],
        ),
      ),
    );
  }
}
