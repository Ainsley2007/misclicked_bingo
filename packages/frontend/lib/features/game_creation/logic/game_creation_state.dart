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

  bool get areTilesValid {
    if (tiles.length != boardSize * boardSize) {
      return false;
    }
    // Check that each tile has a bossId and at least one unique item (or isAnyUnique is true)
    for (final tile in tiles) {
      if (tile.bossId == null || tile.bossId!.trim().isEmpty) {
        return false;
      }
      if (!tile.isAnyUnique && tile.uniqueItems.isEmpty) {
        return false;
      }
    }
    return true;
  }

  bool get canProceedFromStep1 => isGameNameValid;
  bool get canProceedFromStep2 => isTeamSizeValid;
  bool get canProceedFromStep3 => isBoardSizeValid;
  bool get canProceedFromStep4 => areTilesValid;
  bool get canProceedFromStep5 => true;

  int get totalSteps => 5;

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
    }
    return 'You need exactly ${boardSize * boardSize} tiles';
  }
}
