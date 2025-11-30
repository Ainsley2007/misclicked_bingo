import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tile_activity.g.dart';

enum ActivityType {
  @JsonValue('proof_uploaded')
  proofUploaded,
  @JsonValue('tile_completed')
  tileCompleted,
}

@JsonSerializable()
class TileActivity extends Equatable {
  final String id;
  final ActivityType type;
  final String userId;
  final String? username;
  final String? userAvatar;
  final String tileId;
  final String? tileName;
  final String? tileIconUrl;
  final String teamId;
  final String? teamName;
  final String? teamColor;
  final String? proofImageUrl;
  final DateTime timestamp;

  const TileActivity({
    required this.id,
    required this.type,
    required this.userId,
    this.username,
    this.userAvatar,
    required this.tileId,
    this.tileName,
    this.tileIconUrl,
    required this.teamId,
    this.teamName,
    this.teamColor,
    this.proofImageUrl,
    required this.timestamp,
  });

  factory TileActivity.fromJson(Map<String, dynamic> json) =>
      _$TileActivityFromJson(json);
  Map<String, dynamic> toJson() => _$TileActivityToJson(this);

  @override
  List<Object?> get props => [id, type, userId, tileId, teamId, timestamp];
}

