import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_models/shared_models.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di.dart';
import 'package:frontend/features/game/logic/game_bloc.dart';
import 'package:frontend/features/game/logic/game_event.dart';
import 'package:frontend/features/game/logic/game_state.dart';
import 'package:frontend/features/game/presentation/widgets/challenge_card.dart';
import 'package:frontend/features/game/presentation/widgets/bingo_tile_card.dart';
import 'package:frontend/features/game/presentation/widgets/tile_details_dialog.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({required this.gameId, super.key});

  final String gameId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => sl<GameBloc>()..add(GameLoadRequested(gameId)), child: const _GameScreenContent());
  }
}

class _GameScreenContent extends StatefulWidget {
  const _GameScreenContent();

  @override
  State<_GameScreenContent> createState() => _GameScreenContentState();
}

class _GameScreenContentState extends State<_GameScreenContent> {
  bool _challengesExpanded = true;

  static const int mockUnlocksAvailable = 8;
  static const Set<int> mockCompletedChallenges = {0, 3, 7};

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
                  Text('Game Not Found', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('This game may have been deleted or you no longer have access to it.', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  FilledButton.icon(onPressed: () => context.go('/lobby'), icon: const Icon(Icons.home_rounded), label: const Text('Return to Lobby')),
                ],
              ),
            ),
          );
        }

        final loadedState = state as GameLoaded;
        final game = loadedState.game;
        final challenges = loadedState.challenges;
        final tiles = loadedState.tiles;

        // Generate mock tile states based on board size
        final mockTileStates = <int, TileState>{};
        for (var i = 0; i < tiles.length; i++) {
          if (i % 3 == 0) {
            mockTileStates[i] = TileState.completed;
          } else if (i % 3 == 1) {
            mockTileStates[i] = TileState.unlocked;
          } else {
            mockTileStates[i] = TileState.locked;
          }
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 1200;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1600),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (game.hasChallenges && _challengesExpanded)
                              Expanded(
                                flex: 1,
                                child: _ChallengesSection(
                                  challenges: challenges,
                                  completedChallenges: mockCompletedChallenges,
                                  onToggle: () {
                                    setState(() {
                                      _challengesExpanded = false;
                                    });
                                  },
                                ),
                              ),
                            if (game.hasChallenges && !_challengesExpanded)
                              _CollapsedChallengesBar(
                                onToggle: () {
                                  setState(() {
                                    _challengesExpanded = true;
                                  });
                                },
                              ),
                            if (game.hasChallenges) const SizedBox(width: 32),
                            Expanded(
                              flex: game.hasChallenges && _challengesExpanded ? 3 : 4,
                              child: _BingoBoardSection(
                                tiles: tiles,
                                tileStates: mockTileStates,
                                boardSize: game.boardSize,
                                unlocksAvailable: mockUnlocksAvailable,
                                hasChallenges: game.hasChallenges,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            if (game.hasChallenges) ...[
                              _ChallengesSection(challenges: challenges, completedChallenges: mockCompletedChallenges, onToggle: null),
                              const SizedBox(height: 32),
                            ],
                            _BingoBoardSection(
                              tiles: tiles,
                              tileStates: mockTileStates,
                              boardSize: game.boardSize,
                              unlocksAvailable: mockUnlocksAvailable,
                              hasChallenges: game.hasChallenges,
                            ),
                          ],
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

class _ChallengesSection extends StatelessWidget {
  const _ChallengesSection({required this.challenges, required this.completedChallenges, required this.onToggle});

  final List<Challenge> challenges;
  final Set<int> completedChallenges;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.emoji_events_rounded, color: Theme.of(context).colorScheme.primary, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Text('Challenges', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                ),
                if (onToggle != null) IconButton(onPressed: onToggle, icon: const Icon(Icons.chevron_left_rounded), tooltip: 'Collapse challenges'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: challenges.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return ChallengeCard(challenge: challenges[index], isCompleted: completedChallenges.contains(index));
          },
        ),
      ],
    );
  }
}

class _CollapsedChallengesBar extends StatelessWidget {
  const _CollapsedChallengesBar({required this.onToggle});

  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              RotatedBox(
                quarterTurns: 3,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('Challenges', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurface, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BingoBoardSection extends StatelessWidget {
  const _BingoBoardSection({required this.tiles, required this.tileStates, required this.boardSize, required this.unlocksAvailable, required this.hasChallenges});

  final List<BingoTile> tiles;
  final Map<int, TileState> tileStates;
  final int boardSize;
  final int unlocksAvailable;
  final bool hasChallenges;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.grid_on_rounded, color: Theme.of(context).colorScheme.primary, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Text('Bingo Board', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                ),
                if (hasChallenges)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_open_rounded, color: Theme.of(context).colorScheme.onPrimaryContainer, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '$unlocksAvailable',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimaryContainer),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: boardSize, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1),
          itemCount: tiles.length,
          itemBuilder: (context, index) {
            final tile = tiles[index];
            final state = tileStates[index] ?? TileState.locked;

            return BingoTileCard(
              tile: tile,
              state: state,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => TileDetailsDialog(tile: tile, state: state),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
