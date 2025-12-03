import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/di.dart';
import 'package:frontend/core/widgets/widgets.dart';
import 'package:frontend/features/admin/logic/games_bloc.dart';
import 'package:frontend/features/admin/logic/users_bloc.dart';
import 'package:frontend/features/admin/logic/users_event.dart';
import 'package:frontend/features/admin/logic/users_state.dart';
import 'package:frontend/repositories/games_repository.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:shared_models/shared_models.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<GamesBloc>()..add(const GamesLoadRequested()),
        ),
        BlocProvider(
          create: (_) => sl<UsersBloc>()..add(const UsersLoadRequested()),
        ),
      ],
      child: const _AdminScreenContent(),
    );
  }
}

class _AdminScreenContent extends StatefulWidget {
  const _AdminScreenContent();

  @override
  State<_AdminScreenContent> createState() => _AdminScreenContentState();
}

class _AdminScreenContentState extends State<_AdminScreenContent> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<GamesBloc, GamesState>(
          listener: (context, state) {
            if (state is GamesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        BlocListener<UsersBloc, UsersState>(
          listener: (context, state) {
            if (state is UsersError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 1200;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1600),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                SectionCard(
                                  icon: Icons.add_circle_rounded,
                                  title: 'Create New Game',
                                  child: Column(
                                    children: [
                                      Text(
                                        'Set up a new bingo game with custom tiles',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 20),
                                      FullWidthButton(
                                        onPressed: () {
                                          context.go('/admin/games/create');
                                        },
                                        icon: Icons.add_rounded,
                                        label: 'Create New Game',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const _GamesSection(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(child: const _UsersSection()),
                        ],
                      )
                    : Column(
                        children: [
                          SectionCard(
                            icon: Icons.add_circle_rounded,
                            title: 'Create New Game',
                            child: Column(
                              children: [
                                Text(
                                  'Set up a new bingo game with custom tiles',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                FullWidthButton(
                                  onPressed: () {
                                    context.go('/admin/games/create');
                                  },
                                  icon: Icons.add_rounded,
                                  label: 'Create New Game',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const _GamesSection(),
                          const SizedBox(height: 24),
                          const _UsersSection(),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GamesSection extends StatelessWidget {
  const _GamesSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GamesBloc, GamesState>(
      builder: (context, state) {
        return SectionCard(
          icon: Icons.list_rounded,
          title: 'Manage Games',
          child: _buildContent(context, state),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, GamesState state) {
    if (state is GamesInitial || state is GamesLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.games.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.sports_esports_outlined,
                size: 48,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No games yet',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.games.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) => _GameListItem(game: state.games[index]),
    );
  }
}

class _UsersSection extends StatelessWidget {
  const _UsersSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersBloc, UsersState>(
      builder: (context, state) {
        final isLoading = state is UsersLoading;
        return SectionCard(
          icon: Icons.people_rounded,
          title: 'Manage Users',
          trailing: IconButton(
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Refresh users',
            onPressed: isLoading
                ? null
                : () =>
                      context.read<UsersBloc>().add(const UsersLoadRequested()),
          ),
          child: _buildContent(context, state),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, UsersState state) {
    if (state is UsersInitial || state is UsersLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.people_outline,
                size: 48,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No users yet',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.users.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) => _UserListItem(user: state.users[index]),
    );
  }
}

class _UserListItem extends StatelessWidget {
  const _UserListItem({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final displayName = user.username ?? user.globalName ?? 'Unknown';
    final isAdmin = user.role == UserRole.admin;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: user.avatarUrl != null
            ? NetworkImage(user.avatarUrl!)
            : null,
        child: user.avatarUrl == null
            ? Text(
                displayName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              )
            : null,
      ),
      title: Text(
        displayName,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        isAdmin ? 'Admin' : 'User',
        style: TextStyle(
          color: isAdmin
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: isAdmin ? FontWeight.w600 : FontWeight.w500,
          fontSize: 13,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline_rounded, size: 20),
        tooltip: 'Delete user',
        color: Colors.red.shade400,
        onPressed: () => _showDeleteDialog(context),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final displayName = user.username ?? user.globalName ?? 'Unknown';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red),
            SizedBox(width: 12),
            Text('Delete User?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "$displayName"? This action cannot be undone.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<UsersBloc>().add(UsersDeleteRequested(user.id));
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('User "$displayName" deleted'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _GameListItem extends StatelessWidget {
  const _GameListItem({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.of(context).accent;
    final dateFormat = DateFormat('MMM d, y • h:mm a');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accent.withValues(alpha: 0.2)),
        ),
        child: Icon(Icons.grid_3x3_rounded, color: accent, size: 20),
      ),
      title: Text(
        game.name,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: accent.withValues(alpha: 0.3)),
                ),
                child: Text(
                  game.code,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    fontSize: 12,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.access_time,
                size: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                dateFormat.format(game.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.content_copy_rounded, size: 20),
            tooltip: 'Copy code',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: game.code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Code copied to clipboard!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded, size: 20),
            tooltip: 'Edit game',
            onPressed: () => _showEditDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            tooltip: 'Delete game',
            color: Colors.red.shade400,
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => _GameEditDialog(game: game),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red),
            SizedBox(width: 12),
            Text('Delete Game?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${game.name}"? This action cannot be undone.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<GamesBloc>().add(GamesDeleteRequested(game.id));
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Game "${game.name}" deleted'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _GameEditDialog extends StatefulWidget {
  const _GameEditDialog({required this.game});

  final Game game;

  @override
  State<_GameEditDialog> createState() => _GameEditDialogState();
}

class _GameEditDialogState extends State<_GameEditDialog> {
  late TextEditingController _nameController;
  List<BingoTile>? _tiles;
  bool _isLoading = true;
  String? _selectedTileId;
  bool _deleteProofs = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.game.name);
    _loadGameData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadGameData() async {
    try {
      final repository = sl<GamesRepository>();
      final overview = await repository.getOverview(widget.game.id);

      if (mounted) {
        setState(() {
          _tiles = overview.tiles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.edit_rounded, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Edit Game',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Game Name',
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: _updateGameName,
                  child: const Text('Update Name'),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Undo Tile Completions',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Reset tile completion status for all teams',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_tiles == null || _tiles!.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.grid_off,
                        size: 48,
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No tiles found',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Select Tile',
                          prefixIcon: Icon(Icons.grid_3x3),
                        ),
                        value: _selectedTileId,
                        items: _tiles!.map((tile) {
                          final name =
                              tile.bossName ??
                              tile.description ??
                              'Tile ${tile.position}';
                          return DropdownMenuItem(
                            value: tile.id,
                            child: Text(name, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedTileId = value),
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        value: _deleteProofs,
                        onChanged: (value) =>
                            setState(() => _deleteProofs = value ?? false),
                        title: const Text('Also delete proofs'),
                        subtitle: const Text(
                          'Remove all screenshot proofs for this tile',
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _selectedTileId != null
                              ? _uncompleteTile
                              : null,
                          icon: const Icon(Icons.undo),
                          label: const Text('Undo Completion for All Teams'),
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.error,
                            foregroundColor: colorScheme.onError,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateGameName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    try {
      final repository = sl<GamesRepository>();
      await repository.updateGame(gameId: widget.game.id, name: newName);

      if (mounted) {
        context.read<GamesBloc>().add(const GamesLoadRequested());
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Game name updated')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      }
    }
  }

  Future<void> _uncompleteTile() async {
    if (_selectedTileId == null) return;

    try {
      final repository = sl<GamesRepository>();
      await repository.uncompleteTileForAllTeams(
        gameId: widget.game.id,
        tileId: _selectedTileId!,
        deleteProofs: _deleteProofs,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _deleteProofs
                  ? 'Tile uncompleted and proofs deleted'
                  : 'Tile uncompleted for all teams',
            ),
          ),
        );
        setState(() {
          _selectedTileId = null;
          _deleteProofs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to uncomplete: $e')));
      }
    }
  }
}
