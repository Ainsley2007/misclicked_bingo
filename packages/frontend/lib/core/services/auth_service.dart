import 'dart:async';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
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
  AuthService(this._dio) {
    _currentState = const AuthState.unknown();
  }

  final Dio _dio;
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
      final response = await _dio.get('/me');
      if (response.statusCode == 200) {
        final user = AppUser.fromJson(response.data as Map<String, dynamic>);
        _updateState(AuthState.authenticated(user));
        developer.log('User authenticated', name: 'auth');
      } else {
        _updateState(const AuthState.unauthenticated());
        developer.log('Auth check failed: ${response.statusCode}', name: 'auth', level: 900);
      }
    } catch (e, stackTrace) {
      _updateState(const AuthState.unauthenticated());
      developer.log('Auth check error', name: 'auth', level: 1000, error: e, stackTrace: stackTrace);
    }
  }

  String getLoginUrl() {
    final baseUrl = _dio.options.baseUrl;
    return '$baseUrl/auth/discord/login';
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
      developer.log('User logged out', name: 'auth');
    } catch (e, stackTrace) {
      developer.log('Logout request failed', name: 'auth', level: 900, error: e, stackTrace: stackTrace);
    }
    _updateState(const AuthState.unauthenticated());
  }

  void dispose() {
    _authController.close();
  }
}
