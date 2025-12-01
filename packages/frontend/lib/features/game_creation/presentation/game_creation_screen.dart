import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di.dart';
import 'package:frontend/features/game_creation/logic/game_creation_bloc.dart';
import 'package:frontend/features/game_creation/logic/game_creation_state.dart';
import 'package:frontend/features/game_creation/presentation/widgets/wizard_step_indicator.dart';
import 'package:frontend/features/game_creation/presentation/widgets/step_1_game_name.dart';
import 'package:frontend/features/game_creation/presentation/widgets/step_2_game_mode.dart';
import 'package:frontend/features/game_creation/presentation/widgets/step_2_team_size.dart';
import 'package:frontend/features/game_creation/presentation/widgets/step_4_board_size.dart';
import 'package:frontend/features/game_creation/presentation/widgets/step_6_tiles.dart';
import 'package:frontend/features/game_creation/presentation/widgets/step_7_summary.dart';
import 'package:go_router/go_router.dart';

class GameCreationScreen extends StatelessWidget {
  const GameCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GameCreationBloc>(),
      child: const _GameCreationContent(),
    );
  }
}

class _GameCreationContent extends StatelessWidget {
  const _GameCreationContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameCreationBloc, GameCreationState>(
      listener: (context, state) {
        if (state.status == GameCreationStatus.success &&
            state.createdGame != null) {
          _showSuccessDialog(context, state.createdGame!.code);
        } else if (state.status == GameCreationStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? 'Failed to create game'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create New Game',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  WizardStepIndicator(
                    currentStep: state.currentStep,
                    totalSteps: state.totalSteps,
                  ),
                  const SizedBox(height: 32),
                  _buildCurrentStep(state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentStep(GameCreationState state) {
    return switch (state.currentStep) {
      1 => const Step1GameName(),
      2 => const Step2GameMode(),
      3 => const Step2TeamSize(),
      4 => const Step4BoardSize(),
      5 => const Step6Tiles(),
      _ => const Step7Summary(),
    };
  }

  void _showSuccessDialog(BuildContext context, String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            const Text('Game Created!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Your game has been created successfully!'),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Game Code',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        code,
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 8,
                            ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Code copied to clipboard!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        tooltip: 'Copy code',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.go('/admin/games');
            },
            child: const Text('Back to Games'),
          ),
        ],
      ),
    );
  }
}
