import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const _keyHomeCache = 'homeCache';

  /// 🧠 Salva o cache diário da Home (com data)
  Future<void> saveHomeData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T').first;
    data['date'] = today;
    await prefs.setString(_keyHomeCache, jsonEncode(data));
  }

  /// 📅 Retorna o cache do dia atual (se ainda válido)
  Future<Map<String, dynamic>?> getHomeData() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyHomeCache);
    if (json == null) return null;

    try {
      final data = jsonDecode(json);
      final today = DateTime.now().toIso8601String().split('T').first;
      if (data['date'] == today) {
        return Map<String, dynamic>.from(data);
      } else {
        await clearHomeCache();
      }
    } catch (e) {
      await clearHomeCache();
    }
    return null;
  }

  /// ❌ Apaga o cache salvo
  Future<void> clearHomeCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHomeCache);
  }
}
