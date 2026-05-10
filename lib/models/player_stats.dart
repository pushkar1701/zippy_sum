/// Persisted aggregates (no XP, coins, levels, or leaderboard).
class PlayerStats {
  const PlayerStats({
    this.bestClassicScore = 0,
    this.gamesPlayed = 0,
  });

  final int bestClassicScore;
  final int gamesPlayed;

  PlayerStats copyWith({
    int? bestClassicScore,
    int? gamesPlayed,
  }) {
    return PlayerStats(
      bestClassicScore: bestClassicScore ?? this.bestClassicScore,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
    );
  }
}
