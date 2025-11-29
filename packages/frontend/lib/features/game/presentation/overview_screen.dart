import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/features/game/logic/overview_bloc.dart';
import 'package:frontend/features/game/logic/overview_event.dart';
import 'package:frontend/features/game/logic/overview_state.dart';
import 'package:frontend/features/game/presentation/widgets/activity_feed.dart';
import 'package:frontend/features/game/presentation/widgets/leaderboard_widget.dart';
import 'package:frontend/features/game/presentation/widgets/overview_tile_card.dart';
import 'package:frontend/features/game/presentation/widgets/tile_proofs_panel.dart';
import 'package:shared_models/shared_models.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({required this.gameId, super.key});

  final String gameId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OverviewBloc>()..add(OverviewLoadRequested(gameId)),
      child: _OverviewScreenContent(gameId: gameId),
    );
  }
}

class _OverviewScreenContent extends StatefulWidget {
  final String gameId;

  const _OverviewScreenContent({required this.gameId});

  @override
  State<_OverviewScreenContent> createState() => _OverviewScreenContentState();
}

class _OverviewScreenContentState extends State<_OverviewScreenContent> {
  BingoTile? _selectedTile;
  String? _selectedTeamId;
  String? _selectedTeamName;

  @override
  Widget build(BuildContext context) {
    return BlocListener<OverviewBloc, OverviewState>(
      listener: (context, state) async {
        if (state is OverviewError) {
          await sl<AuthService>().checkAuth();
          if (context.mounted) {
            context.go('/lobby');
          }
        }
      },
      child: BlocBuilder<OverviewBloc, OverviewState>(
        builder: (context, state) {
          if (state is OverviewInitial ||
              state is OverviewLoading ||
              state is OverviewError) {
            return const Center(child: CircularProgressIndicator());
          }

          final loadedState = state as OverviewLoaded;
          final game = loadedState.game;
          final tiles = loadedState.tiles;
          final teams = loadedState.teams;

          return Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final screenWidth = constraints.maxWidth;
                            const targetBoardWidth = 300.0;
                            final crossAxisCount =
                                (screenWidth / targetBoardWidth).floor().clamp(
                                  2,
                                  6,
                                );

                            return Center(
                              child: GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
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
                                    onTileTap: (tile, isCompleted) {
                                      if (isCompleted) {
                                        setState(() {
                                          _selectedTile = tile;
                                          _selectedTeamId = team.id;
                                          _selectedTeamName = team.name;
                                        });
                                      }
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: _selectedTile != null ? 360 : 0,
                child: _selectedTile != null
                    ? TileProofsPanel(
                        key: ValueKey('${_selectedTile!.id}_$_selectedTeamId'),
                        tile: _selectedTile!,
                        gameId: widget.gameId,
                        teamId: _selectedTeamId,
                        teamName: _selectedTeamName,
                        onClose: () => setState(() {
                          _selectedTile = null;
                          _selectedTeamId = null;
                          _selectedTeamName = null;
                        }),
                      )
                    : const SizedBox.shrink(),
              ),
              Container(
                width: 360,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    left: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: _ActivitySidebar(
                  activities: loadedState.activities,
                  stats: loadedState.stats,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActivitySidebar extends StatefulWidget {
  final List<TileActivity> activities;
  final ProofStats? stats;

  const _ActivitySidebar({required this.activities, this.stats});

  @override
  State<_ActivitySidebar> createState() => _ActivitySidebarState();
}

class _ActivitySidebarState extends State<_ActivitySidebar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              indicatorColor: colorScheme.primary,
              indicatorWeight: 3,
              tabs: const [
                Tab(icon: Icon(Icons.history, size: 18), text: 'Activity'),
                Tab(
                  icon: Icon(Icons.leaderboard, size: 18),
                  text: 'Leaderboard',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ActivityFeed(activities: widget.activities),
                LeaderboardWidget(stats: widget.stats),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamBoardSection extends StatelessWidget {
  const _TeamBoardSection({
    required this.team,
    required this.tiles,
    required this.boardSize,
    required this.onTileTap,
  });

  final TeamOverview team;
  final List<BingoTile> tiles;
  final int boardSize;
  final void Function(BingoTile tile, bool isCompleted) onTileTap;

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

                  return GestureDetector(
                    onTap: isCompleted
                        ? () => onTileTap(tile, isCompleted)
                        : null,
                    child: OverviewTileCard(
                      tile: tile,
                      isCompleted: isCompleted,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
