// lib/screens/Homescreen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// 🔐 Sessão única
import 'package:firebase_auth/firebase_auth.dart';
import '../services/session_manager.dart';

// Telas e serviços existentes
import '../models/hymn_models.dart';
import '../models/prayer_models.dart';
import '../models/verse_models.dart';
import '../services/cache_service.dart';
import '../services/hymn_service.dart';
import '../services/prayer_service.dart';
import '../services/verse_service.dart';
import '../services/news_service.dart' as news_service;
import '../services/quotes_service.dart';

import '../widgets/detalhes_evento_screen.dart';
import '../widgets/detalhes_hino_screen.dart';
import '../widgets/detalhes_informacao_screen.dart';

// Tela de Login para navegação após signOut
import 'LoginScreen.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final _hymns = HymnService();
  final _verses = VerseService(baseUrl: 'https://abibliadigital.onrender.com/api');
  final _prayers = PrayerService();
  final _news = news_service.NewsService();
  final _quotes = QuotesService();
  final _cache = CacheService();

  String _secao = 'Português';
  Map<String, dynamic>? _homeData;

  bool _loading = true;

  @override
  void initState() {
    super.initState();

    // 🔐 Listener de mismatch de sessão (derruba este device se outro logar)
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      SessionManager.startListeningToUserDoc(
        uid: user.uid,
        onSessionMismatch: (remoteId) async {
          if (!mounted) return;

          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              title: const Text('Sessão iniciada em outro dispositivo'),
              content: const Text(
                'Detectamos que sua conta foi acessada em outro aparelho. '
                    'Para segurança, esta sessão será encerrada aqui.',
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    // encerra sessão local (não limpa no Firestore)
                    await SessionManager.endSession(user.uid, clearRemote: false);
                    await FirebaseAuth.instance.signOut();

                    if (context.mounted) {
                      Navigator.of(context).pop(); // fecha o diálogo
                      // navega para o login limpando a pilha
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const Loginscreen()),
                            (_) => false,
                      );
                    }
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
      );
    }

    _carregarDados();
  }

  @override
  void dispose() {
    // Para o listener do doc do usuário para evitar vazamento
    SessionManager.stopListening();
    super.dispose();
  }

  /// 🔄 Carrega dados do cache ou da internet
  Future<void> _carregarDados({bool forceRefresh = false}) async {
    setState(() => _loading = true);

    // 1) tenta cache SEMPRE
    final cacheData = await _cache.getHomeData();
    if (cacheData != null && !forceRefresh) {
      setState(() {
        _homeData = cacheData;
        _loading = false;
      });
      return;
    }

    // 2) se forçou refresh ou não tem cache, baixa da rede
    try {
      final hino = await _hymns.fetchRandomHymn(secao: _secao);
      final verse = await _verses.fetchVerseOfDay();
      final prayer = await _prayers.fetchRandomPrayer();
      final quote = await _quotes.fetchDailyQuote();
      final highlights = await _news.fetchHighlights(limit: 2);

      final data = {
        'hino': hino?.toMap(),
        'verse': verse.toMap(),
        'prayer': prayer?.toMap(),
        'quote': {'text': quote.text, 'author': quote.author},
        'highlights': highlights.map((n) => n.toMap()).toList(),
        'generatedAt': DateTime.now().toIso8601String(),
      };

      await _cache.saveHomeData(data);
      setState(() {
        _homeData = data;
        _loading = false;
      });
    } catch (e) {
      // Se der erro tentando rede, mas tinha cache antigo, você pode optar por mostrá-lo
      if (cacheData != null) {
        setState(() {
          _homeData = cacheData;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
        debugPrint('Erro ao carregar dados: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hoje = DateTime.now();
    final dataFmt = DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(hoje);

    return Scaffold(
      appBar: AppBar(
        title: const Text('HPC Digital'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar conteúdo do dia',
            onPressed: () => _carregarDados(forceRefresh: true),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _homeData == null
            ? const Center(child: Text('Erro ao carregar dados.'))
            : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 📅 Cabeçalho
            Card(
              color: cs.secondaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: cs.primary,
                      child: Icon(Icons.calendar_today, color: cs.onPrimary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DefaultTextStyle(
                        style: TextStyle(color: cs.onSecondaryContainer),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dataFmt[0].toUpperCase() + dataFmt.substring(1),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text('Inspirado pelo louvor e pela Palavra'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 🎵 Hino do Dia
            _buildHinoSection(cs),

            const SizedBox(height: 10),

            // 📖 Versículo do Dia
            _Section(
              'Versículo do Dia',
              Icons.menu_book_outlined,
              '${_homeData!['verse']?['reference']} — ${_homeData!['verse']?['text']}',
            ),

            const SizedBox(height: 10),

            // 🙏 Oração Curta
            _Section(
              'Oração Curta',
              Icons.volunteer_activism_outlined,
              _homeData!['prayer']?['texto'] ?? 'Sem oração disponível',
            ),

            const SizedBox(height: 10),

            // 🗞️ Destaques
            _buildDestaquesSection(cs),

            const SizedBox(height: 10),

            // ✨ Frase Motivacional
            _Section(
              'Frase Motivacional',
              Icons.format_quote_outlined,
              '${_homeData!['quote']?['text']} — ${_homeData!['quote']?['author']}',
            ),
          ],
        ),
      ),
    );
  }

  /// 🎵 Seção - Hino do Dia com clique
  Widget _buildHinoSection(ColorScheme cs) {
    final hino = _homeData!['hino'];
    if (hino == null) {
      return const _Section('Hino do Dia', Icons.music_note, 'Sem hino disponível');
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.music_note, color: cs.primary),
        title: Text('${hino['titulo']} — Nº ${hino['numero']}'),
        subtitle: Text(
          (hino['conteudo'] ?? '').toString().length > 100
              ? '${hino['conteudo'].toString().substring(0, 100)}...'
              : hino['conteudo'] ?? '',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () async {
          final doc = await FirebaseFirestore.instance
              .collection('hinos')
              .doc(hino['id'])
              .get();
          if (doc.exists && doc.data() != null && context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetalhesHinoScreen(hino: doc)),
            );
          }
        },
      ),
    );
  }

  /// 🗞️ Seção - Destaques da Semana com clique
  Widget _buildDestaquesSection(ColorScheme cs) {
    final destaques = (_homeData!['highlights'] as List?) ?? [];

    if (destaques.isEmpty) {
      return _Section(
        'Destaques da Semana',
        Icons.campaign_outlined,
        '🎉 Nenhum evento ou notícia programado para hoje!',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: destaques.map((d) {
        final dataFmt = DateFormat('dd/MM/yyyy').format(DateTime.parse(d['data']));
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(
              d['origem'] == 'Evento' ? Icons.event : Icons.info_outline,
              color: cs.primary,
            ),
            title: Text(d['titulo'] ?? ''),
            subtitle: Text(
              '${d['origem']} — $dataFmt\n${d['descricao'] ?? ''}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () async {
              final collection =
              d['origem'] == 'Evento' ? 'eventos' : 'informacoes';
              final doc = await FirebaseFirestore.instance
                  .collection(collection)
                  .doc(d['id'])
                  .get();

              if (!doc.exists || doc.data() == null || !context.mounted) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => d['origem'] == 'Evento'
                      ? DetalhesEventoScreen(evento: doc)
                      : DetalhesInformacaoScreen(info: doc),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}

// ==== WIDGET BASE DE SEÇÃO ====
class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final String content;

  const _Section(this.title, this.icon, this.content, {super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: cs.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(content, style: const TextStyle(height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
