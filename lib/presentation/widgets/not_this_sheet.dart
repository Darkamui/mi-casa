import 'package:flutter/material.dart';

import '../../simulation/kitchen_session.dart' show NotThisReason;

/// The no-penalty escape (spec §3.7).
///
/// > 😒 **NOT THIS** → Too tired / Takes too long / Don't feel like it /
/// > Can't right now / Not actually needed
///
/// Nothing here is framed as a failure and nothing asks the user to justify
/// themselves twice: five plain answers, one tap, gone. The reasons are worth
/// collecting only because each one changes what gets offered next - if they
/// were merely logged, a single "no thanks" would be the honest UI.
class NotThisSheet extends StatelessWidget {
  const NotThisSheet({
    super.key,
    required this.onChoose,
    required this.onDismiss,
  });

  final void Function(NotThisReason) onChoose;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onDismiss,
        behavior: HitTestBehavior.opaque,
        child: ColoredBox(
          color: const Color(0xCC15131A),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'NOT THIS',
                    style: TextStyle(
                      color: Color(0xFF9A9AA6),
                      fontSize: 12,
                      letterSpacing: 3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  for (final reason in NotThisReason.values)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: TextButton(
                        onPressed: () => onChoose(reason),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          minimumSize: const Size(240, 48),
                        ),
                        child: Text(
                          reason.label,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
