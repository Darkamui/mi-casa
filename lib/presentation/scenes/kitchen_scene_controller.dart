import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/kitchen_repository.dart';
import '../../simulation/adjacency_graph.dart';
import '../../simulation/combo_engine.dart';
import '../../simulation/content_loader.dart';
import '../../simulation/kitchen_session.dart';
import '../../simulation/voice_grammar.dart';
import '../audio/room_audio.dart';
import '../feedback/haptics.dart';
import '../photos/camera_photo_store.dart';
import '../photos/photo_store.dart';
import '../voice/voice_recognizer.dart';

export '../../simulation/kitchen_session.dart'
    show RunPhase, KitchenSession, KitchenSessionEngine, NotThisReason;
export '../../simulation/voice_grammar.dart' show VoiceIntent;

/// The clock, as a dependency. Overriding this is how a test drives entropy
/// forward without waiting for real hours to pass.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Builds the pure engine from the content files.
///
/// The engine knows nothing about Riverpod, the asset bundle, or the clock -
/// this is the seam where all three are supplied.
final kitchenEngineProvider = FutureProvider<KitchenSessionEngine>((ref) async {
  const loader = ContentLoader();
  final tasks = await loader.loadTasks();
  final edges = await loader.loadAdjacencyEdges();

  return KitchenSessionEngine(
    tasks: tasks.where((task) => task.roomTypeId == 'kitchen').toList(),
    comboEngine: ComboEngine(AdjacencyGraph(edges)),
  );
});

/// The open database, closed with the provider.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});

/// Overridden in tests with a repository over an in-memory database - or with
/// null, for widget tests that have no business touching disk.
final kitchenRepositoryProvider = Provider<KitchenRepository?>(
  (ref) => KitchenRepository(ref.watch(databaseProvider)),
);

/// On-device speech (spec §2.5). Overridden by whatever platform engine is
/// bound - and by a fake in tests, which is the only reason the grammar can
/// be exercised end to end without a microphone.
final voiceRecognizerProvider =
    Provider<VoiceRecognizer>((ref) => const UnavailableVoiceRecognizer());

/// The camera behind the optional before/after pair (spec §2.4). Local-only -
/// see [PhotoStore] for the constraint that shape is protecting.
final photoStoreProvider = Provider<PhotoStore>((ref) => CameraPhotoStore());

/// The device's buzz (spec §4.3). Overridden with [SilentHaptics] in tests,
/// and with a recording double wherever the patterns themselves are checked.
final hapticsProvider = Provider<Haptics>((ref) {
  final haptics = SystemHaptics();
  ref.onDispose(haptics.cancel);
  return haptics;
});

/// Sound (spec §4.2). Overridden with [SilentRoomAudio] in tests, and with a
/// recording double wherever the moments themselves are checked.
final roomAudioProvider = Provider<RoomAudio>((ref) {
  final audio = PlayerRoomAudio();
  ref.onDispose(audio.dispose);
  return audio;
});

/// Whether the room is silenced, for as long as the app is open.
///
/// Deliberately not persisted in Phase 0: there is no settings screen to
/// forget it in, and a mute that survives a restart is a mute the user has to
/// remember they set.
final mutedProvider = StateProvider<bool>((ref) => false);

/// Whether to offer the photo affordances at all. A device that cannot take
/// a picture is shown nothing about pictures.
final cameraAvailableProvider = FutureProvider<bool>(
  (ref) => ref.watch(photoStoreProvider).available(),
);

/// Drives the kitchen. Every transition delegates to the pure engine; this
/// class only supplies the clock, the store, and holds the result.
class KitchenSceneController extends AsyncNotifier<KitchenSession> {
  late KitchenSessionEngine _engine;
  KitchenRepository? _repository;

  KitchenSessionEngine get engine => _engine;

  DateTime _now() => ref.read(clockProvider)();

  @override
  Future<KitchenSession> build() async {
    _engine = await ref.watch(kitchenEngineProvider.future);
    _repository = ref.watch(kitchenRepositoryProvider);

    final now = _now();
    final seeded = _engine.seed(now: now);

    final repository = _repository;
    if (repository == null) return seeded;

    await repository.ensureSeeded(_engine.tasks, now);
    return repository.restore(_engine, seeded);
  }

  void _apply(KitchenSession Function(KitchenSession) transition) {
    final current = state.valueOrNull;
    if (current == null) return;
    final next = transition(current);
    state = AsyncData(next);
    _sweepPhotos(current, next);
  }

  /// Delete any photo the transition just stopped referring to.
  ///
  /// This lives with the transition rather than with the widget that took the
  /// picture, because the engine is what decides a pair is over - a new run
  /// opening, or the user throwing them away. §2.4's "local-only" is only
  /// true for as long as nothing quietly accumulates a folder of photographs
  /// of someone's kitchen; forgetting to delete is how that promise rots.
  ///
  /// Fired and not awaited, like every other write here (CLAUDE.md).
  void _sweepPhotos(KitchenSession before, KitchenSession after) {
    final kept = {after.beforePhoto, after.afterPhoto};
    final dropped = [before.beforePhoto, before.afterPhoto]
        .whereType<String>()
        .where((path) => !kept.contains(path));
    if (dropped.isEmpty) return;

    final store = ref.read(photoStoreProvider);
    for (final path in dropped) {
      unawaited(store.discard(path));
    }
  }

