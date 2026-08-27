import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

/// Anchored adaptive banner. Uses Google sample units in debug/profile and
/// the production AdMob unit in release. Reserved height avoids layout jump.
class BannerAdSlot extends StatefulWidget {
  const BannerAdSlot({super.key});

  @override
  State<BannerAdSlot> createState() => _BannerAdSlotState();
}

class _BannerAdSlotState extends State<BannerAdSlot> {
  BannerAd? _banner;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_banner == null) {
      _load();
    }
  }

  Future<void> _load() async {
    if (!AppConstants.adsSupported) return;

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
      adUnitId: AppConstants.bannerAdUnitId,
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
                    AppConstants.adsSupported ? 'Loading ad…' : 'ADS UNAVAILABLE',
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
