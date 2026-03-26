// lib/admin/users/generate_verification_link_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';

class GenerateVerificationLinkScreen extends StatefulWidget {
  const GenerateVerificationLinkScreen({super.key});

  @override
  State<GenerateVerificationLinkScreen> createState() => _GenerateVerificationLinkScreenState();
}

class _GenerateVerificationLinkScreenState extends State<GenerateVerificationLinkScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _lastLink;
  String? _error;

  // Região onde as functions estão (usa a mesma que tens: africa-south1)
  final _functions = FirebaseFunctions.instanceFor(region: 'africa-south1');

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _generateLink() async {
    setState(() {
      _loading = true;
      _error = null;
      _lastLink = null;
    });

    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !_isValidEmail(email)) {
      setState(() {
        _loading = false;
        _error = 'Insere um email válido.';
      });
      return;
    }

    try {
      final callable = _functions.httpsCallable('generateVerificationLink');
      final resp = await callable.call(<String, dynamic>{'email': email});
      final data = resp.data;
      final link = data != null && data['link'] != null ? data['link'] as String : null;
      if (link == null) {
        setState(() {
          _error = 'Resposta inesperada do servidor.';
          _loading = false;
        });
        return;
      }

      setState(() {
        _lastLink = link;
        _loading = false;
      });

      // mostra snackbar com ação copiar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Link gerado. Usa copiar/abrir para compartilhar.'),
          action: SnackBarAction(
            label: 'Copiar',
            onPressed: () {
              // usar link local para evitar promoção de campo não-final
              final l = link;
              Clipboard.setData(ClipboardData(text: l));
            },
          ),
        ));
      }
    } on FirebaseFunctionsException catch (e) {
      setState(() {
        _error = e.message ?? 'Erro na função: ${e.code}';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro interno: ${e.toString()}';
        _loading = false;
      });
    }
  }

  bool _isValidEmail(String s) {
    final re = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");
    return re.hasMatch(s);
  }

  Future<void> _copyLink() async {
    final link = _lastLink;
    if (link == null) return;
    await Clipboard.setData(ClipboardData(text: link));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copiado para a área de transferência.')));
  }

  Future<void> _openLink() async {
    final link = _lastLink;
    if (link == null) return;
    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível abrir o link.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerar link de verificação'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Insere o e-mail do usuário e gera o link de verificação. Depois copia e envia por WhatsApp.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email do usuário',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Obrigatório';
                        if (!_isValidEmail(v.trim())) return 'Email inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _loading
                        ? null
                        : () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _generateLink();
                      }
                    },
                    icon: _loading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.link),
                    label: const Text('Gerar'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
            ],
            if (_lastLink != null) ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Link gerado:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SelectableText(_lastLink!),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _copyLink,
                            icon: const Icon(Icons.copy),
                            label: const Text('Copiar'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _openLink,
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Abrir'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () {
                              final link = _lastLink;
                              if (link == null) return;
                              // montar mensagem WhatsApp (abre wa.me com texto)
                              final text = Uri.encodeComponent('Olá — segue link para verificar email:\n\n$link');
                              final wa = 'https://wa.me/?text=$text';
                              launchUrl(Uri.parse(wa), mode: LaunchMode.externalApplication);
                            },
                            icon: const Icon(Icons.send),
                            label: const Text('Enviar Whatsapp'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Spacer(),
            const Text('Nota: a função exige que o admin tenha custom claim `admin: true`.'),
          ],
        ),
      ),
    );
  }
}
