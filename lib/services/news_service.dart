import 'package:cloud_firestore/cloud_firestore.dart';

class NewsHighlight {
  final String id;          // ID do documento
  final String titulo;
  final String descricao;
  final String origem;      // "Evento" ou "Informação"
  final DateTime data;

  NewsHighlight({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.origem,
    required this.data,
  });

  /// 🔹 Construtor a partir de um Map (opcional, para compatibilidade futura)
  factory NewsHighlight.fromMap(Map<String, dynamic> data, String id) {
    return NewsHighlight(
      id: id,
      titulo: data['titulo'] ?? '',
      descricao: data['descricao'] ?? '',
      origem: data['origem'] ?? '',
      data: DateTime.tryParse(data['data'] ?? '') ?? DateTime.now(),
    );
  }

  /// 🔹 Converte para Map (para cache e JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'origem': origem,
      'data': data.toIso8601String(),
    };
  }
}

class NewsService {
  final _db = FirebaseFirestore.instance;

  /// Retorna os destaques (até 2) futuros ou do dia
  Future<List<NewsHighlight>> fetchHighlights({int limit = 2}) async {
    final List<NewsHighlight> items = [];
    final agora = DateTime.now();

    try {
      // 🔹 Eventos futuros ou de hoje
      final eventosSnap = await _db
          .collection('eventos')
          .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(
        DateTime(agora.year, agora.month, agora.day),
      ))
          .orderBy('data', descending: false)
          .limit(limit)
          .get();

      for (final doc in eventosSnap.docs) {
        final data = doc.data();
        final nome = (data['nome'] ?? '').toString();
        final descricao = (data['descricao'] ?? '').toString();
        final dataEvento = (data['data'] as Timestamp?)?.toDate() ?? DateTime.now();

        items.add(
          NewsHighlight(
            id: doc.id,
            titulo: nome.isEmpty ? 'Evento' : nome,
            descricao: descricao,
            origem: 'Evento',
            data: dataEvento,
          ),
        );
      }

      // 🔹 Informações recentes (últimos 5 dias)
      final cincoDiasAtras = agora.subtract(const Duration(days: 5));
      final infosSnap = await _db
          .collection('informacoes')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(cincoDiasAtras))
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      for (final doc in infosSnap.docs) {
        final data = doc.data();
        final titulo = (data['titulo'] ?? '').toString();
        final descricao = (data['descricao'] ?? '').toString();
        final dataCriacao = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

        items.add(
          NewsHighlight(
            id: doc.id,
            titulo: titulo.isEmpty ? 'Informação' : titulo,
            descricao: descricao,
            origem: 'Informação',
            data: dataCriacao,
          ),
        );
      }

      // 🔹 Ordena e limita
      items.sort((a, b) => a.data.compareTo(b.data));
      final filtrados = items.take(limit).toList();

      return filtrados;
    } catch (e) {
      print('Erro ao buscar destaques: $e');
      return [];
    }
  }
}
