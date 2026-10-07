import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/constants/app_constants.dart';

abstract class AdsService {
  Future<void> initialize();
  Future<bool> showRewardedAd();
  Future<bool> showInterstitial();
  bool get isInitialized;
}

/// Used in widget tests and on platforms where AdMob is unavailable.
class FakeAdsService implements AdsService {
  FakeAdsService({
    this.rewardedSucceeds = true,
    this.interstitialSucceeds = true,
  });

  bool rewardedSucceeds;
  bool interstitialSucceeds;
  bool _initialized = false;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    _initialized = true;
  }

  @override
  Future<bool> showRewardedAd() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return rewardedSucceeds;
  }

  @override
  Future<bool> showInterstitial() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return interstitialSucceeds;
  }
}

/// Real AdMob implementation.
///
/// Debug and profile use Google's sample units. Release uses production IDs
/// and never tags a test device. Call only after UMP consent allows ad requests.
class MobileAdsService implements AdsService {
  MobileAdsService({required this.isTestMode});

  final bool isTestMode;
  bool _initialized = false;
  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  Completer<RewardedAd?>? _rewardedLoad;
  Completer<InterstitialAd?>? _interstitialLoad;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    if (!AppConstants.adsSupported) {
      _initialized = false;
      return;
    }
    try {
      AppConstants.guardReleaseAdUnits();
      await MobileAds.instance.initialize();
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          // 'EMULATOR' is a debug convenience only. Release and profile send
          // an empty list so a store build cannot be marked as a test device.
          testDeviceIds: kDebugMode ? const ['EMULATOR'] : const <String>[],
        ),
      );
      _initialized = true;
      debugPrint(
        'AdMob ${isTestMode ? 'test' : 'release'} units '
        'banner=${AppConstants.bannerAdUnitId} '
        'interstitial=${AppConstants.interstitialAdUnitId} '
        'rewarded=${AppConstants.rewardedAdUnitId}',
      );
      unawaited(_loadRewarded());
      unawaited(_loadInterstitial());
    } catch (error, stack) {
      debugPrint('AdMob initialize failed: $error\n$stack');
      _initialized = false;
      if (error is StateError) rethrow;
    }
  }

  AdRequest get _request => const AdRequest();

  Future<RewardedAd?> _loadRewarded() {
    final adUnitId = AppConstants.rewardedAdUnitId;
    if (adUnitId == null) return Future.value(null);
    if (_rewardedAd != null) return Future.value(_rewardedAd);
    if (_rewardedLoad != null) return _rewardedLoad!.future;

    final completer = Completer<RewardedAd?>();
    _rewardedLoad = completer;

    RewardedAd.load(
      adUnitId: adUnitId,
      request: _request,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedLoad = null;
          if (!completer.isCompleted) completer.complete(ad);
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded failed to load: $error');
          _rewardedAd = null;
          _rewardedLoad = null;
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );

    return completer.future.timeout(
      const Duration(seconds: 20),
      onTimeout: () {
        _rewardedLoad = null;
        return null;
      },
    );
  }

  Future<InterstitialAd?> _loadInterstitial() {
    final adUnitId = AppConstants.interstitialAdUnitId;
    if (adUnitId == null) return Future.value(null);
    if (_interstitialAd != null) return Future.value(_interstitialAd);
    if (_interstitialLoad != null) return _interstitialLoad!.future;

    final completer = Completer<InterstitialAd?>();
    _interstitialLoad = completer;

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: _request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoad = null;
          if (!completer.isCompleted) completer.complete(ad);
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed to load: $error');
          _interstitialAd = null;
          _interstitialLoad = null;
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );

    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        _interstitialLoad = null;
        return null;
      },
    );
  }

  @override
  Future<bool> showRewardedAd() async {
    if (!_initialized) return false;
    var ad = _rewardedAd ?? await _loadRewarded();
    ad ??= await _loadRewarded();
    if (ad == null) return false;
    _rewardedAd = null;

    final completer = Completer<bool>();
    var earned = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('Rewarded ad shown');
      },
      onAdDismissedFullScreenContent: (ad) async {
        ad.dispose();
        // iOS often fires dismiss before onUserEarnedReward.
        await Future<void>.delayed(const Duration(milliseconds: 400));
        if (!completer.isCompleted) completer.complete(earned);
        unawaited(_loadRewarded());
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Rewarded failed to show: $error');
        ad.dispose();
        if (!completer.isCompleted) completer.complete(false);
        unawaited(_loadRewarded());
      },
    );

    try {
      await ad.show(
        onUserEarnedReward: (ad, reward) {
          earned = true;
          if (!completer.isCompleted) completer.complete(true);
        },
      );
    } catch (error) {
      debugPrint('Rewarded show threw: $error');
      ad.dispose();
      if (!completer.isCompleted) completer.complete(false);
      unawaited(_loadRewarded());
      return false;
    }

    return completer.future;
  }

  @override
  Future<bool> showInterstitial() async {
    if (!_initialized) return false;
    var ad = _interstitialAd ?? await _loadInterstitial();
    if (ad == null) return false;
    _interstitialAd = null;

    final completer = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!completer.isCompleted) completer.complete(true);
        unawaited(_loadInterstitial());
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Interstitial failed to show: $error');
        ad.dispose();
        if (!completer.isCompleted) completer.complete(false);
        unawaited(_loadInterstitial());
      },
    );
    try {
      await ad.show();
    } catch (error) {
      debugPrint('Interstitial show threw: $error');
      ad.dispose();
      if (!completer.isCompleted) completer.complete(false);
      unawaited(_loadInterstitial());
      return false;
    }
    return completer.future;
  }
}
