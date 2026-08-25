import 'package:flutter/material.dart';

/// The two-image slider (spec §2.4).
///
/// "The single strongest honesty mechanic we have" - and it is strong for a
/// reason worth protecting: the app makes no claim here at all. It does not
/// score the change, rate the effort, or say whether it counts. It puts the
/// two photographs on top of each other and hands the user the divider. The
/// verification §2.4 asks for happens in their head, which is the only place
/// it was ever going to be honest.
///
/// Takes [ImageProvider]s rather than paths so it can be shown a picture that
/// never touched a disk.
class BeforeAfterSlider extends StatefulWidget {
  const BeforeAfterSlider({
    super.key,
    required this.before,
    required this.after,
  });

  final ImageProvider before;
  final ImageProvider after;

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  /// Starts slightly left of centre so the "after" has the larger share on
  /// first sight. The run just ended; the room is the reward.
  double _split = 0.4;

  void _moveTo(double dx, double width) {
    if (width <= 0) return;
    setState(() => _split = (dx / width).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return GestureDetector(
          onHorizontalDragUpdate: (details) =>
              _moveTo(details.localPosition.dx, width),
          onTapDown: (details) => _moveTo(details.localPosition.dx, width),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Image(image: widget.after, fit: BoxFit.cover),
              ClipRect(
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: _split,
                  child: SizedBox(
                    width: width,
                    child: Image(image: widget.before, fit: BoxFit.cover),
                  ),
                ),
              ),
              Positioned(
                left: (width * _split) - 1,
                top: 0,
                bottom: 0,
                child: Container(width: 2, color: Colors.white),
              ),
              Positioned(
                left: (width * _split) - 16,
                top: 0,
                bottom: 0,
                child: const Center(
                  child: _Handle(),
                ),
              ),
              const Positioned(
                left: 10,
                bottom: 8,
                child: _Caption('BEFORE'),
              ),
              const Positioned(
                right: 10,
                bottom: 8,
                child: _Caption('AFTER'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 6)],
      ),
      child: const Icon(Icons.code, size: 18, color: Color(0xFF1E1B22)),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        letterSpacing: 3,
        shadows: [Shadow(color: Colors.black87, blurRadius: 6)],
      ),
    );
  }
}
