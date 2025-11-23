import 'package:backend/db.dart';

Future<void> main(List<String> args) async {
  final db = Db.instance;

  print('Seeding bosses...');
  await db.seedBosses();
  print('Boss seeding completed!');
}
