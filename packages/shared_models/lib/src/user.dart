import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'user.g.dart';

enum UserRole { user, captain, admin }

@JsonSerializable()
class AppUser extends Equatable {
  final String id;
  final String discordId;
  final String? globalName;
  final String? username;
  final String? email;
  final UserRole role;
  final String? teamId;
  final String? gameId;

  const AppUser({required this.id, required this.discordId, this.globalName, this.username, this.email, this.role = UserRole.user, this.teamId, this.gameId});

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
  Map<String, dynamic> toJson() => _$AppUserToJson(this);

  @override
  List<Object?> get props => [id, discordId, role, teamId, gameId];
}
