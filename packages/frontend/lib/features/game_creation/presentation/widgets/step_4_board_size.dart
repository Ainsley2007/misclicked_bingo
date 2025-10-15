import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/widgets/widgets.dart';
import 'package:frontend/features/game_creation/logic/game_creation_bloc.dart';
import 'package:frontend/features/game_creation/logic/game_creation_event.dart';
import 'package:frontend/features/game_creation/logic/game_creation_state.dart';

class Step4BoardSize extends StatelessWidget {
  const Step4BoardSize({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCreationBloc, GameCreationState>(
      builder: (context, state) {
        return SectionCard(
          icon: Icons.grid_3x3_rounded,
          title: 'Board Size',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select the size of your bingo board',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 32),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.85,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _BoardSizeCard(
                    size: 2,
                    isSelected: state.boardSize == 2,
                    onTap: () {
                      context.read<GameCreationBloc>().add(
                        const BoardSizeSelected(2),
                      );
                    },
                  ),
                  _BoardSizeCard(
                    size: 3,
                    isSelected: state.boardSize == 3,
                    onTap: () {
                      context.read<GameCreationBloc>().add(
                        const BoardSizeSelected(3),
                      );
                    },
                  ),
                  _BoardSizeCard(
                    size: 4,
                    isSelected: state.boardSize == 4,
                    onTap: () {
                      context.read<GameCreationBloc>().add(
                        const BoardSizeSelected(4),
                      );
                    },
                  ),
                  _BoardSizeCard(
                    size: 5,
                    isSelected: state.boardSize == 5,
                    onTap: () {
                      context.read<GameCreationBloc>().add(
                        const BoardSizeSelected(5),
                      );
                    },
                  ),
                ],
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

class _BoardSizeCard extends StatelessWidget {
  const _BoardSizeCard({
    required this.size,
    required this.isSelected,
    required this.onTap,
  });

  final int size;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final totalTiles = size * size;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${size}x$size',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: size,
                  mainAxisSpacing: 3,
                  crossAxisSpacing: 3,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(
                    totalTiles,
                    (_) => Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.3)
                            : Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$totalTiles tiles',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
