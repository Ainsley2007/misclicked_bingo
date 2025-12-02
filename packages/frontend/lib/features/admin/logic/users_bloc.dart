import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/users_repository.dart';
import 'package:frontend/core/error/api_exception.dart';
import 'package:frontend/features/admin/logic/users_event.dart';
import 'package:frontend/features/admin/logic/users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  UsersBloc(this._repository) : super(const UsersInitial()) {
    on<UsersLoadRequested>(_onLoadRequested);
    on<UsersDeleteRequested>(_onDeleteRequested);
  }

  final UsersRepository _repository;

  Future<void> _onLoadRequested(UsersLoadRequested event, Emitter<UsersState> emit) async {
    emit(const UsersLoading());
    try {
      final users = await _repository.getUsers();
      emit(UsersLoaded(users));
      developer.log('Loaded ${users.length} users', name: 'users');
    } on ApiException catch (e) {
      developer.log('Failed to load users: ${e.code}', name: 'users', level: 1000);
      emit(UsersError(e.message));
    } catch (e, stackTrace) {
      developer.log('Failed to load users', name: 'users', level: 1000, error: e, stackTrace: stackTrace);
      emit(UsersError('Failed to load users: $e'));
    }
  }

  Future<void> _onDeleteRequested(UsersDeleteRequested event, Emitter<UsersState> emit) async {
    try {
      await _repository.deleteUser(event.userId);
      final users = state.users.where((u) => u.id != event.userId).toList();
      emit(UsersLoaded(users));
      developer.log('Deleted user: ${event.userId}', name: 'users');
    } on ApiException catch (e) {
      developer.log('Failed to delete user: ${e.code}', name: 'users', level: 1000);
      emit(UsersError(e.message));
    } catch (e, stackTrace) {
      developer.log('Failed to delete user', name: 'users', level: 1000, error: e, stackTrace: stackTrace);
      emit(UsersError('Failed to delete user: $e'));
    }
  }
}
