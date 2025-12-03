import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/features/lobby/logic/join_game_bloc.dart';
import 'package:frontend/features/lobby/logic/join_game_event.dart';
import 'package:frontend/features/lobby/logic/join_game_state.dart';
import 'package:shared_models/shared_models.dart';
import 'package:frontend/core/widgets/widgets.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: sl<AuthService>().authStream,
      initialData: sl<AuthService>().currentState,
      builder: (context, snapshot) {
        final user = snapshot.data?.user;
        if (user == null) {
          return const SizedBox.expand(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // Redirect users in a game to the game screen
        if (user.gameId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go('/game/${user.gameId}');
            }
          });
          return const SizedBox.expand(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return BlocProvider(
          create: (_) => sl<JoinGameBloc>(),
          child: _JoinGameView(user: user),
        );
      },
    );
  }
}

enum LobbyView { initial, captain, player }

class _JoinGameView extends StatefulWidget {
  const _JoinGameView({required this.user});
  final AppUser user;

  @override
  State<_JoinGameView> createState() => _JoinGameViewState();
}

class _JoinGameViewState extends State<_JoinGameView> {
  LobbyView _currentView = LobbyView.initial;
  final _codeController = TextEditingController();
  final _teamNameController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _teamNameController.dispose();
    super.dispose();
  }

  void _goBack() {
    setState(() {
      _currentView = LobbyView.initial;
      _codeController.clear();
      _teamNameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JoinGameBloc, JoinGameState>(
      listener: (context, state) {
        switch (state) {
          case JoinGameSuccess(:final game):
            sl<AuthService>().checkAuth();
            context.go('/game/${game.id}');
          case JoinGameError(:final message):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          case JoinGameInitial():
          case JoinGameLoading():
            break;
        }
      },
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: _buildCurrentView(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    return switch (_currentView) {
      LobbyView.initial => _buildInitialView(),
      LobbyView.captain => _buildCaptainView(),
      LobbyView.player => _buildPlayerView(),
    };
  }

  Widget _buildInitialView() {
    return SectionCard(
      icon: Icons.sports_esports_rounded,
      title: 'Join a Game',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Are you joining as a team captain or as a regular player?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FullWidthButton(
            onPressed: () {
              setState(() {
                _currentView = LobbyView.captain;
              });
            },
            icon: Icons.person_add_rounded,
            label: 'I\'m a Captain',
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _currentView = LobbyView.player;
                });
              },
              icon: const Icon(Icons.how_to_reg_rounded, size: 20),
              label: const Text('I\'m a Player'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptainView() {
    return SectionCard(
      icon: Icons.person_add_rounded,
      title: 'Join as Captain',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter your game code and team name to join as a captain',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          BlocBuilder<JoinGameBloc, JoinGameState>(
            builder: (context, state) {
              return Column(
                children: [
                  TextField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      labelText: 'Game Code',
                      prefixIcon: const Icon(Icons.tag_rounded),
                      helperText: 'Enter the 6-character game code',
                      errorText:
                          _codeController.text.isNotEmpty &&
                              _codeController.text.length != 6
                          ? 'Game code must be exactly 6 characters'
                          : null,
                    ),
                    maxLength: 6,
                    textInputAction: TextInputAction.next,
                    enabled: state is! JoinGameLoading,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _teamNameController,
                    decoration: const InputDecoration(
                      labelText: 'Team Name',
                      prefixIcon: Icon(Icons.people_rounded),
                      helperText: 'Choose a name for your team',
                    ),
                    enabled: state is! JoinGameLoading,
                  ),
                  const SizedBox(height: 24),
                  FullWidthButton(
                    onPressed: state is JoinGameLoading
                        ? null
                        : () {
                            final code = _codeController.text.trim();
                            final teamName = _teamNameController.text.trim();

                            if (code.isEmpty || teamName.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill in all fields'),
                                ),
                              );
                              return;
                            }

                            if (code.length != 6) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Game code must be exactly 6 characters',
                                  ),
                                ),
                              );
                              return;
                            }

                            context.read<JoinGameBloc>().add(
                              JoinGameRequested(code: code, teamName: teamName),
                            );
                          },
                    icon: state is JoinGameLoading ? null : Icons.login_rounded,
                    label: state is JoinGameLoading
                        ? 'Joining...'
                        : 'Join as Captain',
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _goBack,
                      child: const Text('Back'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerView() {
    return _PlayerWaitingView(onBack: _goBack);
  }
}

class _PlayerWaitingView extends StatefulWidget {
  const _PlayerWaitingView({required this.onBack});

  final VoidCallback onBack;

  @override
  State<_PlayerWaitingView> createState() => _PlayerWaitingViewState();
}

class _PlayerWaitingViewState extends State<_PlayerWaitingView> {
  static const int _maxPolls = 12;
  static const Duration _pollInterval = Duration(seconds: 5);

  Timer? _pollTimer;
  int _pollCount = 0;
  bool _isPolling = false;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _startPolling();
    _authSubscription = sl<AuthService>().authStream.listen(
      _onAuthStateChanged,
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  void _onAuthStateChanged(AuthState state) {
    if (state.user?.teamId != null && mounted) {
      context.go('/game/${state.user!.gameId}');
    }
  }

  void _startPolling() {
    setState(() {
      _pollCount = 0;
      _isPolling = true;
    });

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll());
    _poll();
  }

  Future<void> _poll() async {
    if (!mounted) return;

    await sl<AuthService>().checkAuth();

    if (!mounted) return;

    setState(() {
      _pollCount++;
      if (_pollCount >= _maxPolls) {
        _pollTimer?.cancel();
        _isPolling = false;
      }
    });
  }

  int get _remainingSeconds => (_maxPolls - _pollCount) * 5;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SectionCard(
      icon: Icons.how_to_reg_rounded,
      title: 'Waiting for Invitation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          if (_isPolling) ...[
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: _pollCount / _maxPolls,
                    strokeWidth: 6,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_remainingSeconds}s',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Checking for team invitation...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Auto-refreshing every 5 seconds',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            Icon(
              Icons.refresh_rounded,
              size: 64,
              color: colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Auto-refresh paused',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Click below to check again',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FullWidthButton(
              onPressed: _startPolling,
              icon: Icons.refresh_rounded,
              label: 'Check Again',
            ),
          ],
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ask a team captain to add you from their Manage Team screen',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: widget.onBack,
              child: const Text('Back'),
            ),
          ),
        ],
      ),
    );
  }
}
