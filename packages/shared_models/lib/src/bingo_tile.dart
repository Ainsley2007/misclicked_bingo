import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'boss_type.dart';
import 'tile_unique_item.dart';

part 'bingo_tile.g.dart';

@JsonSerializable()
class BingoTile extends Equatable {
  final String id;
  final String gameId;
  final String bossId;
  final String? description;
  final int position;
  final String? bossName;
  @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
  final BossType? bossType;
  final String? bossIconUrl;
  final List<TileUniqueItem> uniqueItems;
  final bool isAnyUnique;
  final bool isOrLogic;
  final int? anyNCount;
  final bool isCompleted;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<String>? possibleUniqueItems;

  const BingoTile({
    required this.id,
    required this.gameId,
    required this.bossId,
    this.description,
    required this.position,
    this.bossName,
    this.bossType,
    this.bossIconUrl,
    this.uniqueItems = const [],
    this.isAnyUnique = false,
    this.isOrLogic = false,
    this.anyNCount,
    this.isCompleted = false,
    this.possibleUniqueItems,
  });

  static BossType? _typeFromJson(String? json) =>
      json != null ? BossType.fromString(json) : null;
  static String? _typeToJson(BossType? type) => type?.value;

  factory BingoTile.fromJson(Map<String, dynamic> json) =>
      _$BingoTileFromJson(json);
  Map<String, dynamic> toJson() => _$BingoTileToJson(this);

  BingoTile copyWith({
    String? id,
    String? gameId,
    String? bossId,
    String? description,
    int? position,
    String? bossName,
    BossType? bossType,
    String? bossIconUrl,
    List<TileUniqueItem>? uniqueItems,
    bool? isAnyUnique,
    bool? isOrLogic,
    int? anyNCount,
    bool? isCompleted,
    List<String>? possibleUniqueItems,
  }) {
    return BingoTile(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      bossId: bossId ?? this.bossId,
      description: description ?? this.description,
      position: position ?? this.position,
      bossName: bossName ?? this.bossName,
      bossType: bossType ?? this.bossType,
      bossIconUrl: bossIconUrl ?? this.bossIconUrl,
      uniqueItems: uniqueItems ?? this.uniqueItems,
      isAnyUnique: isAnyUnique ?? this.isAnyUnique,
      isOrLogic: isOrLogic ?? this.isOrLogic,
      anyNCount: anyNCount ?? this.anyNCount,
      isCompleted: isCompleted ?? this.isCompleted,
      possibleUniqueItems: possibleUniqueItems ?? this.possibleUniqueItems,
    );
  }

  @override
  List<Object?> get props => [
    id,
    gameId,
    bossId,
    description,
    position,
    bossName,
    bossType,
    bossIconUrl,
    uniqueItems,
    isAnyUnique,
    isOrLogic,
    anyNCount,
    isCompleted,
    possibleUniqueItems,
  ];
}
