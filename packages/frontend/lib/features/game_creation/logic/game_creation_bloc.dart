import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/game_creation/data/game_creation_repository.dart';
import 'package:frontend/features/game_creation/logic/game_creation_event.dart';
import 'package:frontend/features/game_creation/logic/game_creation_state.dart';

class GameCreationBloc extends Bloc<GameCreationEvent, GameCreationState> {
  GameCreationBloc(this._repository)
    : super(const GameCreationState.initial()) {
    on<NextStepRequested>(_onNextStepRequested);
    on<PreviousStepRequested>(_onPreviousStepRequested);
    on<JumpToStepRequested>(_onJumpToStepRequested);
    on<GameNameChanged>(_onGameNameChanged);
    on<TeamSizeChanged>(_onTeamSizeChanged);
    on<ChallengeToggleChanged>(_onChallengeToggleChanged);
    on<BoardSizeSelected>(_onBoardSizeSelected);
    on<ChallengeAdded>(_onChallengeAdded);
    on<ChallengeUpdated>(_onChallengeUpdated);
    on<ChallengeRemoved>(_onChallengeRemoved);
    on<TileAdded>(_onTileAdded);
    on<TileUpdated>(_onTileUpdated);
    on<TileRemoved>(_onTileRemoved);
    on<GameSubmitted>(_onGameSubmitted);
  }

  final GameCreationRepository _repository;

  Future<void> _onNextStepRequested(
    NextStepRequested event,
    Emitter<GameCreationState> emit,
  ) async {
    final canProceed = _canProceedFromCurrentStep(state);
    if (!canProceed) {
      emit(state.copyWith(validationError: _getValidationError(state)));
      return;
    }

    final nextStep = state.currentStep + 1;
    if (state.currentStep == 4 && !state.hasChallenges) {
      emit(state.clearError().copyWith(currentStep: 6));
    } else if (nextStep <= 7) {
      emit(state.clearError().copyWith(currentStep: nextStep));
    }
  }

  void _onPreviousStepRequested(
    PreviousStepRequested event,
    Emitter<GameCreationState> emit,
  ) {
    final previousStep = state.currentStep - 1;
    if (state.currentStep == 6 && !state.hasChallenges) {
      emit(state.clearError().copyWith(currentStep: 4));
    } else if (previousStep >= 1) {
      emit(state.clearError().copyWith(currentStep: previousStep));
    }
  }

  void _onJumpToStepRequested(
    JumpToStepRequested event,
    Emitter<GameCreationState> emit,
  ) {
    if (event.step >= 1 && event.step <= 7) {
      emit(state.clearError().copyWith(currentStep: event.step));
    }
  }

  void _onGameNameChanged(
    GameNameChanged event,
    Emitter<GameCreationState> emit,
  ) {
    emit(state.copyWith(gameName: event.name));
  }

  void _onTeamSizeChanged(
    TeamSizeChanged event,
    Emitter<GameCreationState> emit,
  ) {
    emit(state.copyWith(teamSize: event.size));
  }

  void _onChallengeToggleChanged(
    ChallengeToggleChanged event,
    Emitter<GameCreationState> emit,
  ) {
    emit(state.copyWith(hasChallenges: event.enabled, challenges: []));
  }

  void _onBoardSizeSelected(
    BoardSizeSelected event,
    Emitter<GameCreationState> emit,
  ) {
    emit(state.copyWith(boardSize: event.size, tiles: []));
  }

  void _onChallengeAdded(
    ChallengeAdded event,
    Emitter<GameCreationState> emit,
  ) {
    final newChallenges = List<Map<String, dynamic>>.from(
      state.challenges,
    )..add({'title': '', 'description': '', 'imageUrl': '', 'unlockAmount': 1});
    emit(state.copyWith(challenges: newChallenges));
  }

  void _onChallengeUpdated(
    ChallengeUpdated event,
    Emitter<GameCreationState> emit,
  ) {
    final newChallenges = List<Map<String, dynamic>>.from(state.challenges);
    if (event.index >= 0 && event.index < newChallenges.length) {
      newChallenges[event.index] = event.data;
      emit(state.copyWith(challenges: newChallenges));
    }
  }

  void _onChallengeRemoved(
    ChallengeRemoved event,
    Emitter<GameCreationState> emit,
  ) {
    final newChallenges = List<Map<String, dynamic>>.from(state.challenges);
    if (event.index >= 0 && event.index < newChallenges.length) {
      newChallenges.removeAt(event.index);
      emit(state.copyWith(challenges: newChallenges));
    }
  }

  void _onTileAdded(TileAdded event, Emitter<GameCreationState> emit) {
    final newTiles = List<Map<String, dynamic>>.from(state.tiles)
      ..add({'title': '', 'description': '', 'imageUrl': ''});
    emit(state.copyWith(tiles: newTiles));
  }

  void _onTileUpdated(TileUpdated event, Emitter<GameCreationState> emit) {
    final newTiles = List<Map<String, dynamic>>.from(state.tiles);
    if (event.index >= 0 && event.index < newTiles.length) {
      newTiles[event.index] = event.data;
      emit(state.copyWith(tiles: newTiles));
    }
  }

  void _onTileRemoved(TileRemoved event, Emitter<GameCreationState> emit) {
    final newTiles = List<Map<String, dynamic>>.from(state.tiles);
    if (event.index >= 0 && event.index < newTiles.length) {
      newTiles.removeAt(event.index);
      emit(state.copyWith(tiles: newTiles));
    }
  }

  Future<void> _onGameSubmitted(
    GameSubmitted event,
    Emitter<GameCreationState> emit,
  ) async {
    if (!_canSubmit(state)) {
      emit(
        state.copyWith(validationError: 'Please complete all required fields'),
      );
      return;
    }

    emit(state.copyWith(status: GameCreationStatus.submitting));

    try {
      final game = await _repository.createGame(
        name: state.gameName,
        teamSize: state.teamSize,
        hasChallenges: state.hasChallenges,
        boardSize: state.boardSize,
        challenges: state.challenges,
        tiles: state.tiles,
      );

      emit(
        state.copyWith(status: GameCreationStatus.success, createdGame: game),
      );
    } catch (e) {
      emit(
        state.copyWith(status: GameCreationStatus.error, error: e.toString()),
      );
    }
  }

  bool _canProceedFromCurrentStep(GameCreationState state) {
    return switch (state.currentStep) {
      1 => state.canProceedFromStep1,
      2 => state.canProceedFromStep2,
      3 => state.canProceedFromStep3,
      4 => state.canProceedFromStep4,
      5 => state.canProceedFromStep5,
      6 => state.canProceedFromStep6,
      _ => false,
    };
  }

  String _getValidationError(GameCreationState state) {
    return switch (state.currentStep) {
      1 => 'Please enter a game name',
      2 => 'Team size must be between 1 and 50',
      4 => 'Please select a board size',
      5 =>
        state.hasChallenges && state.challenges.isEmpty
            ? 'Add at least one challenge'
            : 'Total unlock amount must be at least ${state.boardSize * state.boardSize}',
      6 => 'You need exactly ${state.boardSize * state.boardSize} tiles',
      _ => 'Please complete this step',
    };
  }

  bool _canSubmit(GameCreationState state) {
    return state.isGameNameValid &&
        state.isTeamSizeValid &&
        state.isBoardSizeValid &&
        state.areChallengesValid &&
        state.areTilesValid;
  }
}
