import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_models/shared_models.dart';

part 'auth_state.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthBloc extends Cubit<AuthState> {
  AuthBloc(this._dio) : super(const AuthState.unknown());

  final Dio _dio;

  Future<void> checkAuth() async {
    try {
      final response = await _dio.get('/me');
      if (response.statusCode == 200) {
        final user = AppUser.fromJson(response.data as Map<String, dynamic>);
        emit(AuthState.authenticated(user));
        developer.log('User authenticated', name: 'auth');
      } else {
        emit(const AuthState.unauthenticated());
        developer.log('Auth check failed: ${response.statusCode}', name: 'auth', level: 900);
      }
    } catch (e, stackTrace) {
      emit(const AuthState.unauthenticated());
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
    emit(const AuthState.unauthenticated());
  }
}
