import 'package:get_it/get_it.dart';
import 'package:frontend/core/api/api_client.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/api/games_api.dart';
import 'package:frontend/api/teams_api.dart';
import 'package:frontend/api/users_api.dart';
import 'package:frontend/api/auth_api.dart';
import 'package:frontend/api/bosses_api.dart';
import 'package:frontend/api/proofs_api.dart';
import 'package:frontend/repositories/games_repository.dart';
import 'package:frontend/repositories/teams_repository.dart';
import 'package:frontend/repositories/users_repository.dart';
import 'package:frontend/repositories/auth_repository.dart';
import 'package:frontend/repositories/bosses_repository.dart';
import 'package:frontend/repositories/proofs_repository.dart';
import 'package:frontend/features/admin/logic/games_bloc.dart';
import 'package:frontend/features/admin/logic/users_bloc.dart';
import 'package:frontend/features/lobby/logic/join_game_bloc.dart';
import 'package:frontend/features/game/logic/game_bloc.dart';
import 'package:frontend/features/game/logic/overview_bloc.dart';
import 'package:frontend/features/game/logic/proofs_bloc.dart';
import 'package:frontend/features/manage_team/logic/manage_teams_bloc.dart';
import 'package:frontend/features/game_creation/logic/game_creation_bloc.dart';
import 'package:frontend/features/guest/logic/guest_bloc.dart';

final sl = GetIt.instance;

void setupDi() {
  const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://osrs-bingo.globeapp.dev');

  final apiClient = ApiClient(baseUrl: apiBaseUrl);

  sl.registerSingleton<ApiClient>(apiClient);

  sl.registerLazySingleton<GamesApi>(() => GamesApi(sl<ApiClient>().dio));
  sl.registerLazySingleton<TeamsApi>(() => TeamsApi(sl<ApiClient>().dio));
  sl.registerLazySingleton<UsersApi>(() => UsersApi(sl<ApiClient>().dio));
  sl.registerLazySingleton<AuthApi>(() => AuthApi(sl<ApiClient>().dio));
  sl.registerLazySingleton<BossesApi>(() => BossesApi(sl<ApiClient>().dio));
  sl.registerLazySingleton<ProofsApi>(() => ProofsApi(sl<ApiClient>().dio));

  sl.registerLazySingleton<GamesRepository>(() => GamesRepository(sl<GamesApi>()));
  sl.registerLazySingleton<TeamsRepository>(() => TeamsRepository(sl<TeamsApi>()));
  sl.registerLazySingleton<UsersRepository>(() => UsersRepository(sl<UsersApi>()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository(sl<AuthApi>(), apiBaseUrl));
  sl.registerLazySingleton<BossesRepository>(() => BossesRepository(sl<BossesApi>()));
  sl.registerLazySingleton<ProofsRepository>(() => ProofsRepository(sl<ProofsApi>()));

  sl.registerSingleton<AuthService>(AuthService(sl<UsersRepository>(), apiBaseUrl));

  sl.registerFactory<GamesBloc>(() => GamesBloc(sl<GamesRepository>()));
  sl.registerFactory<UsersBloc>(() => UsersBloc(sl<UsersRepository>()));
  sl.registerFactory<JoinGameBloc>(() => JoinGameBloc(sl<GamesRepository>()));
  sl.registerFactory<GameBloc>(() => GameBloc(sl<GamesRepository>(), sl<BossesRepository>()));
  sl.registerFactory<OverviewBloc>(() => OverviewBloc(sl<GamesRepository>(), sl<BossesRepository>(), sl<ProofsRepository>()));
  sl.registerFactory<ManageTeamsBloc>(() => ManageTeamsBloc(teamsRepository: sl<TeamsRepository>(), gamesRepository: sl<GamesRepository>(), usersRepository: sl<UsersRepository>()));
  sl.registerFactory<GameCreationBloc>(() => GameCreationBloc(sl<GamesRepository>(), sl<BossesRepository>()));
  sl.registerFactory<ProofsBloc>(() => ProofsBloc(sl<ProofsRepository>()));
  sl.registerFactory<GuestBloc>(() => GuestBloc(sl<GamesRepository>()));
}
