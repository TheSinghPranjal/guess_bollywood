/// Decides when a full-screen interstitial may run.
///
/// Interstitials are only eligible between rounds. Gameplay, the countdown,
/// pause, and hints are rejected by [duringGameplay].
class InterstitialPolicy {
  const InterstitialPolicy._();

  static bool shouldShow({
    required int roundsSinceLast,
    required int everyNRounds,
    required DateTime? lastShownAt,
    required DateTime now,
    required Duration minInterval,
    required bool duringGameplay,
  }) {
    if (duringGameplay) return false;
    if (everyNRounds <= 0) return false;
    if (roundsSinceLast < everyNRounds) return false;
    final shownAt = lastShownAt;
    if (shownAt != null && now.difference(shownAt) < minInterval) {
      return false;
    }
    return true;
  }
}
