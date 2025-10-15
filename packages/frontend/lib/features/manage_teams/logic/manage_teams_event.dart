import 'package:equatable/equatable.dart';

sealed class ManageTeamsEvent extends Equatable {
  const ManageTeamsEvent();

  @override
  List<Object?> get props => [];
}

final class ManageTeamsLoadRequested extends ManageTeamsEvent {
  const ManageTeamsLoadRequested({required this.teamId, required this.gameId});

  final String teamId;
  final String gameId;

  @override
  List<Object?> get props => [teamId, gameId];
}

final class ManageTeamsAddMember extends ManageTeamsEvent {
  const ManageTeamsAddMember(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

final class ManageTeamsRemoveMember extends ManageTeamsEvent {
  const ManageTeamsRemoveMember(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}
