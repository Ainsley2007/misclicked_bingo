import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di.dart';
import 'package:frontend/features/auth/logic/auth_bloc.dart';
import 'package:frontend/features/lobby/logic/join_game_bloc.dart';
import 'package:frontend/features/lobby/logic/join_game_event.dart';
import 'package:frontend/features/lobby/logic/join_game_state.dart';
import 'package:shared_models/shared_models.dart';
import 'package:frontend/core/widgets/widgets.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // Redirect users in a game to the game screen
        if (user.gameId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/game/${user.gameId}');
          });
          return const Center(child: CircularProgressIndicator());
        }

        return BlocProvider(
          create: (_) => sl<JoinGameBloc>(),
          child: _JoinGameView(user: user),
        );
      },
    );
  }
}

class _JoinGameView extends StatefulWidget {
  const _JoinGameView({required this.user});
  final AppUser user;

  @override
  State<_JoinGameView> createState() => _JoinGameViewState();
}

class _JoinGameViewState extends State<_JoinGameView> {
  final _codeController = TextEditingController();
  final _teamNameController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _teamNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JoinGameBloc, JoinGameState>(
      listener: (context, state) {
        if (state.status == JoinGameStatus.success && state.game != null) {
          context.read<AuthBloc>().checkAuth();
          context.go('/game/${state.game!.id}');
        } else if (state.status == JoinGameStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Failed to join game'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SectionCard(
              icon: Icons.sports_esports_rounded,
              title: 'Join a Game',
              child: BlocBuilder<JoinGameBloc, JoinGameState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      TextField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: 'Game Code',
                          prefixIcon: Icon(Icons.tag_rounded),
                        ),
                        maxLength: 6,
                        textInputAction: TextInputAction.next,
                        enabled: state.status != JoinGameStatus.loading,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _teamNameController,
                        decoration: const InputDecoration(
                          labelText: 'Team Name',
                          prefixIcon: Icon(Icons.people_rounded),
                        ),
                        enabled: state.status != JoinGameStatus.loading,
                      ),
                      const SizedBox(height: 24),
                      FullWidthButton(
                        onPressed: state.status == JoinGameStatus.loading
                            ? null
                            : () {
                                final code = _codeController.text.trim();
                                final teamName = _teamNameController.text
                                    .trim();
                                if (code.isEmpty || teamName.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please fill in all fields',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                context.read<JoinGameBloc>().add(
                                  JoinGameRequested(
                                    code: code,
                                    teamName: teamName,
                                  ),
                                );
                              },
                        icon: state.status == JoinGameStatus.loading
                            ? null
                            : Icons.login_rounded,
                        label: state.status == JoinGameStatus.loading
                            ? 'Joining...'
                            : 'Join Game',
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
