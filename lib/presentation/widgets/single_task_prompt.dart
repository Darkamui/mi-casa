import 'dart:async';

import 'package:flutter/material.dart';

/// Run mode - "put the phone down" (spec §3.3).
///
/// The UI collapses to one task, one clock, and one big button. Everything
/// lives in the lower half so it works one-handed.
///
/// Spec §3.3: the timer is **visual first** - a candle burning down - with
/// exact digits subtle underneath, never dominant. The candle is also why
/// overrunning is safe to show: a short candle still burns, where a clock
/// hitting 00:00 would read as failure. Nothing here ever turns red.
class SingleTaskPrompt extends StatefulWidget {
  const SingleTaskPrompt({
    super.key,
    required this.onDone,
    required this.elapsed,
    this.label = 'Take out the garbage',
    this.targetMinutes = 2,
    this.paused = false,
    this.onPause,
    this.onResume,
    this.onSkip,
  });

  final VoidCallback onDone;

  /// Pulled from the simulation on every tick rather than counted here, so
  /// the engine stays the only thing that knows how much active time exists
  /// (CLAUDE.md: the world renders application state, never stores it).
  final Duration Function() elapsed;

  /// The one task in play. Spec §2 locks this to a single task at a time -
  /// never a checklist.
  final String label;

  /// What the run was offered as. The candle is sized against this; running
  /// past it is not a failure state.
  final double targetMinutes;

  final bool paused;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onSkip;

  @override
  State<SingleTaskPrompt> createState() => _SingleTaskPromptState();
}

class _SingleTaskPromptState extends State<SingleTaskPrompt> {
  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _elapsed = widget.elapsed();
    // One tick per second, not per frame: the digits only change that often,
    // and the candle is smoothed by an implicit animation between ticks.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed = widget.elapsed());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = Duration(seconds: (widget.targetMinutes * 60).round());
    final burned = target.inSeconds == 0
        ? 1.0
        : (_elapsed.inSeconds / target.inSeconds).clamp(0.0, 1.0);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40, left: 24, right: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'QUEST',
              style: TextStyle(
                color: Color(0xFF9A94A6),
                fontSize: 10,
                letterSpacing: 3,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 22),
            ),
            const SizedBox(height: 18),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: burned, end: burned),
              duration: const Duration(milliseconds: 950),
              curve: Curves.linear,
              builder: (context, value, _) => CustomPaint(
                size: const Size(46, 96),
                painter: _CandlePainter(burned: value, lit: !widget.paused),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _format(_elapsed),
              style: TextStyle(
                // Deliberately quiet: the candle is the timer, this is the
                // footnote.
                color: Colors.white.withValues(alpha: widget.paused ? 0.4 : 0.6),
                fontSize: 13,
                letterSpacing: 1.5,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.onDone,
              style: ElevatedButton.styleFrom(minimumSize: const Size(180, 60)),
              child: const Text('DONE'),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.onSkip != null)
                  TextButton(
                    onPressed: widget.onSkip,
                    child: const Text('Skip',
                        style: TextStyle(color: Color(0xFF9A9AA6))),
                  ),
                if (widget.onPause != null || widget.onResume != null)
                  TextButton(
                    onPressed: widget.paused ? widget.onResume : widget.onPause,
                    child: Text(widget.paused ? 'Resume' : 'Pause',
                        style: const TextStyle(color: Color(0xFF9A9AA6))),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _format(Duration elapsed) {
  final minutes = elapsed.inMinutes;
  final seconds = elapsed.inSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

/// A candle that shortens as the run goes. At full burn it keeps a stub and
/// keeps its flame - running long is allowed, and the art must not say
/// otherwise.
class _CandlePainter extends CustomPainter {
  const _CandlePainter({required this.burned, required this.lit});

  /// 0 = untouched, 1 = burned down to the stub.
  final double burned;

  /// False while paused: the flame goes out, the candle stays.
  final bool lit;

  @override
  void paint(Canvas canvas, Size size) {
    const stub = 0.22;
    final bodyWidth = size.width * 0.52;
    final fullHeight = size.height * 0.74;
    final height = fullHeight * (1 - (1 - stub) * burned);
    final left = (size.width - bodyWidth) / 2;
    final top = size.height - height;

    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, bodyWidth, height),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF3DA), Color(0xFFE8D3AC)],
        ).createShader(body.outerRect),
    );

    final wickTop = top - size.height * 0.06;
    canvas.drawLine(
      Offset(size.width / 2, top),
      Offset(size.width / 2, wickTop),
      Paint()
        ..color = const Color(0xFF4A4038)
        ..strokeWidth = 1.6,
    );

    if (!lit) return;

    final flameCentre = Offset(size.width / 2, wickTop - size.height * 0.05);
    canvas.drawCircle(
      flameCentre,
      size.width * 0.42,
      Paint()
        ..color = const Color(0xFFFFCB6B).withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    final flame = Path()
      ..moveTo(flameCentre.dx, flameCentre.dy - size.height * 0.075)
      ..quadraticBezierTo(
        flameCentre.dx + size.width * 0.13,
        flameCentre.dy,
        flameCentre.dx,
        flameCentre.dy + size.height * 0.05,
      )
      ..quadraticBezierTo(
        flameCentre.dx - size.width * 0.13,
        flameCentre.dy,
        flameCentre.dx,
        flameCentre.dy - size.height * 0.075,
      );
    canvas.drawPath(
      flame,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFFFF9E4A), Color(0xFFFFE9A8)],
        ).createShader(
          Rect.fromCircle(center: flameCentre, radius: size.width * 0.2),
        ),
    );
  }

  @override
  bool shouldRepaint(_CandlePainter old) =>
      old.burned != burned || old.lit != lit;
}
