/// Visual/interaction state for a tile in the grid.
enum TileState { normal, selected, correct, mistake, disabled }

/// One cell on the board for UI rendering (4×4 classic = 16 cells).
///
/// Built by [GameController.tileModels]: [id] is the stable index (row-major),
/// [isSelected] and [state] reflect selection and mistake / end-of-round rules.
class TileModel {
  const TileModel({
    required this.id,
    required this.value,
    required this.isSelected,
    required this.state,
  });

  final int id;
  final int value;
  final bool isSelected;
  final TileState state;

  TileModel copyWith({
    int? id,
    int? value,
    bool? isSelected,
    TileState? state,
  }) {
    return TileModel(
      id: id ?? this.id,
      value: value ?? this.value,
      isSelected: isSelected ?? this.isSelected,
      state: state ?? this.state,
    );
  }
}
