import 'package:flutter/material.dart';

import '../app/app_colors.dart';
import '../app/app_spacing.dart';
import '../app/app_text_styles.dart';
import '../models/tile_model.dart';
import '../widgets/number_tile.dart';

/// Placeholder classic round — no submit; Clear + Pause only.
class ClassicGameScreen extends StatefulWidget {
  const ClassicGameScreen({super.key});

  @override
  State<ClassicGameScreen> createState() => _ClassicGameScreenState();
}

class _ClassicGameScreenState extends State<ClassicGameScreen> {
  static const List<int> _values = [
    7, 2, 5, 3,
    1, 9, 4, 8,
    6, 3, 2, 5,
    4, 1, 8, 7,
  ];

  final List<bool> _selected = List<bool>.filled(16, false);

  static const int _time = 60;
  static const int _score = 0;
  static const String _combo = 'x1';
  static const int _target = 17;
  int get _currentSum {
    var s = 0;
    for (var i = 0; i < _values.length; i++) {
      if (_selected[i]) s += _values[i];
    }
    return s;
  }

  void _toggle(int index) {
    setState(() => _selected[index] = !_selected[index]);
  }

  void _clear() {
    setState(() {
      for (var i = 0; i < _selected.length; i++) {
        _selected[i] = false;
      }
    });
  }

  Future<void> _pause() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Paused'),
          content: const Text('Take a breather. Gameplay is still a placeholder.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Resume'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                'Quit',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Classic'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HudRow(
              label1: 'Time',
              value1: '$_time',
              label2: 'Score',
              value2: '$_score',
            ),
            const SizedBox(height: AppSpacing.sm),
            _HudRow(
              label1: 'Combo',
              value1: _combo,
              label2: 'Target',
              value2: '$_target',
            ),
            const SizedBox(height: AppSpacing.sm),
            _HudRow(
              label1: 'Current sum',
              value1: '$_currentSum',
              label2: '',
              value2: '',
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Demo grid — tap tiles to toggle (placeholder).',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 1,
                ),
                itemCount: 16,
                itemBuilder: (context, index) {
                  return NumberTile(
                    tile: TileModel(
                      id: index,
                      value: _values[index],
                      isSelected: _selected[index],
                      state: _selected[index]
                          ? TileState.selected
                          : TileState.normal,
                    ),
                    onTap: () => _toggle(index),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clear,
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: _pause,
                    child: const Text('Pause'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HudRow extends StatelessWidget {
  const _HudRow({
    required this.label1,
    required this.value1,
    required this.label2,
    required this.value2,
  });

  final String label1;
  final String value1;
  final String label2;
  final String value2;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _HudCell(label: label1, value: value1)),
        if (label2.isNotEmpty) const SizedBox(width: AppSpacing.md),
        if (label2.isNotEmpty)
          Expanded(child: _HudCell(label: label2, value: value2)),
      ],
    );
  }
}

class _HudCell extends StatelessWidget {
  const _HudCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTextStyles.hudLabel),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.hudValue),
        ],
      ),
    );
  }
}
