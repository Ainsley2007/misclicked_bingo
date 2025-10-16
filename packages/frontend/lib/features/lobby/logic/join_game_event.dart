sealed class JoinGameEvent {
  const JoinGameEvent();
}

final class JoinGameRequested extends JoinGameEvent {
  const JoinGameRequested({required this.code, required this.teamName});

  final String code;
  final String teamName;
}
