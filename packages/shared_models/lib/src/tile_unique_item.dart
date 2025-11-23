import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'tile_unique_item.g.dart';

@JsonSerializable()
class TileUniqueItem extends Equatable {
  final String itemName;
  final int requiredCount;

  const TileUniqueItem({
    required this.itemName,
    required this.requiredCount,
  });

  factory TileUniqueItem.fromJson(Map<String, dynamic> json) =>
      _$TileUniqueItemFromJson(json);
  Map<String, dynamic> toJson() => _$TileUniqueItemToJson(this);

  @override
  List<Object?> get props => [itemName, requiredCount];
}

