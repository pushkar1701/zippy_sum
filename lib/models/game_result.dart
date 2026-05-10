/// Outcome of a finished classic round.
class GameResult {
  const GameResult({
    required this.score,
    required this.targetsSolved,
    required this.mistakes,
    required this.bestCombo,
    required this.accuracy,
    required this.durationSeconds,
    required this.playedAt,
    this.isNewBestScore = false,
    this.bestScore = 0,
    /// Lifetime classic games completed after this round (set in [LocalStorageService.recordClassicResult]).
    this.classicCompletionsTotal = 0,
  });

  final int score;
  final int targetsSolved;
  final int mistakes;
  final int bestCombo;

  /// In \[0, 1\]: [targetsSolved] / ([targetsSolved] + [mistakes]), or 0 if none.
  final double accuracy;

  final int durationSeconds;
  final DateTime playedAt;
  final bool isNewBestScore;

  /// Lifetime best classic score after this round (filled when recording to storage).
  final int bestScore;

  /// Total classic games completed after this round; used for interstitial cadence on game over.
  final int classicCompletionsTotal;

  /// Accuracy for display: `targetsSolved / (targetsSolved + mistakes)`, or 0.
  static double computeAccuracy({
    required int targetsSolved,
    required int mistakes,
  }) {
    final denom = targetsSolved + mistakes;
    if (denom == 0) return 0;
    return targetsSolved / denom;
  }

  GameResult copyWith({
    int? score,
    int? targetsSolved,
    int? mistakes,
    int? bestCombo,
    double? accuracy,
    int? durationSeconds,
    DateTime? playedAt,
    bool? isNewBestScore,
    int? bestScore,
    int? classicCompletionsTotal,
  }) {
    return GameResult(
      score: score ?? this.score,
      targetsSolved: targetsSolved ?? this.targetsSolved,
      mistakes: mistakes ?? this.mistakes,
      bestCombo: bestCombo ?? this.bestCombo,
      accuracy: accuracy ?? this.accuracy,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      playedAt: playedAt ?? this.playedAt,
      isNewBestScore: isNewBestScore ?? this.isNewBestScore,
      bestScore: bestScore ?? this.bestScore,
      classicCompletionsTotal:
          classicCompletionsTotal ?? this.classicCompletionsTotal,
    );
  }

  /// Placeholder when opening the route without arguments (should not happen in normal play).
  static GameResult placeholder() {
    final now = DateTime.now();
    return GameResult(
      score: 0,
      targetsSolved: 0,
      mistakes: 0,
      bestCombo: 1,
      accuracy: 0,
      durationSeconds: 60,
      playedAt: now,
      bestScore: 0,
    );
  }
}
