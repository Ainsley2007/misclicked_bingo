import 'package:backend/database.dart';
import 'package:backend/services/activity_service.dart';
import 'package:backend/services/auth_service.dart';
import 'package:backend/services/boss_service.dart';
import 'package:backend/services/game_service.dart';
import 'package:backend/services/proofs_service.dart';
import 'package:backend/services/teams_service.dart';
import 'package:backend/services/tiles_service.dart';
import 'package:backend/services/user_service.dart';
import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return handler.use(servicesProvider());
}

Middleware servicesProvider() {
  return (handler) {
    return (context) async {
      final db = context.read<AppDatabase>();
      final proofsService = context.read<ProofsService>();

      return handler(
        context
            .provide<GameService>(() => GameService(db))
            .provide<TeamsService>(() => TeamsService(db))
            .provide<TilesService>(() => TilesService(db))
            .provide<UserService>(() => UserService(db))
            .provide<AuthService>(() => AuthService(db))
            .provide<BossService>(() => BossService(db))
            .provide<ActivityService>(() => ActivityService(db))
            .provide<ProofsService>(() => proofsService),
      );
    };
  };
}
