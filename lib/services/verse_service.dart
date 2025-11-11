// lib/services/verse_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/verse_models.dart';

class VerseService {
  final String baseUrl; // ex: https://abibliadigital.onrender.com/api

  VerseService({required this.baseUrl});

  Future<VerseOfDay> fetchVerseOfDay() async {
    try {
      final uri = Uri.parse('$baseUrl/verses/acf/random');
      final resp = await http.get(uri, headers: {
        'Accept': 'application/json',
      });

      if (resp.statusCode != 200) {
        throw Exception('HTTP ${resp.statusCode}');
      }

      final j = json.decode(resp.body);
      final bookName = (j['book']?['name'] ?? '').toString();
      final chapter  = (j['chapter'] ?? '').toString();
      final number   = (j['number'] ?? '').toString();
      final text     = (j['text'] ?? '').toString();

      return VerseOfDay(reference: '$bookName $chapter:$number', text: text);
    } catch (_) {
      // fallback local
      return VerseOfDay(
        reference: 'Salmos 118:24',
        text: 'Este é o dia que fez o Senhor; regozijemo-nos e alegremo-nos nele.',
      );
    }
  }
}
