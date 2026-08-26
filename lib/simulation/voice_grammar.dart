/// What the user meant, independent of how they said it.
///
/// Spec §2.5 fixes the minimum viable set: done, next, skip, pause, five more
/// minutes. [resume] is the sixth because [pause] without it is a trap - a
/// user whose hands are wet enough to need voice cannot tap to come back.
enum VoiceIntent { done, next, skip, pause, resume, fiveMoreMinutes }

/// Turns a recognised utterance into an intent.
///
/// Pure, offline, and deliberately tiny. Spec §2.5: "Hands are wet, gloved,
/// or full. This is the actual usability constraint, not a nice-to-have."
/// That constraint is also why this is a phrase matcher rather than anything
/// cleverer - a phrase matcher fails predictably, and a user with soapy hands
/// needs to know what will happen before they say it.
class VoiceGrammar {
  const VoiceGrammar();

  /// Phrases per intent, matched on word boundaries.
  ///
  /// Ordered most specific first, because "five more minutes" contains
  /// nothing else but "next one" would otherwise lose to a bare "next".
  static const _phrases = <VoiceIntent, List<String>>{
    VoiceIntent.fiveMoreMinutes: [
      'five more minutes',
      '5 more minutes',
      'five minutes',
      '5 minutes',
      'a bit longer',
      'more time',
    ],
    VoiceIntent.done: ['done', 'finished', 'got it', 'complete'],
    VoiceIntent.next: ['next', 'keep going', 'another one', 'yes'],
    VoiceIntent.skip: ['skip', 'not this', 'something else', 'pass'],
    VoiceIntent.pause: ['pause', 'hold on', 'wait', 'stop'],
    VoiceIntent.resume: ['resume', 'carry on', 'unpause', 'continue', 'go'],
  };

  /// Words that reverse whatever follows them.
  ///
  /// "I'm not done" must never record a completion. A misheard yes is
  /// recoverable; a misheard DONE quietly tells the room a lie, and §2.4
  /// makes the room's honesty the whole point.
  static const _negations = ['not', "n't", 'never', 'no '];

  VoiceIntent? parse(String utterance) {
    final text = _normalise(utterance);
    if (text.isEmpty) return null;

    for (final entry in _phrases.entries) {
      for (final phrase in entry.value) {
        final at = _indexOfPhrase(text, phrase);
        if (at < 0) continue;
        if (_isNegated(text, at)) return null;
        return entry.key;
      }
    }
    return null;
  }

  String _normalise(String utterance) {
    final lowered = utterance.toLowerCase();
    final stripped = lowered.replaceAll(RegExp(r"[^a-z0-9' ]"), ' ');
    // Pad so word-boundary checks need no special case at either end.
    return ' ${stripped.replaceAll(RegExp(r'\s+'), ' ').trim()} ';
  }

  /// Index of [phrase] in the padded [text], or -1. Whole words only, so
  /// "abandoned" is not "done" and "gone" is not "go".
  int _indexOfPhrase(String text, String phrase) => text.indexOf(' $phrase ');

  /// Whether a negation appears in the few words before the match.
  ///
  /// Scoped rather than global: "skip the dishes, I never do them" is still a
  /// skip, but "not done" is nothing at all.
  bool _isNegated(String text, int matchAt) {
    final before = text.substring(0, matchAt + 1);
    final words = before.trim().split(' ');
    final window = words.length <= 3 ? words : words.sublist(words.length - 3);
    final tail = ' ${window.join(' ')} ';
    return _negations.any(tail.contains);
  }
}
