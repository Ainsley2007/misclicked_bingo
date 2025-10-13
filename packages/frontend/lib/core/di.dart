import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:frontend/features/auth/logic/auth_bloc.dart';
import 'package:frontend/features/admin/logic/games_bloc.dart';
import 'package:frontend/features/admin/data/games_repository.dart';

final sl = GetIt.instance;

void setupDi() {
  const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://osrs-bingo.globeapp.dev',
  );

  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      validateStatus: (code) => code != null && code < 500,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.extra['withCredentials'] = true;
        return handler.next(options);
      },
    ),
  );

  sl.registerSingleton<Dio>(dio);

  // Repositories
  sl.registerLazySingleton<GamesRepository>(() => GamesRepository(sl<Dio>()));

  // BLoCs
  sl.registerLazySingleton<AuthBloc>(() => AuthBloc(sl<Dio>()));
  sl.registerFactory<GamesBloc>(() => GamesBloc(sl<GamesRepository>()));
}
