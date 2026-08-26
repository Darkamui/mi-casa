import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../scenes/kitchen_scene_controller.dart';
import '../voice/voice_recognizer.dart';

/// The microphone (spec §2.5).
///
/// Renders nothing at all when the device cannot listen, rather than a
/// disabled button explaining what the user is missing. Voice is an
/// alternative set of hands, and every command it carries has a tap that does
/// the same thing - so its absence is not a loss worth narrating.
class VoiceButton extends ConsumerStatefulWidget {
  const VoiceButton({super.key});

  @override
  ConsumerState<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends ConsumerState<VoiceButton> {
  bool _available = false;
  bool _listening = false;
  StreamSubscription<String>? _subscription;

  /// The last command that landed, shown briefly so the user knows they were
  /// heard. Hands-free means eyes are the only channel left for that.
  VoiceIntent? _heard;
  Timer? _heardTimer;

  /// Held rather than read back through `ref` on the way out: `ref` is dead
  /// by the time [dispose] runs, and an open microphone is not something to
  /// leave behind on a technicality.
  VoiceRecognizer? _listeningTo;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    final available = await ref.read(voiceRecognizerProvider).available();
    if (!mounted) return;
    setState(() => _available = available);
  }

  @override
  void dispose() {
    _heardTimer?.cancel();
    _subscription?.cancel();
    // Never leave a microphone open behind a disposed widget.
    final recognizer = _listeningTo;
    if (recognizer != null) unawaited(recognizer.stop());
    super.dispose();
  }

  Future<void> _toggle() async {
    final recognizer = ref.read(voiceRecognizerProvider);
    if (_listening) {
      // Stop first, then unsubscribe: releasing the microphone is the part
      // the user asked for, and it must not queue behind stream teardown.
      await recognizer.stop();
      _listeningTo = null;
      unawaited(_subscription?.cancel());
      _subscription = null;
      if (mounted) setState(() => _listening = false);
      return;
    }

    _subscription = recognizer.utterances.listen(_onUtterance);
    _listeningTo = recognizer;
    await recognizer.start();
    if (mounted) setState(() => _listening = true);
  }

  void _onUtterance(String utterance) {
    final intent = ref.read(kitchenSessionProvider.notifier).hear(utterance);
    if (intent == null || !mounted) return;

    setState(() => _heard = intent);
    _heardTimer?.cancel();
    _heardTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _heard = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_available) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_heard != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              _label(_heard!),
              style: const TextStyle(
                color: Color(0xFFFFCB6B),
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
          ),
        IconButton(
          onPressed: _toggle,
          tooltip: _listening ? 'Stop listening' : 'Listen',
          icon: Icon(
            _listening ? Icons.mic : Icons.mic_none,
            color: _listening ? const Color(0xFFFFCB6B) : Colors.white70,
          ),
        ),
      ],
    );
  }

  String _label(VoiceIntent intent) => switch (intent) {
        VoiceIntent.done => 'DONE',
        VoiceIntent.next => 'NEXT',
        VoiceIntent.skip => 'SKIP',
        VoiceIntent.pause => 'PAUSED',
        VoiceIntent.resume => 'RESUMED',
        VoiceIntent.fiveMoreMinutes => 'FIVE MORE MINUTES',
      };
}
