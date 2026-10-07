import 'package:bollywood_guess/services/ads/interstitial_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 7, 12);

  bool show({
    int roundsSinceLast = 4,
    bool duringGameplay = false,
    DateTime? lastShownAt,
    int everyNRounds = 4,
  }) {
    return InterstitialPolicy.shouldShow(
      roundsSinceLast: roundsSinceLast,
      everyNRounds: everyNRounds,
      lastShownAt: lastShownAt,
      now: now,
      minInterval: const Duration(seconds: 90),
      duringGameplay: duringGameplay,
    );
  }

  test('waits until four finished rounds', () {
    expect(show(roundsSinceLast: 0), isFalse);
    expect(show(roundsSinceLast: 3), isFalse);
    expect(show(roundsSinceLast: 4), isTrue);
    expect(show(roundsSinceLast: 5), isTrue);
  });

  test('does not show during gameplay', () {
    expect(show(duringGameplay: true), isFalse);
    expect(show(roundsSinceLast: 8, duringGameplay: true), isFalse);
  });

  test('frequency cap blocks a second interstitial inside 90 seconds', () {
    expect(
      show(lastShownAt: now.subtract(const Duration(seconds: 89))),
      isFalse,
    );
    expect(
      show(lastShownAt: now.subtract(const Duration(seconds: 90))),
      isTrue,
    );
  });
}
