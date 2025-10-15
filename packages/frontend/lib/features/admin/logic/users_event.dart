import 'package:equatable/equatable.dart';

sealed class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object> get props => [];
}

final class UsersLoadRequested extends UsersEvent {
  const UsersLoadRequested();
}

final class UsersDeleteRequested extends UsersEvent {
  const UsersDeleteRequested(this.userId);

  final String userId;

  @override
  List<Object> get props => [userId];
}

