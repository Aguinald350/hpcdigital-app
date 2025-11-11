// lib/services/firestore_retry.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreRetry {
  /// Faz get() com timeout e retry exponencial (para Firestore falhando com "unavailable")
  static Future<DocumentSnapshot<Map<String, dynamic>>?> getDocWithRetry({
    required DocumentReference<Map<String, dynamic>> ref,
    int maxAttempts = 4,
    Duration initialDelay = const Duration(seconds: 2),
    Duration timeout = const Duration(seconds: 10),
  }) async {
    Duration delay = initialDelay;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final snap = await ref.get().timeout(timeout);
        return snap;
      } on TimeoutException {
        debugPrint('[FirestoreRetry] Timeout na tentativa $attempt');
      } on FirebaseException catch (e) {
        debugPrint('[FirestoreRetry] Erro ${e.code} na tentativa $attempt');
        if (e.code != 'unavailable' && e.code != 'deadline-exceeded') {
          rethrow;
        }
      } catch (e) {
        debugPrint('[FirestoreRetry] Erro inesperado $e');
      }

      await Future.delayed(delay);
      delay *= 2;
    }
    return null;
  }

  /// Mostra um diálogo amigável ao usuário para tentar novamente
  static Future<bool> showRetryDialog(BuildContext context, {String? message}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Erro de Conexão'),
        content: Text(
          message ??
              'Não foi possível comunicar com o servidor.\n'
                  'Verifique sua internet e tente novamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
