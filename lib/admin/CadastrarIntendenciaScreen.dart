import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../admin/widgets/admin_shell.dart';

class CadastrarIntendenciaScreen extends StatefulWidget {
  const CadastrarIntendenciaScreen({super.key});

  @override
  State<CadastrarIntendenciaScreen> createState() => _CadastrarIntendenciaScreenState();
}

class _CadastrarIntendenciaScreenState extends State<CadastrarIntendenciaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();

  bool _salvando = false;
  String? _distritoSelecionadoId;   // id no Firestore
  String? _distritoSelecionadoNome; // nome para exibir/salvar

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.grey[50],
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
      final nome = _nomeController.text.trim();
      final nomeLower = nome.toLowerCase();

      // Evita duplicidade por distrito (case-insensitive)
      final dup = await FirebaseFirestore.instance
          .collection('intendencias')
          .where('distritoId', isEqualTo: _distritoSelecionadoId)
          .where('nomeLower', isEqualTo: nomeLower)
          .limit(1)
          .get();

      if (dup.docs.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Já existe uma intendência com esse nome neste distrito.')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('intendencias').add({
        'nome': nome,
        'nomeLower': nomeLower,
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
    // ⚠️ Sem orderBy (compatível com docs antigos); ordenamos no cliente por 'nome'
    final distritosStream = FirebaseFirestore.instance.collection('distritos').snapshots();

    return AdminShell(
      title: 'Cadastrar Intendência',
      currentIndex: 4,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(24),
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

                      // Dropdown de Distritos
                      StreamBuilder<QuerySnapshot>(
                        stream: distritosStream,
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          if (snap.hasError) return const Text('Erro ao carregar distritos');

                          var docs = snap.data?.docs ?? [];
                          if (docs.isEmpty) {
                            return const Text(
                              'Nenhum distrito cadastrado.\nCadastre um distrito antes de criar a intendência.',
                              style: TextStyle(fontSize: 14),
                            );
                          }

                          // Ordena no cliente por 'nome'
                          docs.sort((a, b) {
                            final an = ((a['nome'] ?? '') as String).toLowerCase();
                            final bn = ((b['nome'] ?? '') as String).toLowerCase();
                            return an.compareTo(bn);
                          });

                          // Garante consistência do value
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

                      const SizedBox(height: 20),
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
            ),
          ),
        ),
      ),
    );
  }
}
