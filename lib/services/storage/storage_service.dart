import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/game_settings.dart';

class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  GameSettings loadSettings() {
    final raw = _prefs.getString(AppConstants.settingsKey);
    if (raw == null) return const GameSettings();
    try {
      return GameSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const GameSettings();
    }
  }

  Future<void> saveSettings(GameSettings settings) async {
    await _prefs.setString(
      AppConstants.settingsKey,
      jsonEncode(settings.toJson()),
    );
  }

  List<String> loadRecentMovieIds() {
    return _prefs.getStringList(AppConstants.recentMoviesKey) ?? [];
  }

  Future<void> pushRecentMovieId(String id) async {
    final list = loadRecentMovieIds();
    list.remove(id);
    list.insert(0, id);
    while (list.length > AppConstants.recentMoviesLimit) {
      list.removeLast();
    }
    await _prefs.setStringList(AppConstants.recentMoviesKey, list);
  }
}

class SeededRandomSource {
  SeededRandomSource([int? seed]) : _random = Random(seed);

  final Random _random;

  bool nextBool() => _random.nextBool();

  int nextInt(int max) => _random.nextInt(max);
}
