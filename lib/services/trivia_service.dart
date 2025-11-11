// lib/services/trivia_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/trivia_models.dart';

class TriviaService {
  final String endpoint; // sua Cloud Function/endpoint IA
  final String apiKey;
  TriviaService({required this.endpoint, required this.apiKey});

  Future<ChristianTrivia> fetchTrivia({required String liturgicalTheme}) async {
    final uri = Uri.parse(endpoint);
    final resp = await http.post(
      uri,
      headers: {'Authorization': 'Bearer $apiKey', 'Content-Type': 'application/json'},
      body: json.encode({
        'prompt': 'Curiosidade cristã breve e fiel às Escrituras sobre: $liturgicalTheme',
        'max_chars': 180,
      }),
    );

    if (resp.statusCode != 200) {
      return ChristianTrivia('“Aleluia” significa “Louvai ao Senhor”.');
    }

    final j = json.decode(resp.body);
    return ChristianTrivia((j['text'] ?? '').toString());
  }
}
