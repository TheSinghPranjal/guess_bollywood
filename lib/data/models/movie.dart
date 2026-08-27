import 'package:equatable/equatable.dart';

enum MovieIndustry { bollywood }

extension MovieIndustryX on MovieIndustry {
  String get label => 'Bollywood';

  String get lifeHeader => 'BOLLY-WOOD';

  String get jsonValue => name;

  static MovieIndustry fromJson(String value) {
    return MovieIndustry.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => MovieIndustry.bollywood,
    );
  }
}

enum MovieDifficulty { easy, medium, hard }

class Movie extends Equatable {
  const Movie({
    required this.id,
    required this.title,
    required this.industry,
    required this.year,
    required this.cast,
    required this.about,
    required this.hints,
    required this.era,
    this.difficulty = MovieDifficulty.medium,
  });

  final String id;
  final String title;
  final MovieIndustry industry;
  final int year;
  final List<String> cast;
  final String about;
  final List<String> hints;
  final String era;
  final MovieDifficulty difficulty;

  String get normalizedTitle => normalizeTitle(title);

  static String normalizeTitle(String raw) {
    final upper = raw.toUpperCase().trim();
    final buffer = StringBuffer();
    for (final rune in upper.runes) {
      final ch = String.fromCharCode(rune);
      if (RegExp(r"[A-Z0-9\s'\-:,.&!]").hasMatch(ch)) {
        buffer.write(ch);
      } else {
        final mapped = _accentMap[ch];
        if (mapped != null) buffer.write(mapped);
      }
    }
    return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static const Map<String, String> _accentMap = {
    'Á': 'A',
    'À': 'A',
    'Ä': 'A',
    'Â': 'A',
    'Ã': 'A',
    'É': 'E',
    'È': 'E',
    'Ê': 'E',
    'Ë': 'E',
    'Í': 'I',
    'Ì': 'I',
    'Î': 'I',
    'Ï': 'I',
    'Ó': 'O',
    'Ò': 'O',
    'Ô': 'O',
    'Ö': 'O',
    'Õ': 'O',
    'Ú': 'U',
    'Ù': 'U',
    'Û': 'U',
    'Ü': 'U',
    'Ñ': 'N',
    'Ç': 'C',
  };

  factory Movie.fromJson(Map<String, dynamic> json) {
    final hintsRaw = json['hints'];
    final List<String> hints;
    if (hintsRaw is List) {
      hints = hintsRaw.map((e) => e.toString()).toList();
    } else {
      hints = [
        json['hint1']?.toString() ?? '',
        json['hint2']?.toString() ?? '',
        json['hint3']?.toString() ?? '',
        json['hint4']?.toString() ?? '',
      ];
    }

    return Movie(
      id: json['id'] as String,
      title: json['title'] as String,
      industry: MovieIndustryX.fromJson(json['industry'] as String),
      year: json['year'] as int,
      cast: (json['cast'] as List<dynamic>).map((e) => e.toString()).toList(),
      about: json['about'] as String,
      hints: hints,
      era: json['era'] as String? ?? eraForYear(json['year'] as int),
      difficulty: _difficultyFromJson(json['difficulty'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'normalizedTitle': normalizedTitle,
        'industry': industry.jsonValue,
        'year': year,
        'cast': cast,
        'about': about,
        'hints': hints,
        'era': era,
        'difficulty': difficulty.name,
      };

  static String eraForYear(int year) {
    if (year < 2000) return '1990-1999';
    if (year < 2010) return '2000-2009';
    if (year < 2020) return '2010-2019';
    return '2020-2026';
  }

  static MovieDifficulty _difficultyFromJson(String? value) {
    if (value == null) return MovieDifficulty.medium;
    return MovieDifficulty.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MovieDifficulty.medium,
    );
  }

  static MovieDifficulty computeDifficulty(String title) {
    final normalized = normalizeTitle(title);
    final letters = normalized.replaceAll(RegExp(r'[^A-Z]'), '');
    final consonants = letters
        .split('')
        .where((c) => !{'A', 'E', 'I', 'O', 'U'}.contains(c))
        .toList();
    final unique = consonants.toSet().length;
    final words = normalized.split(' ').where((w) => w.isNotEmpty).length;

    if (consonants.length <= 4 && unique <= 3) return MovieDifficulty.easy;
    if (consonants.length >= 10 || words >= 4 || unique >= 8) {
      return MovieDifficulty.hard;
    }
    return MovieDifficulty.medium;
  }

  @override
  List<Object?> get props => [id, title, industry, year];
}
