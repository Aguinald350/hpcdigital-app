// lib/screens/verify_email_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/Navegation.dart'; // troque para sua Home/Navegação depois da verificação

class VerifiqueEmailScreen extends StatefulWidget {
  const VerifiqueEmailScreen({super.key});

  @override
  State<VerifiqueEmailScreen> createState() => _VerifiqueEmailScreenState();
}

class _VerifiqueEmailScreenState extends State<VerifiqueEmailScreen> {
  bool _sending = false;
  bool _checking = false;

  Future<void> _reenviar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _sending = true);
    try {
      await FirebaseAuth.instance.setLanguageCode('pt');
      await user.sendEmailVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail de verificação reenviado!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao reenviar: $e')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _jaVerifiquei() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _checking = true);
    try {
      await user.reload();
      final refreshed = FirebaseAuth.instance.currentUser;
      if (refreshed != null && refreshed.emailVerified) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const Navegation_Screen()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ainda não verificado. Confira seu e-mail.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao checar: $e')),
      );
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Verifique seu e-mail')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mark_email_unread, size: 64, color: cs.primary),
            const SizedBox(height: 12),
            const Text(
              'Enviamos um link de verificação para seu e-mail.\n'
                  'Abra a mensagem e toque em “Verificar”.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _sending ? null : _reenviar,
              child: _sending ? const CircularProgressIndicator() : const Text('Reenviar e-mail'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _checking ? null : _jaVerifiquei,
              child: _checking ? const CircularProgressIndicator() : const Text('Já verifiquei'),
            ),
          ],
        ),
      ),
    );
  }
}
