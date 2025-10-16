import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/admin/data/users_repository.dart';
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
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(UsersDeleteRequested event, Emitter<UsersState> emit) async {
    try {
      await _repository.deleteUser(event.userId);
      final users = state.users.where((u) => u.id != event.userId).toList();
      emit(UsersLoaded(users));
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }
}
