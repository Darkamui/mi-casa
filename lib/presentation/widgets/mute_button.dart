import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../scenes/kitchen_scene_controller.dart';

/// Silences the room (spec §4.2).
///
/// Always present, never hidden behind a settings screen. Sound that starts
/// on its own has to be stoppable in one tap from wherever it started - a
/// mute the user has to go looking for is a reason to close the app instead.
class MuteButton extends ConsumerWidget {
  const MuteButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muted = ref.watch(mutedProvider);

    return IconButton(
      onPressed: () {
        final next = !muted;
        ref.read(mutedProvider.notifier).state = next;
        ref.read(roomAudioProvider).setMuted(next);
      },
      tooltip: muted ? 'Unmute' : 'Mute',
      icon: Icon(
        muted ? Icons.volume_off : Icons.volume_up,
        color: muted ? Colors.white38 : Colors.white70,
      ),
    );
  }
}
