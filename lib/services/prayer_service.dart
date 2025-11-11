// lib/services/prayer_service.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/prayer_models.dart';


class PrayerService {
  final _db = FirebaseFirestore.instance;

  /// Retorna uma oração aleatória da coleção `oracoes`.
  Future<ShortPrayer?> fetchRandomPrayer() async {
    try {
      final snapshot = await _db.collection('oracoes').get();
      if (snapshot.docs.isEmpty) {
        print('⚠️ Nenhuma oração encontrada.');
        return null;
      }

      final random = Random();
      final doc = snapshot.docs[random.nextInt(snapshot.docs.length)];
      final data = doc.data();

      return ShortPrayer.fromMap(doc.id, data);
    } catch (e) {
      print('❌ Erro ao buscar oração aleatória: $e');
      return null;
    }
  }
}
