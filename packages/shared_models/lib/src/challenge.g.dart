// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Challenge _$ChallengeFromJson(Map<String, dynamic> json) => Challenge(
  id: json['id'] as String,
  gameId: json['gameId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  imageUrl: json['imageUrl'] as String,
  unlockAmount: (json['unlockAmount'] as num).toInt(),
);

Map<String, dynamic> _$ChallengeToJson(Challenge instance) => <String, dynamic>{
  'id': instance.id,
  'gameId': instance.gameId,
  'title': instance.title,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
  'unlockAmount': instance.unlockAmount,
};
