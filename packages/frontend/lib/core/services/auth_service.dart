import 'dart:async';
import 'dart:developer' as developer;

import 'package:frontend/repositories/users_repository.dart';
import 'package:frontend/core/error/api_exception.dart';
import 'package:shared_models/shared_models.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthState {
  const AuthState._(this.status, this.user);

  const AuthState.unknown() : this._(AuthStatus.unknown, null);
  const AuthState.unauthenticated() : this._(AuthStatus.unauthenticated, null);
  const AuthState.authenticated(AppUser user) : this._(AuthStatus.authenticated, user);

  final AuthStatus status;
  final AppUser? user;
}

class AuthService {
  AuthService(this._usersRepository, this._baseUrl) {
    _currentState = const AuthState.unknown();
  }

  final UsersRepository _usersRepository;
  final String _baseUrl;
  final _authController = StreamController<AuthState>.broadcast();
  late AuthState _currentState;

  Stream<AuthState> get authStream => _authController.stream;
  AuthState get currentState => _currentState;
  AppUser? get currentUser => _currentState.user;

  void _updateState(AuthState newState) {
    _currentState = newState;
    _authController.add(newState);
  }

  Future<void> checkAuth() async {
    try {
      final user = await _usersRepository.getCurrentUser();
      _updateState(AuthState.authenticated(user));
      developer.log('User authenticated', name: 'auth');
    } on ApiException catch (e) {
      _updateState(const AuthState.unauthenticated());
      developer.log('Auth check failed: ${e.code}', name: 'auth', level: 900);
    } catch (e, stackTrace) {
      _updateState(const AuthState.unauthenticated());
      developer.log('Auth check error', name: 'auth', level: 1000, error: e, stackTrace: stackTrace);
    }
  }

  String getLoginUrl() => '$_baseUrl/auth/discord/login';

  Future<void> logout() async {
    _updateState(const AuthState.unauthenticated());
    developer.log('User logged out', name: 'auth');
  }

  void dispose() {
    _authController.close();
  }
}
