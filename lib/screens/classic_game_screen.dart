import 'package:flutter/material.dart';

import '../app/app_router.dart';
import '../app/app_spacing.dart';
import '../game/board_generator.dart';
import '../game/game_config.dart';
import '../models/tile_model.dart';
import '../widgets/bottom_banner_placeholder.dart';
import '../widgets/number_tile.dart';
import '../widgets/primary_button.dart';

class ClassicGameScreen extends StatelessWidget {
  const ClassicGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const config = GameConfig();
    final grid = BoardGenerator().randomGrid(config);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classic'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Text('Placeholder board — gameplay coming later.'),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                ),
                itemCount: config.gridRows * config.gridColumns,
                itemBuilder: (context, index) {
                  final row = index ~/ config.gridColumns;
                  final col = index % config.gridColumns;
                  final value = grid[row][col];
                  return NumberTile(
                    tile: TileModel(value: value),
                    onTap: () {},
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: PrimaryButton(
              label: 'End round (placeholder)',
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRouter.gameOver),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const BottomBannerPlaceholder(),
        ],
      ),
    );
  }
}
