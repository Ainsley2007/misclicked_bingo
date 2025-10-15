import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/admin/data/users_repository.dart';
import 'package:frontend/features/admin/logic/users_event.dart';
import 'package:frontend/features/admin/logic/users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  UsersBloc(this._repository) : super(const UsersState.initial()) {
    on<UsersLoadRequested>(_onLoadRequested);
    on<UsersDeleteRequested>(_onDeleteRequested);
  }

  final UsersRepository _repository;

  Future<void> _onLoadRequested(
    UsersLoadRequested event,
    Emitter<UsersState> emit,
  ) async {
    emit(const UsersState.loading());
    try {
      final users = await _repository.getUsers();
      emit(UsersState.loaded(users));
    } catch (e) {
      emit(UsersState.error(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    UsersDeleteRequested event,
    Emitter<UsersState> emit,
  ) async {
    try {
      await _repository.deleteUser(event.userId);
      final users = state.users.where((u) => u.id != event.userId).toList();
      emit(UsersState.loaded(users));
    } catch (e) {
      emit(UsersState.error(e.toString()));
    }
  }
}

