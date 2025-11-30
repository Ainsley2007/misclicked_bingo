import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_models/shared_models.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di.dart';
import 'package:frontend/core/services/auth_service.dart';
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
    return BlocListener<GameBloc, GameState>(
      listener: (context, state) async {
        if (state is GameError) {
          await sl<AuthService>().checkAuth();
          if (context.mounted) {
            context.go('/lobby');
          }
        }
      },
      child: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          if (state is GameInitial ||
              state is GameLoading ||
              state is GameError) {
            return const SizedBox.expand(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final loadedState = state as GameLoaded;
          final game = loadedState.game;
          final tiles = loadedState.tiles;

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
                        boardSize: game.boardSize,
                        availableHeight: availableHeight,
                        gameId: game.id,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _BingoBoardSection extends StatelessWidget {
  const _BingoBoardSection({
    required this.tiles,
    required this.boardSize,
    required this.availableHeight,
    required this.gameId,
  });

  final List<BingoTile> tiles;
  final int boardSize;
  final double availableHeight;
  final String gameId;

  @override
  Widget build(BuildContext context) {
    final completedTiles = tiles.where((tile) => tile.isCompleted).length;
    final totalTiles = tiles.length;

    return Center(
      child: LayoutBuilder(
        builder: (context, outerConstraints) {
          const minTileSize = 80.0;
          const maxTileSize = 160.0;
          const headerAndPadding = 100.0;
          const spacing = 10.0;
          final maxBoardHeight = availableHeight - headerAndPadding;

          // Calculate tile size based on BOTH width and height to fit screen
          final tileSizeFromWidth =
              (outerConstraints.maxWidth - (boardSize - 1) * spacing - 40) /
              boardSize;
          final tileSizeFromHeight =
              (maxBoardHeight - (boardSize - 1) * spacing) / boardSize;
          
          // Use the smaller of the two to ensure it fits
          final calculatedTileSize = tileSizeFromWidth < tileSizeFromHeight
              ? tileSizeFromWidth
              : tileSizeFromHeight;
          final tileSize = calculatedTileSize.clamp(minTileSize, maxTileSize);
          final boardWidth = (tileSize * boardSize) + ((boardSize - 1) * spacing);

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
                  const SizedBox(height: 16),
                  Builder(
                    builder: (context) {
                      final boardHeight =
                          (tileSize * boardSize) + ((boardSize - 1) * spacing);

                      // If board would be too tall or tiles too small, make it scrollable
                      final shouldScroll = boardHeight > maxBoardHeight;

                      final gridView = GridView.builder(
                        shrinkWrap: !shouldScroll,
                        physics: shouldScroll
                            ? const AlwaysScrollableScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: boardSize,
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing,
                          childAspectRatio: 1,
                        ),
                        itemCount: tiles.length,
                        itemBuilder: (context, index) {
                          final tile = tiles[index];

                          return BingoTileCard(
                            tile: tile,
                            isCompleted: tile.isCompleted,
                            onTap: () {
                              final bloc = context.read<GameBloc>();
                              showDialog(
                                context: context,
                                builder: (dialogContext) => BlocProvider.value(
                                  value: bloc,
                                  child: TileDetailsDialog(
                                    tile: tile,
                                    gameId: gameId,
                                    onToggleCompletion: (_) {
                                      bloc.add(
                                        TileCompletionToggled(
                                          gameId: gameId,
                                          tileId: tile.id,
                                        ),
                                      );
                                    },
                                  ),
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
