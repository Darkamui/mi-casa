import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../room/kitchen_room_view.dart';
import '../room/room_definition.dart';
import '../room/room_definition_loader.dart';
import '../room/room_vitality.dart';
import '../scenes/kitchen_scene_controller.dart';
import '../widgets/quest_card.dart';
import '../widgets/single_task_prompt.dart';

/// The point-and-click kitchen (direction doc §19, §24).
///
/// tap hotspot/companion -> quest offer -> run -> DONE -> overlay clears,
/// companion celebrates, room warms.
class KitchenScreen extends ConsumerStatefulWidget {
  const KitchenScreen({super.key});

  @override
  ConsumerState<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends ConsumerState<KitchenScreen> {
  RoomHotspot? _selected;

  @override
  Widget build(BuildContext context) {
    final phase = ref.watch(kitchenSceneProvider);
    final notifier = ref.read(kitchenSceneProvider.notifier);
    final room = ref.watch(roomDefinitionProvider('kitchen'));

    ref.listen<RunPhase>(kitchenSceneProvider, (previous, next) {
      if (next == RunPhase.celebrating) {
        // Feedback never waits on I/O (CLAUDE.md): state is already
        // updated, so haptic and sound fire immediately.
        HapticFeedback.mediumImpact();
        SystemSound.play(SystemSoundType.click);
        Future.delayed(
            const Duration(milliseconds: 900), notifier.finishCelebration);
      }
    });

    final restored = phase == RunPhase.restored;
    final vitality =
        restored ? RoomVitality.comfortable : RoomVitality.slipping;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1B22),
      body: room.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load the kitchen.\n$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70)),
          ),
        ),
        data: (definition) => Stack(
          children: [
            Positioned.fill(
              child: KitchenRoomView(
                room: definition,
                vitality: vitality,
                showDishPile: !restored && phase != RunPhase.celebrating,
                companionMood: switch (phase) {
                  RunPhase.celebrating => CompanionMood.excited,
                  RunPhase.restored => CompanionMood.happy,
                  RunPhase.questOffered => CompanionMood.thinking,
                  _ => null,
                },
                onCompanionTap: () {
                  _selected = definition.hotspots.first;
                  notifier.tapCompanion();
                },
                onHotspotTap: (hotspot) {
                  setState(() => _selected = hotspot);
                  notifier.tapCompanion();
                },
              ),
            ),
            _vitalityBadge(vitality),
            if (phase == RunPhase.questOffered)
              Center(
                child: QuestCard(
                  title: _selected?.label ?? 'Kitchen Rescue',
                  onPlay: notifier.startRun,
                ),
              ),
            if (phase == RunPhase.running)
              SingleTaskPrompt(
                label: _selected?.label ?? 'Take out the garbage',
                onDone: notifier.completeTask,
              ),
          ],
        ),
      ),
    );
  }

  /// Coarse verbal state only — spec §2 forbids percentages in the UI.
  Widget _vitalityBadge(RoomVitality vitality) => Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 28),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              vitality.treatment.label,
              key: ValueKey(vitality),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                letterSpacing: 4,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
              ),
            ),
          ),
        ),
      );
}
