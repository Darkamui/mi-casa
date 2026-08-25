import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RunPhase { idle, questOffered, running, celebrating, restored }

class KitchenSceneController extends Notifier<RunPhase> {
  @override
  RunPhase build() => RunPhase.idle;

  void tapCompanion() {
    if (state != RunPhase.idle) return;
    state = RunPhase.questOffered;
  }

  /// Backs out of an offer without starting it. Declining a quest must be
  /// as cheap as accepting one - the room goes back to idle, nothing is
  /// recorded against the player, and every hotspot is live again.
  void dismissQuest() {
    if (state != RunPhase.questOffered) return;
    state = RunPhase.idle;
  }

  void startRun() {
    if (state != RunPhase.questOffered) return;
    state = RunPhase.running;
  }

  void completeTask() {
    if (state != RunPhase.running) return;
    state = RunPhase.celebrating;
  }

  void finishCelebration() {
    if (state != RunPhase.celebrating) return;
    state = RunPhase.restored;
  }
}

final kitchenSceneProvider =
    NotifierProvider<KitchenSceneController, RunPhase>(
  KitchenSceneController.new,
);
