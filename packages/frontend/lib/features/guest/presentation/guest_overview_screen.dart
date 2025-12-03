import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di.dart';
import 'package:frontend/features/game/presentation/widgets/activity_feed.dart';
import 'package:frontend/features/game/presentation/widgets/game_countdown.dart';
import 'package:frontend/features/game/presentation/widgets/leaderboard_widget.dart';
import 'package:frontend/features/game/presentation/widgets/overview_tile_card.dart';
import 'package:frontend/features/guest/logic/guest_bloc.dart';
import 'package:frontend/features/guest/logic/guest_event.dart';
import 'package:frontend/features/guest/logic/guest_state.dart';
import 'package:frontend/repositories/proofs_repository.dart';
import 'package:shared_models/shared_models.dart';

class GuestOverviewScreen extends StatelessWidget {
  const GuestOverviewScreen({required this.gameId, super.key});

  final String gameId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<GuestBloc>()..add(GuestGameOverviewLoadRequested(gameId)),
      child: _GuestOverviewContent(gameId: gameId),
    );
  }
}

class _GuestOverviewContent extends StatefulWidget {
  const _GuestOverviewContent({required this.gameId});

  final String gameId;

  @override
  State<_GuestOverviewContent> createState() => _GuestOverviewContentState();
}

class _GuestOverviewContentState extends State<_GuestOverviewContent> {
  BingoTile? _selectedTile;
  String? _selectedTeamId;
  String? _selectedTeamName;
  String? _selectedTeamColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<GuestBloc, GuestState>(
          builder: (context, state) {
            if (state is GuestGameOverviewLoaded) {
              final game = state.game;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(game.name),
                  if (game.startTime != null || game.endTime != null) ...[
                    const SizedBox(width: 12),
                    GameCountdown(
                      startTime: game.startTime,
                      endTime: game.endTime,
                    ),
                  ],
                ],
              );
            }
            return const Text('Game Overview');
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/guest'),
        ),
        backgroundColor: colorScheme.surfaceContainer,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.visibility,
                  size: 16,
                  color: colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  'View Only',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: BlocBuilder<GuestBloc, GuestState>(
        builder: (context, state) {
          if (state is GuestLoading || state is GuestInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GuestError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go('/guest'),
                    child: const Text('Back to Games'),
                  ),
                ],
              ),
            );
          }

          final loadedState = state as GuestGameOverviewLoaded;
          final game = loadedState.game;
          final tiles = loadedState.tiles;
          final teams = loadedState.teams;

          return LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final showSidebar = screenWidth > 900;
              const sidebarWidth = 360.0;

              // Calculate board area width
              final boardAreaWidth = showSidebar
                  ? screenWidth - sidebarWidth - 72
                  : screenWidth - 48;

              const targetBoardWidth = 300.0;
              final crossAxisCount = (boardAreaWidth / targetBoardWidth)
                  .floor()
                  .clamp(1, 4);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
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
                            return _GuestTeamBoardSection(
                              team: team,
                              tiles: tiles,
                              boardSize: game.boardSize,
                              onTileTap: (tile, isCompleted) {
                                if (isCompleted) {
                                  setState(() {
                                    _selectedTile = tile;
                                    _selectedTeamId = team.id;
                                    _selectedTeamName = team.name;
                                    _selectedTeamColor = team.color;
                                  });
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  if (showSidebar)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: SizedBox(
                        width: sidebarWidth,
                        child: _selectedTile != null
                            ? _GuestProofsSidebarCard(
                                key: ValueKey(
                                  '${_selectedTile!.id}_$_selectedTeamId',
                                ),
                                tile: _selectedTile!,
                                gameId: widget.gameId,
                                teamId: _selectedTeamId,
                                teamName: _selectedTeamName,
                                teamColor: _selectedTeamColor,
                                onClose: () => setState(() {
                                  _selectedTile = null;
                                  _selectedTeamId = null;
                                  _selectedTeamName = null;
                                  _selectedTeamColor = null;
                                }),
                              )
                            : _ActivitySidebarCard(
                                activities: loadedState.activities,
                                stats: loadedState.stats,
                                isLoading: loadedState.isSidebarLoading,
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

class _ActivitySidebarCard extends StatefulWidget {
  final List<TileActivity> activities;
  final ProofStats? stats;
  final bool isLoading;

  const _ActivitySidebarCard({
    required this.activities,
    this.stats,
    this.isLoading = false,
  });

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
            child: widget.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
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

class _GuestProofsSidebarCard extends StatefulWidget {
  final BingoTile tile;
  final String gameId;
  final String? teamId;
  final String? teamName;
  final String? teamColor;
  final VoidCallback onClose;

  const _GuestProofsSidebarCard({
    super.key,
    required this.tile,
    required this.gameId,
    this.teamId,
    this.teamName,
    this.teamColor,
    required this.onClose,
  });

  @override
  State<_GuestProofsSidebarCard> createState() =>
      _GuestProofsSidebarCardState();
}

class _GuestProofsSidebarCardState extends State<_GuestProofsSidebarCard> {
  List<TileProof>? _proofs;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProofs();
  }

  Future<void> _loadProofs() async {
    if (widget.teamId == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = sl<ProofsRepository>();
      final proofs = await repository.getPublicProofs(
        gameId: widget.gameId,
        tileId: widget.tile.id,
        teamId: widget.teamId!,
      );
      if (mounted) {
        setState(() {
          _proofs = proofs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Color _parseColor(String? hex) {
    if (hex == null) return const Color(0xFF4CAF50);
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final teamColor = _parseColor(widget.teamColor);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: teamColor.withValues(alpha: 0.15),
              border: Border(
                bottom: BorderSide(color: teamColor.withValues(alpha: 0.3)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: teamColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.tile.bossName ?? 'Tile',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.teamName != null)
                        Text(
                          widget.teamName!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: teamColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildContent(colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ColorScheme colorScheme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 8),
            Text('Failed to load proofs'),
            TextButton(
              onPressed: _loadProofs,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_proofs == null || _proofs!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No proofs uploaded',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _proofs!.length,
      itemBuilder: (context, index) {
        final proof = _proofs![index];
        return _ProofCard(proof: proof);
      },
    );
  }
}

class _ProofCard extends StatelessWidget {
  const _ProofCard({required this.proof});

  final TileProof proof;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _openFullImage(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  proof.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.broken_image,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proof.uploadedByUsername ?? 'Unknown',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(proof.uploadedAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _openFullImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: InteractiveViewer(
          child: Image.network(proof.imageUrl),
        ),
      ),
    );
  }
}

class _GuestTeamBoardSection extends StatelessWidget {
  const _GuestTeamBoardSection({
    required this.team,
    required this.tiles,
    required this.boardSize,
    required this.onTileTap,
  });

  final GuestTeamOverview team;
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              padding: const EdgeInsets.all(12),
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
          ),
        ],
      ),
    );
  }
}

