import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:frontend/auth/auth_bloc.dart';

final sl = GetIt.instance;

void setupDi() {
  final dio = Dio(BaseOptions(baseUrl: 'https://osrs-bingo.globeapp.dev', validateStatus: (code) => code != null && code < 500, headers: {'Content-Type': 'application/json'}));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.extra['withCredentials'] = true;
        return handler.next(options);
      },
    ),
  );

  sl.registerSingleton<Dio>(dio);
  sl.registerLazySingleton<AuthBloc>(() => AuthBloc(sl<Dio>()));
}
