import 'dart:convert';

/// Persisted aggregates for Classic + Daily (device-only).
class PlayerStats {
  const PlayerStats({
    this.bestClassicScore = 0,
    this.totalGamesPlayed = 0,
    this.totalTargetsSolved = 0,
    this.totalMistakes = 0,
    this.bestCombo = 0,
    this.lastPlayedAt,
    this.lastDailyDateString,
    this.dailyStreak = 0,
    this.todayDailyBestScore = 0,
    this.bestDailyScore = 0,
  });

  final int bestClassicScore;
  final int totalGamesPlayed;
  final int totalTargetsSolved;
  final int totalMistakes;
  final int bestCombo;
  final DateTime? lastPlayedAt;

  /// [DailySeed.dateKey] for last completed daily, or null.
  final String? lastDailyDateString;
  final int dailyStreak;
  final int todayDailyBestScore;
  final int bestDailyScore;

  /// Lifetime classic: [totalTargetsSolved] / ([totalTargetsSolved] + [totalMistakes]), or 0.
  double get averageAccuracy {
    final d = totalTargetsSolved + totalMistakes;
    if (d == 0) return 0;
    return totalTargetsSolved / d;
  }

  factory PlayerStats.empty() => const PlayerStats();

  Map<String, dynamic> toJson() => {
    'bestClassicScore': bestClassicScore,
    'totalGamesPlayed': totalGamesPlayed,
    'totalTargetsSolved': totalTargetsSolved,
    'totalMistakes': totalMistakes,
    'bestCombo': bestCombo,
    'lastPlayedAt': lastPlayedAt?.toIso8601String(),
    'lastDailyDateString': lastDailyDateString,
    'dailyStreak': dailyStreak,
    'todayDailyBestScore': todayDailyBestScore,
    'bestDailyScore': bestDailyScore,
  };

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      bestClassicScore: (json['bestClassicScore'] as num?)?.toInt() ?? 0,
      totalGamesPlayed: (json['totalGamesPlayed'] as num?)?.toInt() ?? 0,
      totalTargetsSolved: (json['totalTargetsSolved'] as num?)?.toInt() ?? 0,
      totalMistakes: (json['totalMistakes'] as num?)?.toInt() ?? 0,
      bestCombo: (json['bestCombo'] as num?)?.toInt() ?? 0,
      lastPlayedAt: json['lastPlayedAt'] != null
          ? DateTime.tryParse(json['lastPlayedAt'] as String)
          : null,
      lastDailyDateString: json['lastDailyDateString'] as String?,
      dailyStreak: (json['dailyStreak'] as num?)?.toInt() ?? 0,
      todayDailyBestScore: (json['todayDailyBestScore'] as num?)?.toInt() ?? 0,
      bestDailyScore: (json['bestDailyScore'] as num?)?.toInt() ?? 0,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory PlayerStats.fromJsonString(String raw) {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return PlayerStats.fromJson(map);
  }

  PlayerStats copyWith({
    int? bestClassicScore,
    int? totalGamesPlayed,
    int? totalTargetsSolved,
    int? totalMistakes,
    int? bestCombo,
    DateTime? lastPlayedAt,
    String? lastDailyDateString,
    int? dailyStreak,
    int? todayDailyBestScore,
    int? bestDailyScore,
  }) {
    return PlayerStats(
      bestClassicScore: bestClassicScore ?? this.bestClassicScore,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalTargetsSolved: totalTargetsSolved ?? this.totalTargetsSolved,
      totalMistakes: totalMistakes ?? this.totalMistakes,
      bestCombo: bestCombo ?? this.bestCombo,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      lastDailyDateString: lastDailyDateString ?? this.lastDailyDateString,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      todayDailyBestScore: todayDailyBestScore ?? this.todayDailyBestScore,
      bestDailyScore: bestDailyScore ?? this.bestDailyScore,
    );
  }
}
