import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/error/bloc_error_handler_mixin.dart';

export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:frontend/core/error/bloc_error_handler_mixin.dart';

abstract class BaseBloc<Event, State> extends Bloc<Event, State> with BlocErrorHandlerMixin {
  BaseBloc(super.initialState);

  void onDroppable<E extends Event>(EventHandler<E, State> handler, {EventTransformer<E>? transformer}) {
    on<E>(handler, transformer: transformer ?? droppable());
  }

  void onRestartable<E extends Event>(EventHandler<E, State> handler, {EventTransformer<E>? transformer}) {
    on<E>(handler, transformer: transformer ?? restartable());
  }

  void onSequential<E extends Event>(EventHandler<E, State> handler, {EventTransformer<E>? transformer}) {
    on<E>(handler, transformer: transformer ?? sequential());
  }
}
