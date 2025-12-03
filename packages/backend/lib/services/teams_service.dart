import 'package:backend/database.dart' hide Team;
import 'package:backend/database.dart' as db;
import 'package:shared_models/shared_models.dart';
import 'package:uuid/uuid.dart';

class TeamsService {
  TeamsService(this._db);
  final AppDatabase _db;

  Future<Team> createTeam({
    required String gameId,
    required String name,
    required String captainUserId,
    String? color,
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
    if (team == null) throw Exception('Team creation failed');
    return _convertToTeam(team);
  }

  Future<Team?> joinGameAndCreateTeam({
    required String gameId,
    required String teamName,
    required String captainUserId,
  }) async {
    await createTeam(
      gameId: gameId,
      name: teamName,
      captainUserId: captainUserId,
    );

    final user = await _db.getUserById(captainUserId);
    final createdTeam = user?.teamId != null
        ? await _db.getTeamById(user!.teamId!)
        : null;

    if (createdTeam == null) return null;

    return _convertToTeam(createdTeam);
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

  Future<Team?> getTeamById(String teamId) async {
    final team = await _db.getTeamById(teamId);
    if (team == null) return null;
    return _convertToTeam(team);
  }

  Future<List<Team>> getTeamsByGameId(String gameId) async {
    final teams = await _db.getTeamsByGameId(gameId);
    return teams.map<Team>(_convertToTeam).toList();
  }

  Future<bool> isTeamCaptain({
    required String teamId,
    required String userId,
  }) async {
    final team = await _db.getTeamById(teamId);
    return team?.captainUserId == userId;
  }

  Future<List<AppUser>> getTeamMembers(String teamId) async {
    final users = await _db.getTeamMembers(teamId);
    return users.map(_convertToAppUser).toList();
  }

  Team _convertToTeam(db.Team teamData) {
    return Team(
      id: teamData.id,
      gameId: teamData.gameId,
      name: teamData.name,
      captainUserId: teamData.captainUserId,
      color: teamData.color,
    );
  }

  AppUser _convertToAppUser(User user) {
    return AppUser(
      id: user.id,
      discordId: user.discordId,
      globalName: user.globalName,
      username: user.username,
      email: user.email,
      avatar: user.avatar,
      role: UserRole.values.byName(user.role),
      teamId: user.teamId,
      gameId: user.gameId,
    );
  }
}
