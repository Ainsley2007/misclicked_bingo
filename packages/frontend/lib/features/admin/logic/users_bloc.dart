import 'package:frontend/core/bloc/base_bloc.dart';
import 'package:frontend/repositories/users_repository.dart';
import 'package:frontend/features/admin/logic/users_event.dart';
import 'package:frontend/features/admin/logic/users_state.dart';

class UsersBloc extends BaseBloc<UsersEvent, UsersState> {
  UsersBloc(this._repository) : super(const UsersInitial()) {
    on<UsersLoadRequested>(_onLoadRequested);
    onDroppable<UsersDeleteRequested>(_onDeleteRequested);
  }

  final UsersRepository _repository;

  Future<void> _onLoadRequested(UsersLoadRequested event, Emitter<UsersState> emit) async {
    emit(const UsersLoading());
    await executeWithResult(
      action: () => _repository.getUsers(),
      onSuccess: (users) => emit(UsersLoaded(users)),
      onError: (message) => emit(UsersError(message)),
      context: 'users',
      defaultMessage: 'Failed to load users',
    );
  }

  Future<void> _onDeleteRequested(UsersDeleteRequested event, Emitter<UsersState> emit) async {
    await execute(
      action: () async {
        await _repository.deleteUser(event.userId);
        final users = state.users.where((u) => u.id != event.userId).toList();
        emit(UsersLoaded(users));
      },
      onError: (message) => emit(UsersError(message)),
      context: 'users',
      defaultMessage: 'Failed to delete user',
    );
  }
}
