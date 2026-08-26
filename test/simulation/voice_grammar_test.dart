import 'package:flutter_test/flutter_test.dart';
import 'package:micasa/simulation/voice_grammar.dart';

void main() {
  const grammar = VoiceGrammar();

  group('the five commands spec 2.5 requires', () {
    test('each bare command is understood', () {
      expect(grammar.parse('done'), VoiceIntent.done);
      expect(grammar.parse('next'), VoiceIntent.next);
      expect(grammar.parse('skip'), VoiceIntent.skip);
      expect(grammar.parse('pause'), VoiceIntent.pause);
      expect(grammar.parse('five more minutes'), VoiceIntent.fiveMoreMinutes);
    });

    test('pause has a way back', () {
      // A user whose hands are wet enough to need voice cannot tap to resume.
      expect(grammar.parse('resume'), VoiceIntent.resume);
      expect(grammar.parse('carry on'), VoiceIntent.resume);
    });
  });

  group('people do not speak in single words', () {
    test('a command inside a sentence still counts', () {
      expect(grammar.parse("okay I'm done"), VoiceIntent.done);
      expect(grammar.parse('alright next one'), VoiceIntent.next);
      expect(grammar.parse('just skip this one'), VoiceIntent.skip);
    });

    test('punctuation and case do not matter', () {
      expect(grammar.parse('DONE!'), VoiceIntent.done);
      expect(grammar.parse('Pause.'), VoiceIntent.pause);
    });

    test('the digit and the word are the same request', () {
      expect(grammar.parse('5 more minutes'), VoiceIntent.fiveMoreMinutes);
      expect(
        grammar.parse('give me five more minutes'),
        VoiceIntent.fiveMoreMinutes,
      );
    });

    test('"five more minutes" is not heard as something shorter', () {
      // It contains no other command, but a careless matcher that scans
      // shortest-first can still find one inside a longer utterance.
      expect(
        grammar.parse('can I have five more minutes'),
        VoiceIntent.fiveMoreMinutes,
      );
    });
  });

  group('mishearing must be safe', () {
    test('a negated command is nothing at all', () {
      // A misheard yes is recoverable; a misheard DONE tells the room a lie.
      expect(grammar.parse("I'm not done"), isNull);
      expect(grammar.parse('no not done yet'), isNull);
      expect(grammar.parse("don't pause"), isNull);
    });

    test('commands are whole words, never fragments', () {
      expect(grammar.parse('I abandoned it'), isNull);
      expect(grammar.parse('the dog has gone'), isNull);
      expect(grammar.parse('undone'), isNull);
    });

    test('an unrelated sentence means nothing', () {
      expect(grammar.parse('what is the weather like'), isNull);
      expect(grammar.parse(''), isNull);
      expect(grammar.parse('   '), isNull);
    });

    test('a negation far from the command does not swallow it', () {
      // "I never do these" is context, not a reversal of "skip".
      expect(
        grammar.parse('skip this one I never do these anyway'),
        VoiceIntent.skip,
      );
    });
  });
}
