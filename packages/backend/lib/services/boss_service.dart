import 'package:backend/database.dart';
import 'package:uuid/uuid.dart';

class BossService {
  BossService(this._db);
  final AppDatabase _db;

  Future<List<Map<String, dynamic>>> getAllBossesWithItems() async {
    final bosses = await _db.getAllBosses();

    final bossesWithItems = await Future.wait(
      bosses.map((boss) async {
        final uniqueItems = await _db.getUniqueItemsByBossId(boss.id);
        return {
          'id': boss.id,
          'name': boss.name,
          'type': boss.type,
          'iconUrl': boss.iconUrl,
          'uniqueItems': uniqueItems.map((item) => item.itemName).toList(),
        };
      }),
    );

    return bossesWithItems;
  }

  Future<Map<String, dynamic>> createBoss({
    required String name,
    required String type,
    required String iconUrl,
    required List<String> uniqueItems,
  }) async {
    const uuid = Uuid();
    final bossId = uuid.v4();
    final now = DateTime.now();

    await _db.createBoss(
      id: bossId,
      name: name.trim(),
      type: type.trim(),
      iconUrl: iconUrl.trim(),
      createdAt: now,
    );

    for (final itemName in uniqueItems) {
      if (itemName.trim().isNotEmpty) {
        await _db.createBossUniqueItem(
          bossId: bossId,
          itemName: itemName.trim(),
        );
      }
    }

    final boss = await _db.getBossById(bossId);
    if (boss == null) {
      throw Exception('Failed to create boss');
    }

    final uniqueItemsList = await _db.getUniqueItemsByBossId(bossId);

    return {
      'id': boss.id,
      'name': boss.name,
      'type': boss.type,
      'iconUrl': boss.iconUrl,
      'uniqueItems': uniqueItemsList.map((item) => item.itemName).toList(),
    };
  }
}
