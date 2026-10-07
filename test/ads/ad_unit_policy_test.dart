import 'dart:io';

import 'package:bollywood_guess/core/constants/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production constants are not Google sample ids', () {
    for (final id in AppConstants.productionAdIds) {
      expect(AppConstants.isGoogleSampleAdId(id), isFalse, reason: id);
    }
    AppConstants.guardReleaseAdUnits();
  });

  test('debug and profile getters stay on sample units', () {
    expect(AppConstants.isAdTestMode, isTrue);
    expect(
      AppConstants.isGoogleSampleAdId(AppConstants.bannerAdUnitId!),
      isTrue,
    );
    expect(
      AppConstants.isGoogleSampleAdId(AppConstants.rewardedAdUnitId!),
      isTrue,
    );
    expect(
      AppConstants.isGoogleSampleAdId(AppConstants.interstitialAdUnitId!),
      isTrue,
    );
  });

  test('release resolver uses real Android banner and rewarded units', () {
    expect(
      AppConstants.resolveAdUnit(
        useTestAds: false,
        productionId: AppConstants.androidBannerId,
        testId: AppConstants.androidBannerTestId,
      ),
      'ca-app-pub-8661918790125012/2909023888',
    );
    expect(
      AppConstants.resolveAdUnit(
        useTestAds: false,
        productionId: AppConstants.androidRewardedId,
        testId: AppConstants.androidRewardedTestId,
      ),
      'ca-app-pub-8661918790125012/1532740336',
    );
    expect(AppConstants.androidAppId, 'ca-app-pub-8661918790125012~8544493942');
    expect(
      AppConstants.isPlaceholderAdId(AppConstants.androidBannerId),
      isFalse,
    );
    expect(
      AppConstants.isPlaceholderAdId(AppConstants.androidRewardedId),
      isFalse,
    );
  });

  test('release resolver does not request TODO placeholders or sample ids', () {
    expect(
      AppConstants.androidInterstitialId,
      contains('TODO_ANDROID_INTERSTITIAL'),
    );
    expect(
      AppConstants.resolveAdUnit(
        useTestAds: false,
        productionId: AppConstants.androidInterstitialId,
        testId: AppConstants.androidInterstitialTestId,
      ),
      isNull,
    );

    for (final id in [
      AppConstants.iosBannerId,
      AppConstants.iosInterstitialId,
      AppConstants.iosRewardedId,
    ]) {
      expect(id, contains('TODO'));
      expect(AppConstants.isPlaceholderAdId(id), isTrue);
      expect(
        AppConstants.resolveAdUnit(
          useTestAds: false,
          productionId: id,
          testId: AppConstants.iosBannerTestId,
        ),
        isNull,
      );
    }

    expect(AppConstants.isPlaceholderAdId(AppConstants.iosAppId), isTrue);
    expect(AppConstants.isGoogleSampleAdId(AppConstants.iosAppId), isFalse);
  });

  test('pasting a sample unit into a production slot is refused', () {
    expect(
      () => AppConstants.resolveAdUnit(
        useTestAds: false,
        productionId: AppConstants.iosBannerTestId,
        testId: AppConstants.iosBannerTestId,
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('3940256099942544'),
        ),
      ),
    );
  });

  test('native configs do not ship a sample app id in release', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    final release = File('ios/Flutter/Release.xcconfig').readAsStringSync();
    final debug = File('ios/Flutter/Debug.xcconfig').readAsStringSync();
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(plist, contains('\$(GAD_APPLICATION_ID)'));
    expect(plist, contains('GADDelayAppMeasurementInit'));
    expect(plist, contains('NSUserTrackingUsageDescription'));
    expect(plist, isNot(contains(AppConstants.googleSamplePublisherId)));

    expect(release, contains('GAD_APPLICATION_ID=${AppConstants.iosAppId}'));
    expect(release, isNot(contains(AppConstants.googleSamplePublisherId)));
    expect(release, contains('TODO(admob)'));

    expect(
      debug,
      contains('GAD_APPLICATION_ID=${AppConstants.iosSampleAppId}'),
    );

    expect(manifest, contains(AppConstants.androidAppId));
    expect(manifest, contains('DELAY_APP_MEASUREMENT_INIT'));
    expect(manifest, isNot(contains(AppConstants.googleSamplePublisherId)));
    expect(
      File('pubspec.yaml').readAsStringSync(),
      contains('version: 1.1.0+4'),
    );
  });
}
