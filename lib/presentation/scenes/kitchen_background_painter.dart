import 'package:flutter/rendering.dart';

class KitchenBackgroundPainter extends CustomPainter {
  final bool restored;
  const KitchenBackgroundPainter({required this.restored});

  @override
  void paint(Canvas canvas, Size size) {
    final wallColor =
        restored ? const Color(0xFFF3E1C4) : const Color(0xFF8A8F98);
    final floorColor =
        restored ? const Color(0xFFB98356) : const Color(0xFF6B6B6B);
    final counterColor =
        restored ? const Color(0xFFDCC7A0) : const Color(0xFF4E4E4E);
    final sinkColor =
        restored ? const Color(0xFFEFEFEF) : const Color(0xFF3A3A3A);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.7),
      Paint()..color = wallColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.7, size.width, size.height * 0.3),
      Paint()..color = floorColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.55,
          size.width * 0.35, size.height * 0.15),
      Paint()..color = counterColor,
    );
    canvas.drawRect(
      Rect.fromLTWH(
          size.width * 0.15, size.height * 0.5, size.width * 0.2, size.height * 0.1),
      Paint()..color = sinkColor,
    );
  }

  @override
  bool shouldRepaint(covariant KitchenBackgroundPainter oldDelegate) =>
      oldDelegate.restored != restored;
}
