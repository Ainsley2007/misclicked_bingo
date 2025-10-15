import 'package:equatable/equatable.dart';
import 'package:shared_models/shared_models.dart';

enum UsersStatus { initial, loading, loaded, error }

final class UsersState extends Equatable {
  const UsersState._({required this.status, this.users = const [], this.error});

  const UsersState.initial() : this._(status: UsersStatus.initial);

  const UsersState.loading() : this._(status: UsersStatus.loading);

  const UsersState.loaded(List<AppUser> users)
    : this._(status: UsersStatus.loaded, users: users);

  const UsersState.error(String error)
    : this._(status: UsersStatus.error, error: error);

  final UsersStatus status;
  final List<AppUser> users;
  final String? error;

  @override
  List<Object?> get props => [status, users, error];
}
