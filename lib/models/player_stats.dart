import 'dart:convert';

/// Persisted aggregates for Classic and related local progress (device-only).
class PlayerStats {
  const PlayerStats({
    this.bestClassicScore = 0,
    this.totalGamesPlayed = 0,
    this.totalTargetsSolved = 0,
    this.totalMistakes = 0,
    this.bestCombo = 0,
    this.lastPlayedAt,
  });

  final int bestClassicScore;
  final int totalGamesPlayed;
  final int totalTargetsSolved;
  final int totalMistakes;
  final int bestCombo;
  final DateTime? lastPlayedAt;

  /// Lifetime: [totalTargetsSolved] / ([totalTargetsSolved] + [totalMistakes]), or 0.
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
  }) {
    return PlayerStats(
      bestClassicScore: bestClassicScore ?? this.bestClassicScore,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalTargetsSolved: totalTargetsSolved ?? this.totalTargetsSolved,
      totalMistakes: totalMistakes ?? this.totalMistakes,
      bestCombo: bestCombo ?? this.bestCombo,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }
}
