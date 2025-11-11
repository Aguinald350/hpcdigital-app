// lib/services/session_manager.dart
import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

/// Erro lançado quando a conta já está em uso em outro dispositivo.
class SessionInUseException implements Exception {
  final String? currentSessionId;
  SessionInUseException([this.currentSessionId]);
  @override
  String toString() => 'SessionInUseException(current=$currentSessionId)';
}

/// Serviço para garantir **sessão única** por usuário.
/// Usa o campo `currentSessionId` no doc `/usuarios/{uid}`.
class SessionManager {
  static const _prefsKey = 'hpc_local_session_id';
  static const _prefsHeartbeatKey = 'hpc_local_session_heartbeat_ms';
  static StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _docSub;
  static Timer? _heartbeatTimer;

  /// Janela de tolerância para considerar uma sessão remota como "estagnada".
  /// Se `sessionUpdatedAt` for mais antigo que isso, permitimos takeover.
  static const Duration kStaleTolerance = Duration(minutes: 5);

  /// Gera um ID de sessão com carimbo + random.
  static String _generateSessionId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rnd = Random().nextInt(1 << 32).toRadixString(16).padLeft(8, '0');
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'nouid';
    return '$ts-$rnd-$uid';
  }

  /// Salva/obtém sessionId local (SharedPreferences)
  static Future<void> _saveLocalSessionId(String id) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_prefsKey, id);
  }

  static Future<String?> localSessionId() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_prefsKey);
  }

  static Future<void> clearLocalSession() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_prefsKey);
    await p.remove(_prefsHeartbeatKey);
  }

  /// Marca último heartbeat local (para debug/telemetria).
  static Future<void> _markLocalHeartbeat() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_prefsHeartbeatKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Inicia/“reclama” a sessão de forma **transacional**, com tolerância a sessão órfã:
  ///
  /// - Se não houver `currentSessionId` → grava o nosso e segue.
  /// - Se houver **igual** ao nosso → só atualiza timestamp.
  /// - Se houver **diferente**, mas o `sessionUpdatedAt` for mais antigo que [kStaleTolerance],
  ///   consideramos órfã → fazemos **takeover** (gravamos o nosso).
  /// - Caso contrário, lança [SessionInUseException].
  static Future<String> claimOrStart(String uid) async {
    final userRef = FirebaseFirestore.instance.collection('usuarios').doc(uid);

    // garanta que temos um sessionId local ANTES de iniciar o listener
    String? local = await localSessionId();
    local ??= _generateSessionId();
    await _saveLocalSessionId(local);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(userRef);
      final data = snap.data() ?? {};

      final String remoteId = (data['currentSessionId'] ?? '').toString();
      final Timestamp? ts = data['sessionUpdatedAt'] as Timestamp?;
      final DateTime? lastSeen = ts?.toDate();

      if (remoteId.isEmpty) {
        // livre → grava o nosso
        tx.set(userRef, {
          'currentSessionId': local,
          'sessionUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return;
      }

      if (remoteId == local) {
        // já é nosso → atualiza timestamp
        tx.set(userRef, {
          'sessionUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return;
      }

      // remoto é de outro device → verificar se está “stale”
      final now = DateTime.now();
      final isStale = lastSeen == null || now.difference(lastSeen) > kStaleTolerance;

      if (isStale) {
        // sessão antiga/órfã → takeover
        tx.set(userRef, {
          'currentSessionId': local,
          'sessionUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return;
      }

      // sessão ativa em outro device
      throw SessionInUseException(remoteId);
    });

    return local;
  }

  /// Opcional: atualiza `sessionUpdatedAt` periodicamente
  static void startHeartbeat(String uid, {Duration interval = const Duration(seconds: 30)}) {
    stopHeartbeat();
    _heartbeatTimer = Timer.periodic(interval, (_) async {
      final ref = FirebaseFirestore.instance.collection('usuarios').doc(uid);
      try {
        await ref.set({
          'sessionUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        await _markLocalHeartbeat();
      } catch (e) {
        debugPrint('[SessionManager] heartbeat error: $e');
      }
    });
  }

  static void stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Listener do documento do usuário:
  /// se o `currentSessionId` remoto mudar e não for o nosso, dispara callback.
  static void startListeningToUserDoc({
    required String uid,
    required void Function(String? remoteSessionId) onSessionMismatch,
  }) {
    stopListening();
    final ref = FirebaseFirestore.instance.collection('usuarios').doc(uid);
    _docSub = ref.snapshots().listen((snap) async {
      if (!snap.exists) return;
      final data = snap.data() ?? {};
      final String remote = (data['currentSessionId'] ?? '').toString();
      final local = await localSessionId();

      if ((local ?? '').isEmpty) return; // se ainda não setamos local, ignore
      if (remote.isEmpty) return;        // se remoto limpo, ok
      if (remote != local) {
        debugPrint('[SessionManager] ⚠️ Mismatch — remoto: $remote | local: $local');
        onSessionMismatch(remote);
      }
    }, onError: (e) {
      debugPrint('[SessionManager] listen error: $e');
    });
  }

  static void stopListening() {
    _docSub?.cancel();
    _docSub = null;
  }

  /// (Opcional) “reclamar” sessão novamente manualmente
  static Future<void> reclaimSession(String uid) async {
    final local = await localSessionId();
    if (local == null) return;
    await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
      'currentSessionId': local,
      'sessionUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Finaliza sessão: para batimentos/listeners, limpa local e, se quiser, zera remoto.
  static Future<void> endSession(String uid, {bool clearRemote = false}) async {
    stopHeartbeat();
    stopListening();
    await clearLocalSession();
    if (clearRemote) {
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'currentSessionId': null,
        'sessionUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  /// 🔒 Wipe de dados locais (use no logout)
  /// - SharedPreferences.clear()
  /// - Hive.deleteFromDisk()
  /// - Limpa caches de imagem do Flutter
  static Future<void> wipeLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      debugPrint('[SessionManager] prefs.clear error: $e');
    }

    try {
      // fecha e apaga tudo do Hive (se você usa Hive)
      await Hive.close();
      await Hive.deleteFromDisk();
    } catch (e) {
      debugPrint('[SessionManager] hive wipe error: $e');
    }

    try {
      // limpa image cache (thumbnails, etc.)
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    } catch (e) {
      debugPrint('[SessionManager] image cache clear error: $e');
    }
  }
}
