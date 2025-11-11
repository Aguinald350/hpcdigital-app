// lib/screens/conf/widgets/helpers.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hpcdigital/screens/conf/widgets/tipos_conta.dart';


/// Converte diversos formatos para DateTime?
/// Aceita: Timestamp, DateTime, String (ISO), null
DateTime? toDate(dynamic v) {
  if (v == null) return null;
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  if (v is String) {
    try {
      return DateTime.parse(v);
    } catch (_) {
      return null;
    }
  }
  return null;
}

/// Retorna um resumo simples: Free (em teste) OU Plus (paga)
TipoContaResumo accountType(
    DateTime? trialEndsAt,
    DateTime? activeFrom,
    DateTime? activeUntil,
    ) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // 1) Se está dentro do período pago -> Plus
  if (activeFrom != null &&
      activeUntil != null &&
      !today.isBefore(DateTime(activeFrom.year, activeFrom.month, activeFrom.day)) &&
      !today.isAfter(DateTime(activeUntil.year, activeUntil.month, activeUntil.day))) {
    final dias = activeUntil.difference(today).inDays;
    return TipoContaResumo('Plus — ${dias}d restantes', Colors.green);
  }

  // 2) Caso contrário: Free (sempre como "em teste")
  // Se há trialEndsAt e ainda não expirou: mostrar dias
  if (trialEndsAt != null && today.isBefore(DateTime(trialEndsAt.year, trialEndsAt.month, trialEndsAt.day))) {
    final dias = trialEndsAt.difference(today).inDays;
    return TipoContaResumo('Free (em teste) — ${dias}d restantes', Colors.orange);
  }

  // 3) Padrão: Free (em teste) sem contagem específica
  return TipoContaResumo('Free (em teste)', Colors.orange);
}

/// Widget reutilizável de cabeçalho de seção
Widget sectionHeader(BuildContext context, String title) => Text(
  title,
  style: TextStyle(
    fontWeight: FontWeight.w800,
    color: Theme.of(context).colorScheme.primary,
    fontSize: 16,
  ),
);

class CenteredMsg extends StatelessWidget {
  final String text;
  const CenteredMsg(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Center(child: Text(text, textAlign: TextAlign.center));
}

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorStateWidget({super.key, required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    ),
  );
}
