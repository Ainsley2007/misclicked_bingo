// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_team.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Game _$GameFromJson(Map<String, dynamic> json) => Game(
  id: json['id'] as String,
  code: json['code'] as String,
  name: json['name'] as String,
  teamSize: (json['teamSize'] as num).toInt(),
  boardSize: (json['boardSize'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$GameToJson(Game instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'teamSize': instance.teamSize,
  'boardSize': instance.boardSize,
  'createdAt': instance.createdAt.toIso8601String(),
};

Team _$TeamFromJson(Map<String, dynamic> json) => Team(
  id: json['id'] as String,
  gameId: json['gameId'] as String,
  name: json['name'] as String,
  captainUserId: json['captainUserId'] as String,
  color: json['color'] as String? ?? '#4CAF50',
);

Map<String, dynamic> _$TeamToJson(Team instance) => <String, dynamic>{
  'id': instance.id,
  'gameId': instance.gameId,
  'name': instance.name,
  'captainUserId': instance.captainUserId,
  'color': instance.color,
};
