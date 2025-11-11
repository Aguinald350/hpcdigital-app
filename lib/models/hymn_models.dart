import 'package:hive/hive.dart';

part 'hymn_models.g.dart';

@HiveType(typeId: 0)
class HymnOfDay {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String numero;
  @HiveField(2)
  final String titulo;
  @HiveField(3)
  final String conteudo;
  @HiveField(4)
  final String secao;
  @HiveField(5)
  final String lingua;

  HymnOfDay({
    required this.id,
    required this.numero,
    required this.titulo,
    required this.conteudo,
    required this.secao,
    required this.lingua, // ✅ agora o parâmetro existe
  });

  factory HymnOfDay.fromMap(String id, Map<String, dynamic> data) {
    return HymnOfDay(
      id: id,
      numero: (data['numero'] ?? '').toString(),
      titulo: (data['titulo'] ?? '').toString(),
      conteudo: (data['conteudo'] ?? '').toString(),
      secao: (data['secao'] ?? 'Outros').toString(),
      lingua: (data['lingua'] ?? 'Português').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero': numero,
      'titulo': titulo,
      'conteudo': conteudo,
      'secao': secao,
      'lingua': lingua,
    };
  }
}
