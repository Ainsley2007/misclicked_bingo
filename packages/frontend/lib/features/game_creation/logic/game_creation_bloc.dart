import 'package:frontend/core/bloc/base_bloc.dart';
import 'package:frontend/repositories/bosses_repository.dart';
import 'package:frontend/repositories/games_repository.dart';
import 'package:frontend/features/game_creation/logic/game_creation_event.dart';
import 'package:frontend/features/game_creation/logic/game_creation_state.dart';
import 'package:shared_models/shared_models.dart';

class GameCreationBloc extends BaseBloc<GameCreationEvent, GameCreationState> {
  GameCreationBloc(this._repository, this._bossRepository) : super(const GameCreationState.initial()) {
    on<NextStepRequested>(_onNextStepRequested);
    on<PreviousStepRequested>(_onPreviousStepRequested);
    on<JumpToStepRequested>(_onJumpToStepRequested);
    on<GameNameChanged>(_onGameNameChanged);
    on<GameModeChanged>(_onGameModeChanged);
    on<StartTimeChanged>(_onStartTimeChanged);
    on<EndTimeChanged>(_onEndTimeChanged);
    on<TeamSizeChanged>(_onTeamSizeChanged);
    on<BoardSizeSelected>(_onBoardSizeSelected);
    on<TileAdded>(_onTileAdded);
    on<TileUpdated>(_onTileUpdated);
    on<TileRemoved>(_onTileRemoved);
    onDroppable<GameSubmitted>(_onGameSubmitted);
    on<BossesLoadRequested>(_onBossesLoadRequested);
  }

  final GamesRepository _repository;
  final BossesRepository _bossRepository;

  Future<void> _onNextStepRequested(NextStepRequested event, Emitter<GameCreationState> emit) async {
    final canProceed = _canProceedFromCurrentStep(state);
    if (!canProceed) {
      emit(state.copyWith(validationError: _getValidationError(state)));
      return;
    }

    final nextStep = state.currentStep + 1;
    if (nextStep <= state.totalSteps) {
      emit(state.clearError().copyWith(currentStep: nextStep));
    }
  }

  void _onPreviousStepRequested(PreviousStepRequested event, Emitter<GameCreationState> emit) {
    final previousStep = state.currentStep - 1;
    if (previousStep >= 1) {
      emit(state.clearError().copyWith(currentStep: previousStep));
    }
  }

  void _onJumpToStepRequested(JumpToStepRequested event, Emitter<GameCreationState> emit) {
    if (event.step >= 1 && event.step <= state.totalSteps) {
      emit(state.clearError().copyWith(currentStep: event.step));
    }
  }

  void _onGameNameChanged(GameNameChanged event, Emitter<GameCreationState> emit) {
    emit(state.copyWith(gameName: event.name));
  }

  void _onTeamSizeChanged(TeamSizeChanged event, Emitter<GameCreationState> emit) {
    emit(state.copyWith(teamSize: event.size));
  }

  void _onBoardSizeSelected(BoardSizeSelected event, Emitter<GameCreationState> emit) {
    emit(state.copyWith(boardSize: event.size, tiles: []));
  }

  void _onGameModeChanged(GameModeChanged event, Emitter<GameCreationState> emit) {
    emit(state.copyWith(gameMode: event.mode));
  }

  void _onStartTimeChanged(StartTimeChanged event, Emitter<GameCreationState> emit) {
    if (event.startTime == null) {
      emit(state.copyWith(clearStartTime: true));
    } else {
      emit(state.copyWith(startTime: event.startTime));
    }
  }

  void _onEndTimeChanged(EndTimeChanged event, Emitter<GameCreationState> emit) {
    if (event.endTime == null) {
      emit(state.copyWith(clearEndTime: true));
    } else {
      emit(state.copyWith(endTime: event.endTime));
    }
  }

  void _onTileAdded(TileAdded event, Emitter<GameCreationState> emit) {
    final newTiles = List<GameTileCreation>.from(state.tiles)..add(const GameTileCreation());
    emit(state.copyWith(tiles: newTiles));
  }

  void _onTileUpdated(TileUpdated event, Emitter<GameCreationState> emit) {
    final newTiles = List<GameTileCreation>.from(state.tiles);
    if (event.index >= 0 && event.index < newTiles.length) {
      newTiles[event.index] = event.tile;
      emit(state.copyWith(tiles: newTiles));
    }
  }

  void _onTileRemoved(TileRemoved event, Emitter<GameCreationState> emit) {
    final newTiles = List<GameTileCreation>.from(state.tiles);
    if (event.index >= 0 && event.index < newTiles.length) {
      newTiles.removeAt(event.index);
      emit(state.copyWith(tiles: newTiles));
    }
  }

  Future<void> _onGameSubmitted(GameSubmitted event, Emitter<GameCreationState> emit) async {
    if (!_canSubmit(state)) {
      emit(state.copyWith(validationError: 'Please complete all required fields'));
      return;
    }

    emit(state.copyWith(status: GameCreationStatus.submitting));

    await executeWithResult(
      action: () => _repository.createGame(
        name: state.gameName,
        teamSize: state.teamSize,
        boardSize: state.boardSize,
        gameMode: state.gameMode,
        startTime: state.startTime,
        endTime: state.endTime,
        tiles: state.tiles,
      ),
      onSuccess: (game) => emit(state.copyWith(status: GameCreationStatus.success, createdGame: game)),
      onError: (message) => emit(state.copyWith(status: GameCreationStatus.error, error: message)),
      context: 'game_creation',
      errorMessages: BlocErrorHandlerMixin.validationErrors,
      defaultMessage: 'Failed to create game',
    );
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
      2 => 'Please select a game mode',
      3 => 'Team size must be between 1 and 50',
      4 => 'Please select a board size',
      5 => state.tileValidationError,
      _ => 'Please complete this step',
    };
  }

  bool _canSubmit(GameCreationState state) {
    return state.isGameNameValid && state.isTeamSizeValid && state.isBoardSizeValid && state.areTilesValid;
  }

  Future<void> _onBossesLoadRequested(BossesLoadRequested event, Emitter<GameCreationState> emit) async {
    if (state.bosses.isNotEmpty) return;

    emit(state.copyWith(isLoadingBosses: true));

    await executeWithResult(
      action: () => _bossRepository.getBosses(),
      onSuccess: (bosses) => emit(state.copyWith(bosses: bosses, isLoadingBosses: false)),
      onError: (message) => emit(state.copyWith(isLoadingBosses: false, error: message)),
      context: 'game_creation',
      defaultMessage: 'Failed to load bosses',
    );
  }
}
