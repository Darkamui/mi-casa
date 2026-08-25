import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../room/kitchen_room_view.dart';
import '../room/room_definition.dart';
import '../room/room_definition_loader.dart';
import '../room/room_vitality.dart';
import '../scenes/kitchen_scene_controller.dart';
import '../widgets/combo_card.dart';
import '../widgets/quest_card.dart';
import '../widgets/single_task_prompt.dart';
import '../widgets/vitality_hud.dart';

/// The point-and-click kitchen (direction doc §19, §24).
///
/// tap hotspot -> quest offer -> run -> DONE -> the room warms, the
/// companion celebrates, and the combo engine offers whatever is physically
/// next to what you just finished.
class KitchenScreen extends ConsumerStatefulWidget {
  const KitchenScreen({super.key});

  @override
  ConsumerState<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends ConsumerState<KitchenScreen> {
  @override
  Widget build(BuildContext context) {
    final room = ref.watch(roomDefinitionProvider('kitchen'));
    final session = ref.watch(kitchenSessionProvider);
    final controller = ref.read(kitchenSessionProvider.notifier);

    ref.listen(kitchenSessionProvider, (previous, next) {
      if (previous?.valueOrNull?.phase == next.valueOrNull?.phase) return;
      if (next.valueOrNull?.phase != RunPhase.celebrating) return;

      // Feedback never waits on I/O (CLAUDE.md): state is already updated,
      // so haptic and sound fire immediately.
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.click);
      Future.delayed(
          const Duration(milliseconds: 900), controller.finishCelebration);
    });

    return Scaffold(
      backgroundColor: const Color(0xFF1E1B22),
      body: switch ((room, session)) {
        (AsyncError(:final error), _) || (_, AsyncError(:final error)) =>
          _error(error),
        (AsyncData(value: final definition), AsyncData(value: final state)) =>
          _room(definition, state, controller),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _error(Object error) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Could not load the kitchen.\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70)),
        ),
      );

  Widget _room(
    RoomDefinition definition,
    KitchenSession state,
    KitchenSceneController controller,
  ) {
    final engine = controller.engine;
    final now = ref.read(clockProvider)();

    // Everything visible is derived from the simulation now - none of it is
    // a hardcoded phase ternary any more.
    final vitality = engine.vitality(state, now);
    final currentTask = state.currentTaskId == null
        ? null
        : engine.taskById(state.currentTaskId!);

    return Stack(
      children: [
        Positioned.fill(
          child: KitchenRoomView(
            room: definition,
            vitality: vitality,
            showDishPile: engine.showsDishPile(state, now),
            showAffordances:
                state.phase == RunPhase.idle || state.phase == RunPhase.restored,
            companionMood: switch (state.phase) {
              RunPhase.celebrating => CompanionMood.excited,
              RunPhase.comboOffered => CompanionMood.happy,
              RunPhase.restored => CompanionMood.happy,
              RunPhase.questOffered => CompanionMood.thinking,
              _ => null,
            },
            onCompanionTap: () => _offerMostNeeded(state, controller),
            onHotspotTap: (hotspot) => controller.offerQuest(hotspot.taskId),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.topLeft,
              child: VitalityHud(vitality: vitality, momentum: state.momentum),
            ),
          ),
        ),
        if (state.phase == RunPhase.questOffered && currentTask != null)
          Center(
            child: QuestCard(
              title: currentTask.label,
              minutes: engine.offeredMinutes(state, currentTask.id),
              onPlay: controller.startRun,
              onDismiss: controller.dismissQuest,
            ),
          ),
        if (state.phase == RunPhase.comboOffered && state.comboOffer != null)
          Center(
            child: ComboCard(
              prompt: state.comboOffer!.prompt,
              minutes: state.comboOffer!.estimatedMinutes,
              momentum: state.momentum,
              onAccept: controller.acceptCombo,
              onDecline: controller.declineCombo,
            ),
          ),
        if (state.phase == RunPhase.running && currentTask != null)
          SingleTaskPrompt(
            label: currentTask.label,
            targetMinutes: engine.offeredMinutes(state, currentTask.id),
            elapsed: controller.activeElapsed,
            paused: state.isPaused,
            onDone: controller.completeTask,
            onPause: controller.pauseRun,
            onResume: controller.resumeRun,
            onSkip: controller.skipTask,
          ),
      ],
    );
  }

  /// The companion suggests rather than decides: it opens whichever task the
  /// room most needs, which is exactly what the entropy engine already
  /// knows. Spec §3.2 - runs are companion-initiated.
  void _offerMostNeeded(
    KitchenSession state,
    KitchenSceneController controller,
  ) {
    final engine = controller.engine;
    final now = ref.read(clockProvider)();

    String? worst;
    var worstLevel = -1.0;
    for (final task in engine.tasks) {
      final level = engine.needLevel(state, task.id, now);
      if (level > worstLevel) {
        worstLevel = level;
        worst = task.id;
      }
    }
    if (worst != null) controller.offerQuest(worst);
  }
}
