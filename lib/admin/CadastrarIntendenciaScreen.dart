// lib/minha_igreja/cadastrar_intendencia_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CadastrarIntendenciaScreen extends StatefulWidget {
  const CadastrarIntendenciaScreen({super.key});

  @override
  State<CadastrarIntendenciaScreen> createState() => _CadastrarIntendenciaScreenState();
}

class _CadastrarIntendenciaScreenState extends State<CadastrarIntendenciaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();

  bool _salvando = false;
  String? _distritoSelecionadoId;   // id do doc no Firestore
  String? _distritoSelecionadoNome; // nome para exibir/salvar junto

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.deepOrange, width: 2),
    ),
  );

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_distritoSelecionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o distrito.')),
      );
      return;
    }

    setState(() => _salvando = true);
    try {
      await FirebaseFirestore.instance.collection('intendencias').add({
        'nome': _nomeController.text.trim(),
        'distritoId': _distritoSelecionadoId,
        'distritoNome': _distritoSelecionadoNome,
        'criadoEm': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Intendência cadastrada com sucesso!')),
      );
      Navigator.pop(context, true);
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
    final distritosQuery = FirebaseFirestore.instance
        .collection('distritos')
        .orderBy('nome');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Intendência'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Nome da Intendência
              TextFormField(
                controller: _nomeController,
                decoration: _dec('Nome da Intendência'),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return 'Informe o nome da intendência';
                  if (t.length < 3) return 'O nome deve ter pelo menos 3 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Dropdown de Distritos (carregado do Firestore)
              StreamBuilder<QuerySnapshot>(
                stream: distritosQuery.snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: CircularProgressIndicator(),
                    ));
                  }
                  if (snap.hasError) {
                    return const Text('Erro ao carregar distritos');
                  }

                  final docs = snap.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Text(
                      'Nenhum distrito cadastrado.\nCadastre um distrito antes de criar a intendência.',
                      style: TextStyle(fontSize: 14),
                    );
                  }

                  // Garante consistência do value (se o selecionado não existir mais)
                  if (_distritoSelecionadoId != null &&
                      !docs.any((d) => d.id == _distritoSelecionadoId)) {
                    _distritoSelecionadoId = null;
                    _distritoSelecionadoNome = null;
                  }

                  return DropdownButtonFormField<String>(
                    value: _distritoSelecionadoId,
                    isExpanded: true,
                    decoration: _dec('Distrito'),
                    items: docs.map((d) {
                      final nome = (d['nome'] ?? '').toString();
                      return DropdownMenuItem<String>(
                        value: d.id,
                        child: Text(nome.isEmpty ? '(Sem nome)' : nome),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _distritoSelecionadoId = val;
                        final doc = docs.firstWhere((d) => d.id == val);
                        _distritoSelecionadoNome = (doc['nome'] ?? '').toString();
                      });
                    },
                    validator: (v) => v == null ? 'Selecione um distrito' : null,
                  );
                },
              ),

              const SizedBox(height: 24),
              _salvando
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: _salvar,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
