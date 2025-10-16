import 'package:flutter/foundation.dart';
import 'package:shared_models/shared_models.dart';

@immutable
sealed class UsersState {
  const UsersState();
  List<AppUser> get users => const [];
}

@immutable
final class UsersInitial extends UsersState {
  const UsersInitial();
}

@immutable
final class UsersLoading extends UsersState {
  const UsersLoading();
}

@immutable
final class UsersLoaded extends UsersState {
  const UsersLoaded(this._users);
  final List<AppUser> _users;

  @override
  List<AppUser> get users => _users;
}

@immutable
final class UsersError extends UsersState {
  const UsersError(this.message);
  final String message;
}
