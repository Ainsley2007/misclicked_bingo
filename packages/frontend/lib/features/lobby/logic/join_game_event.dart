import 'package:equatable/equatable.dart';

sealed class JoinGameEvent extends Equatable {
  const JoinGameEvent();

  @override
  List<Object?> get props => [];
}

final class JoinGameRequested extends JoinGameEvent {
  const JoinGameRequested({required this.code, required this.teamName});

  final String code;
  final String teamName;

  @override
  List<Object?> get props => [code, teamName];
}
