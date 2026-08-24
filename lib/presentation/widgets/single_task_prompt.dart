import 'package:flutter/material.dart';

class SingleTaskPrompt extends StatelessWidget {
  final VoidCallback onDone;
  const SingleTaskPrompt({super.key, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Put the dishes away',
              style: TextStyle(color: Colors.white, fontSize: 20),
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
