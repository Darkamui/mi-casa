import 'package:flutter/material.dart';

class QuestCard extends StatelessWidget {
  final VoidCallback onPlay;
  const QuestCard({super.key, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2B2B33),
      margin: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Kitchen Rescue — 2 min',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onPlay, child: const Text('PLAY')),
          ],
        ),
      ),
    );
  }
}
