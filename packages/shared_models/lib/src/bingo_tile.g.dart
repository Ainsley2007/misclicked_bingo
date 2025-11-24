// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bingo_tile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BingoTile _$BingoTileFromJson(Map<String, dynamic> json) => BingoTile(
  id: json['id'] as String,
  gameId: json['gameId'] as String,
  bossId: json['bossId'] as String,
  description: json['description'] as String?,
  position: (json['position'] as num).toInt(),
  bossName: json['bossName'] as String?,
  bossType: BingoTile._typeFromJson(json['bossType'] as String?),
  bossIconUrl: json['bossIconUrl'] as String?,
  uniqueItems:
      (json['uniqueItems'] as List<dynamic>?)
          ?.map((e) => TileUniqueItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  isAnyUnique: json['isAnyUnique'] as bool? ?? false,
  isOrLogic: json['isOrLogic'] as bool? ?? false,
  anyNCount: (json['anyNCount'] as num?)?.toInt(),
  isCompleted: json['isCompleted'] as bool? ?? false,
);

Map<String, dynamic> _$BingoTileToJson(BingoTile instance) => <String, dynamic>{
  'id': instance.id,
  'gameId': instance.gameId,
  'bossId': instance.bossId,
  'description': instance.description,
  'position': instance.position,
  'bossName': instance.bossName,
  'bossType': BingoTile._typeToJson(instance.bossType),
  'bossIconUrl': instance.bossIconUrl,
  'uniqueItems': instance.uniqueItems,
  'isAnyUnique': instance.isAnyUnique,
  'isOrLogic': instance.isOrLogic,
  'anyNCount': instance.anyNCount,
  'isCompleted': instance.isCompleted,
};
