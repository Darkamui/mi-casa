import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../effects/particle_burst.dart';
import '../widgets/companion_widget.dart';
import '../widgets/quest_card.dart';
import '../widgets/single_task_prompt.dart';
import 'dish_pile.dart';
import 'kitchen_background.dart';
import 'kitchen_scene_controller.dart';

class KitchenScene extends ConsumerWidget {
  const KitchenScene({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(kitchenSceneProvider);
    final notifier = ref.read(kitchenSceneProvider.notifier);

    ref.listen<RunPhase>(kitchenSceneProvider, (previous, next) {
      if (next == RunPhase.celebrating) {
        HapticFeedback.mediumImpact();
        SystemSound.play(SystemSoundType.click);
        Future.delayed(const Duration(milliseconds: 900), notifier.finishCelebration);
      }
    });

    final restored = phase == RunPhase.celebrating || phase == RunPhase.restored;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: KitchenBackground()),
          Align(
            alignment: const Alignment(0.05, -0.1),
            child: AnimatedOpacity(
              opacity: restored ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 500),
              child: AnimatedScale(
                scale: restored ? 0.6 : 1.0,
                duration: const Duration(milliseconds: 500),
                child: const SizedBox(
                  width: 140,
                  height: 100,
                  child: DishPile(),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: 40,
            child: CompanionWidget(
              mood: phase == RunPhase.celebrating
                  ? CompanionMood.celebrating
                  : CompanionMood.idle,
              onTap: notifier.tapCompanion,
            ),
          ),
          if (phase == RunPhase.questOffered)
            Center(child: QuestCard(onPlay: notifier.startRun)),
          if (phase == RunPhase.running) SingleTaskPrompt(onDone: notifier.completeTask),
          Positioned.fill(child: ParticleBurst(active: phase == RunPhase.celebrating)),
          if (phase == RunPhase.restored)
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 64),
                child: Text(
                  'KITCHEN RESTORED',
                  style: TextStyle(
                      color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
