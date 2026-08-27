import 'package:equatable/equatable.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/game_status.dart';
import '../../../data/models/movie.dart';

enum MaskCellType { letter, separator, punctuation, digit }

class MaskCell extends Equatable {
  const MaskCell({
    required this.raw,
    required this.display,
    required this.type,
    required this.revealed,
    required this.guessable,
  });

  final String raw;
  final String display;
  final MaskCellType type;
  final bool revealed;
  final bool guessable;

  MaskCell copyWith({bool? revealed, String? display}) {
    return MaskCell(
      raw: raw,
      display: display ?? this.display,
      type: type,
      revealed: revealed ?? this.revealed,
      guessable: guessable,
    );
  }

  @override
  List<Object?> get props => [raw, display, type, revealed, guessable];
}

class GuessResult extends Equatable {
  const GuessResult({
    required this.letter,
    required this.ignored,
    required this.correct,
    required this.lifeLost,
    required this.hintUnlocked,
    required this.won,
    required this.lost,
  });

  final String letter;
  final bool ignored;
  final bool correct;
  final bool lifeLost;
  final int? hintUnlocked; // 1-based hint index, null if none
  final bool won;
  final bool lost;

  @override
  List<Object?> get props =>
      [letter, ignored, correct, lifeLost, hintUnlocked, won, lost];
}

class GameSession extends Equatable {
  const GameSession({
    required this.movie,
    required this.cells,
    required this.status,
    required this.guessedLetters,
    required this.correctLetters,
    required this.incorrectLetters,
    required this.livesRemaining,
    required this.wrongGuessCount,
    required this.configuredHintCount,
    required this.unlockedHintCount,
    required this.remainingTime,
    required this.elapsed,
    required this.extraLifeActive,
    required this.extraLifeUsed,
    required this.lastGuess,
  });

  final Movie movie;
  final List<MaskCell> cells;
  final GameStatus status;
  final Set<String> guessedLetters;
  final Set<String> correctLetters;
  final Set<String> incorrectLetters;
  final int livesRemaining;
  final int wrongGuessCount;
  final int configuredHintCount;
  final int unlockedHintCount;
  final Duration? remainingTime;
  final Duration elapsed;
  final bool extraLifeActive;
  final bool extraLifeUsed;
  final GuessResult? lastGuess;

  bool get hasExtraLifeVisual => extraLifeActive;
  bool get canOfferRewardedLife =>
      status == GameStatus.lost && !extraLifeUsed && !extraLifeActive;
  bool get hintButtonVisible => unlockedHintCount > 0;

  List<String> get unlockedHints =>
      movie.hints.take(unlockedHintCount).toList(growable: false);

  String get maskedDisplay {
    final buffer = StringBuffer();
    for (final cell in cells) {
      if (cell.type == MaskCellType.separator) {
        buffer.write(' / ');
      } else if (cell.revealed) {
        buffer.write(cell.display);
      } else {
        buffer.write('_');
      }
      if (cell.type != MaskCellType.separator) buffer.write(' ');
    }
    return buffer.toString().trim();
  }

  GameSession copyWith({
    Movie? movie,
    List<MaskCell>? cells,
    GameStatus? status,
    Set<String>? guessedLetters,
    Set<String>? correctLetters,
    Set<String>? incorrectLetters,
    int? livesRemaining,
    int? wrongGuessCount,
    int? configuredHintCount,
    int? unlockedHintCount,
    Duration? remainingTime,
    bool clearRemainingTime = false,
    Duration? elapsed,
    bool? extraLifeActive,
    bool? extraLifeUsed,
    GuessResult? lastGuess,
    bool clearLastGuess = false,
  }) {
    return GameSession(
      movie: movie ?? this.movie,
      cells: cells ?? this.cells,
      status: status ?? this.status,
      guessedLetters: guessedLetters ?? this.guessedLetters,
      correctLetters: correctLetters ?? this.correctLetters,
      incorrectLetters: incorrectLetters ?? this.incorrectLetters,
      livesRemaining: livesRemaining ?? this.livesRemaining,
      wrongGuessCount: wrongGuessCount ?? this.wrongGuessCount,
      configuredHintCount: configuredHintCount ?? this.configuredHintCount,
      unlockedHintCount: unlockedHintCount ?? this.unlockedHintCount,
      remainingTime:
          clearRemainingTime ? remainingTime : remainingTime ?? this.remainingTime,
      elapsed: elapsed ?? this.elapsed,
      extraLifeActive: extraLifeActive ?? this.extraLifeActive,
      extraLifeUsed: extraLifeUsed ?? this.extraLifeUsed,
      lastGuess: clearLastGuess ? lastGuess : lastGuess ?? this.lastGuess,
    );
  }

