import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'Bollywood Guess';
  static const String tagline = 'GUESS THE BLOCKBUSTER';

  static const int maxLives = 10;
  static const int maxHints = 4;
  static const int defaultHintCount = 4;
  static const int defaultTimerMinutes = 10;
  static const int minYear = 1990;

  static int get maxYear => DateTime.now().year;

  // Life display characters — spell "BOLLY-WOOD"
  static const List<String> lifeChars = [
    'B',
    'O',
    'L',
    'L',
    'Y',
    '-',
    'W',
    'O',
    'O',
    'D',
  ];

  /// Wrong-guess counts that unlock hints 1–4 (when configured).
  static const List<int> hintTriggerWrongCounts = [6, 7, 8, 9];

  // Consonants only (no vowels — vowels are always revealed)
  static const List<String> consonants = [
    'B',
    'C',
    'D',
    'F',
    'G',
    'H',
    'J',
    'K',
    'L',
    'M',
    'N',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];

  static const Set<String> vowels = {'A', 'E', 'I', 'O', 'U'};

  static const String moviesAssetPath = 'assets/data/movies.json';
  static const String settingsKey = 'game_settings_v1';
  static const String recentMoviesKey = 'recent_movies_v1';
  static const int recentMoviesLimit = 40;

  static const List<int> timerOptionsMinutes = [2, 5, 10, 15, 20, 30, 0];

  /// Show an interstitial only on every Nth Next Round tap.
  static const int interstitialEveryNRounds = 5;

  /// Use Google sample ad units in debug/profile. Release AABs use prod IDs.
  static bool get isAdTestMode => !kReleaseMode;

  static const double bannerAdHeight = 50;

  static const String androidAppId =
      'ca-app-pub-8661918790125012~8544493942';
  static const String iosAppId = 'ca-app-pub-3940256099942544~1458002511';

  static const String androidBannerId =
      'ca-app-pub-8661918790125012/2909023888';
  static const String androidRewardedId =
      'ca-app-pub-8661918790125012/1532740336';

  /// No production interstitial unit yet — release skips these ads.
  static const String? androidInterstitialId = null;

  static const String androidBannerTestId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String iosBannerTestId =
      'ca-app-pub-3940256099942544/2934735716';
  static const String androidRewardedTestId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String iosRewardedTestId =
      'ca-app-pub-3940256099942544/1712484513';
  static const String androidInterstitialTestId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String iosInterstitialTestId =
      'ca-app-pub-3940256099942544/4411468910';

  static bool get adsSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static String get bannerAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return iosBannerTestId;
    }
    return isAdTestMode ? androidBannerTestId : androidBannerId;
  }

  static String get rewardedAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return iosRewardedTestId;
    }
    return isAdTestMode ? androidRewardedTestId : androidRewardedId;
  }

  static String? get interstitialAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return isAdTestMode ? iosInterstitialTestId : null;
    }
    return isAdTestMode ? androidInterstitialTestId : androidInterstitialId;
  }
}
