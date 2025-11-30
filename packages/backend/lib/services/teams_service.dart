import 'package:backend/database.dart';

class TeamsService {
  final AppDatabase _db;

  TeamsService(this._db);

  Future<void> updateTeamColor({
    required String teamId,
    required String color,
  }) async {
    await _db.updateTeamColor(teamId, color);
  }
}

