import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'bingo_tile.g.dart';

@JsonSerializable()
class BingoTile extends Equatable {
  final String id;
  final String gameId;
  final String title;
  final String description;
  final String imageUrl;
  final int position;

  const BingoTile({
    required this.id,
    required this.gameId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.position,
  });

  factory BingoTile.fromJson(Map<String, dynamic> json) =>
      _$BingoTileFromJson(json);
  Map<String, dynamic> toJson() => _$BingoTileToJson(this);

  @override
  List<Object?> get props => [
    id,
    gameId,
    title,
    description,
    imageUrl,
    position,
  ];
}
