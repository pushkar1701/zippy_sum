/// Outcome of a finished classic round (no persistence / XP / coins).
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

  /// Accuracy for display: `targetsSolved / (targetsSolved + mistakes)`, or 0.
  static double computeAccuracy({
    required int targetsSolved,
    required int mistakes,
  }) {
    final denom = targetsSolved + mistakes;
    if (denom == 0) return 0;
    return targetsSolved / denom;
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
    );
  }
}
