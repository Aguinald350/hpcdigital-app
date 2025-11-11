// lib/services/connectivity_service.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Serviço central de conectividade (stream + checagem "real" de internet)
class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  final InternetConnection _internetChecker = InternetConnection();

  // 🔧 CORRIGIDO: agora StreamSubscription<List<ConnectivityResult>>
  StreamSubscription<List<ConnectivityResult>>? _connSub;

  final StreamController<bool> _onlineCtrl = StreamController<bool>.broadcast();

  /// Stream pública: true = online, false = offline
  Stream<bool> get online$ => _onlineCtrl.stream;

  /// Inicia a escuta de mudanças de rede e publica "online real".
  Future<void> start() async {
    // Emite estado inicial
    _onlineCtrl.add(await hasRealInternet());

    // 🔧 Corrigido para receber List<ConnectivityResult>
    _connSub ??= _connectivity.onConnectivityChanged.listen((results) async {
      // A lista pode estar vazia em casos raros; consideramos offline
      final hasConnection =
          results.isNotEmpty && results.any((r) => r != ConnectivityResult.none);
      if (!hasConnection) {
        _onlineCtrl.add(false);
      } else {
        _onlineCtrl.add(await hasRealInternet());
      }
    });
  }

  Future<void> dispose() async {
    await _connSub?.cancel();
    _connSub = null;
    await _onlineCtrl.close();
  }

  /// Checagem “real”: precisa ter rota externa respondendo.
  Future<bool> hasRealInternet() async {
    try {
      return await _internetChecker.hasInternetAccess; // ping DNS/provedores
    } catch (_) {
      return false;
    }
  }
}

