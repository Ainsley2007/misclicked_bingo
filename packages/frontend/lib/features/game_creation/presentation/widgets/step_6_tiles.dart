import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/widgets/widgets.dart';
import 'package:frontend/features/game_creation/logic/game_creation_bloc.dart';
import 'package:frontend/features/game_creation/logic/game_creation_event.dart';
import 'package:frontend/features/game_creation/logic/game_creation_state.dart';
import 'package:frontend/features/game_creation/presentation/widgets/tile_form_card.dart';

class Step6Tiles extends StatelessWidget {
  const Step6Tiles({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCreationBloc, GameCreationState>(
      builder: (context, state) {
        final requiredTiles = state.boardSize * state.boardSize;
        final currentTiles = state.tiles.length;

        return SectionCard(
          icon: Icons.grid_on_rounded,
          title: 'Bingo Tiles',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Define the tiles that will appear on the bingo board',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: currentTiles == requiredTiles
                      ? Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withOpacity(0.5)
                      : Theme.of(
                          context,
                        ).colorScheme.errorContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: currentTiles == requiredTiles
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      currentTiles == requiredTiles
                          ? Icons.check_circle_rounded
                          : Icons.warning_rounded,
                      color: currentTiles == requiredTiles
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tiles: $currentTiles / $requiredTiles',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
              if (state.validationError != null) ...[
                const SizedBox(height: 8),
                Text(
                  state.validationError!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (state.tiles.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.grid_on_outlined,
                          size: 48,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tiles yet',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.tiles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return TileFormCard(
                      index: index,
                      data: state.tiles[index],
                      onUpdate: (data) {
                        context.read<GameCreationBloc>().add(
                          TileUpdated(index, data),
                        );
                      },
                      onRemove: () {
                        context.read<GameCreationBloc>().add(
                          TileRemoved(index),
                        );
                      },
                    );
                  },
                ),
              const SizedBox(height: 16),
              if (currentTiles < requiredTiles)
                OutlinedButton.icon(
                  onPressed: () {
                    context.read<GameCreationBloc>().add(const TileAdded());
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Tile'),
                ),
              const SizedBox(height: 24),
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
                        const NextStepRequested(),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
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
