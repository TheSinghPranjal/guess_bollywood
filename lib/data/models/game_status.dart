enum GameStatus {
  idle,
  starting,
  playing,
  paused,
  hintOpen,
  adLoading,
  watchingRewardedAd,
  extraLifePlaying,
  won,
  lost,
  result,
  noMovies,
}

extension GameStatusX on GameStatus {
  bool get allowsGuesses =>
      this == GameStatus.playing || this == GameStatus.extraLifePlaying;

  bool get isTerminal =>
      this == GameStatus.won ||
      this == GameStatus.lost ||
      this == GameStatus.result;

  bool get timerShouldRun =>
      this == GameStatus.playing || this == GameStatus.extraLifePlaying;
}
