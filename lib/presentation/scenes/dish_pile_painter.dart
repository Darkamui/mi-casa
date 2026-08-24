import 'package:flutter/rendering.dart';

class DishPilePainter extends CustomPainter {
  const DishPilePainter();

  static const List<Offset> dishOffsets = [
    Offset(0.0, 0.0),
    Offset(0.4, -0.1),
    Offset(0.2, 0.15),
    Offset(-0.3, 0.05),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFDCD3C3);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.35;

    for (final offset in dishOffsets) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center +
              Offset(offset.dx * size.width * 0.3, offset.dy * size.height * 0.3),
          width: radius,
          height: radius * 0.5,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DishPilePainter oldDelegate) => false;
}
