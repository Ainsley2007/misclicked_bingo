// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proof_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserStats _$UserStatsFromJson(Map<String, dynamic> json) => UserStats(
  userId: json['userId'] as String,
  username: json['username'] as String?,
  avatar: json['avatar'] as String?,
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$UserStatsToJson(UserStats instance) => <String, dynamic>{
  'userId': instance.userId,
  'username': instance.username,
  'avatar': instance.avatar,
  'count': instance.count,
};

ProofStats _$ProofStatsFromJson(Map<String, dynamic> json) => ProofStats(
  topProofUploaders: (json['topProofUploaders'] as List<dynamic>)
      .map((e) => UserStats.fromJson(e as Map<String, dynamic>))
      .toList(),
  topTileCompleters: (json['topTileCompleters'] as List<dynamic>)
      .map((e) => UserStats.fromJson(e as Map<String, dynamic>))
      .toList(),
  topPointsContributors:
      (json['topPointsContributors'] as List<dynamic>?)
          ?.map((e) => UserStats.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  totalProofs: (json['totalProofs'] as num).toInt(),
  totalCompletions: (json['totalCompletions'] as num).toInt(),
  totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ProofStatsToJson(ProofStats instance) =>
    <String, dynamic>{
      'topProofUploaders': instance.topProofUploaders,
      'topTileCompleters': instance.topTileCompleters,
      'topPointsContributors': instance.topPointsContributors,
      'totalProofs': instance.totalProofs,
      'totalCompletions': instance.totalCompletions,
      'totalPoints': instance.totalPoints,
    };
