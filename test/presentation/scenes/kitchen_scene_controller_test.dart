import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/scenes/kitchen_scene_controller.dart';

void main() {
  test('starts idle', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(kitchenSceneProvider), RunPhase.idle);
  });

  test('tapCompanion moves idle -> questOffered', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(kitchenSceneProvider.notifier).tapCompanion();

    expect(container.read(kitchenSceneProvider), RunPhase.questOffered);
  });

  test('startRun is ignored unless questOffered', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(kitchenSceneProvider.notifier).startRun();

    expect(container.read(kitchenSceneProvider), RunPhase.idle);
  });

  test('completeTask is ignored unless running', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(kitchenSceneProvider.notifier).completeTask();

    expect(container.read(kitchenSceneProvider), RunPhase.idle);
  });

  test('dismissQuest returns an offer to idle so it can be re-offered', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(kitchenSceneProvider.notifier);

    notifier.tapCompanion();
    notifier.dismissQuest();
    expect(container.read(kitchenSceneProvider), RunPhase.idle);

    // Declining must not lock the player out of trying again.
    notifier.tapCompanion();
    expect(container.read(kitchenSceneProvider), RunPhase.questOffered);
  });

  test('dismissQuest cannot abandon a run already underway', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(kitchenSceneProvider.notifier);

    notifier.tapCompanion();
    notifier.startRun();
    notifier.dismissQuest();

    expect(container.read(kitchenSceneProvider), RunPhase.running);
  });

  test('full happy path idle -> restored', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(kitchenSceneProvider.notifier);

    notifier.tapCompanion();
    notifier.startRun();
    notifier.completeTask();
    notifier.finishCelebration();

    expect(container.read(kitchenSceneProvider), RunPhase.restored);
  });
}
