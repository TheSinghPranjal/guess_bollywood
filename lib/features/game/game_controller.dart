import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers.dart';
import '../../data/models/game_settings.dart';
import '../../data/models/game_status.dart';
import '../../data/repositories/movie_repository.dart';
import 'engine/game_engine.dart';

class GameControllerState {
  const GameControllerState({
    this.session,
    this.errorMessage,
    this.countdown,
    this.hintJustUnlocked = false,
    this.adErrorMessage,
    this.roundsPlayed = 0,
  });

  final GameSession? session;
  final String? errorMessage;
  final int? countdown; // 3,2,1 or null when playing
  final bool hintJustUnlocked;
  final String? adErrorMessage;
  final int roundsPlayed;

  GameControllerState copyWith({
    GameSession? session,
    String? errorMessage,
    bool clearError = false,
    int? countdown,
    bool clearCountdown = false,
    bool? hintJustUnlocked,
    String? adErrorMessage,
    bool clearAdError = false,
    int? roundsPlayed,
  }) {
    return GameControllerState(
      session: session ?? this.session,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      countdown: clearCountdown ? null : countdown ?? this.countdown,
      hintJustUnlocked: hintJustUnlocked ?? this.hintJustUnlocked,
      adErrorMessage:
          clearAdError ? null : adErrorMessage ?? this.adErrorMessage,
      roundsPlayed: roundsPlayed ?? this.roundsPlayed,
    );
  }
}

final gameControllerProvider =
    StateNotifierProvider<GameController, GameControllerState>((ref) {
  return GameController(ref);
});

