import 'package:equatable/equatable.dart';
import 'package:shared_models/shared_models.dart';

enum ManageTeamsStatus { initial, loading, loaded, error }

final class ManageTeamsState extends Equatable {
  const ManageTeamsState._({
    required this.status,
    this.teamId,
    this.gameId,
    this.teamName,
    this.teamSize,
    this.teamMembers = const [],
    this.availableUsers = const [],
    this.errorMessage,
  });

  const ManageTeamsState.initial() : this._(status: ManageTeamsStatus.initial);

  const ManageTeamsState.loading({String? teamId, String? gameId})
    : this._(status: ManageTeamsStatus.loading, teamId: teamId, gameId: gameId);

  const ManageTeamsState.loaded({
    required String teamId,
    required String gameId,
    required String teamName,
    required int teamSize,
    required List<AppUser> teamMembers,
    required List<AppUser> availableUsers,
  }) : this._(
         status: ManageTeamsStatus.loaded,
         teamId: teamId,
         gameId: gameId,
         teamName: teamName,
         teamSize: teamSize,
         teamMembers: teamMembers,
         availableUsers: availableUsers,
       );

  const ManageTeamsState.error(String message)
    : this._(status: ManageTeamsStatus.error, errorMessage: message);

  final ManageTeamsStatus status;
  final String? teamId;
  final String? gameId;
  final String? teamName;
  final int? teamSize;
  final List<AppUser> teamMembers;
  final List<AppUser> availableUsers;
  final String? errorMessage;

  @override
  List<Object?> get props => [
    status,
    teamId,
    gameId,
    teamName,
    teamSize,
    teamMembers,
    availableUsers,
    errorMessage,
  ];
}
