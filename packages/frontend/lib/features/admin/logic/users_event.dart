sealed class UsersEvent {
  const UsersEvent();
}

final class UsersLoadRequested extends UsersEvent {
  const UsersLoadRequested();
}

final class UsersDeleteRequested extends UsersEvent {
  const UsersDeleteRequested(this.userId);

  final String userId;
}
