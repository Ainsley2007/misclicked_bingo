import 'package:backend/db.dart';
import 'package:uuid/uuid.dart';

Future<void> main() async {
  print('🌱 Seeding second test team...\n');

  final db = Db.instance;
  const uuid = Uuid();

  // Find the existing game
  final games = await db.getAllGames();
  if (games.isEmpty) {
    print('❌ No games found. Please create a game first.');
    return;
  }
  final game = games.first;
  print('📋 Found game: ${game.name} (${game.id})\n');

  // Find users not in a team
  final allUsers = await db.getAllUsers();
  final usersWithoutTeam = allUsers.where((u) => u.teamId == null).toList();

  if (usersWithoutTeam.isEmpty) {
    print('❌ No users without a team found.');
    return;
  }

  // Pick Charlie Chen as captain (or first available user)
  final captain = usersWithoutTeam.firstWhere(
    (u) => u.globalName == 'Charlie Chen',
    orElse: () => usersWithoutTeam.first,
  );

  print('👤 Selected captain: ${captain.globalName} (@${captain.username})');

  // Create the team
  final teamId = uuid.v4();
  await db.createTeam(
    id: teamId,
    gameId: game.id,
    name: 'Winners delight',
    captainUserId: captain.id,
  );
  print('✅ Created team: Winners delight\n');

  // Add captain to team
  await db.addUserToTeam(
    userId: captain.id,
    teamId: teamId,
    gameId: game.id,
    isCaptain: true,
  );
  print('✅ Added ${captain.globalName} as captain and member\n');

  // Add a few more members if available
  final additionalMembers = usersWithoutTeam
      .where((u) => u.id != captain.id)
      .take(2)
      .toList();

  for (final member in additionalMembers) {
    await db.addUserToTeam(
      userId: member.id,
      teamId: teamId,
      gameId: game.id,
      isCaptain: false,
    );
    print('✅ Added ${member.globalName} to team');
  }

  print('\n✨ Successfully created "Winners delight" team!');
  print('   Captain: ${captain.globalName}');
  print('   Total members: ${additionalMembers.length + 1}');
}
