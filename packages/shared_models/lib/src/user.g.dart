// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppUser _$AppUserFromJson(Map<String, dynamic> json) => AppUser(
  id: json['id'] as String,
  discordId: json['discordId'] as String,
  globalName: json['globalName'] as String?,
  username: json['username'] as String?,
  avatar: json['avatar'] as String?,
  role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ?? UserRole.user,
  teamId: json['teamId'] as String?,
  gameId: json['gameId'] as String?,
);

Map<String, dynamic> _$AppUserToJson(AppUser instance) => <String, dynamic>{
  'id': instance.id,
  'discordId': instance.discordId,
  'globalName': instance.globalName,
  'username': instance.username,
  'avatar': instance.avatar,
  'role': _$UserRoleEnumMap[instance.role]!,
  'teamId': instance.teamId,
  'gameId': instance.gameId,
};

const _$UserRoleEnumMap = {
  UserRole.user: 'user',
  UserRole.captain: 'captain',
  UserRole.admin: 'admin',
};
