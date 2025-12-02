import 'package:backend/database.dart';
import 'package:uuid/uuid.dart';

class TeamsService {
  final AppDatabase _db;

  TeamsService(this._db);

  Future<Map<String, dynamic>> createTeam({
    required String gameId,
    required String name,
    required String captainUserId,
    required String color,
  }) async {
    final teamId = const Uuid().v4();

    await _db.createTeam(
      id: teamId,
      gameId: gameId,
      name: name.trim(),
      captainUserId: captainUserId,
      color: color,
    );

    await _db.addUserToTeam(
      userId: captainUserId,
      teamId: teamId,
      gameId: gameId,
      isCaptain: true,
    );

    final team = await _db.getTeamById(teamId);
    return team!.toJson();
  }

  Future<void> updateTeamColor({
    required String teamId,
    required String color,
  }) async {
    await _db.updateTeamColor(teamId, color);
  }

  Future<void> disbandTeam(String teamId) async {
    await _db.deleteTeam(teamId);
  }

  Future<void> addMemberToTeam({
    required String teamId,
    required String userId,
    required String gameId,
  }) async {
    await _db.addUserToTeam(
      userId: userId,
      teamId: teamId,
      gameId: gameId,
    );
  }

  Future<void> removeMemberFromTeam({
    required String userId,
  }) async {
    await _db.removeUserFromTeam(userId);
  }

  Future<int> getTeamMemberCount(String teamId) async {
    final members = await _db.getTeamMembers(teamId);
    return members.length;
  }

  Future<Map<String, dynamic>?> getTeamById(String teamId) async {
    final team = await _db.getTeamById(teamId);
    return team?.toJson();
  }

  Future<List<Map<String, dynamic>>> getTeamsByGameId(String gameId) async {
    final teams = await _db.getTeamsByGameId(gameId);
    return teams.map((t) => t.toJson()).toList();
  }

  Future<bool> isTeamCaptain({
    required String teamId,
    required String userId,
  }) async {
    final team = await _db.getTeamById(teamId);
    return team?.captainUserId == userId;
  }
}
