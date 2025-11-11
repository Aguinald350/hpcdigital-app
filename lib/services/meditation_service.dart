// lib/services/meditation_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meditation_models.dart';

class MeditationService {
  final String endpoint; // seu endpoint (ex: Cloud Function) que gera/retorna a meditação
  final String apiKey;

  MeditationService({required this.endpoint, required this.apiKey});

  /// Você pode enviar o versículo do dia (ou tema litúrgico) para a sua API gerar um texto curto
  Future<MeditationOfDay> fetchMeditation({
    required String verseReference,
    required String liturgicalTheme,
  }) async {
    final uri = Uri.parse(endpoint);
    final resp = await http.post(
      uri,
      headers: {'Authorization': 'Bearer $apiKey', 'Content-Type': 'application/json'},
      body: json.encode({
        'verse': verseReference,
        'theme': liturgicalTheme,
        'length': 'short', // dica para sua API
      }),
    );

    if (resp.statusCode != 200) {
      return MeditationOfDay(
        title: 'Meditação do Dia',
        text: 'Que este dia seja guiado pela Palavra e pela presença de Deus em seu coração.',
      );
    }

    final j = json.decode(resp.body) as Map<String, dynamic>;
    return MeditationOfDay(
      title: (j['title'] ?? 'Meditação do Dia').toString(),
      text: (j['text'] ?? '').toString(),
    );
  }
}
