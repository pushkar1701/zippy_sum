import 'package:flutter/foundation.dart';

/// Coordinates classic game flow (placeholder).
class GameController extends ChangeNotifier {
  int _score = 0;

  int get score => _score;

  void reset() {
    _score = 0;
    notifyListeners();
  }

  void addScore(int delta) {
    _score += delta;
    notifyListeners();
  }
}
