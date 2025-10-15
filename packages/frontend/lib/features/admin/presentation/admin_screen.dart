import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di.dart';
import 'package:frontend/features/admin/logic/games_bloc.dart';
import 'package:frontend/features/admin/logic/users_bloc.dart';
import 'package:frontend/features/admin/logic/users_event.dart';
import 'package:frontend/features/admin/logic/users_state.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/core/widgets/widgets.dart';
import 'package:shared_models/shared_models.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

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
            if (state.status == GamesStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error ?? 'Games error'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        BlocListener<UsersBloc, UsersState>(
          listener: (context, state) {
            if (state.status == UsersStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error ?? 'Users error'),
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
            padding: const EdgeInsets.all(32),
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
                                        'Set up a new bingo game with custom challenges and tiles',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge,
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
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
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
                                  'Set up a new bingo game with custom challenges and tiles',
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
    if (state.status == GamesStatus.loading ||
        state.status == GamesStatus.initial) {
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
        return SectionCard(
          icon: Icons.people_rounded,
          title: 'Manage Users',
          child: _buildContent(context, state),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, UsersState state) {
    if (state.status == UsersStatus.loading ||
        state.status == UsersStatus.initial) {
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: CircleAvatar(
        backgroundImage: user.avatarUrl != null
            ? NetworkImage(user.avatarUrl!)
            : null,
        child: user.avatarUrl == null
            ? Text(displayName[0].toUpperCase())
            : null,
      ),
      title: Text(
        displayName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        isAdmin ? 'Admin' : 'User',
        style: TextStyle(
          color: isAdmin
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: isAdmin ? FontWeight.w600 : null,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline_rounded),
        tooltip: 'Delete user',
        color: Colors.red,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.grid_3x3_rounded, color: accent),
      ),
      title: Text(
        game.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  game.code,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.access_time,
                size: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                dateFormat.format(game.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
            icon: const Icon(Icons.content_copy_rounded),
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
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete game',
            color: Colors.red,
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
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
