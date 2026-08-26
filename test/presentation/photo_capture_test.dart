import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/presentation/photos/photo_store.dart';
import 'package:micasa/presentation/scenes/kitchen_scene_controller.dart';
import 'package:micasa/simulation/adjacency_graph.dart';
import 'package:micasa/simulation/combo_engine.dart';
import 'package:micasa/simulation/models/task_definition.dart';

/// A camera that hands out paths and remembers what it was told to delete.
class FakePhotoStore implements PhotoStore {
  FakePhotoStore({this.isAvailable = true, this.backsOut = false});

  final bool isAvailable;

  /// The user opening the camera and changing their mind.
  bool backsOut;

  int captures = 0;
  final List<String> handedOut = [];
  final List<String> discarded = [];

  /// What is actually still on disk.
  Set<String> get onDisk => handedOut.toSet().difference(discarded.toSet());

  @override
  Future<bool> available() async => isAvailable;

  @override
  Future<String?> capture() async {
    if (!isAvailable || backsOut) return null;
    final path = '/photos/${captures++}.jpg';
    handedOut.add(path);
    return path;
  }

  @override
  Future<void> discard(String path) async => discarded.add(path);
}

const _tasks = [
  TaskDefinition(
    id: 'dishes',
    roomTypeId: 'kitchen',
    label: 'Put the dishes away',
    baseDurationMinutes: 10,
    defaultRisePerHour: 0.05,
  ),
];

final _t0 = DateTime.utc(2026, 8, 25, 12);

final _engine = KitchenSessionEngine(
  tasks: _tasks,
  comboEngine: ComboEngine(AdjacencyGraph(const [])),
);

void main() {
  late FakePhotoStore store;
  late ProviderContainer container;
  late KitchenSceneController controller;

  setUp(() async {
    store = FakePhotoStore();
    container = ProviderContainer(overrides: [
      kitchenEngineProvider.overrideWith((ref) async => _engine),
      kitchenRepositoryProvider.overrideWithValue(null),
      clockProvider.overrideWithValue(() => _t0),
      photoStoreProvider.overrideWithValue(store),
    ]);
    addTearDown(container.dispose);
    await container.read(kitchenSessionProvider.future);
    controller = container.read(kitchenSessionProvider.notifier);
  });

  KitchenSession state() => container.read(kitchenSessionProvider).value!;

  /// Play a run from the open offer to its end.
  void playThrough() {
    controller.startRun();
    controller.completeTask();
    controller.finishCelebration();
  }

  group('taking the pair (spec 2.4)', () {
    test('a before and an after become a comparison', () async {
      controller.offerQuest('dishes');
      expect(await controller.captureBeforePhoto(), isTrue);

      playThrough();
      expect(state().phase, RunPhase.restored);
      expect(await controller.captureAfterPhoto(), isTrue);

      expect(state().hasComparison, isTrue);
    });

    test('backing out of the camera is not a failure and costs nothing',
        () async {
      controller.offerQuest('dishes');
      store.backsOut = true;

      expect(await controller.captureBeforePhoto(), isFalse);
      expect(state().beforePhoto, isNull);
      expect(state().phase, RunPhase.questOffered);
    });

    test('a device with no camera reports nothing taken', () async {
      final blind = ProviderContainer(overrides: [
        kitchenEngineProvider.overrideWith((ref) async => _engine),
        kitchenRepositoryProvider.overrideWithValue(null),
        clockProvider.overrideWithValue(() => _t0),
        photoStoreProvider.overrideWithValue(const UnavailablePhotoStore()),
      ]);
      addTearDown(blind.dispose);
      await blind.read(kitchenSessionProvider.future);

      expect(await blind.read(cameraAvailableProvider.future), isFalse);
      expect(
        await blind.read(kitchenSessionProvider.notifier).captureBeforePhoto(),
        isFalse,
      );
    });
  });

  group('nothing is left on disk that nothing points at', () {
    test('deleting the pair deletes the files', () async {
      controller.offerQuest('dishes');
      await controller.captureBeforePhoto();
      playThrough();
      await controller.captureAfterPhoto();

      controller.discardPhotos();

      expect(store.onDisk, isEmpty);
      expect(store.discarded.length, 2);
    });

    test('starting a new run deletes the last run\'s pair', () async {
      controller.offerQuest('dishes');
      await controller.captureBeforePhoto();
      playThrough();
      await controller.captureAfterPhoto();

      controller.offerQuest('dishes');

      expect(store.onDisk, isEmpty);
    });

    test('a photo the engine refused is deleted, not orphaned', () async {
      // The offer can close while the camera is open. Nobody will ever see
      // that file, so it must not survive.
      controller.offerQuest('dishes');
      playThrough();

      // Restored, with no before - the engine refuses the after.
      expect(await controller.captureAfterPhoto(), isFalse);
      expect(store.onDisk, isEmpty);
      expect(store.handedOut, hasLength(1));
    });

    test('a run with no photos deletes nothing', () async {
      controller.offerQuest('dishes');
      playThrough();
      controller.offerQuest('dishes');

      expect(store.discarded, isEmpty);
    });
  });
}
