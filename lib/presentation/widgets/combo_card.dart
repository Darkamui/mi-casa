import 'package:flutter/material.dart';

/// The combo offer (spec §5.2 item 9, §3.3).
///
/// Shown the moment a task lands, naming the physically-adjacent thing next
/// to it. The chain is the point of the game, so this card leads with the
/// momentum already built rather than presenting a fresh decision.
///
/// Declining is a first-class button, not a dismissal X: stopping after two
/// tasks is a win, and the UI must not make it feel like abandoning one.
class ComboCard extends StatelessWidget {
  const ComboCard({
    super.key,
    required this.prompt,
    required this.minutes,
    required this.momentum,
    required this.onAccept,
    required this.onDecline,
  });

  /// Authored in `content/adjacency/edges.json` - "Wipe it?", not a
  /// generated sentence.
  final String prompt;
  final double minutes;

  /// How many tasks deep this run already is.
  final int momentum;

  final VoidCallback onAccept;
  final VoidCallback onDecline;

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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt_rounded,
                    size: 16, color: Color(0xFFFFCB6B)),
                const SizedBox(width: 4),
                Text(
                  momentum > 1 ? '$momentum IN A ROW' : 'WHILE YOU\'RE HERE',
                  style: const TextStyle(
                    color: Color(0xFFFFCB6B),
                    fontSize: 12,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              prompt,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 22),
            ),
            const SizedBox(height: 4),
            Text(
              '~${minutes.round()} min',
              style: const TextStyle(color: Color(0xFF9A9AA6), fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: onDecline,
                  child: const Text(
                    "I'M DONE",
                    style: TextStyle(color: Color(0xFF9A9AA6)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onAccept,
                  child: const Text('KEEP GOING'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
