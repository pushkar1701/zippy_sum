/// Pure scoring helpers.
class Scoring {
  static int sumSelected(Iterable<int> values) =>
      values.fold<int>(0, (a, b) => a + b);
}
