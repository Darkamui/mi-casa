import 'package:flutter/material.dart';

import '../house/app_menu_sheet.dart';
import 'house_screen.dart';

/// The very first thing a launch shows (spec §2.3, updated 2026-08-26).
///
/// Collects nothing - no field, no toggle, no first-run branching. It
/// looks identical on launch #1 and launch #100; this is a title screen
/// with a real menu, not the rejected 5-step config wizard.
class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1B22),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, -8 * _controller.value),
                child: child,
              ),
              child: Image.asset(
                'content/art/companion/companion_idle.png',
                height: 160,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'MiCasa',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HouseScreen()),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                child: Text('Enter House'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => showAppMenuSheet(context),
              child: const Text(
                'Settings',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
