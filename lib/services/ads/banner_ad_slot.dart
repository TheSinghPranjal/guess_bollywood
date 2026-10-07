import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';

/// Anchored adaptive banner. Debug and profile use Google sample units.
/// Release uses the production unit. Nothing is requested until UMP consent
/// allows ads, and a TODO placeholder is never swapped for a sample unit.
class BannerAdSlot extends ConsumerStatefulWidget {
  const BannerAdSlot({super.key});

  @override
  ConsumerState<BannerAdSlot> createState() => _BannerAdSlotState();
}

class _BannerAdSlotState extends ConsumerState<BannerAdSlot> {
  BannerAd? _banner;
  bool _loaded = false;
  bool _loadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final canRequest = ref.read(consentManagerProvider).canRequestAds;
    if (canRequest && !_loadStarted) {
      _loadStarted = true;
      _load();
    }
  }

  Future<void> _load() async {
    if (!AppConstants.adsSupported) return;
    final adUnitId = AppConstants.bannerAdUnitId;
    if (adUnitId == null) return;

    final width = MediaQuery.sizeOf(context).width.truncate();
    AdSize size = AdSize.banner;
    try {
      final adaptive =
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
      if (adaptive != null) size = adaptive;
    } catch (error) {
      debugPrint('Adaptive banner size failed: $error');
    }

    final banner = BannerAd(
      adUnitId: adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner failed to load: $error');
          ad.dispose();
          if (mounted) setState(() => _loaded = false);
        },
      ),
    );

    _banner = banner;
    await banner.load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canRequest = ref.watch(consentManagerProvider).canRequestAds;
    if (!canRequest || AppConstants.bannerAdUnitId == null) {
      return const SizedBox.shrink();
    }

    final height = _loaded && _banner != null
        ? _banner!.size.height.toDouble()
        : AppConstants.bannerAdHeight;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: _loaded && _banner != null
            ? AdWidget(ad: _banner!)
            : ColoredBox(
                color: AppColors.surface,
                child: Center(
                  child: Text(
                    AppConstants.adsSupported
                        ? 'Loading ad…'
                        : 'ADS UNAVAILABLE',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
