import 'dart:async';

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
import '../widgets/room_restored_banner.dart';
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
  /// The celebration currently playing, if any. Purely a presentation
  /// concern - the simulation has no opinion about particles.
  RoomCelebration? _celebration;
  int _celebrationCount = 0;

  bool _showRestored = false;
  Timer? _restoredTimer;

  @override
  void dispose() {
    _restoredTimer?.cancel();
    super.dispose();
  }

  void _dismissRestored() {
    _restoredTimer?.cancel();
    if (mounted) setState(() => _showRestored = false);
  }

  @override
  Widget build(BuildContext context) {
    final room = ref.watch(roomDefinitionProvider('kitchen'));
    final session = ref.watch(kitchenSessionProvider);
    final controller = ref.read(kitchenSessionProvider.notifier);

    ref.listen(kitchenSessionProvider, (previous, next) {
      final phase = next.valueOrNull?.phase;
      if (previous?.valueOrNull?.phase == phase) return;

      if (phase == RunPhase.restored) {
        setState(() => _showRestored = true);
        _restoredTimer?.cancel();
        // Long enough to land, short enough that it never becomes a wall
        // between the user and the room.
        _restoredTimer =
            Timer(const Duration(milliseconds: 2600), _dismissRestored);
        return;
      }

      if (phase != RunPhase.celebrating) return;

      // Feedback never waits on I/O (CLAUDE.md): state is already updated,
      // so haptic, sound and particles fire immediately.
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.click);

      final spot = _spotFor(
        room.valueOrNull,
        next.valueOrNull?.currentTaskId,
      );
      setState(() {
        _celebrationCount++;
        _celebration =
            RoomCelebration(id: _celebrationCount, spot: spot);
      });

      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() => _celebration = null);
        controller.finishCelebration();
      });
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

  /// Celebrate where the work happened. Falls back to the middle of the room
  /// only if the task has no painted home.
  ({double x, double y}) _spotFor(RoomDefinition? definition, String? taskId) {
    final hotspot =
        taskId == null ? null : definition?.hotspotForTask(taskId);
    if (hotspot == null) return (x: 0.5, y: 0.5);
    return (x: hotspot.area.center.dx, y: hotspot.area.center.dy);
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
            celebration: _celebration,
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
        if (_showRestored && state.phase == RunPhase.restored)
          RoomRestoredBanner(onDismiss: _dismissRestored),
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
