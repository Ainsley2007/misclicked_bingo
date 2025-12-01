import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/widgets/widgets.dart';
import 'package:frontend/features/game_creation/logic/game_creation_bloc.dart';
import 'package:frontend/features/game_creation/logic/game_creation_event.dart';
import 'package:frontend/features/game_creation/logic/game_creation_state.dart';

class Step2TeamSize extends StatefulWidget {
  const Step2TeamSize({super.key});

  @override
  State<Step2TeamSize> createState() => _Step2TeamSizeState();
}

class _Step2TeamSizeState extends State<Step2TeamSize> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final state = context.read<GameCreationBloc>().state;
    _controller = TextEditingController(text: state.teamSize.toString());
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
          icon: Icons.groups_rounded,
          title: 'Team Size',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'How many players can join each team?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 32),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Maximum team size (e.g., 5)',
                    prefixIcon: const Icon(Icons.people_rounded),
                    helperText: 'Between 1 and 50 players',
                    errorText: state.validationError,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    final size = int.tryParse(value);
                    if (size != null) {
                      context.read<GameCreationBloc>().add(
                        TeamSizeChanged(size),
                      );
                    }
                  },
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 32),
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
