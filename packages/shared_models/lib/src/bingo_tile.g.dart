// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bingo_tile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BingoTile _$BingoTileFromJson(Map<String, dynamic> json) => BingoTile(
  id: json['id'] as String,
  gameId: json['gameId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  imageUrl: json['imageUrl'] as String,
  position: (json['position'] as num).toInt(),
);

Map<String, dynamic> _$BingoTileToJson(BingoTile instance) => <String, dynamic>{
  'id': instance.id,
  'gameId': instance.gameId,
  'title': instance.title,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
  'position': instance.position,
};
