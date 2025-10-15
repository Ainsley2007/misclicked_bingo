import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'challenge.g.dart';

@JsonSerializable()
class Challenge extends Equatable {
  final String id;
  final String gameId;
  final String title;
  final String description;
  final String imageUrl;
  final int unlockAmount;

  const Challenge({
    required this.id,
    required this.gameId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.unlockAmount,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) =>
      _$ChallengeFromJson(json);
  Map<String, dynamic> toJson() => _$ChallengeToJson(this);

  @override
  List<Object?> get props => [
    id,
    gameId,
    title,
    description,
    imageUrl,
    unlockAmount,
  ];
}
