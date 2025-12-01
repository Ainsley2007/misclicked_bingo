import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/widgets/widgets.dart';
import 'package:frontend/features/game_creation/logic/game_creation_bloc.dart';
import 'package:frontend/features/game_creation/logic/game_creation_event.dart';
import 'package:frontend/features/game_creation/logic/game_creation_state.dart';

class Step1GameName extends StatefulWidget {
  const Step1GameName({super.key});

  @override
  State<Step1GameName> createState() => _Step1GameNameState();
}

class _Step1GameNameState extends State<Step1GameName> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final state = context.read<GameCreationBloc>().state;
    _controller = TextEditingController(text: state.gameName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCreationBloc, GameCreationState>(
      builder: (context, state) {
        return SectionCard(
          icon: Icons.sports_esports_rounded,
          title: 'Game Name',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose a memorable name for your bingo game',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 32),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'e.g., Summer Bingo 2025',
                    prefixIcon: const Icon(Icons.label_rounded),
                    errorText: state.validationError,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    context.read<GameCreationBloc>().add(
                      GameNameChanged(value),
                    );
                  },
                  maxLength: 100,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
