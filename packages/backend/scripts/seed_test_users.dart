import 'package:backend/database.dart';
import 'package:backend/db.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

Future<void> main() async {
  print('🌱 Seeding test users...\n');

  final db = Db.instance;
  const uuid = Uuid();

  print('Clearing existing test users...');
  await db.customStatement(
    "DELETE FROM users WHERE discord_id LIKE 'test_%'",
  );

  final testUsers = [
    {
      'id': uuid.v4(),
      'discordId': 'test_admin_001',
      'globalName': 'Admin User',
      'username': 'admin_test',
      'role': 'admin',
    },
    {
      'id': uuid.v4(),
      'discordId': 'test_user_002',
      'globalName': 'Alice Anderson',
      'username': 'alice_test',
      'role': 'user',
    },
    {
      'id': uuid.v4(),
      'discordId': 'test_user_003',
      'globalName': 'Bob Builder',
      'username': 'bob_test',
      'role': 'user',
    },
    {
      'id': uuid.v4(),
      'discordId': 'test_user_004',
      'globalName': 'Charlie Chen',
      'username': 'charlie_test',
      'role': 'user',
    },
    {
      'id': uuid.v4(),
      'discordId': 'test_user_005',
      'globalName': 'Diana Davis',
      'username': 'diana_test',
      'role': 'user',
    },
    {
      'id': uuid.v4(),
      'discordId': 'test_user_006',
      'globalName': 'Eve Evans',
      'username': 'eve_test',
      'role': 'user',
    },
    {
      'id': uuid.v4(),
      'discordId': 'test_user_007',
      'globalName': 'Frank Foster',
      'username': 'frank_test',
      'role': 'user',
    },
    {
      'id': uuid.v4(),
      'discordId': 'test_user_008',
      'globalName': 'Grace Green',
      'username': 'grace_test',
      'role': 'user',
    },
    {
      'id': uuid.v4(),
      'discordId': 'test_user_009',
      'globalName': 'Henry Hill',
      'username': 'henry_test',
      'role': 'user',
    },
    {
      'id': uuid.v4(),
      'discordId': 'test_user_010',
      'globalName': 'Iris Ivanov',
      'username': 'iris_test',
      'role': 'user',
    },
  ];

  print('Inserting ${testUsers.length} test users...\n');

  for (final userData in testUsers) {
    await db
        .into(db.users)
        .insert(
          UsersCompanion.insert(
            id: userData['id']!,
            discordId: userData['discordId']!,
            globalName: Value(userData['globalName']),
            username: Value(userData['username']),
            role: Value(userData['role']!),
          ),
        );
    print(
      '✅ Created: ${userData['globalName']} (@${userData['username']}) - ${userData['role']}',
    );
  }

  print('\n✨ Successfully seeded ${testUsers.length} test users!');
  print('\nTest login credentials:');
  print('  Discord ID: test_admin_001 (Admin)');
  print('  Discord ID: test_user_002-010 (Regular users)');
  print('\nNote: These are fake Discord IDs for testing.');
  print('      You can manually update your real Discord user to admin role.');
}
