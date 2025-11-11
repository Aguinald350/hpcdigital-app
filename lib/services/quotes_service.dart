import 'dart:convert';
import 'package:http/http.dart' as http;

class MotivationalQuote {
  final String text;
  final String author;

  MotivationalQuote({required this.text, required this.author});
}

class QuotesService {
  final _url = Uri.parse('https://zenquotes.io/api/random');

  /// Busca uma frase inspiradora e traduz para português
  Future<MotivationalQuote> fetchDailyQuote() async {
    try {
      // 🔹 1. Busca frase em inglês
      final res = await http.get(_url);
      if (res.statusCode != 200) {
        return MotivationalQuote(
          text: 'A inspiração está dentro de você.',
          author: 'Desconhecido',
        );
      }

      final data = jsonDecode(res.body);
      if (data is! List || data.isEmpty) {
        return MotivationalQuote(
          text: 'Siga em frente com fé e coragem.',
          author: 'Anônimo',
        );
      }

      final quote = data.first;
      String text = quote['q'] ?? 'Acredite em si mesmo.';
      String author = quote['a'] ?? 'Desconhecido';

      // 🔹 2. Traduz texto e autor para português
      final translatedText = await _translateToPortuguese(text);
      final translatedAuthor = await _translateToPortuguese(author);

      return MotivationalQuote(
        text: translatedText,
        author: translatedAuthor,
      );
    } catch (e) {
      print('Erro ao buscar ou traduzir frase: $e');
      return MotivationalQuote(
        text: 'Continue acreditando no seu propósito.',
        author: 'Anônimo',
      );
    }
  }

  /// Traduz uma string para português via MyMemory API
  Future<String> _translateToPortuguese(String text) async {
    try {
      final url = Uri.parse(
          'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(text)}&langpair=en|pt');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final translated = data['responseData']?['translatedText'];
        if (translated != null && translated is String) {
          return translated;
        }
      }
    } catch (_) {}
    return text; // fallback caso falhe
  }
}
