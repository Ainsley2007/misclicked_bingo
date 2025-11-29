// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tile_proof.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TileProof _$TileProofFromJson(Map<String, dynamic> json) => TileProof(
  id: json['id'] as String,
  teamId: json['teamId'] as String,
  tileId: json['tileId'] as String,
  imageUrl: json['imageUrl'] as String,
  uploadedByUserId: json['uploadedByUserId'] as String,
  uploadedByUsername: json['uploadedByUsername'] as String?,
  uploadedAt: DateTime.parse(json['uploadedAt'] as String),
);

Map<String, dynamic> _$TileProofToJson(TileProof instance) => <String, dynamic>{
  'id': instance.id,
  'teamId': instance.teamId,
  'tileId': instance.tileId,
  'imageUrl': instance.imageUrl,
  'uploadedByUserId': instance.uploadedByUserId,
  'uploadedByUsername': instance.uploadedByUsername,
  'uploadedAt': instance.uploadedAt.toIso8601String(),
};
