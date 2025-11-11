// lib/admin/editar_informacao_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ⬇️ ajuste o caminho do seu shell
import 'widgets/admin_shell.dart';

class EditarInformacaoScreen extends StatefulWidget {
  final DocumentReference<Map<String, dynamic>> ref;

  const EditarInformacaoScreen({super.key, required this.ref});

  @override
  State<EditarInformacaoScreen> createState() => _EditarInformacaoScreenState();
}

class _EditarInformacaoScreenState extends State<EditarInformacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  bool _loading = true;
  bool _salvando = false;
  String? _classe;

  static const _classes = <String>[
    'Todos',
    'criancas',
    'JIMUA',
    'OJA',
    'Org.Mulheres',
    'Org.Homens',
  ];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final snap = await widget.ref.get();
      final m = snap.data() ?? {};
      _tituloCtrl.text = (m['titulo'] ?? '').toString();
      _descCtrl.text = (m['descricao'] ?? '').toString();
      _classe = (m['classe'] ?? '').toString().isEmpty ? null : (m['classe'] as String);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar: $e')));
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);
    try {
      await widget.ref.update({
        'titulo': _tituloCtrl.text.trim(),
        'descricao': _descCtrl.text.trim(),
        'classe': _classe ?? 'Todos',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informação atualizada!')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _apagar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Apagar informação'),
        content: const Text('Tem certeza que deseja apagar esta informação?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await widget.ref.delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informação apagada.')));
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao apagar: $e')));
        }
      }
    }
  }

  InputDecoration _dec(String label) => const InputDecoration(
    labelText: '',
  ).copyWith(
    labelText: label,
    border: const OutlineInputBorder(),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.deepOrange, width: 2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Editar Informação',
      currentIndex: 7,
      actions: [
        IconButton(
          tooltip: 'Apagar',
          onPressed: _salvando ? null : _apagar,
          icon: const Icon(Icons.delete_outline, color: Colors.white),
        ),
      ],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _tituloCtrl,
                    decoration: _dec('Título'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o título' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _classe,
                    isExpanded: true,
                    items: _classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _classe = v),
                    decoration: _dec('Público / Classe'),
                    validator: (v) => v == null ? 'Selecione a classe' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descCtrl,
                    minLines: 4,
                    maxLines: 8,
                    decoration: _dec('Descrição'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe a descrição' : null,
                  ),
                  const SizedBox(height: 24),
                  _salvando
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                    onPressed: _salvar,
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar alterações'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
