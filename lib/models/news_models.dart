class NewsHighlight {
  final String id;
  final String titulo;
  final String descricao;
  final String origem;
  final DateTime data;

  NewsHighlight({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.origem,
    required this.data,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'titulo': titulo,
    'descricao': descricao,
    'origem': origem,
    'data': data.toIso8601String(),
  };
}