class GameController extends StateNotifier<GameControllerState>
    with WidgetsBindingObserver {
  GameController(this._ref) : super(const GameControllerState()) {
    WidgetsBinding.instance.addObserver(this);
  }

  final Ref _ref;
  Timer? _ticker;
  Timer? _countdownTimer;
  bool _skipNextInterstitial = false;

  GameEngine get _engine => _ref.read(gameEngineProvider);
  MovieRepository get _movies => _ref.read(movieRepositoryProvider);
  GameSettings get _settings => _ref.read(settingsProvider);

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      final session = this.state.session;
      if (session != null && session.status.timerShouldRun) {
        pause();
      }
    }
  }

  Future<void> startNewRound({bool fromNextRound = false}) async {
    _ticker?.cancel();
    _countdownTimer?.cancel();

    final shouldShowInterstitial = fromNextRound &&
        !_skipNextInterstitial &&
        state.roundsPlayed > 0 &&
        state.roundsPlayed % AppConstants.interstitialEveryNRounds == 0;
    if (shouldShowInterstitial) {
      final ads = _ref.read(adsServiceProvider);
      state = state.copyWith(
        session: state.session?.copyWith(status: GameStatus.adLoading),
      );
      await ads.showInterstitial();
    }
    _skipNextInterstitial = false;

    final all = await _movies.loadMovies();
    final settings = _settings;
    final pool = _movies.filter(
      all,
      startYear: settings.startYear,
      endYear: settings.resolvedEndYear,
    );

    if (pool.isEmpty) {
      state = state.copyWith(
        session: null,
        errorMessage:
            'No movies available for this selection.\nTry expanding the year range.',
        clearCountdown: true,
      );
      return;
    }

    final storage = _ref.read(storageServiceProvider);
    final recent = storage.loadRecentMovieIds();
    final movie = _movies.selectMovie(
      pool: pool,
      recentIds: recent,
      random: DefaultRandomSource(),
    );

    if (movie == null) {
      state = state.copyWith(
        errorMessage: 'No movies available for this selection.',
        clearCountdown: true,
      );
      return;
    }

    await storage.pushRecentMovieId(movie.id);

    final started = _engine.startSession(
      movie: movie,
      hintCount: settings.hintCount,
      timerDuration: settings.timerDuration,
    );

    // Auto-win if title has no guessable consonants.
    if (started.status == GameStatus.won) {
      state = state.copyWith(
        session: started,
        clearError: true,
        clearAdError: true,
        clearCountdown: true,
        hintJustUnlocked: false,
      );
      return;
    }

    final session = started.copyWith(status: GameStatus.starting);

    state = state.copyWith(
      session: session,
      clearError: true,
      clearAdError: true,
      countdown: 3,
      hintJustUnlocked: false,
    );

    _runCountdown();
  }

  void _runCountdown() {
    _countdownTimer?.cancel();
    var value = state.countdown ?? 3;
    _countdownTimer = Timer.periodic(const Duration(milliseconds: 700), (t) {
      value -= 1;
      if (value > 0) {
        state = state.copyWith(countdown: value);
      } else {
        t.cancel();
        final session = state.session;
        if (session == null) return;
        final playing = _engine.setStatus(session, GameStatus.playing);
        state = state.copyWith(session: playing, clearCountdown: true);
        _startTicker();
      }
    });
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final session = state.session;
      if (session == null || !session.status.timerShouldRun) return;
      final next = _engine.tick(session, const Duration(seconds: 1));
      state = state.copyWith(session: next);
      if (next.status == GameStatus.lost) {
        _ticker?.cancel();
        _onLose();
      }
    });
  }

  Future<void> guess(String letter) async {
    final session = state.session;
    if (session == null || !session.status.allowsGuesses) return;

    final next = _engine.applyGuess(session, letter);
    final result = next.lastGuess;
    final feedback = _ref.read(feedbackServiceProvider);
    final settings = _settings;

    if (result == null || result.ignored) {
      state = state.copyWith(session: next);
      return;
    }

    if (result.correct) {
      await feedback.correct(
        sound: settings.soundEnabled,
        haptics: settings.hapticsEnabled,
      );
    } else if (result.lifeLost) {
      await feedback.wrong(
        sound: settings.soundEnabled,
        haptics: settings.hapticsEnabled,
      );
    }

    var hintFlash = false;
    if (result.hintUnlocked != null) {
      hintFlash = true;
      await feedback.hint(
        sound: settings.soundEnabled,
        haptics: settings.hapticsEnabled,
      );
    }

    state = state.copyWith(session: next, hintJustUnlocked: hintFlash);

    if (next.status == GameStatus.won) {
      _ticker?.cancel();
      await feedback.win(
        sound: settings.soundEnabled,
        haptics: settings.hapticsEnabled,
      );
    } else if (next.status == GameStatus.lost) {
      _ticker?.cancel();
      await _onLose();
    }
  }

  Future<void> _onLose() async {
    final settings = _settings;
    await _ref.read(feedbackServiceProvider).lose(
          sound: settings.soundEnabled,
          haptics: settings.hapticsEnabled,
        );
  }

  void pause() {
    final session = state.session;
    if (session == null) return;
    if (!session.status.allowsGuesses && session.status != GameStatus.hintOpen) {
      return;
    }
    _ticker?.cancel();
    state = state.copyWith(
      session: _engine.setStatus(session, GameStatus.paused),
    );
  }

  void resume() {
    final session = state.session;
    if (session == null || session.status != GameStatus.paused) return;
    final status = session.extraLifeActive
        ? GameStatus.extraLifePlaying
        : GameStatus.playing;
    state = state.copyWith(session: _engine.setStatus(session, status));
    _startTicker();
  }

  void openHint() {
    final session = state.session;
    if (session == null || session.unlockedHintCount <= 0) return;
    if (!session.status.allowsGuesses && session.status != GameStatus.playing) {
      if (session.status != GameStatus.extraLifePlaying) return;
    }
    _ticker?.cancel();
    state = state.copyWith(
      session: _engine.setStatus(session, GameStatus.hintOpen),
      hintJustUnlocked: false,
    );
  }

  void closeHint() {
    final session = state.session;
    if (session == null || session.status != GameStatus.hintOpen) return;
    final status = session.extraLifeActive
        ? GameStatus.extraLifePlaying
        : GameStatus.playing;
    state = state.copyWith(session: _engine.setStatus(session, status));
    _startTicker();
  }

  Future<void> watchRewardedAd() async {
    final session = state.session;
    if (session == null || !session.canOfferRewardedLife) return;

    state = state.copyWith(
      session: _engine.setStatus(session, GameStatus.watchingRewardedAd),
      clearAdError: true,
    );

    // Let the Game Over dialog finish closing so the native ad can present.
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final ok = await _ref.read(adsServiceProvider).showRewardedAd();
    final latest = state.session ?? session;
    if (!ok) {
      state = state.copyWith(
        session: _engine.setStatus(latest, GameStatus.lost),
        adErrorMessage: 'The reward could not be granted.',
      );
      return;
    }

    final restored = _engine.grantExtraLife(
      latest.copyWith(status: GameStatus.lost),
    );
    state = state.copyWith(session: restored, clearAdError: true);
    _skipNextInterstitial = true;
    _startTicker();
  }

  void clearAdError() {
    state = state.copyWith(clearAdError: true);
  }

  Future<void> nextRound() async {
    state = state.copyWith(roundsPlayed: state.roundsPlayed + 1);
    await startNewRound(fromNextRound: true);
  }

  void clearSession() {
    _ticker?.cancel();
    _countdownTimer?.cancel();
    state = const GameControllerState();
  }
}
