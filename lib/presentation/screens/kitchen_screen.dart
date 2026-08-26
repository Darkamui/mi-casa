import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/room_audio.dart';
import '../feedback/haptic_score.dart';
import '../feedback/haptics.dart';
import '../house/app_menu_sheet.dart';
import '../room/kitchen_room_view.dart';
import '../room/room_definition.dart';
import '../room/room_definition_loader.dart';
import '../room/room_vitality.dart';
import '../scenes/kitchen_scene_controller.dart';
import '../widgets/combo_card.dart';
import '../widgets/mute_button.dart';
import '../widgets/photo_comparison_sheet.dart';
import '../widgets/quest_card.dart';
import '../widgets/room_restored_banner.dart';
import '../widgets/single_task_prompt.dart';
import '../widgets/vitality_hud.dart';
import '../widgets/voice_button.dart';

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

  /// The companion, mid-answer. Purely a beat - it changes nothing about the
  /// room or the run.
  bool _greeting = false;
  Timer? _greetingTimer;

  /// The before/after panel (§2.4), open after the ROOM RESTORED card has had
  /// its moment. Closed for good once dismissed, so it never becomes a thing
  /// the user has to keep swatting away.
  bool _showPhotos = false;

  static const _score = HapticScore();

  Haptics get _haptics => ref.read(hapticsProvider);
  RoomAudio get _audio => ref.read(roomAudioProvider);

  @override
  void dispose() {
    _restoredTimer?.cancel();
    _greetingTimer?.cancel();
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

    // The bed plays while the clock is running and stops the moment it is
    // not - a paused timer that keeps humming reads as "still going", which
    // is exactly the thing pause exists to stop saying.
    ref.listen(kitchenSessionProvider, (previous, next) {
      final state = next.valueOrNull;
      final running = state?.phase == RunPhase.running && !(state!.isPaused);
      final was = previous?.valueOrNull;
      final wasRunning = was?.phase == RunPhase.running && !(was!.isPaused);
      if (running == wasRunning) return;
      running ? _audio.startMusic() : _audio.stopMusic();
    });

    ref.listen(kitchenSessionProvider, (previous, next) {
      final phase = next.valueOrNull?.phase;
      if (previous?.valueOrNull?.phase == phase) return;

      if (phase == RunPhase.comboOffered) {
        _haptics.play(HapticCue.combo);
        return;
      }

      if (phase == RunPhase.restored) {
        _haptics.play(HapticCue.roomRestored);
        setState(() {
          _showRestored = true;
          // Only when there is a "before" to compare against - §2.4's
          // mechanic is the pair, and an unprompted camera at the end of a
          // run the user never photographed is just an interruption.
          _showPhotos = next.valueOrNull?.beforePhoto != null;
        });
        _restoredTimer?.cancel();
        // Long enough to land, short enough that it never becomes a wall
        // between the user and the room.
        _restoredTimer = Timer(
          const Duration(milliseconds: 2600),
          _dismissRestored,
        );
        return;
      }

      if (phase != RunPhase.celebrating) return;

      // Feedback never waits on I/O (CLAUDE.md): state is already updated,
      // so haptic, sound and particles fire immediately.
      final momentum = next.valueOrNull?.momentum ?? 0;
      _haptics.play(
        _score.isMilestone(momentum)
            ? HapticCue.momentumMilestone
            : HapticCue.taskComplete,
      );
      SystemSound.play(SystemSoundType.click);

      final spot = _spotFor(room.valueOrNull, next.valueOrNull?.currentTaskId);
      setState(() {
        _celebrationCount++;
        _celebration = RoomCelebration(id: _celebrationCount, spot: spot);
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
        (AsyncError(:final error), _) ||
        (_, AsyncError(:final error)) => _error(error),
        (AsyncData(value: final definition), AsyncData(value: final state)) =>
          _room(definition, state, controller),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  /// The offer names itself honestly. A setup quest says so (§3.6) rather
  /// than presenting itself as a shrunken failure of the real chore - that
  /// framing is the whole reason the bottom rung works.
  String _eyebrowFor(KitchenSession state, KitchenSessionEngine engine) {
    final rung = engine.activeRung(state);
    if (rung == null) return 'KITCHEN RESCUE';
    return rung.setupQuest ? 'GETTING READY' : 'SMALLER';
  }

  /// Whether this device can take a picture (§2.4). Unresolved counts as no:
  /// the affordance appearing a frame late is invisible, one that appears and
  /// then does nothing is not.
  bool _cameraReady() =>
      ref.watch(cameraAvailableProvider).valueOrNull ?? false;

  /// Celebrate where the work happened. Falls back to the middle of the room
  /// only if the task has no painted home.
  ({double x, double y}) _spotFor(RoomDefinition? definition, String? taskId) {
    final hotspot = taskId == null ? null : definition?.hotspotForTask(taskId);
    if (hotspot == null) return (x: 0.5, y: 0.5);
    return (x: hotspot.area.center.dx, y: hotspot.area.center.dy);
  }

  Widget _error(Object error) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        'Could not load the kitchen.\n$error',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white70),
      ),
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

    // Expanded deliberately. Scaffold hands its body *loose* constraints, and
    // a loose Stack shrinks to its largest non-positioned child - which here
    // is the HUD row. That collapsed the room to a band the height of the
    // vitality chip at the top of the screen, and made it snap to full size
    // the moment a centred card appeared, which read as a violent zoom.
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(
            child: KitchenRoomView(
              room: definition,
              vitality: vitality,
              showDishPile: engine.showsDishPile(state, now),
              showAffordances:
                  state.phase == RunPhase.idle ||
                  state.phase == RunPhase.restored,
              celebration: _celebration,
              companionMood: switch (state.phase) {
                _ when _greeting => CompanionMood.happy,
                RunPhase.celebrating => CompanionMood.excited,
                RunPhase.comboOffered => CompanionMood.happy,
                RunPhase.restored => CompanionMood.happy,
                RunPhase.questOffered => CompanionMood.thinking,
                _ => null,
              },
              onCompanionTap: _greetCompanion,
              onHotspotTap: (hotspot) => controller.offerQuest(hotspot.taskId),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VitalityHud(vitality: vitality, momentum: state.momentum),
                  const Spacer(),
                  IconButton(
                    onPressed: () =>
                        showAppMenuSheet(context, showBackToHouse: true),
                    tooltip: 'Menu',
                    icon: const Icon(Icons.menu, color: Colors.white70),
                  ),
                  const MuteButton(),
                  const VoiceButton(),
                ],
              ),
            ),
          ),
          if (state.phase == RunPhase.questOffered && currentTask != null)
            Center(
              child: QuestCard(
                title: engine.currentLabel(state) ?? currentTask.label,
                minutes: engine.currentMinutes(state),
                eyebrow: _eyebrowFor(state, engine),
                onPlay: controller.startRun,
                onDismiss: controller.dismissQuest,
                onNotThis: () => controller.notThis(NotThisReason.takesTooLong),
                onBeforePhoto: _cameraReady()
                    ? () => unawaited(controller.captureBeforePhoto())
                    : null,
                hasBeforePhoto: state.beforePhoto != null,
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
              label: engine.currentLabel(state) ?? currentTask.label,
              targetMinutes: engine.currentMinutes(state),
              elapsed: controller.activeElapsed,
              paused: state.isPaused,
              onDone: controller.completeTask,
              onPause: controller.pauseRun,
              onResume: controller.resumeRun,
              onSkip: controller.skipTask,
            ),
          if (_showRestored && state.phase == RunPhase.restored)
            RoomRestoredBanner(onDismiss: _dismissRestored),
          // After the title card, never over it. ROOM RESTORED is the reward
          // and it does not share the screen.
          if (!_showRestored &&
              _showPhotos &&
              state.phase == RunPhase.restored &&
              state.beforePhoto != null)
            PhotoComparisonSheet(
              beforePath: state.beforePhoto!,
              afterPath: state.afterPhoto,
              onDismiss: () => setState(() => _showPhotos = false),
              onDiscard: () {
                setState(() => _showPhotos = false);
                controller.discardPhotos();
              },
              onTakeAfter: _cameraReady()
                  ? () => unawaited(controller.captureAfterPhoto())
                  : null,
            ),
        ],
      ),
    );
  }

  /// Petting the companion (spec §2.2).
  ///
  /// It answers and nothing else happens. It used to open the room's most
  /// neglected task, which made the one warm, no-stakes thing on the screen
  /// into another way to be handed a chore - so the only safe place to put a
  /// finger was nowhere.
  void _greetCompanion() {
    _audio.play(AudioCue.companion);
    _greetingTimer?.cancel();
    setState(() => _greeting = true);
    _greetingTimer = Timer(
      const Duration(milliseconds: 900),
      () {
        if (mounted) setState(() => _greeting = false);
      },
    );
  }
}
