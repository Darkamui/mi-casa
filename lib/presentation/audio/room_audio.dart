import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

/// One-shot sounds the room can make.
enum AudioCue {
  /// The companion, answering a tap. Spec §2.2 - it responds, it does not
  /// take over.
  companion('content/audio/companion_tap.wav');

  const AudioCue(this.asset);

  final String asset;
}

/// The looping bed under a run. See `content/audio/README.md`.
const kRunMusicAsset = 'content/audio/run_loop.wav';

/// Sound, as a dependency.
///
/// An interface for the same reason [Haptics] is one: the tests that matter
/// are about *when* the room makes a noise, and those must run without a
/// device. It is also the only place that knows an audio file exists at all,
/// so replacing the placeholder loops with authored music is a content
/// change rather than a code change.
///
/// Nothing here is ever awaited by the UI. CLAUDE.md: DONE -> local state ->
/// feedback; a sound the screen waits on is not feedback.
abstract class RoomAudio {
  /// Starts the run bed, or does nothing if it is already playing.
  void startMusic();

  /// Stops it. Called on pause as well as on finish - a paused clock should
  /// not still be humming.
  void stopMusic();

  /// Silences everything without forgetting what was playing, so unmuting
  /// mid-run picks the bed back up.
  void setMuted(bool muted);

  void play(AudioCue cue);

  void dispose();
}

/// The real thing.
class PlayerRoomAudio implements RoomAudio {
  PlayerRoomAudio({AudioPlayer? music, AudioPlayer? effects})
      : _music = music ?? AudioPlayer(playerId: 'micasa.music'),
        _effects = effects ?? AudioPlayer(playerId: 'micasa.effects') {
    // audioplayers looks under `assets/` unless told otherwise, and this
    // project keeps its authored content in `content/` (CLAUDE.md).
    final cache = AudioCache(prefix: '');
    _music.audioCache = cache;
    _effects.audioCache = cache;
    unawaited(_music.setReleaseMode(ReleaseMode.loop));
    // The bed sits under the room, not over it.
    unawaited(_music.setVolume(0.35));
  }

  final AudioPlayer _music;
  final AudioPlayer _effects;

  bool _muted = false;
  bool _wantsMusic = false;

  @override
  void startMusic() {
    _wantsMusic = true;
    if (_muted) return;
    unawaited(_music.play(AssetSource(kRunMusicAsset)));
  }

  @override
  void stopMusic() {
    _wantsMusic = false;
    unawaited(_music.stop());
  }

  @override
  void setMuted(bool muted) {
    if (_muted == muted) return;
    _muted = muted;
    if (muted) {
      unawaited(_music.stop());
      return;
    }
    if (_wantsMusic) startMusic();
  }

  @override
  void play(AudioCue cue) {
    if (_muted) return;
    unawaited(_effects.play(AssetSource(cue.asset)));
  }

  @override
  void dispose() {
    unawaited(_music.dispose());
    unawaited(_effects.dispose());
  }
}

/// Nothing at all - for tests, and for anywhere sound would be wrong.
class SilentRoomAudio implements RoomAudio {
  const SilentRoomAudio();

  @override
  void startMusic() {}

  @override
  void stopMusic() {}

  @override
  void setMuted(bool muted) {}

  @override
  void play(AudioCue cue) {}

  @override
  void dispose() {}
}
