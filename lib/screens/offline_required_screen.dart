// import 'package:flutter/material.dart';
// import '../services/connectivity_service.dart';
//
// /// Tela full-screen exibida quando não há internet.
// /// Possui botão "Recarregar" para reprocessar do zero (evita freeze).
// class OfflineRequiredScreen extends StatefulWidget {
//   final VoidCallback? onBackAllowed; // opcional para fechar app/voltar
//   final VoidCallback? onBecameOnline; // chamado quando voltar a ficar online
//   const OfflineRequiredScreen({super.key, this.onBackAllowed, this.onBecameOnline});
//
//   @override
//   State<OfflineRequiredScreen> createState() => _OfflineRequiredScreenState();
// }
//
// class _OfflineRequiredScreenState extends State<OfflineRequiredScreen> {
//   bool _checking = false;
//   String? _lastError;
//
//   Future<void> _reload() async {
//     setState(() {
//       _checking = true;
//       _lastError = null;
//     });
//
//     final online = await ConnectivityService.instance.hasRealInternet();
//
//     if (!mounted) return;
//     if (online) {
//       // Voltou a ter internet: avisa o "gate" para liberar a navegação
//       widget.onBecameOnline?.call();
//     } else {
//       setState(() {
//         _checking = false;
//         _lastError = 'Ainda sem conexão. Verifique dados/Wi-Fi e tente novamente.';
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Center(
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 480),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(Icons.wifi_off, size: 72, color: Colors.deepOrange),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Conecte-se para usar o app',
//                     textAlign: TextAlign.center,
//                     style: theme.textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.deepOrange,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   const Text(
//                     'Parece que você está sem internet. Ligue os dados ou o Wi-Fi para continuar.',
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 24),
//                   _checking
//                       ? const CircularProgressIndicator(color: Colors.deepOrange)
//                       : FilledButton.icon(
//                     style: FilledButton.styleFrom(
//                       minimumSize: const Size(double.infinity, 48),
//                       backgroundColor: Colors.deepOrange,
//                     ),
//                     onPressed: _reload,
//                     icon: const Icon(Icons.refresh),
//                     label: const Text('Recarregar'),
//                   ),
//                   if (_lastError != null) ...[
//                     const SizedBox(height: 12),
//                     Text(
//                       _lastError!,
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(color: Colors.redAccent),
//                     ),
//                   ],
//                   const SizedBox(height: 8),
//                   TextButton.icon(
//                     onPressed: widget.onBackAllowed,
//                     icon: const Icon(Icons.exit_to_app),
//                     label: const Text('Sair / Voltar'),
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// lib/screens/offline_required_screen.dart
import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';

/// Tela full-screen exibida quando não há internet.
/// Possui botão "Recarregar" para reprocessar do zero (evita freeze).
class OfflineRequiredScreen extends StatefulWidget {
  final VoidCallback? onBackAllowed; // opcional para fechar app/voltar
  final VoidCallback? onBecameOnline; // chamado quando voltar a ficar online
  const OfflineRequiredScreen({super.key, this.onBackAllowed, this.onBecameOnline});

  @override
  State<OfflineRequiredScreen> createState() => _OfflineRequiredScreenState();
}

class _OfflineRequiredScreenState extends State<OfflineRequiredScreen> {
  bool _checking = false;
  String? _lastError;

  Future<void> _reload() async {
    if (_checking) return;
    setState(() {
      _checking = true;
      _lastError = null;
    });

    final online = await ConnectivityService.instance.hasRealInternet();

    if (!mounted) return;
    if (online) {
      // Voltou a ter internet: avisa o "gate" para liberar a navegação
      widget.onBecameOnline?.call();
    } else {
      setState(() {
        _checking = false;
        _lastError = 'Ainda sem conexão. Verifique dados/Wi-Fi e tente novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off, size: 72, color: Colors.deepOrange),
                  const SizedBox(height: 16),
                  Text(
                    'Conecte-se para usar o app',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Parece que você está sem internet. Ligue os dados ou o Wi-Fi para continuar.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _checking
                      ? const CircularProgressIndicator(color: Colors.deepOrange)
                      : FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: Colors.deepOrange,
                    ),
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Recarregar'),
                  ),
                  if (_lastError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _lastError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ],
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: widget.onBackAllowed,
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text('Sair / Voltar'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
