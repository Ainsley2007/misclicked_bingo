import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'tile_unique_item.dart';

part 'game_tile_creation.g.dart';

@JsonSerializable()
class GameTileCreation extends Equatable {
  final String? bossId;
  final String? description;
  final List<TileUniqueItem> uniqueItems;
  final bool isAnyUnique;
  final bool isOrLogic;

  const GameTileCreation({
    this.bossId,
    this.description,
    this.uniqueItems = const [],
    this.isAnyUnique = false,
    this.isOrLogic = false,
  });

  factory GameTileCreation.fromJson(Map<String, dynamic> json) =>
      _$GameTileCreationFromJson(json);
  Map<String, dynamic> toJson() => _$GameTileCreationToJson(this);

  GameTileCreation copyWith({
    String? bossId,
    String? description,
    List<TileUniqueItem>? uniqueItems,
    bool? isAnyUnique,
    bool? isOrLogic,
  }) {
    return GameTileCreation(
      bossId: bossId ?? this.bossId,
      description: description ?? this.description,
      uniqueItems: uniqueItems ?? this.uniqueItems,
      isAnyUnique: isAnyUnique ?? this.isAnyUnique,
      isOrLogic: isOrLogic ?? this.isOrLogic,
    );
  }

  @override
  List<Object?> get props => [
    bossId,
    description,
    uniqueItems,
    isAnyUnique,
    isOrLogic,
  ];
}
