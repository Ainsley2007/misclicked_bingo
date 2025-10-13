part of 'auth_bloc.dart';

class AuthState extends Equatable {
  const AuthState._(this.status, this.user);

  const AuthState.unknown() : this._(AuthStatus.unknown, null);
  const AuthState.unauthenticated() : this._(AuthStatus.unauthenticated, null);
  const AuthState.authenticated(AppUser user) : this._(AuthStatus.authenticated, user);

  final AuthStatus status;
  final AppUser? user;

  @override
  List<Object?> get props => [status, user];
}
