import 'package:flutter/foundation.dart';
import 'package:shared_models/shared_models.dart';

enum GameCreationStatus { editing, submitting, success, error }

@immutable
final class GameCreationState {
  const GameCreationState._({
    required this.currentStep,
    required this.status,
    this.gameName = '',
    this.teamSize = 5,
    this.boardSize = 3,
    this.gameMode = GameMode.blackout,
    this.startTime,
    this.endTime,
    this.tiles = const [],
    this.bosses = const [],
    this.isLoadingBosses = false,
    this.validationError,
    this.createdGame,
    this.error,
  });

  const GameCreationState.initial()
    : this._(currentStep: 1, status: GameCreationStatus.editing);

  final int currentStep;
  final GameCreationStatus status;
  final String gameName;
  final int teamSize;
  final int boardSize;
  final GameMode gameMode;
  final DateTime? startTime;
  final DateTime? endTime;
  final List<GameTileCreation> tiles;
  final List<Boss> bosses;
  final bool isLoadingBosses;
  final String? validationError;
  final Game? createdGame;
  final String? error;

  GameCreationState copyWith({
    int? currentStep,
    GameCreationStatus? status,
    String? gameName,
    int? teamSize,
    int? boardSize,
    GameMode? gameMode,
    DateTime? startTime,
    bool clearStartTime = false,
    DateTime? endTime,
    bool clearEndTime = false,
    List<GameTileCreation>? tiles,
    List<Boss>? bosses,
    bool? isLoadingBosses,
    String? validationError,
    Game? createdGame,
    String? error,
  }) {
    return GameCreationState._(
      currentStep: currentStep ?? this.currentStep,
      status: status ?? this.status,
      gameName: gameName ?? this.gameName,
      teamSize: teamSize ?? this.teamSize,
      boardSize: boardSize ?? this.boardSize,
      gameMode: gameMode ?? this.gameMode,
      startTime: clearStartTime ? null : (startTime ?? this.startTime),
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
      tiles: tiles ?? this.tiles,
      bosses: bosses ?? this.bosses,
      isLoadingBosses: isLoadingBosses ?? this.isLoadingBosses,
      validationError: validationError,
      createdGame: createdGame ?? this.createdGame,
      error: error,
    );
  }

  GameCreationState clearError() {
    return GameCreationState._(
      currentStep: currentStep,
      status: status,
      gameName: gameName,
      teamSize: teamSize,
      boardSize: boardSize,
      gameMode: gameMode,
      startTime: startTime,
      endTime: endTime,
      tiles: tiles,
      bosses: bosses,
      isLoadingBosses: isLoadingBosses,
      validationError: null,
      createdGame: createdGame,
      error: null,
    );
  }

  bool get isGameNameValid => gameName.trim().isNotEmpty;
  bool get isTeamSizeValid => teamSize >= 1 && teamSize <= 50;
  bool get isBoardSizeValid => [2, 3, 4, 5].contains(boardSize);
  bool get isPointsMode => gameMode == GameMode.points;

  bool get areTilesValid {
    if (tiles.length != boardSize * boardSize) {
      return false;
    }
    for (final tile in tiles) {
      if (tile.bossId == null || tile.bossId!.trim().isEmpty) {
        return false;
      }
      if (!tile.isAnyUnique && tile.uniqueItems.isEmpty) {
        return false;
      }
      if (isPointsMode && tile.points <= 0) {
        return false;
      }
    }
    return true;
  }

  bool get canProceedFromStep1 => isGameNameValid;
  bool get canProceedFromStep2 => true; // Game mode step - always valid
  bool get canProceedFromStep3 => isTeamSizeValid;
  bool get canProceedFromStep4 => isBoardSizeValid;
  bool get canProceedFromStep5 => areTilesValid;
  bool get canProceedFromStep6 => true;

  int get totalSteps => 6;

  String get tileValidationError {
    if (tiles.length != boardSize * boardSize) {
      return 'You need exactly ${boardSize * boardSize} tiles';
    }
    for (var i = 0; i < tiles.length; i++) {
      final tile = tiles[i];
      if (tile.bossId == null || tile.bossId!.trim().isEmpty) {
        return 'Tile ${i + 1} is missing a boss selection';
      }
      if (!tile.isAnyUnique && tile.uniqueItems.isEmpty) {
        return 'Tile ${i + 1} must have at least one unique item selected or use "Any Unique" option';
      }
      if (isPointsMode && tile.points <= 0) {
        return 'Tile ${i + 1} must have points > 0 for points mode';
      }
    }
    return 'You need exactly ${boardSize * boardSize} tiles';
  }
}
