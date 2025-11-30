import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/core/api/proofs_api.dart';
import 'package:frontend/features/admin/logic/games_bloc.dart';
import 'package:frontend/features/admin/data/games_repository.dart';
import 'package:frontend/features/admin/logic/users_bloc.dart';
import 'package:frontend/features/admin/data/users_repository.dart';
import 'package:frontend/features/lobby/data/lobby_repository.dart';
import 'package:frontend/features/lobby/logic/join_game_bloc.dart';
import 'package:frontend/features/game/data/game_repository.dart';
import 'package:frontend/features/game/data/proofs_repository.dart';
import 'package:frontend/features/game/logic/game_bloc.dart';
import 'package:frontend/features/game/logic/overview_bloc.dart';
import 'package:frontend/features/game/logic/proofs_bloc.dart';
import 'package:frontend/features/manage_team/data/teams_repository.dart';
import 'package:frontend/features/manage_team/logic/manage_teams_bloc.dart';
import 'package:frontend/features/game_creation/data/game_creation_repository.dart';
import 'package:frontend/features/game_creation/logic/game_creation_bloc.dart';
import 'package:frontend/features/bosses/data/boss_repository.dart';
import 'package:frontend/features/guest/data/guest_repository.dart';
import 'package:frontend/features/guest/logic/guest_bloc.dart';

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

  // Services
  sl.registerSingleton<AuthService>(AuthService(sl<Dio>()));

  // APIs
  sl.registerLazySingleton<ProofsApi>(() => ProofsApi(sl<Dio>()));

  // Repositories
  sl.registerLazySingleton<GamesRepository>(() => GamesRepository(sl<Dio>()));
  sl.registerLazySingleton<UsersRepository>(() => UsersRepository(sl<Dio>()));
  sl.registerLazySingleton<LobbyRepository>(() => LobbyRepository(sl<Dio>()));
  sl.registerLazySingleton<GameRepository>(() => GameRepository(sl<Dio>()));
  sl.registerLazySingleton<TeamsRepository>(() => TeamsRepository(sl<Dio>()));
  sl.registerLazySingleton<GameCreationRepository>(
    () => GameCreationRepository(sl<Dio>()),
  );
  sl.registerLazySingleton<BossRepository>(() => BossRepository(sl<Dio>()));
  sl.registerLazySingleton<ProofsRepository>(
    () => ProofsRepository(sl<ProofsApi>()),
  );
  sl.registerLazySingleton<GuestRepository>(() => GuestRepository(sl<Dio>()));

  // BLoCs
  sl.registerFactory<GamesBloc>(() => GamesBloc(sl<GamesRepository>()));
  sl.registerFactory<UsersBloc>(() => UsersBloc(sl<UsersRepository>()));
  sl.registerFactory<JoinGameBloc>(() => JoinGameBloc(sl<LobbyRepository>()));
  sl.registerFactory<GameBloc>(
    () => GameBloc(sl<GameRepository>(), sl<BossRepository>()),
  );
  sl.registerFactory<OverviewBloc>(
    () => OverviewBloc(sl<GameRepository>(), sl<BossRepository>(), sl<ProofsRepository>()),
  );
  sl.registerFactory<ManageTeamsBloc>(
    () => ManageTeamsBloc(
      teamsRepository: sl<TeamsRepository>(),
      gameRepository: sl<GameRepository>(),
    ),
  );
  sl.registerFactory<GameCreationBloc>(
    () => GameCreationBloc(sl<GameCreationRepository>(), sl<BossRepository>()),
  );
  sl.registerFactory<ProofsBloc>(() => ProofsBloc(sl<ProofsRepository>()));
  sl.registerFactory<GuestBloc>(() => GuestBloc(sl<GuestRepository>()));
}
