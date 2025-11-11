// lib/models/prayer_model.dart
class ShortPrayer {
  final String id;
  final String titulo;
  final String texto;
  final String tema;

  ShortPrayer({
    required this.id,
    required this.titulo,
    required this.texto,
    required this.tema,
  });

  factory ShortPrayer.fromMap(String id, Map<String, dynamic> data) {
    return ShortPrayer(
      id: id,
      titulo: (data['titulo'] ?? '').toString(),
      texto: (data['texto'] ?? '').toString(),
      tema: (data['tema'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'texto': texto,
      'tema': tema,
    };
  }
}
