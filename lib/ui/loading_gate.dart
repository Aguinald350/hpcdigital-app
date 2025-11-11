// lib/ui/loading_gate.dart
import 'dart:async';
import 'package:flutter/material.dart';

// ⬇️ Garanta que o caminho/capitalização do arquivo da Home está correto
import '../screens/homescreen.dart'; // ou '../screens/HomeScreen.dart'
import '../services/home_prefetcher.dart';

class LoadingGate extends StatefulWidget {
  final bool force; // se quiser forçar download mesmo no mesmo dia
  const LoadingGate({super.key, this.force = false});

  @override
  State<LoadingGate> createState() => _LoadingGateState();
}

class _LoadingGateState extends State<LoadingGate> {
  String? _error;
  bool _loading = true;

  final _prefetcher = HomePrefetcher();

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _prefetcher.ensureReady(force: widget.force);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Homescreen()),
      );
    } on TimeoutException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Tempo esgotado. Verifique sua conexão e tente novamente.\n$e';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erro ao preparar dados da Home: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _loading
                ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Preparando sua experiência...',
                  style: TextStyle(color: cs.onSurface, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            )
                : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Não foi possível preparar a Home:\n$_error',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _start,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
