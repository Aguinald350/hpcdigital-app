// import 'dart:async';
// import 'package:flutter/material.dart';
// import '../services/connectivity_service.dart';
// import '../screens/offline_required_screen.dart';
//
// class ConnectivityGate extends StatefulWidget {
//   final Widget child; // seu fluxo real (ex.: Loginscreen)
//   const ConnectivityGate({super.key, required this.child});
//
//   @override
//   State<ConnectivityGate> createState() => _ConnectivityGateState();
// }
//
// class _ConnectivityGateState extends State<ConnectivityGate> with WidgetsBindingObserver {
//   bool _online = true;
//   StreamSubscription<bool>? _sub;
//   bool _initialized = false;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _setup();
//   }
//
//   Future<void> _setup() async {
//     await ConnectivityService.instance.start();
//     _sub = ConnectivityService.instance.online$.listen((isOnline) {
//       if (!mounted) return;
//       setState(() {
//         _online = isOnline;
//         _initialized = true;
//       });
//     });
//
//     // Estado inicial
//     final first = await ConnectivityService.instance.hasRealInternet();
//     if (mounted) {
//       setState(() {
//         _online = first;
//         _initialized = true;
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _sub?.cancel();
//     super.dispose();
//   }
//
//   /// Se o app voltar do background sem internet, garantimos a tela offline.
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) async {
//     if (state == AppLifecycleState.resumed) {
//       final ok = await ConnectivityService.instance.hasRealInternet();
//       if (!mounted) return;
//       setState(() => _online = ok);
//     }
//   }
//
//   void _onReloadSuccess() async {
//     final ok = await ConnectivityService.instance.hasRealInternet();
//     if (!mounted) return;
//     if (ok) {
//       setState(() => _online = true);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Enquanto não inicializou, evita disparar telas do fluxo (auto-login etc.)
//     if (!_initialized) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator(color: Colors.deepOrange)),
//       );
//     }
//
//     if (!_online) {
//       return OfflineRequiredScreen(
//         onBecameOnline: _onReloadSuccess,
//         onBackAllowed: () => Navigator.maybePop(context),
//       );
//     }
//
//     // Internet OK → entrega o app real
//     return widget.child;
//   }
// }
/////test///

// lib/widgets/connectivity_gate.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';
import '../screens/offline_required_screen.dart';

class ConnectivityGate extends StatefulWidget {
  final Widget child; // seu fluxo real (ex.: Loginscreen)
  const ConnectivityGate({super.key, required this.child});

  @override
  State<ConnectivityGate> createState() => _ConnectivityGateState();
}

class _ConnectivityGateState extends State<ConnectivityGate> with WidgetsBindingObserver {
  bool _online = true;
  StreamSubscription<bool>? _sub;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setup();
  }

  Future<void> _setup() async {
    // inicializa serviço e pega o estado inicial
    await ConnectivityService.instance.start();

    // subscreve a stream
    _sub = ConnectivityService.instance.online$.listen((isOnline) {
      if (!mounted) return;
      setState(() {
        _online = isOnline;
        _initialized = true;
      });
    }, onError: (_) {
      if (!mounted) return;
      setState(() {
        _online = false;
        _initialized = true;
      });
    });

    // força leitura inicial também (redundante, mas seguro)
    final first = await ConnectivityService.instance.hasRealInternet();
    if (mounted) {
      setState(() {
        _online = first;
        _initialized = true;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      final ok = await ConnectivityService.instance.hasRealInternet();
      if (!mounted) return;
      setState(() => _online = ok);
    }
  }

  void _onReloadSuccess() async {
    final ok = await ConnectivityService.instance.hasRealInternet();
    if (!mounted) return;
    if (ok) {
      setState(() => _online = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Enquanto não inicializou, evita disparar telas do fluxo (auto-login etc.)
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.deepOrange)),
      );
    }

    if (!_online) {
      return OfflineRequiredScreen(
        onBecameOnline: _onReloadSuccess,
        onBackAllowed: () => Navigator.maybePop(context),
      );
    }

    // Internet OK → entrega o app real
    return widget.child;
  }
}

