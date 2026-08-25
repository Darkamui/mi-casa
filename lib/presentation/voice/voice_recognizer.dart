import 'dart:async';

/// On-device speech, as a port (spec §2.5).
///
/// The contract is deliberately narrow - start, stop, a stream of recognised
/// text - because everything interesting about voice in this app is the
/// grammar behind it, and that lives in `lib/simulation` where it can be
/// tested without a microphone.
///
/// **No implementation of this may send audio anywhere.** §2.5 says
/// "on-device speech recognition; no server round-trip", and the reason is
/// not latency: the app has no backend and no login, and a chore assistant
/// that streams the inside of someone's home to a server is a different
/// product.
abstract class VoiceRecognizer {
  /// Whether this device can listen at all. False is a normal answer - it is
  /// what every desktop build returns today - and the UI must stay complete
  /// without voice, never degraded by its absence.
  Future<bool> available();

  /// Recognised utterances, as plain text. One event per phrase.
  Stream<String> get utterances;

  Future<void> start();

  Future<void> stop();
}

/// The default: a device that cannot listen.
///
/// Phase 0 ships the grammar and the wiring; binding a real engine is a
/// platform-channel job that spec §5.4 explicitly rates lower risk and tells
/// us not to spike deeply. This keeps that seam honest in the meantime -
/// nothing pretends to hear.
class UnavailableVoiceRecognizer implements VoiceRecognizer {
  const UnavailableVoiceRecognizer();

  @override
  Future<bool> available() async => false;

  @override
  Stream<String> get utterances => const Stream.empty();

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}
}
