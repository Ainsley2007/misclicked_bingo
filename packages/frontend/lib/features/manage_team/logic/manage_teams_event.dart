sealed class ManageTeamsEvent {
  const ManageTeamsEvent();
}

final class ManageTeamsLoadRequested extends ManageTeamsEvent {
  const ManageTeamsLoadRequested({required this.teamId, required this.gameId});

  final String teamId;
  final String gameId;
}

final class ManageTeamsAddMember extends ManageTeamsEvent {
  const ManageTeamsAddMember(this.userId);

  final String userId;
}

final class ManageTeamsRemoveMember extends ManageTeamsEvent {
  const ManageTeamsRemoveMember(this.userId);

  final String userId;
}

final class ManageTeamsUpdateColor extends ManageTeamsEvent {
  const ManageTeamsUpdateColor(this.color);

  final String color;
}