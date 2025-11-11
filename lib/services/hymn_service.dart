// lib/services/hymn_service.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hymn_models.dart';

class HymnService {
  final _db = FirebaseFirestore.instance;

  /// Busca um hino aleatório da coleção principal `hinos`,
  /// filtrando pelo campo `lingua`.
  Future<HymnOfDay?> fetchRandomHymn({required String secao}) async {
    try {
      final query = await _db
          .collection('hinos')
          .where('lingua', isEqualTo: secao)
          .get();

      if (query.docs.isEmpty) {
        print('⚠️ Nenhum hino encontrado para a língua: $secao');
        return null;
      }

      final random = Random();
      final doc = query.docs[random.nextInt(query.docs.length)];
      final data = doc.data();

      return HymnOfDay.fromMap(doc.id, data);
    } catch (e) {
      print('❌ Erro ao buscar hino aleatório: $e');
      return null;
    }
  }
}
