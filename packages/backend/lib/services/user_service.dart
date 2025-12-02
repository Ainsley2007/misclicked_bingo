import 'package:backend/database.dart';
import 'package:shared_models/shared_models.dart';

class UserService {
  UserService(this._db);
  final AppDatabase _db;

  Future<AppUser?> getUserById(String userId) async {
    final user = await _db.getUserById(userId);
    if (user == null) return null;
    return _convertToAppUser(user);
  }

  Future<List<AppUser>> getAllUsers() async {
    final users = await _db.getAllUsers();
    return users.map(_convertToAppUser).toList();
  }

  Future<List<AppUser>> getUsersInGame(String gameId) async {
    final users = await _db.getUsersInGame(gameId);
    return users.map(_convertToAppUser).toList();
  }

  Future<void> deleteUser(String userId) async {
    await _db.deleteUser(userId);
  }

  Future<bool> isAdmin(String userId) async {
    final user = await _db.getUserById(userId);
    return user?.role == 'admin';
  }

  Future<bool> isInTeam(String userId) async {
    final user = await _db.getUserById(userId);
    return user?.teamId != null;
  }

  Future<String?> getUserTeamId(String userId) async {
    final user = await _db.getUserById(userId);
    return user?.teamId;
  }

  Future<void> promoteToAdmin(String userId) async {
    await _db.promoteUserToAdmin(userId);
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
