import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tile_proof.g.dart';

@JsonSerializable()
class TileProof extends Equatable {
  final String id;
  final String teamId;
  final String tileId;
  final String imageUrl;
  final String uploadedByUserId;
  final String? uploadedByUsername;
  final DateTime uploadedAt;

  const TileProof({
    required this.id,
    required this.teamId,
    required this.tileId,
    required this.imageUrl,
    required this.uploadedByUserId,
    this.uploadedByUsername,
    required this.uploadedAt,
  });

  factory TileProof.fromJson(Map<String, dynamic> json) =>
      _$TileProofFromJson(json);
  Map<String, dynamic> toJson() => _$TileProofToJson(this);

  @override
  List<Object?> get props => [id, teamId, tileId, imageUrl, uploadedByUserId, uploadedAt];
}

