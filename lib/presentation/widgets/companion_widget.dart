import 'dart:math' as math;

import 'package:flutter/material.dart';

enum CompanionMood { idle, celebrating }

class CompanionWidget extends StatefulWidget {
  final CompanionMood mood;
  final VoidCallback onTap;

  const CompanionWidget({super.key, required this.mood, required this.onTap});

  @override
  State<CompanionWidget> createState() => _CompanionWidgetState();
}

class _CompanionWidgetState extends State<CompanionWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.mood == CompanionMood.celebrating
        ? 'content/art/companion/companion_excited.png'
        : 'content/art/companion/companion_idle.png';

    return GestureDetector(
      key: const ValueKey('companionTap'),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _bounceController,
        builder: (context, child) {
          final bounce = widget.mood == CompanionMood.celebrating
              ? 0.0
              : math.sin(_bounceController.value * math.pi) * 6;
          return Transform.translate(offset: Offset(0, -bounce), child: child);
        },
        child: Image.asset(asset, width: 96, height: 112),
      ),
    );
  }
}
