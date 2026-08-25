import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../scenes/kitchen_scene_controller.dart';
import '../widgets/quest_card.dart';
import '../widgets/single_task_prompt.dart';
import 'kitchen_game.dart';

class KitchenFlameScreen extends ConsumerStatefulWidget {
  const KitchenFlameScreen({super.key});

  @override
  ConsumerState<KitchenFlameScreen> createState() =>
      _KitchenFlameScreenState();
}

class _KitchenFlameScreenState extends ConsumerState<KitchenFlameScreen> {
  late final KitchenGame _game;

  @override
  void initState() {
    super.initState();
    _game = KitchenGame(
      onCompanionTap: () =>
          ref.read(kitchenSceneProvider.notifier).tapCompanion(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final phase = ref.watch(kitchenSceneProvider);
    final notifier = ref.read(kitchenSceneProvider.notifier);

    ref.listen<RunPhase>(kitchenSceneProvider, (previous, next) {
      if (next == RunPhase.celebrating) {
        _game.kitchenRoom.celebrateCompletion();
        HapticFeedback.mediumImpact();
        SystemSound.play(SystemSoundType.click);
        Future.delayed(
            const Duration(milliseconds: 900), notifier.finishCelebration);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF2B2B33),
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: _game)),
          if (phase == RunPhase.questOffered)
            Center(child: QuestCard(onPlay: notifier.startRun)),
          if (phase == RunPhase.running)
            SingleTaskPrompt(onDone: notifier.completeTask),
          if (phase == RunPhase.restored)
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 64),
                child: Text(
                  'KITCHEN RESTORED',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