  @override
  List<Object?> get props => [
        movie,
        cells,
        status,
        guessedLetters,
        correctLetters,
        incorrectLetters,
        livesRemaining,
        wrongGuessCount,
        configuredHintCount,
        unlockedHintCount,
        remainingTime,
        elapsed,
        extraLifeActive,
        extraLifeUsed,
        lastGuess,
      ];
}

/// Pure game engine — no Flutter dependencies. Fully unit-testable.
class GameEngine {
  GameEngine({int maxLives = AppConstants.maxLives}) : _maxLives = maxLives;

  final int _maxLives;

  List<MaskCell> buildMask(String title) {
    final normalized = Movie.normalizeTitle(title);
    final cells = <MaskCell>[];
    final words = normalized.split(' ');

    for (var w = 0; w < words.length; w++) {
      final word = words[w];
      for (final rune in word.runes) {
        final ch = String.fromCharCode(rune);
        if (RegExp(r'[0-9]').hasMatch(ch)) {
          cells.add(MaskCell(
            raw: ch,
            display: ch,
            type: MaskCellType.digit,
            revealed: true,
            guessable: false,
          ));
        } else if (AppConstants.vowels.contains(ch)) {
          cells.add(MaskCell(
            raw: ch,
            display: ch,
            type: MaskCellType.letter,
            revealed: true,
            guessable: false,
          ));
        } else if (RegExp(r'[A-Z]').hasMatch(ch)) {
          cells.add(MaskCell(
            raw: ch,
            display: '_',
            type: MaskCellType.letter,
            revealed: false,
            guessable: true,
          ));
        } else {
          // Punctuation — auto-reveal
          cells.add(MaskCell(
            raw: ch,
            display: ch,
            type: MaskCellType.punctuation,
            revealed: true,
            guessable: false,
          ));
        }
      }
      if (w < words.length - 1) {
        cells.add(const MaskCell(
          raw: ' ',
          display: '/',
          type: MaskCellType.separator,
          revealed: true,
          guessable: false,
        ));
      }
    }
    return cells;
  }

  String formatMask(List<MaskCell> cells) {
    final buffer = StringBuffer();
    for (var i = 0; i < cells.length; i++) {
      final cell = cells[i];
      if (cell.type == MaskCellType.separator) {
        buffer.write('/');
      } else if (cell.revealed) {
        buffer.write(cell.display);
      } else {
        buffer.write('_');
      }
      if (i < cells.length - 1) {
        final next = cells[i + 1];
        if (cell.type != MaskCellType.separator &&
            next.type != MaskCellType.separator) {
          buffer.write(' ');
        } else if (cell.type == MaskCellType.separator ||
            next.type == MaskCellType.separator) {
          buffer.write(' ');
        }
      }
    }
    return buffer.toString().trim();
  }

  GameSession startSession({
    required Movie movie,
    required int hintCount,
    Duration? timerDuration,
  }) {
    final cells = buildMask(movie.title);
    var status = GameStatus.playing;
    if (_isFullyRevealed(cells)) {
      status = GameStatus.won;
    }

    return GameSession(
      movie: movie,
      cells: cells,
      status: status,
      guessedLetters: {},
      correctLetters: {},
      incorrectLetters: {},
      livesRemaining: _maxLives,
      wrongGuessCount: 0,
      configuredHintCount: hintCount.clamp(0, AppConstants.maxHints),
      unlockedHintCount: 0,
      remainingTime: timerDuration,
      elapsed: Duration.zero,
      extraLifeActive: false,
      extraLifeUsed: false,
      lastGuess: null,
    );
  }

