import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'proof_stats.g.dart';

@JsonSerializable()
class UserStats extends Equatable {
  final String userId;
  final String? username;
  final String? avatar;
  final int count;

  const UserStats({
    required this.userId,
    this.username,
    this.avatar,
    required this.count,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);
  Map<String, dynamic> toJson() => _$UserStatsToJson(this);

  @override
  List<Object?> get props => [userId, count];
}

@JsonSerializable()
class ProofStats extends Equatable {
  final List<UserStats> topProofUploaders;
  final List<UserStats> topTileCompleters;
  final int totalProofs;
  final int totalCompletions;

  const ProofStats({
    required this.topProofUploaders,
    required this.topTileCompleters,
    required this.totalProofs,
    required this.totalCompletions,
  });

  factory ProofStats.fromJson(Map<String, dynamic> json) =>
      _$ProofStatsFromJson(json);
  Map<String, dynamic> toJson() => _$ProofStatsToJson(this);

  @override
  List<Object?> get props => [topProofUploaders, topTileCompleters, totalProofs, totalCompletions];
}

