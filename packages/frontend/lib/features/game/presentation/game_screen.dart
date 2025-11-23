import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_models/shared_models.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di.dart';
import 'package:frontend/features/game/logic/game_bloc.dart';
import 'package:frontend/features/game/logic/game_event.dart';
import 'package:frontend/features/game/logic/game_state.dart';
import 'package:frontend/features/game/presentation/widgets/bingo_tile_card.dart';
import 'package:frontend/features/game/presentation/widgets/tile_details_dialog.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({required this.gameId, super.key});

  final String gameId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GameBloc>()..add(GameLoadRequested(gameId)),
      child: const _GameScreenContent(),
    );
  }
}

class _GameScreenContent extends StatefulWidget {
  const _GameScreenContent();

  @override
  State<_GameScreenContent> createState() => _GameScreenContentState();
}

class _GameScreenContentState extends State<_GameScreenContent> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        if (state is GameInitial || state is GameLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is GameError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Game Not Found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This game may have been deleted or you no longer have access to it.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.go('/lobby'),
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Return to Lobby'),
                  ),
                ],
              ),
            ),
          );
        }

        final loadedState = state as GameLoaded;
        final game = loadedState.game;
        final tiles = loadedState.tiles;

        final tileStates = <int, bool>{};

        return LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1600),
                  child: Center(
                    child: _BingoBoardSection(
                      tiles: tiles,
                      tileStates: tileStates,
                      boardSize: game.boardSize,
                      availableHeight: availableHeight,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _BingoBoardSection extends StatelessWidget {
  const _BingoBoardSection({
    required this.tiles,
    required this.tileStates,
    required this.boardSize,
    required this.availableHeight,
  });

  final List<BingoTile> tiles;
  final Map<int, bool> tileStates;
  final int boardSize;
  final double availableHeight;

  @override
  Widget build(BuildContext context) {
    final completedTiles = tileStates.values
        .where((isCompleted) => isCompleted)
        .length;
    final totalTiles = tiles.length;

    return Center(
      child: LayoutBuilder(
        builder: (context, outerConstraints) {
          const minTileSize = 100.0;
          const maxTileSize = 200.0;
          const headerAndPadding = 150.0;
          final maxBoardHeight = availableHeight - headerAndPadding;

          final calculatedTileSize =
              (outerConstraints.maxWidth - (boardSize - 1) * 12 - 40) /
              boardSize;
          final tileSize = calculatedTileSize.clamp(minTileSize, maxTileSize);
          final boardWidth = (tileSize * boardSize) + ((boardSize - 1) * 12);

          return Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: boardWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Board',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$completedTiles / $totalTiles',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Builder(
                    builder: (context) {
                      final boardHeight =
                          (tileSize * boardSize) + ((boardSize - 1) * 12);

                      // If board would be too tall or tiles too small, make it scrollable
                      final shouldScroll = boardHeight > maxBoardHeight;

                      final gridView = GridView.builder(
                        shrinkWrap: !shouldScroll,
                        physics: shouldScroll
                            ? const AlwaysScrollableScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: boardSize,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: tiles.length,
                        itemBuilder: (context, index) {
                          final tile = tiles[index];
                          final isCompleted = tileStates[index] ?? false;

                          return BingoTileCard(
                            tile: tile,
                            isCompleted: isCompleted,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => TileDetailsDialog(
                                  tile: tile,
                                  isCompleted: isCompleted,
                                ),
                              );
                            },
                          );
                        },
                      );

                      if (shouldScroll) {
                        return SizedBox(
                          width: boardWidth,
                          height: maxBoardHeight,
                          child: gridView,
                        );
                      }

                      return SizedBox(width: boardWidth, child: gridView);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
