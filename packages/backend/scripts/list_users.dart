import 'package:backend/db.dart';

Future<void> main() async {
  final db = Db.instance;
  final users = await db.getAllUsers();

  if (users.isEmpty) {
    print('No users found in database.');
    return;
  }

  print('Users in database:\n');
  for (final user in users) {
    print('ID: ${user.id}');
    print('Discord ID: ${user.discordId}');
    print('Name: ${user.globalName ?? user.username ?? "N/A"}');
    print('Role: ${user.role}');
    print('---');
  }
}

