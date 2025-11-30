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
            return const SizedBox.expand(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final loadedState = state as OverviewLoaded;
          final game = loadedState.game;
          final tiles = loadedState.tiles;
          final teams = loadedState.teams;

          return LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final showSidebar = screenWidth > 800;
              const sidebarWidth = 360.0;

              // Calculate board area width
              final boardAreaWidth = showSidebar
                  ? screenWidth -
                        sidebarWidth -
                        72 // 72 = padding
                  : screenWidth - 48;

              const targetBoardWidth = 380.0;
              final crossAxisCount = (boardAreaWidth / targetBoardWidth)
                  .floor()
                  .clamp(1, 4);

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
                            child: Center(
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (showSidebar)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: SizedBox(
                        width: sidebarWidth,
                        child: _SlidingSidebarPanel(
                          showProofs: _selectedTile != null,
                          activityPanel: _ActivitySidebarCard(
                            activities: loadedState.activities,
                            stats: loadedState.stats,
                          ),
                          proofsPanel: _selectedTile != null
                              ? _ProofsSidebarCard(
                                  key: ValueKey(
                                    '${_selectedTile!.id}_$_selectedTeamId',
                                  ),
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
                              : null,
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _SlidingSidebarPanel extends StatefulWidget {
  final bool showProofs;
  final Widget activityPanel;
  final Widget? proofsPanel;

  const _SlidingSidebarPanel({
    required this.showProofs,
    required this.activityPanel,
    this.proofsPanel,
  });

  @override
  State<_SlidingSidebarPanel> createState() => _SlidingSidebarPanelState();
}

class _SlidingSidebarPanelState extends State<_SlidingSidebarPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _activitySlideAnimation;
  late Animation<Offset> _proofsSlideAnimation;
  Widget? _cachedProofsPanel;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Activity slides OUT to the right
    _activitySlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Proofs slides IN from the right
    _proofsSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.showProofs) {
      _controller.value = 1.0;
      _cachedProofsPanel = widget.proofsPanel;
    }

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() => _cachedProofsPanel = null);
      }
    });
  }

  @override
  void didUpdateWidget(_SlidingSidebarPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showProofs != oldWidget.showProofs) {
      if (widget.showProofs) {
        _cachedProofsPanel = widget.proofsPanel;
        _controller.forward();
      } else {
        _controller.reverse();
      }
    } else if (widget.showProofs && widget.proofsPanel != null) {
      _cachedProofsPanel = widget.proofsPanel;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final proofsPanelToShow = _cachedProofsPanel;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Proofs panel renders first (behind) so activity slides over it
            if (proofsPanelToShow != null)
              SlideTransition(
                position: _proofsSlideAnimation,
                child: SizedBox.expand(child: proofsPanelToShow),
              ),
            // Activity panel on top, slides out to reveal proofs
            SlideTransition(
              position: _activitySlideAnimation,
              child: SizedBox.expand(child: widget.activityPanel),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivitySidebarCard extends StatefulWidget {
  final List<TileActivity> activities;
  final ProofStats? stats;

  const _ActivitySidebarCard({super.key, required this.activities, this.stats});

  @override
  State<_ActivitySidebarCard> createState() => _ActivitySidebarCardState();
}

class _ActivitySidebarCardState extends State<_ActivitySidebarCard>
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

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 2,
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

class _ProofsSidebarCard extends StatelessWidget {
  final BingoTile tile;
  final String gameId;
  final String? teamId;
  final String? teamName;
  final VoidCallback onClose;

  const _ProofsSidebarCard({
    super.key,
    required this.tile,
    required this.gameId,
    this.teamId,
    this.teamName,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: TileProofsPanel(
        tile: tile,
        gameId: gameId,
        teamId: teamId,
        teamName: teamName,
        onClose: onClose,
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

  Color _parseColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final completedTiles = tiles
        .where((tile) => team.boardStates[tile.id] == 'completed')
        .length;
    final totalTiles = tiles.length;
    final teamColor = _parseColor(team.color);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: teamColor.withValues(alpha: 0.15),
              border: Border(
                bottom: BorderSide(color: teamColor.withValues(alpha: 0.3)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: teamColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: teamColor.withValues(alpha: 0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    team.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: teamColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$completedTiles / $totalTiles',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: teamColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: boardSize,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
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
          ),
        ],
      ),
    );
  }
}
