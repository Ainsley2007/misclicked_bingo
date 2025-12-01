import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/game_creation/logic/game_creation_bloc.dart';
import 'package:frontend/features/game_creation/logic/game_creation_event.dart';
import 'package:frontend/features/game_creation/logic/game_creation_state.dart';
import 'package:shared_models/shared_models.dart';

class Step2GameMode extends StatelessWidget {
  const Step2GameMode({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCreationBloc, GameCreationState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Game Mode',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose how winners are determined',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: _GameModeCard(
                        title: 'Blackout',
                        description:
                            'First team to complete ALL tiles wins. No time limit.',
                        icon: Icons.grid_on_rounded,
                        isSelected: state.gameMode == GameMode.blackout,
                        onTap: () => context
                            .read<GameCreationBloc>()
                            .add(const GameModeChanged(GameMode.blackout)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _GameModeCard(
                        title: 'Points',
                        description:
                            'Each tile has points. Team with most points wins when time ends.',
                        icon: Icons.emoji_events_rounded,
                        isSelected: state.gameMode == GameMode.points,
                        onTap: () => context
                            .read<GameCreationBloc>()
                            .add(const GameModeChanged(GameMode.points)),
                      ),
                    ),
                  ],
                ),
                if (state.gameMode == GameMode.points) ...[
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 24),
                  _EndTimeSection(endTime: state.endTime),
                ],
                const SizedBox(height: 32),
                _NavigationButtons(state: state),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GameModeCard extends StatelessWidget {
  const _GameModeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : colorScheme.surface,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EndTimeSection extends StatelessWidget {
  const _EndTimeSection({this.endTime});

  final DateTime? endTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'End Time (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Set when the game ends. Leave empty to end manually.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _selectDateTime(context),
                icon: const Icon(Icons.calendar_today_rounded),
                label: Text(
                  endTime != null ? _formatDateTime(endTime!) : 'Select date & time',
                ),
              ),
            ),
            if (endTime != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => context
                    .read<GameCreationBloc>()
                    .add(const EndTimeChanged(null)),
                icon: const Icon(Icons.clear_rounded),
                tooltip: 'Clear end time',
              ),
            ],
          ],
        ),
      ],
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = endTime ?? now.add(const Duration(days: 7));

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (time == null || !context.mounted) return;

    final selectedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    context.read<GameCreationBloc>().add(EndTimeChanged(selectedDateTime));
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final amPm = dt.hour < 12 ? 'AM' : 'PM';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $hour:${dt.minute.toString().padLeft(2, '0')} $amPm';
  }
}

class _NavigationButtons extends StatelessWidget {
  const _NavigationButtons({required this.state});

  final GameCreationState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton.icon(
          onPressed: () => context
              .read<GameCreationBloc>()
              .add(const PreviousStepRequested()),
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Back'),
        ),
        FilledButton.icon(
          onPressed: () =>
              context.read<GameCreationBloc>().add(const NextStepRequested()),
          icon: const Icon(Icons.arrow_forward_rounded),
          label: const Text('Next'),
        ),
      ],
    );
  }
}

