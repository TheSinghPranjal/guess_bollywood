import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../data/models/game_settings.dart';
import '../data/repositories/movie_repository.dart';
import '../features/game/engine/game_engine.dart';
import '../services/ads/ads_service.dart';
import '../services/audio/feedback_service.dart';
import '../services/storage/storage_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(ref.watch(sharedPreferencesProvider));
});

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return MovieRepository();
});

final gameEngineProvider = Provider<GameEngine>((ref) {
  return GameEngine();
});

final adsServiceProvider = Provider<AdsService>((ref) {
  if (AppConstants.adsSupported) {
    return MobileAdsService(isTestMode: AppConstants.isAdTestMode);
  }
  return FakeAdsService();
});

final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  return const FeedbackService();
});

final moviesProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(movieRepositoryProvider).loadMovies();
});

final settingsProvider =
    StateNotifierProvider<SettingsController, GameSettings>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SettingsController(storage);
});

class SettingsController extends StateNotifier<GameSettings> {
  SettingsController(this._storage) : super(_storage.loadSettings());

  final StorageService _storage;

  Future<void> update(GameSettings Function(GameSettings) fn) async {
    state = fn(state);
    await _storage.saveSettings(state);
  }

  Future<void> setTimerMinutes(int minutes) =>
      update((s) => s.copyWith(timerMinutes: minutes));

  Future<void> setYearRange(int start, int end) => update(
        (s) => s.copyWith(
          startYear: start.clamp(AppConstants.minYear, AppConstants.maxYear),
          endYear: end.clamp(AppConstants.minYear, AppConstants.maxYear),
        ),
      );

  Future<void> setHintCount(int count) =>
      update((s) => s.copyWith(hintCount: count.clamp(0, AppConstants.maxHints)));

  Future<void> setSound(bool enabled) =>
      update((s) => s.copyWith(soundEnabled: enabled));

  Future<void> setHaptics(bool enabled) =>
      update((s) => s.copyWith(hapticsEnabled: enabled));
}
