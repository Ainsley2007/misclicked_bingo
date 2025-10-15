import 'package:equatable/equatable.dart';
import 'package:shared_models/shared_models.dart';

enum GameCreationStatus { editing, submitting, success, error }

final class GameCreationState extends Equatable {
  const GameCreationState._({
    required this.currentStep,
    required this.status,
    this.gameName = '',
    this.teamSize = 5,
    this.hasChallenges = false,
    this.boardSize = 3,
    this.challenges = const [],
    this.tiles = const [],
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
  final bool hasChallenges;
  final int boardSize;
  final List<Map<String, dynamic>> challenges;
  final List<Map<String, dynamic>> tiles;
  final String? validationError;
  final Game? createdGame;
  final String? error;

  GameCreationState copyWith({
    int? currentStep,
    GameCreationStatus? status,
    String? gameName,
    int? teamSize,
    bool? hasChallenges,
    int? boardSize,
    List<Map<String, dynamic>>? challenges,
    List<Map<String, dynamic>>? tiles,
    String? validationError,
    Game? createdGame,
    String? error,
  }) {
    return GameCreationState._(
      currentStep: currentStep ?? this.currentStep,
      status: status ?? this.status,
      gameName: gameName ?? this.gameName,
      teamSize: teamSize ?? this.teamSize,
      hasChallenges: hasChallenges ?? this.hasChallenges,
      boardSize: boardSize ?? this.boardSize,
      challenges: challenges ?? this.challenges,
      tiles: tiles ?? this.tiles,
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
      hasChallenges: hasChallenges,
      boardSize: boardSize,
      challenges: challenges,
      tiles: tiles,
      validationError: null,
      createdGame: createdGame,
      error: null,
    );
  }

  bool get isGameNameValid => gameName.trim().isNotEmpty;
  bool get isTeamSizeValid => teamSize >= 1 && teamSize <= 50;
  bool get isBoardSizeValid => [2, 3, 4, 5].contains(boardSize);

  bool get areChallengesValid {
    if (!hasChallenges) return true;
    if (challenges.isEmpty) return false;

    final totalUnlock = challenges.fold<int>(
      0,
      (sum, c) => sum + ((c['unlockAmount'] as int?) ?? 0),
    );
    final requiredTiles = boardSize * boardSize;
    return totalUnlock >= requiredTiles;
  }

  bool get areTilesValid => tiles.length == boardSize * boardSize;

  bool get canProceedFromStep1 => isGameNameValid;
  bool get canProceedFromStep2 => isTeamSizeValid;
  bool get canProceedFromStep3 => true;
  bool get canProceedFromStep4 => isBoardSizeValid;
  bool get canProceedFromStep5 => !hasChallenges || areChallengesValid;
  bool get canProceedFromStep6 => areTilesValid;

  int get totalSteps => hasChallenges ? 7 : 6;

  int get effectiveStep {
    if (currentStep <= 4) return currentStep;
    if (!hasChallenges && currentStep > 4) return currentStep - 1;
    return currentStep;
  }

  @override
  List<Object?> get props => [
    currentStep,
    status,
    gameName,
    teamSize,
    hasChallenges,
    boardSize,
    challenges,
    tiles,
    validationError,
    createdGame,
    error,
  ];
}
