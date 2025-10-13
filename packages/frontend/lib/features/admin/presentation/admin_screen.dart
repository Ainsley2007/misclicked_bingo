import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di.dart';
import 'package:frontend/features/admin/logic/games_bloc.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/core/widgets/widgets.dart';
import 'package:shared_models/shared_models.dart';
import 'package:intl/intl.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => sl<GamesBloc>()..add(const GamesLoadRequested()), child: const _AdminScreenContent());
  }
}

class _AdminScreenContent extends StatefulWidget {
  const _AdminScreenContent();

  @override
  State<_AdminScreenContent> createState() => _AdminScreenContentState();
}

class _AdminScreenContentState extends State<_AdminScreenContent> {
  final _gameNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _gameNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GamesBloc, GamesState>(
      listener: (context, state) {
        if (state.status == GamesStatus.created && state.createdGame != null) {
          _showGameCreatedDialog(context, state.createdGame!);
          _gameNameController.clear();
        } else if (state.status == GamesStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error ?? 'An error occurred'), backgroundColor: Colors.red));
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionCard(
                    icon: Icons.add_circle_rounded,
                    title: 'Create New Game',
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _gameNameController,
                            decoration: const InputDecoration(labelText: 'Game Name', hintText: 'Enter game name', prefixIcon: Icon(Icons.sports_esports_rounded)),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a game name';
                              }
                              return null;
                            },
                            enabled: state.status != GamesStatus.creating,
                          ),
                          const SizedBox(height: 24),
                          FullWidthButton(
                            onPressed: state.status == GamesStatus.creating
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<GamesBloc>().add(GamesCreateRequested(_gameNameController.text.trim()));
                                    }
                                  },
                            icon: state.status == GamesStatus.creating ? Icons.hourglass_empty : Icons.add_rounded,
                            label: state.status == GamesStatus.creating ? 'Creating...' : 'Create Game',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SectionCard(icon: Icons.list_rounded, title: 'Manage Games', child: _buildGamesList(state)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGamesList(GamesState state) {
    if (state.status == GamesStatus.loading || state.status == GamesStatus.initial) {
      return const Center(
        child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()),
      );
    }

    if (state.games.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.sports_esports_outlined, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text('No games yet', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
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

  void _showGameCreatedDialog(BuildContext context, Game game) {
    final accent = AppColors.of(context).accent;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: accent),
            const SizedBox(width: 12),
            const Text('Game Created!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Game "${game.name}" has been created successfully.', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Text('Game Code', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        game.code,
                        style: Theme.of(
                          context,
                        ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 8, color: accent, fontFeatures: [const FontFeature.tabularFigures()]),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: game.code));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied to clipboard!'), duration: Duration(seconds: 2)));
                        },
                        tooltip: 'Copy code',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Share this code with captains so they can join the game.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
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
        decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(Icons.grid_3x3_rounded, color: accent),
      ),
      title: Text(game.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                child: Text(
                  game.code,
                  style: TextStyle(color: accent, fontWeight: FontWeight.bold, letterSpacing: 2, fontFeatures: [const FontFeature.tabularFigures()]),
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.access_time, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(dateFormat.format(game.createdAt), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.content_copy_rounded),
        tooltip: 'Copy code',
        onPressed: () {
          Clipboard.setData(ClipboardData(text: game.code));
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied to clipboard!'), duration: Duration(seconds: 2)));
        },
      ),
    );
  }
}
