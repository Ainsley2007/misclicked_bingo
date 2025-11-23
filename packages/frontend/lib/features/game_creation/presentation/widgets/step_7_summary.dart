import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/widgets/widgets.dart';
import 'package:frontend/features/game_creation/logic/game_creation_bloc.dart';
import 'package:frontend/features/game_creation/logic/game_creation_event.dart';
import 'package:frontend/features/game_creation/logic/game_creation_state.dart';

class Step7Summary extends StatelessWidget {
  const Step7Summary({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCreationBloc, GameCreationState>(
      builder: (context, state) {
        return SectionCard(
          icon: Icons.summarize_rounded,
          title: 'Review & Submit',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Review your game configuration before submitting',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              _SummarySection(
                title: 'Game Details',
                icon: Icons.sports_esports_rounded,
                onEdit: () => context.read<GameCreationBloc>().add(
                  const JumpToStepRequested(1),
                ),
                children: [
                  _SummaryItem(label: 'Name', value: state.gameName),
                  _SummaryItem(
                    label: 'Team Size',
                    value: '${state.teamSize} players',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SummarySection(
                title: 'Board Configuration',
                icon: Icons.grid_3x3_rounded,
                onEdit: () => context.read<GameCreationBloc>().add(
                  const JumpToStepRequested(3),
                ),
                children: [
                  _SummaryItem(
                    label: 'Board Size',
                    value: '${state.boardSize}x${state.boardSize}',
                  ),
                  _SummaryItem(
                    label: 'Total Tiles',
                    value: '${state.boardSize * state.boardSize}',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SummarySection(
                title: 'Tiles',
                icon: Icons.grid_on_rounded,
                onEdit: () => context.read<GameCreationBloc>().add(
                  const JumpToStepRequested(4),
                ),
                children: [
                  _SummaryItem(label: 'Count', value: '${state.tiles.length}'),
                ],
              ),
              const SizedBox(height: 24),
              if (state.status == GameCreationStatus.submitting)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        context.read<GameCreationBloc>().add(
                          const PreviousStepRequested(),
                        );
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<GameCreationBloc>().add(
                          const GameSubmitted(),
                        );
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Create Game'),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({
    required this.title,
    required this.icon,
    required this.onEdit,
    required this.children,
  });

  final String title;
  final IconData icon;
  final VoidCallback onEdit;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
