// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_tile_creation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameTileCreation _$GameTileCreationFromJson(Map<String, dynamic> json) =>
    GameTileCreation(
      bossId: json['bossId'] as String?,
      description: json['description'] as String?,
      uniqueItems:
          (json['uniqueItems'] as List<dynamic>?)
              ?.map((e) => TileUniqueItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isAnyUnique: json['isAnyUnique'] as bool? ?? false,
      isOrLogic: json['isOrLogic'] as bool? ?? false,
      anyNCount: (json['anyNCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$GameTileCreationToJson(GameTileCreation instance) =>
    <String, dynamic>{
      'bossId': instance.bossId,
      'description': instance.description,
      'uniqueItems': instance.uniqueItems,
      'isAnyUnique': instance.isAnyUnique,
      'isOrLogic': instance.isOrLogic,
      'anyNCount': instance.anyNCount,
    };
