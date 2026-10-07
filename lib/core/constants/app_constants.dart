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

  /// Offer an interstitial on the transition into the next round after this
  /// many finished rounds (kept inside a 3–5 round cap).
  static const int interstitialEveryNRounds = 4;

  /// Extra cap so a fast run of rounds cannot show interstitials back to back.
  static const Duration interstitialMinInterval = Duration(seconds: 90);

  /// Sample unit IDs in debug and profile. Release uses the production IDs.
  static bool get isAdTestMode => !kReleaseMode;

  static const double bannerAdHeight = 50;

  /// Google's public sample publisher. Legal in debug/profile test units only.
  static const String googleSamplePublisherId = '3940256099942544';

  static const String androidAppId = 'ca-app-pub-8661918790125012~8544493942';
  static const String androidBannerId =
      'ca-app-pub-8661918790125012/2909023888';
  static const String androidRewardedId =
      'ca-app-pub-8661918790125012/1532740336';

  static const String androidInterstitialId =
      'ca-app-pub-8661918790125012/5959696196';

  /// TODO(admob): create the iOS app in AdMob and paste its App ID here.
  /// Must stay identical to GAD_APPLICATION_ID in ios/Flutter/Release.xcconfig.
  /// The value is a well-formed placeholder so iOS does not abort at launch;
  /// it is not a Google sample App ID. Replace it before shipping iOS.
  static const String iosAppId = 'ca-app-pub-8661918790125012~1000000002';

  /// TODO(admob): create an iOS banner unit and paste it here.
  static const String iosBannerId =
      'ca-app-pub-8661918790125012/TODO_IOS_BANNER';

  /// TODO(admob): create an iOS interstitial unit and paste it here.
  static const String iosInterstitialId =
      'ca-app-pub-8661918790125012/TODO_IOS_INTERSTITIAL';

  /// TODO(admob): create an iOS rewarded unit and paste it here.
  static const String iosRewardedId =
      'ca-app-pub-8661918790125012/TODO_IOS_REWARDED';

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

  /// Sample App ID used only by the iOS debug build configuration.
  static const String iosSampleAppId = 'ca-app-pub-3940256099942544~1458002511';

  static const List<String> productionAdIds = [
    androidAppId,
    androidBannerId,
    androidRewardedId,
    androidInterstitialId,
    iosAppId,
    iosBannerId,
    iosInterstitialId,
    iosRewardedId,
  ];

  static final Set<String> _placeholderWarnings = <String>{};

  static bool get adsSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static bool isGoogleSampleAdId(String id) =>
      id.contains(googleSamplePublisherId);

  /// True for IDs that still have to be created in the AdMob console.
  static bool isPlaceholderAdId(String id) =>
      id.contains('TODO') || id.endsWith('~1000000002');

  /// Release builds request [productionId]. Debug and profile request [testId].
  /// A production ID that is still a Google sample unit is refused.
  /// A TODO placeholder is not requested, so release never falls back to samples.
  static String? resolveAdUnit({
    required bool useTestAds,
    required String productionId,
    required String testId,
  }) {
    if (useTestAds) return testId;
    if (isGoogleSampleAdId(productionId)) {
      debugPrint(
        'AdMob: refusing Google sample ad unit in release: $productionId',
      );
      throw StateError(
        'Release builds must not use Google sample ad IDs ($productionId).',
      );
    }
    if (isPlaceholderAdId(productionId)) {
      warnPlaceholderAdId(productionId);
      return null;
    }
    return productionId;
  }

  static void warnPlaceholderAdId(String id) {
    if (!_placeholderWarnings.add(id)) return;
    debugPrint(
      'AdMob TODO: $id is still a placeholder. Create the unit in AdMob and '
      'paste the ID. This build will not request a Google sample unit.',
    );
  }

  /// Fails the process if a release build is configured with sample ad IDs.
  /// Asserts in debug/profile as well, because those asserts run during
  /// `flutter test` and `flutter run`. Release strips asserts, so the
  /// [StateError] is what actually stops a store build.
  static void guardReleaseAdUnits() {
    final sampleIds = productionAdIds
        .where(isGoogleSampleAdId)
        .toList(growable: false);
    assert(
      sampleIds.isEmpty,
      'Production ad IDs must not use Google sample publisher '
      '$googleSamplePublisherId. Sample units belong only in the *TestId '
      'constants. Found: $sampleIds',
    );
    if (!kReleaseMode) return;
    if (sampleIds.isNotEmpty) {
      final message =
          'Release builds must not use Google sample ad IDs: ${sampleIds.join(', ')}';
      debugPrint('AdMob: $message');
      throw StateError(message);
    }
    for (final id in productionAdIds.where(isPlaceholderAdId)) {
      warnPlaceholderAdId(id);
    }
  }

  static String? get bannerAdUnitId {
    final ios = defaultTargetPlatform == TargetPlatform.iOS;
    return resolveAdUnit(
      useTestAds: isAdTestMode,
      productionId: ios ? iosBannerId : androidBannerId,
      testId: ios ? iosBannerTestId : androidBannerTestId,
    );
  }

  static String? get rewardedAdUnitId {
    final ios = defaultTargetPlatform == TargetPlatform.iOS;
    return resolveAdUnit(
      useTestAds: isAdTestMode,
      productionId: ios ? iosRewardedId : androidRewardedId,
      testId: ios ? iosRewardedTestId : androidRewardedTestId,
    );
  }

  static String? get interstitialAdUnitId {
    final ios = defaultTargetPlatform == TargetPlatform.iOS;
    return resolveAdUnit(
      useTestAds: isAdTestMode,
      productionId: ios ? iosInterstitialId : androidInterstitialId,
      testId: ios ? iosInterstitialTestId : androidInterstitialTestId,
    );
  }
}
