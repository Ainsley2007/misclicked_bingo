import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/bosses/data/boss_repository.dart';
import 'package:frontend/features/game_creation/data/game_creation_repository.dart';
import 'package:frontend/features/game_creation/logic/game_creation_event.dart';
import 'package:frontend/features/game_creation/logic/game_creation_state.dart';
import 'package:shared_models/shared_models.dart';

class GameCreationBloc extends Bloc<GameCreationEvent, GameCreationState> {
  GameCreationBloc(this._repository, this._bossRepository)
    : super(const GameCreationState.initial()) {
    on<NextStepRequested>(_onNextStepRequested);
    on<PreviousStepRequested>(_onPreviousStepRequested);
    on<JumpToStepRequested>(_onJumpToStepRequested);
    on<GameNameChanged>(_onGameNameChanged);
    on<TeamSizeChanged>(_onTeamSizeChanged);
    on<BoardSizeSelected>(_onBoardSizeSelected);
    on<TileAdded>(_onTileAdded);
    on<TileUpdated>(_onTileUpdated);
    on<TileRemoved>(_onTileRemoved);
    on<GameSubmitted>(_onGameSubmitted);
    on<BossesLoadRequested>(_onBossesLoadRequested);
  }

  final GameCreationRepository _repository;
  final BossRepository _bossRepository;

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
    if (nextStep <= state.totalSteps) {
      emit(state.clearError().copyWith(currentStep: nextStep));
    }
  }

  void _onPreviousStepRequested(
    PreviousStepRequested event,
    Emitter<GameCreationState> emit,
  ) {
    final previousStep = state.currentStep - 1;
    if (previousStep >= 1) {
      emit(state.clearError().copyWith(currentStep: previousStep));
    }
  }

  void _onJumpToStepRequested(
    JumpToStepRequested event,
    Emitter<GameCreationState> emit,
  ) {
    if (event.step >= 1 && event.step <= state.totalSteps) {
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

  void _onBoardSizeSelected(
    BoardSizeSelected event,
    Emitter<GameCreationState> emit,
  ) {
    emit(state.copyWith(boardSize: event.size, tiles: []));
  }

  void _onTileAdded(TileAdded event, Emitter<GameCreationState> emit) {
    final newTiles = List<GameTileCreation>.from(state.tiles)
      ..add(const GameTileCreation());
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
        boardSize: state.boardSize,
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
      _ => false,
    };
  }

  String _getValidationError(GameCreationState state) {
    return switch (state.currentStep) {
      1 => 'Please enter a game name',
      2 => 'Team size must be between 1 and 50',
      3 => 'Please select a board size',
      4 => state.tileValidationError,
      _ => 'Please complete this step',
    };
  }

  bool _canSubmit(GameCreationState state) {
    return state.isGameNameValid &&
        state.isTeamSizeValid &&
        state.isBoardSizeValid &&
        state.areTilesValid;
  }

  Future<void> _onBossesLoadRequested(
    BossesLoadRequested event,
    Emitter<GameCreationState> emit,
  ) async {
    if (state.bosses.isNotEmpty) {
      return;
    }

    emit(state.copyWith(isLoadingBosses: true));

    try {
      final bosses = await _bossRepository.getAllBosses();
      emit(state.copyWith(bosses: bosses, isLoadingBosses: false));
    } catch (e) {
      emit(state.copyWith(isLoadingBosses: false, error: e.toString()));
    }
  }
}
