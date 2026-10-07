import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/providers.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'services/ads/ads_service.dart';
import 'services/ads/consent_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  AppConstants.guardReleaseAdUnits();

  final prefs = await SharedPreferences.getInstance();
  final consent = ConsentManager();
  if (AppConstants.adsSupported) {
    await consent.gatherConsent();
  }

  final ads = AppConstants.adsSupported
      ? MobileAdsService(isTestMode: AppConstants.isAdTestMode)
      : FakeAdsService();
  final requestAds = !AppConstants.adsSupported || consent.canRequestAds;
  if (requestAds) {
    await ads.initialize();
  } else {
    debugPrint('AdMob: skipping ad requests until consent allows them.');
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        adsServiceProvider.overrideWithValue(ads),
        consentManagerProvider.overrideWithValue(consent),
      ],
      child: const BollywoodGuessApp(),
    ),
  );
}

class BollywoodGuessApp extends StatelessWidget {
  const BollywoodGuessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bollywood Guess',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const SplashScreen(),
    );
  }
}
