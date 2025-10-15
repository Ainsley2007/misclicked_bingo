import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'game_team.g.dart';

@JsonSerializable()
class Game extends Equatable {
  final String id;
  final String code;
  final String name;
  final int teamSize;
  final bool hasChallenges;
  final int boardSize;
  final DateTime createdAt;

  const Game({
    required this.id,
    required this.code,
    required this.name,
    required this.teamSize,
    required this.hasChallenges,
    required this.boardSize,
    required this.createdAt,
  });

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
  Map<String, dynamic> toJson() => _$GameToJson(this);

  @override
  List<Object?> get props => [
    id,
    code,
    name,
    teamSize,
    hasChallenges,
    boardSize,
  ];
}

@JsonSerializable()
class Team extends Equatable {
  final String id;
  final String gameId;
  final String name;
  final String captainUserId;

  const Team({
    required this.id,
    required this.gameId,
    required this.name,
    required this.captainUserId,
  });

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
  Map<String, dynamic> toJson() => _$TeamToJson(this);

  @override
  List<Object?> get props => [id, gameId, name, captainUserId];
}