  GameSession applyGuess(GameSession session, String rawLetter) {
    if (!session.status.allowsGuesses) {
      return session.copyWith(
        lastGuess: GuessResult(
          letter: rawLetter.toUpperCase(),
          ignored: true,
          correct: false,
          lifeLost: false,
          hintUnlocked: null,
          won: false,
          lost: false,
        ),
      );
    }

    final letter = rawLetter.toUpperCase();
    if (!RegExp(r'^[A-Z]$').hasMatch(letter)) {
      return session.copyWith(
        lastGuess: GuessResult(
          letter: letter,
          ignored: true,
          correct: false,
          lifeLost: false,
          hintUnlocked: null,
          won: false,
          lost: false,
        ),
      );
    }

    // Already guessed — ignore completely (no life, no animation trigger)
    if (session.guessedLetters.contains(letter)) {
      return session.copyWith(
        lastGuess: GuessResult(
          letter: letter,
          ignored: true,
          correct: false,
          lifeLost: false,
          hintUnlocked: null,
          won: false,
          lost: false,
        ),
      );
    }

    final guessed = {...session.guessedLetters, letter};
    final contains = session.cells.any(
      (c) => c.guessable && c.raw == letter,
    );

    if (contains) {
      final newCells = session.cells.map((c) {
        if (c.guessable && c.raw == letter) {
          return c.copyWith(revealed: true, display: letter);
        }
        return c;
      }).toList();

      final won = _isFullyRevealed(newCells);

      return session.copyWith(
        cells: newCells,
        guessedLetters: guessed,
        correctLetters: {...session.correctLetters, letter},
        status: won ? GameStatus.won : session.status,
        lastGuess: GuessResult(
          letter: letter,
          ignored: false,
          correct: true,
          lifeLost: false,
          hintUnlocked: null,
          won: won,
          lost: false,
        ),
      );
    }

    // Wrong guess
    var wrongCount = session.wrongGuessCount + 1;
    var lives = session.livesRemaining;
    var extraActive = session.extraLifeActive;
    var extraUsed = session.extraLifeUsed;
    int? hintUnlocked;
    var unlockedHints = session.unlockedHintCount;
    var status = session.status;
    var lost = false;

    if (extraActive) {
      // Consume special extra life — no hint trigger
      extraActive = false;
      lives = 0;
      lost = true;
      status = GameStatus.lost;
    } else {
      lives = (lives - 1).clamp(0, _maxLives);
      // Hint triggers on wrongGuessCount 6–9, limited by config
      final hintIndex = AppConstants.hintTriggerWrongCounts.indexOf(wrongCount);
      if (hintIndex >= 0) {
        final hintNumber = hintIndex + 1; // 1-based
        if (hintNumber <= session.configuredHintCount &&
            unlockedHints < hintNumber) {
          unlockedHints = hintNumber;
          hintUnlocked = hintNumber;
        }
      }

      if (lives <= 0 || wrongCount >= _maxLives) {
        lost = true;
        status = GameStatus.lost;
        lives = 0;
      }
    }

    // Reveal title on loss
    var cells = session.cells;
    if (lost) {
      cells = cells
          .map((c) => c.revealed
              ? c
              : c.copyWith(revealed: true, display: c.raw))
          .toList();
    }

    return session.copyWith(
      cells: cells,
      guessedLetters: guessed,
      incorrectLetters: {...session.incorrectLetters, letter},
      livesRemaining: lives,
      wrongGuessCount: wrongCount,
      unlockedHintCount: unlockedHints,
      extraLifeActive: extraActive,
      extraLifeUsed: extraUsed,
      status: status,
      lastGuess: GuessResult(
        letter: letter,
        ignored: false,
        correct: false,
        lifeLost: true,
        hintUnlocked: hintUnlocked,
        won: false,
        lost: lost,
      ),
    );
  }

  GameSession grantExtraLife(GameSession session) {
    if (session.extraLifeUsed) return session;
    if (session.status != GameStatus.lost &&
        session.status != GameStatus.watchingRewardedAd) {
      return session;
    }
    return session.copyWith(
      status: GameStatus.extraLifePlaying,
      extraLifeActive: true,
      extraLifeUsed: true,
      livesRemaining: 1,
      cells: _restoreMaskFromGuesses(session),
    );
  }

  List<MaskCell> _restoreMaskFromGuesses(GameSession session) {
    final base = buildMask(session.movie.title);
    return base.map((c) {
      if (!c.guessable) return c;
      if (session.correctLetters.contains(c.raw)) {
        return c.copyWith(revealed: true, display: c.raw);
      }
      return c;
    }).toList();
  }

  GameSession tick(GameSession session, Duration delta) {
    if (!session.status.timerShouldRun) return session;

    final elapsed = session.elapsed + delta;
    if (session.remainingTime == null) {
      return session.copyWith(elapsed: elapsed);
    }

    final left = session.remainingTime! - delta;
    if (left <= Duration.zero) {
      final revealed = session.cells
          .map((c) => c.revealed
              ? c
              : c.copyWith(revealed: true, display: c.raw))
          .toList();
      return session.copyWith(
        elapsed: elapsed,
        remainingTime: Duration.zero,
        cells: revealed,
        status: GameStatus.lost,
      );
    }
    return session.copyWith(elapsed: elapsed, remainingTime: left);
  }

  GameSession setStatus(GameSession session, GameStatus status) {
    return session.copyWith(status: status);
  }

  bool _isFullyRevealed(List<MaskCell> cells) {
    return cells.every((c) => !c.guessable || c.revealed);
  }
}
