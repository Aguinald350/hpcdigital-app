// lib/screens/conf/perfil_detalhado_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widgets/tipos_conta.dart';
import 'widgets/helpers.dart';

class PerfilDetalhadoScreen extends StatefulWidget {
  final String uid;
  final String nome;
  final String email;

  const PerfilDetalhadoScreen({
    super.key,
    required this.uid,
    required this.nome,
    required this.email,
  });

  @override
  State<PerfilDetalhadoScreen> createState() => _PerfilDetalhadoScreenState();
}

class _PerfilDetalhadoScreenState extends State<PerfilDetalhadoScreen> {
  bool _loading = true;
  bool _saving = false;
  Map<String, dynamic> _data = {};

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeCtrl;
  late TextEditingController _telCtrl;

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.nome);
    _telCtrl = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final snap = await FirebaseFirestore.instance.collection('usuarios').doc(widget.uid).get();
    final d = snap.data() ?? {};
    _data = d;
    _telCtrl.text = (d['telefone'] ?? '').toString();
    if (mounted) setState(() => _loading = false);
  }

  DateTime? _toDate(dynamic v) => toDate(v);

  TipoContaDetalhe _tipoConta() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final trialEndsAt = _toDate(_data['trialEndsAt']);
    final activeFrom = _toDate(_data['activeFrom']);
    final activeUntil = _toDate(_data['activeUntil']);

    // 1) Plus (paga) se dentro do período
    if (activeFrom != null &&
        activeUntil != null &&
        !today.isBefore(DateTime(activeFrom.year, activeFrom.month, activeFrom.day)) &&
        !today.isAfter(DateTime(activeUntil.year, activeUntil.month, activeUntil.day))) {
      final dias = activeUntil.difference(today).inDays;
      return TipoContaDetalhe(
        label: 'Plus (Paga)',
        descricao: '$dias dias restantes',
        color: Colors.green,
        diasRestantes: dias,
        isTrial: false,
      );
    }

    // 2) Free (em teste) — se houver trial válido, mostra dias; se não houver, mostra sem dias
    if (trialEndsAt != null && today.isBefore(DateTime(trialEndsAt.year, trialEndsAt.month, trialEndsAt.day))) {
      final dias = trialEndsAt.difference(today).inDays;
      return TipoContaDetalhe(
        label: 'Free (em teste)',
        descricao: 'Expira em $dias dias',
        color: Colors.orange,
        diasRestantes: dias,
        isTrial: true,
      );
    }

    // 3) Default: Free (em teste) sem contagem — tratamos sempre como "Free (em teste)"
    return TipoContaDetalhe(
      label: 'Free (em teste)',
      descricao: 'Conta Free (teste)',
      color: Colors.orange,
      diasRestantes: 0,
      isTrial: true,
    );
  }

  bool _deveMostrarBanner(TipoContaDetalhe tipo) {
    // Sempre mostrar banner para trial (Free)
    if (tipo.isTrial) return true;
    // Para Plus, mostrar somente se faltarem 7 dias ou menos
    return !tipo.isTrial && tipo.diasRestantes <= 7 && tipo.diasRestantes >= 0;
  }

  // ===== WhatsApp Upgrade (único fluxo) =====
  Future<void> _abrirWhatsappUpgrade() async {
    const suporte = '244925780193'; // sem "+"

    final tipo = _tipoConta();
    final nome = _nomeCtrl.text.trim().isEmpty ? widget.nome : _nomeCtrl.text.trim();

    final msg = [
      'Saudações 👋',
      'Quero fazer upgrade do meu plano.',
      '— Nome: $nome',
      '— Email: ${widget.email}',
      '— UID: ${widget.uid}',
      '— Tipo atual: ${tipo.label} (${tipo.descricao})',
    ].join('\n');

    // 1) tenta abrir o app do WhatsApp
    final uriWhats = Uri.parse('whatsapp://send?phone=$suporte&text=${Uri.encodeComponent(msg)}');
    try {
      final ok = await launchUrl(uriWhats, mode: LaunchMode.externalApplication);
      if (ok) return;
    } catch (_) {}

    // 2) fallback via wa.me (navegador → WhatsApp)
    final uriWaMe = Uri.parse('https://wa.me/$suporte?text=${Uri.encodeComponent(msg)}');
    try {
      final ok = await launchUrl(uriWaMe, mode: LaunchMode.externalApplication);
      if (ok) return;
    } catch (_) {}

    // 3) se nada deu certo, mostra uma folha com opções
    if (!mounted) return;
    _showWhatsappHelpSheet(suporte, msg);
  }

  void _showWhatsappHelpSheet(String telefone, String msg) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.support_agent, size: 32),
              const SizedBox(height: 8),
              const Text('Abrir WhatsApp', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 8),
              Text('Não consegui abrir o WhatsApp automaticamente. Toque em uma das opções abaixo:',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.black.withOpacity(.7))),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () async {
                  final uri = Uri.parse('https://wa.me/$telefone?text=${Uri.encodeComponent(msg)}');
                  Navigator.of(context).pop();
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Abrir via wa.me'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: telefone));
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(behavior: SnackBarBehavior.floating, content: Text('Telefone copiado. Abra o WhatsApp e cole na busca.')),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copiar telefone do suporte'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _salvarPerfil() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(_nomeCtrl.text.trim());
      }

      await FirebaseFirestore.instance.collection('usuarios').doc(widget.uid).set(
        {
          'nome': _nomeCtrl.text.trim(),
          'telefone': _telCtrl.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil atualizado!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tipo = _tipoConta();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          children: [
            if (_deveMostrarBanner(tipo))
              BannerPremium(
                message: tipo.isTrial
                    ? 'Sua conta Free (teste). ${tipo.diasRestantes > 0 ? 'Expira em ${tipo.diasRestantes} dia(s).' : ''}'
                    : 'Sua assinatura Plus expira em ${tipo.diasRestantes} dia(s).',
                buttonLabel: 'Fazer upgrade',
                onPressed: _abrirWhatsappUpgrade,
              ),
            const SizedBox(height: 12),

            // Cabeçalho
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cs.secondaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: cs.primary.withOpacity(.12),
                    child: Text(
                      _initials(widget.nome),
                      style: TextStyle(color: cs.primary, fontWeight: FontWeight.w800, fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.nome, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text(widget.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: tipo.color.withOpacity(.12),
                            border: Border.all(color: tipo.color),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Tipo de conta: ${tipo.label} — ${tipo.descricao}',
                            style: TextStyle(color: tipo.color, fontWeight: FontWeight.w700, fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Formulário
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Informações da conta', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w800, fontSize: 16)),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 1.5,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nomeCtrl,
                        decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(labelText: 'Email', hintText: widget.email, border: const OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _telCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Telefone', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saving ? null : _salvarPerfil,
                          icon: const Icon(Icons.save),
                          label: _saving ? const Text('Salvando...') : const Text('Salvar alterações'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String nome) {
    final parts = nome.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    String first = parts.isNotEmpty ? parts.first[0] : '?';
    String last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }
}

/// ======================
/// BannerPremium embutido
/// ======================
class BannerPremium extends StatelessWidget {
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;
  const BannerPremium({super.key, required this.message, required this.buttonLabel, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(child: Text(message, style: TextStyle(color: cs.onPrimaryContainer))),
          const SizedBox(width: 12),
          FilledButton(onPressed: onPressed, child: Text(buttonLabel)),
        ],
      ),
    );
  }
}
