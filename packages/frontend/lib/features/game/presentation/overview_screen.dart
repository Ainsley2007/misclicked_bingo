import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di.dart';
import 'package:frontend/features/game/logic/overview_bloc.dart';
import 'package:frontend/features/game/logic/overview_event.dart';
import 'package:frontend/features/game/logic/overview_state.dart';
import 'package:frontend/features/game/presentation/widgets/overview_tile_card.dart';
import 'package:shared_models/shared_models.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({required this.gameId, super.key});

  final String gameId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OverviewBloc>()..add(OverviewLoadRequested(gameId)),
      child: const _OverviewScreenContent(),
    );
  }
}

class _OverviewScreenContent extends StatelessWidget {
  const _OverviewScreenContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OverviewBloc, OverviewState>(
      builder: (context, state) {
        if (state is OverviewInitial || state is OverviewLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is OverviewError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to Load Overview',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final loadedState = state as OverviewLoaded;
        final game = loadedState.game;
        final tiles = loadedState.tiles;
        final teams = loadedState.teams;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(game.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Make boards smaller - target ~300px per board
                    final screenWidth = constraints.maxWidth;
                    final targetBoardWidth = 300.0;
                    final crossAxisCount = (screenWidth / targetBoardWidth)
                        .floor()
                        .clamp(2, 6);

                    return Center(
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: teams.length,
                        itemBuilder: (context, index) {
                          final team = teams[index];
                          return _TeamBoardSection(
                            team: team,
                            tiles: tiles,
                            boardSize: game.boardSize,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TeamBoardSection extends StatelessWidget {
  const _TeamBoardSection({
    required this.team,
    required this.tiles,
    required this.boardSize,
  });

  final TeamOverview team;
  final List<BingoTile> tiles;
  final int boardSize;

  @override
  Widget build(BuildContext context) {
    final completedTiles = tiles
        .where((tile) => team.boardStates[tile.id] == 'completed')
        .length;
    final totalTiles = tiles.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 16,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    team.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '$completedTiles / $totalTiles',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: boardSize,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: tiles.length,
                itemBuilder: (context, index) {
                  final tile = tiles[index];
                  final isCompleted = team.boardStates[tile.id] == 'completed';

                  return OverviewTileCard(tile: tile, isCompleted: isCompleted);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
