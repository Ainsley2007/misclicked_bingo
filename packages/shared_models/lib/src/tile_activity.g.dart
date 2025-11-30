// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tile_activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TileActivity _$TileActivityFromJson(Map<String, dynamic> json) => TileActivity(
  id: json['id'] as String,
  type: $enumDecode(_$ActivityTypeEnumMap, json['type']),
  userId: json['userId'] as String,
  username: json['username'] as String?,
  userAvatar: json['userAvatar'] as String?,
  tileId: json['tileId'] as String,
  tileName: json['tileName'] as String?,
  tileIconUrl: json['tileIconUrl'] as String?,
  teamId: json['teamId'] as String,
  teamName: json['teamName'] as String?,
  teamColor: json['teamColor'] as String?,
  proofImageUrl: json['proofImageUrl'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$TileActivityToJson(TileActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ActivityTypeEnumMap[instance.type]!,
      'userId': instance.userId,
      'username': instance.username,
      'userAvatar': instance.userAvatar,
      'tileId': instance.tileId,
      'tileName': instance.tileName,
      'tileIconUrl': instance.tileIconUrl,
      'teamId': instance.teamId,
      'teamName': instance.teamName,
      'teamColor': instance.teamColor,
      'proofImageUrl': instance.proofImageUrl,
      'timestamp': instance.timestamp.toIso8601String(),
    };

const _$ActivityTypeEnumMap = {
  ActivityType.proofUploaded: 'proof_uploaded',
  ActivityType.tileCompleted: 'tile_completed',
};
