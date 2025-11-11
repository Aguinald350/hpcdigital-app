// lib/admin/CadastrarInformacaoScreen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Tela para cadastrar uma informação/aviso.
/// - Use embedded:true quando for exibir dentro do painel (AdminShell).
class CadastrarInformacaoScreen extends StatefulWidget {
  const CadastrarInformacaoScreen({super.key, this.embedded = false});

  /// Se true, não cria AppBar próprio (para ser usado dentro do shell do admin)
  final bool embedded;

  @override
  State<CadastrarInformacaoScreen> createState() => _CadastrarInformacaoScreenState();
}

class _CadastrarInformacaoScreenState extends State<CadastrarInformacaoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _tituloCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();

  String? _classeSelecionada;
  bool _salvando = false;

  // Caso você já tenha esta lista em constants.dart, importe-a e use aqui:
  static const List<String> _categorias = <String>[
    'Todos',
    'criancas',
    'JIMUA',
    'OJA',
    'Org.Mulheres',
    'Org.Homens',
  ];

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descricaoCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    try {
      await FirebaseFirestore.instance.collection('informacoes').add({
        'titulo': _tituloCtrl.text.trim(),
        'descricao': _descricaoCtrl.text.trim(),
        'classe': _classeSelecionada,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informação cadastrada com sucesso!')),
      );

      // Se estiver embutido no painel, apenas limpa; se estiver sozinho, pode voltar.
      if (widget.embedded) {
        _formKey.currentState!.reset();
        setState(() => _classeSelecionada = null);
        _tituloCtrl.clear();
        _descricaoCtrl.clear();
      } else {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Material(
            color: Colors.white,
            elevation: 1,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Text(
                      'Cadastrar Informação / Aviso',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Título
                    TextFormField(
                      controller: _tituloCtrl,
                      decoration: _dec('Título (ex.: Aviso — JIMUA / Todos...)'),
                      textInputAction: TextInputAction.next,
                      maxLength: 80,
                      validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Informe o título' : null,
                    ),
                    const SizedBox(height: 12),

                    // Público-alvo
                    DropdownButtonFormField<String>(
                      value: _classeSelecionada,
                      isExpanded: true,
                      decoration: _dec('Público-alvo'),
                      items: _categorias
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _classeSelecionada = v),
                      validator: (v) => v == null ? 'Selecione o público-alvo' : null,
                    ),
                    const SizedBox(height: 12),

                    // Descrição
                    TextFormField(
                      controller: _descricaoCtrl,
                      decoration: _dec('Descrição'),
                      minLines: 4,
                      maxLines: 8,
                      maxLength: 1200,
                      validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Informe a descrição' : null,
                    ),

                    const SizedBox(height: 20),

                    _salvando
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _salvando ? null : _salvar,
                        icon: const Icon(Icons.save),
                        label: const Text(
                          'Salvar',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Quando embutido dentro do painel do admin (AdminShell), retornamos só o corpo.
    if (widget.embedded) {
      return Container(
        color: const Color(0xFFF6F6F8),
        child: content,
      );
    }

    // Versão stand-alone com AppBar próprio
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: AppBar(
        title: const Text('Cadastrar Informação'),
        backgroundColor: Colors.deepOrange,
        elevation: 2,
      ),
      body: content,
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.grey[50],
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.deepOrange, width: 2),
    ),
  );
}
