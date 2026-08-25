import 'package:flutter/material.dart';

class SingleTaskPrompt extends StatelessWidget {
  final VoidCallback onDone;

  /// The one task in play. Spec §2 locks this to a single task at a time —
  /// never a checklist.
  final String label;

  const SingleTaskPrompt({
    super.key,
    required this.onDone,
    this.label = 'Take out the garbage',
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(minimumSize: const Size(160, 56)),
              child: const Text('DONE'),
            ),
          ],
        ),
      ),
    );
  }
}
