// lib/services/liturgy_service.dart
import 'package:intl/intl.dart';

class LiturgyService {
  // TODO: Trocar por calendário litúrgico real (Firestore/endpoint próprio)
  String themeFor(DateTime d) {
    final m = d.month;
    if (m == 12) return 'Advento';
    if (m == 4) return 'Páscoa';
    if (m == 6 || m == 7) return 'Tempo de Reflexão';
    return 'Tempo Comum';
  }

  String docIdHoje() => DateFormat('yyyyMMdd').format(DateTime.now());
}