  void offerQuest(String taskId) =>
      _apply((s) => _engine.offerQuest(s, taskId));

  void dismissQuest() => _apply(_engine.dismissQuest);

  /// NOT THIS (spec §3.7). No write, because nothing happened - the only
  /// record a rejection leaves is what the app offers next.
  void notThis(NotThisReason reason) =>
      _apply((s) => _engine.notThis(s, reason, _now()));

  void startRun() => _apply((s) => _engine.startRun(s, _now()));

  /// DONE.
  ///
  /// The state update is synchronous and lands first; the write is fired off
  /// afterwards and nothing waits on it (CLAUDE.md: DONE -> local state ->
  /// feedback -> then background work, never DONE -> request -> spinner).
  void completeTask() {
    final before = state.valueOrNull;
    if (before == null || before.phase != RunPhase.running) return;

    final now = _now();
    final active = _engine.activeElapsed(before, now);
    // A rung is stored under its own id: it is a different act from the task
    // it stands in for, and the estimate it teaches belongs to itself.
    final taskId =
        _engine.activeRung(before)?.id ?? before.currentTaskId;

    _apply((s) => _engine.completeTask(s, now));

    if (taskId == null) return;
    final write = _repository?.recordCompletion(
      taskId: taskId,
      at: now,
      actualMinutes: active.inSeconds / 60.0,
    );
    if (write != null) unawaited(write);
  }

  void pauseRun() => _apply((s) => _engine.pauseRun(s, _now()));

  void resumeRun() => _apply((s) => _engine.resumeRun(s, _now()));

  void skipTask() => _apply(_engine.skipTask);

  /// Active time on the task in play, read live by the run timer.
  Duration activeElapsed() {
    final current = state.valueOrNull;
    if (current == null) return Duration.zero;
    return _engine.activeElapsed(current, _now());
  }

  /// Something was said (spec §2.5).
  ///
  /// Returns the intent it resolved to, or null if the utterance meant
  /// nothing here - the caller uses that to decide whether to acknowledge.
  /// An unrecognised phrase is silence, never an error: telling someone with
  /// wet hands that they said it wrong is worse than doing nothing.
  VoiceIntent? hear(String utterance) {
    const grammar = VoiceGrammar();
    final intent = grammar.parse(utterance);
    if (intent == null) return null;

    // DONE is the one spoken command that writes, so it goes through the same
    // path a tap does rather than a second, quieter one.
    if (intent == VoiceIntent.done) {
      final before = state.valueOrNull;
      if (before == null || before.phase != RunPhase.running) return null;
      completeTask();
      return intent;
    }

    final before = state.valueOrNull;
    _apply((s) => _engine.applyVoice(s, intent, _now()));
    // A command that changed nothing did not apply here.
    return identical(state.valueOrNull, before) ? null : intent;
  }

  /// Take the optional "before" (spec §2.4).
  ///
  /// Returns false when nothing was taken - no camera, or the user backed
  /// out. Backing out is not a failure and the caller must not report it as
  /// one; the run is unaffected either way.
  Future<bool> captureBeforePhoto() async {
    final path = await ref.read(photoStoreProvider).capture();
    if (path == null) return false;

    final before = state.valueOrNull;
    _apply((s) => _engine.attachBeforePhoto(s, path));
    // The offer can close while the camera is open. If the engine refused the
    // photo, the file is ours and nobody is going to look at it.
    if (identical(state.valueOrNull?.beforePhoto, before?.beforePhoto)) {
      unawaited(ref.read(photoStoreProvider).discard(path));
      return false;
    }
    return true;
  }

  Future<bool> captureAfterPhoto() async {
    final path = await ref.read(photoStoreProvider).capture();
    if (path == null) return false;

    final before = state.valueOrNull;
    _apply((s) => _engine.attachAfterPhoto(s, path));
    if (identical(state.valueOrNull?.afterPhoto, before?.afterPhoto)) {
      unawaited(ref.read(photoStoreProvider).discard(path));
      return false;
    }
    return true;
  }

  /// Throw the pair away, files included (see [_sweepPhotos]).
  void discardPhotos() => _apply(_engine.discardPhotos);

  void finishCelebration() => _apply(_engine.finishCelebration);

  void acceptCombo() => _apply((s) => _engine.acceptCombo(s, _now()));

  void declineCombo() => _apply(_engine.declineCombo);
}

final kitchenSessionProvider =
    AsyncNotifierProvider<KitchenSceneController, KitchenSession>(
  KitchenSceneController.new,
);
