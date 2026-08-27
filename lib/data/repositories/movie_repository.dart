import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../models/movie.dart';

class MovieRepository {
  List<Movie>? _cache;

  Future<List<Movie>> loadMovies() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(AppConstants.moviesAssetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = (decoded['movies'] as List<dynamic>)
        .map((e) => Movie.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    _cache = list;
    return list;
  }

  List<Movie> filter(
    List<Movie> all, {
    required int startYear,
    required int endYear,
  }) {
    return all
        .where((m) => m.industry == MovieIndustry.bollywood)
        .where((m) => m.year >= startYear && m.year <= endYear)
        .where((m) => !RegExp(r'\d').hasMatch(m.title))
        .toList();
  }

  /// Random selection with recent-history avoidance.
  Movie? selectMovie({
    required List<Movie> pool,
    required List<String> recentIds,
    RandomSource? random,
  }) {
    random ??= DefaultRandomSource();
    if (pool.isEmpty) return null;
    if (pool.length == 1) return pool.first;

    var candidates = pool.where((m) => !recentIds.contains(m.id)).toList();
    if (candidates.isEmpty) candidates = List.of(pool);

    return candidates[random.nextInt(candidates.length)];
  }
}

/// Thin wrapper so tests can inject determinism.
abstract class RandomSource {
  const RandomSource();

  bool nextBool();
  int nextInt(int max);
}

class DefaultRandomSource implements RandomSource {
  DefaultRandomSource([int? seed]) : _random = Random(seed);

  final Random _random;

  @override
  bool nextBool() => _random.nextBool();

  @override
  int nextInt(int max) => max <= 0 ? 0 : _random.nextInt(max);
}
