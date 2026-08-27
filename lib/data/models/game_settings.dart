import 'package:equatable/equatable.dart';

import '../../core/constants/app_constants.dart';

enum IndustryFilter { bollywood }

extension IndustryFilterX on IndustryFilter {
  String get label => 'Bollywood';
}

class GameSettings extends Equatable {
  const GameSettings({
    this.timerMinutes = AppConstants.defaultTimerMinutes,
    this.startYear = AppConstants.minYear,
    this.endYear,
    this.hintCount = AppConstants.defaultHintCount,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
  });

  final int timerMinutes; // 0 = unlimited
  final int startYear;
  final int? endYear;
  final int hintCount;
  final bool soundEnabled;
  final bool hapticsEnabled;

  int get resolvedEndYear => endYear ?? AppConstants.maxYear;

  Duration? get timerDuration {
    if (timerMinutes <= 0) return null;
    return Duration(minutes: timerMinutes);
  }

  GameSettings copyWith({
    int? timerMinutes,
    int? startYear,
    int? endYear,
    int? hintCount,
    bool? soundEnabled,
    bool? hapticsEnabled,
  }) {
    return GameSettings(
      timerMinutes: timerMinutes ?? this.timerMinutes,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
      hintCount: hintCount ?? this.hintCount,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'timerMinutes': timerMinutes,
        'startYear': startYear,
        'endYear': resolvedEndYear,
        'hintCount': hintCount,
        'soundEnabled': soundEnabled,
        'hapticsEnabled': hapticsEnabled,
      };

  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(
      timerMinutes: json['timerMinutes'] as int? ?? AppConstants.defaultTimerMinutes,
      startYear: json['startYear'] as int? ?? AppConstants.minYear,
      endYear: json['endYear'] as int? ?? AppConstants.maxYear,
      hintCount: (json['hintCount'] as int? ?? AppConstants.defaultHintCount)
          .clamp(0, AppConstants.maxHints),
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        timerMinutes,
        startYear,
        resolvedEndYear,
        hintCount,
        soundEnabled,
        hapticsEnabled,
      ];
}
