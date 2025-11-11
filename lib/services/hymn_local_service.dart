import 'package:hive_flutter/hive_flutter.dart';
import '../models/hymn_models.dart';

class HymnLocalService {
  static const _boxName = 'hymnsBox';

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(HymnOfDayAdapter());
    }
  }

  Future<void> saveHymns(List<HymnOfDay> hymns) async {
    final box = await Hive.openBox<HymnOfDay>(_boxName);
    await box.clear();
    for (var h in hymns) {
      await box.put(h.id, h);
    }
  }

  Future<List<HymnOfDay>> getAllHymns() async {
    final box = await Hive.openBox<HymnOfDay>(_boxName);
    return box.values.toList();
  }

  Future<void> clear() async {
    final box = await Hive.openBox<HymnOfDay>(_boxName);
    await box.clear();
  }
}
