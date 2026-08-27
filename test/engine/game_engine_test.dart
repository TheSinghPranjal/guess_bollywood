import 'package:bollywood_guess/data/models/movie.dart';
import 'package:bollywood_guess/features/game/engine/game_engine.dart';
import 'package:flutter_test/flutter_test.dart';

Movie _movie(String title) {
  return Movie(
    id: 'test',
    title: title,
    industry: MovieIndustry.bollywood,
    year: 2004,
    cast: const ['A', 'B'],
    about: 'About',
    hints: const ['h1', 'h2', 'h3', 'h4'],
    era: '2000-2009',
  );
}

void main() {
  late GameEngine engine;

  setUp(() {
    engine = GameEngine();
  });

  group('masking', () {
    test('MASTI vowels revealed', () {
      final cells = engine.buildMask('MASTI');
      expect(engine.formatMask(cells), '_ A _ _ I');
    });

    test('SAIYAARA', () {
      final cells = engine.buildMask('SAIYAARA');
      expect(engine.formatMask(cells), '_ A I _ A A _ A');
    });

    test('MISSION MAJNU multi-word', () {
      final cells = engine.buildMask('MISSION MAJNU');
      expect(engine.formatMask(cells), '_ I _ _ I O _ / _ A _ _ U');
    });

    test('numbers auto-revealed', () {
      final cells = engine.buildMask('Mardaani 3');
      expect(engine.formatMask(cells), '_ A _ _ A A _ I / 3');
    });

    test('DANGAL', () {
      expect(engine.formatMask(engine.buildMask('DANGAL')), '_ A _ _ A _');
    });
  });

  group('guessing', () {
    test('correct guess reveals all occurrences', () {
      var session = engine.startSession(
        movie: _movie('BANANA'),
        hintCount: 4,
      );
      expect(engine.formatMask(session.cells), '_ A _ A _ A');
      session = engine.applyGuess(session, 'N');
      expect(engine.formatMask(session.cells), '_ A N A N A');
      expect(session.livesRemaining, 10);
      expect(session.lastGuess?.correct, isTrue);
    });

    test('wrong guess consumes one life', () {
      var session = engine.startSession(movie: _movie('MASTI'), hintCount: 4);
      session = engine.applyGuess(session, 'B');
      expect(session.livesRemaining, 9);
      expect(session.wrongGuessCount, 1);
      expect(session.incorrectLetters.contains('B'), isTrue);
    });

    test('duplicate guess ignored', () {
      var session = engine.startSession(movie: _movie('MASTI'), hintCount: 4);
      session = engine.applyGuess(session, 'B');
      session = engine.applyGuess(session, 'B');
      expect(session.livesRemaining, 9);
      expect(session.wrongGuessCount, 1);
      expect(session.lastGuess?.ignored, isTrue);
    });

    test('win detection', () {
      var session = engine.startSession(movie: _movie('MASTI'), hintCount: 4);
      session = engine.applyGuess(session, 'M');
      session = engine.applyGuess(session, 'T');
      session = engine.applyGuess(session, 'S');
      expect(session.status.name, 'won');
      expect(engine.formatMask(session.cells), 'M A S T I');
    });

    test('lose after 10 wrong guesses', () {
      var session = engine.startSession(movie: _movie('MASTI'), hintCount: 4);
      const wrongs = ['B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'N'];
      for (final w in wrongs) {
        session = engine.applyGuess(session, w);
      }
      expect(session.status.name, 'lost');
      expect(session.livesRemaining, 0);
    });

    test('hint triggers on 6-9 with config 4', () {
      var session = engine.startSession(movie: _movie('MASTI'), hintCount: 4);
      const wrongs = ['B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'L'];
      final unlocked = <int?>[];
      for (final w in wrongs) {
        session = engine.applyGuess(session, w);
        unlocked.add(session.lastGuess?.hintUnlocked);
      }
      expect(unlocked[5], 1); // 6th
      expect(unlocked[6], 2);
      expect(unlocked[7], 3);
      expect(unlocked[8], 4);
      expect(session.unlockedHintCount, 4);
    });

    test('hint config 2 only unlocks two hints', () {
      var session = engine.startSession(movie: _movie('MASTI'), hintCount: 2);
      const wrongs = ['B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'L'];
      for (final w in wrongs) {
        session = engine.applyGuess(session, w);
      }
      expect(session.unlockedHintCount, 2);
    });

    test('extra life does not grant hint', () {
      var session = engine.startSession(movie: _movie('MASTI'), hintCount: 4);
      const wrongs = ['B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'N'];
      for (final w in wrongs) {
        session = engine.applyGuess(session, w);
      }
      expect(session.status.name, 'lost');
      final hintsBefore = session.unlockedHintCount;
      session = engine.grantExtraLife(session);
      expect(session.extraLifeActive, isTrue);
      expect(session.extraLifeUsed, isTrue);
      session = engine.applyGuess(session, 'P');
      expect(session.status.name, 'lost');
      expect(session.unlockedHintCount, hintsBefore);
      expect(session.extraLifeActive, isFalse);
    });

    test('vowel-only title auto wins', () {
      final session = engine.startSession(movie: _movie('AEIOU'), hintCount: 0);
      expect(session.status.name, 'won');
    });
  });
}
