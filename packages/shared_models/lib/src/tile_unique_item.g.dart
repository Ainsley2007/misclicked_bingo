// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tile_unique_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TileUniqueItem _$TileUniqueItemFromJson(Map<String, dynamic> json) =>
    TileUniqueItem(
      itemName: json['itemName'] as String,
      requiredCount: (json['requiredCount'] as num).toInt(),
    );

Map<String, dynamic> _$TileUniqueItemToJson(TileUniqueItem instance) =>
    <String, dynamic>{
      'itemName': instance.itemName,
      'requiredCount': instance.requiredCount,
    };
