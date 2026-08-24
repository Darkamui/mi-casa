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
        child: CustomPaint(
          size: const Size(64, 64),
          painter:
              CompanionPainter(celebrating: widget.mood == CompanionMood.celebrating),
        ),
      ),
    );
  }
}

class CompanionPainter extends CustomPainter {
  final bool celebrating;
  const CompanionPainter({required this.celebrating});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = const Color(0xFFE8A33D);
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.shortestSide / 2, bodyPaint);

    final eyePaint = Paint()..color = Colors.black;
    final eyeOffset = size.shortestSide * 0.15;
    final eyeRadius = celebrating ? size.shortestSide * 0.05 : size.shortestSide * 0.04;
    canvas.drawCircle(center + Offset(-eyeOffset, -eyeOffset * 0.3), eyeRadius, eyePaint);
    canvas.drawCircle(center + Offset(eyeOffset, -eyeOffset * 0.3), eyeRadius, eyePaint);

    if (celebrating) {
      final armPaint = Paint()
        ..color = const Color(0xFFE8A33D)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke;
      canvas.drawLine(center + Offset(-eyeOffset * 2, 0),
          center + Offset(-eyeOffset * 3, -eyeOffset * 2), armPaint);
      canvas.drawLine(center + Offset(eyeOffset * 2, 0),
          center + Offset(eyeOffset * 3, -eyeOffset * 2), armPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CompanionPainter oldDelegate) =>
      oldDelegate.celebrating != celebrating;
}
