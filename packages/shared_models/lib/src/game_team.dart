import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'game_team.g.dart';

enum GameMode {
  blackout,
  points;

  String get value => name;

  static GameMode fromString(String value) {
    return GameMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => GameMode.blackout,
    );
  }
}

@JsonSerializable()
class Game extends Equatable {
  final String id;
  final String code;
  final String name;
  final int teamSize;
  final int boardSize;
  @JsonKey(fromJson: _gameModeFromJson, toJson: _gameModeToJson)
  final GameMode gameMode;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime createdAt;

  const Game({
    required this.id,
    required this.code,
    required this.name,
    required this.teamSize,
    required this.boardSize,
    this.gameMode = GameMode.blackout,
    this.startTime,
    this.endTime,
    required this.createdAt,
  });

  static GameMode _gameModeFromJson(String? json) =>
      json != null ? GameMode.fromString(json) : GameMode.blackout;
  static String _gameModeToJson(GameMode mode) => mode.value;

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
  Map<String, dynamic> toJson() => _$GameToJson(this);

  bool get hasStarted => startTime == null || DateTime.now().isAfter(startTime!);
  bool get hasEnded => endTime != null && DateTime.now().isAfter(endTime!);
  bool get isActive => hasStarted && !hasEnded;

  @override
  List<Object?> get props => [id, code, name, teamSize, boardSize, gameMode, startTime, endTime];
}

@JsonSerializable()
class Team extends Equatable {
  final String id;
  final String gameId;
  final String name;
  final String captainUserId;
  final String color;

  const Team({
    required this.id,
    required this.gameId,
    required this.name,
    required this.captainUserId,
    this.color = '#4CAF50',
  });

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
  Map<String, dynamic> toJson() => _$TeamToJson(this);

  @override
  List<Object?> get props => [id, gameId, name, captainUserId, color];
}
