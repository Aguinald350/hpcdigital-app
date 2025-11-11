// lib/services/home_prefetcher.dart
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/cache_service.dart';
import '../services/hymn_service.dart';
import '../services/verse_service.dart';
import '../services/prayer_service.dart';
import '../services/news_service.dart' as news_service;
import '../services/quotes_service.dart';

class HomePrefetcher {
  static const _lastLoadKey = 'home_last_load_date'; // yyyy-mm-dd

  final HymnService _hymns;
  final VerseService _verses;
  final PrayerService _prayers;
  final news_service.NewsService _news;
  final QuotesService _quotes;
  final CacheService _cache;

  /// Idioma padrão dos hinos
  final String secaoPadrao;

  HomePrefetcher({
    HymnService? hymns,
    VerseService? verses,
    PrayerService? prayers,
    news_service.NewsService? news,
    QuotesService? quotes,
    CacheService? cache,
    this.secaoPadrao = 'Português',
  })  : _hymns = hymns ?? HymnService(),
        _verses = verses ?? VerseService(baseUrl: 'https://abibliadigital.onrender.com/api'),
        _prayers = prayers ?? PrayerService(),
        _news = news ?? news_service.NewsService(),
        _quotes = quotes ?? QuotesService(),
        _cache = cache ?? CacheService();

  Future<bool> _alreadyLoadedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final d = DateTime.now();
    // yyyy-mm-dd sem padding é suficiente, só precisa ser consistente
    final today = '${d.year}-${d.month}-${d.day}';
    return prefs.getString(_lastLoadKey) == today;
  }

  Future<void> _markLoadedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final d = DateTime.now();
    final today = '${d.year}-${d.month}-${d.day}';
    await prefs.setString(_lastLoadKey, today);
  }

  /// Baixa tudo em paralelo e grava no cache no MESMO formato que a Home espera.
  Future<void> _downloadAndCacheAll({required String secao}) async {
    try {
      final results = await Future.wait([
        _hymns.fetchRandomHymn(secao: secao),   // 0
        _verses.fetchVerseOfDay(),              // 1
        _prayers.fetchRandomPrayer(),           // 2
        _quotes.fetchDailyQuote(),              // 3
        _news.fetchHighlights(limit: 2),        // 4 (List)
      ]);

      final hino = results[0];
      final verse = results[1];
      final prayer = results[2];
      final quote = results[3];
      final highlights = results[4];

      final data = <String, dynamic>{
        'hino'      : _safeToMap(hino),
        'verse'     : _safeToMap(verse),
        'prayer'    : _safeToMap(prayer),
        'quote'     : _safeQuoteMap(quote),
        'highlights': _safeHighlightList(highlights),
        'generatedAt': DateTime.now().toIso8601String(),
      };

      await _cache.saveHomeData(data);
    } catch (e) {
      // Deixa registrado para debug
      // ignore: avoid_print
      print('❌ Erro no _downloadAndCacheAll: $e');
      rethrow;
    }
  }

  /// Garante que a Home estará pronta (carregada e em cache).
  /// - Por padrão só atualiza 1x por dia; use [force=true] para forçar recarregar.
  /// - Timeout de segurança para não travar indefinidamente.
  Future<void> ensureReady({
    bool force = false,
    Duration timeout = const Duration(seconds: 25),
  }) async {
    if (!force && await _alreadyLoadedToday()) return;
    await _downloadAndCacheAll(secao: secaoPadrao).timeout(timeout);
    await _markLoadedToday();
  }

  // === Métodos auxiliares seguros ===

  /// Aceita Map ou objetos com método toMap(); caso contrário converte em string.
  Map<String, dynamic>? _safeToMap(dynamic item) {
    if (item == null) return null;
    if (item is Map<String, dynamic>) return item;

    // Tenta item.toMap()
    try {
      final maybe = (item as dynamic).toMap();
      if (maybe is Map<String, dynamic>) return maybe;
    } catch (_) {
      // ignora e cai no fallback
    }

    return <String, dynamic>{'value': item.toString()};
  }

  /// Aceita Map, ou objetos com campos text/author (ou getters).
  Map<String, dynamic>? _safeQuoteMap(dynamic quote) {
    if (quote == null) return null;

    if (quote is Map<String, dynamic>) {
      // normaliza chaves garantindo existência
      return <String, dynamic>{
        'text': quote['text']?.toString() ?? '',
        'author': quote['author']?.toString() ?? '',
      };
    }

    // Tenta acessar como objeto com getters (quote.text / quote.author)
    try {
      final dyn = quote as dynamic;
      final text = dyn.text?.toString() ?? '';
      final author = dyn.author?.toString() ?? '';
      return <String, dynamic>{'text': text, 'author': author};
    } catch (_) {
      // Fallback: tudo em texto
      return <String, dynamic>{'text': quote.toString(), 'author': ''};
    }
  }

  /// Garante lista de mapas serializáveis para os destaques.
  List<Map<String, dynamic>> _safeHighlightList(dynamic list) {
    if (list == null) return <Map<String, dynamic>>[];

    if (list is List) {
      return list.map<Map<String, dynamic>>((e) {
        if (e is Map<String, dynamic>) return e;

        // Tenta e.toMap()
        try {
          final m = (e as dynamic).toMap();
          if (m is Map<String, dynamic>) return m;
        } catch (_) {
          // ignora e cai no fallback
        }

        return <String, dynamic>{'value': e.toString()};
      }).toList();
    }

    return <Map<String, dynamic>>[];
  }
}
