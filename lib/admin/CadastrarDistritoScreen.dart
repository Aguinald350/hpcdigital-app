// lib/screens/admin/cadastrar_distrito_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../admin/widgets/admin_shell.dart';

class CadastrarDistritoScreen extends StatefulWidget {
  const CadastrarDistritoScreen({super.key});

  @override
  State<CadastrarDistritoScreen> createState() => _CadastrarDistritoScreenState();
}

class _CadastrarDistritoScreenState extends State<CadastrarDistritoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _bispoController = TextEditingController();
  final _superintendenteController = TextEditingController();

  bool _salvando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _bispoController.dispose();
    _superintendenteController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    try {
      final nome = _nomeController.text.trim();
      final nomeLower = nome.toLowerCase();

      final bispo = _bispoController.text.trim();
      final superintendente = _superintendenteController.text.trim();

      // 🔎 verificação case-insensitive de duplicidade
      final jaExiste = await FirebaseFirestore.instance
          .collection('distritos')
          .where('nomeLower', isEqualTo: nomeLower)
          .limit(1)
          .get();

      if (jaExiste.docs.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Já existe um distrito com esse nome.')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('distritos').add({
        'nome': nome,
        'nomeLower': nomeLower,
        'bispoNome': bispo, // pode ser vazio (mantemos o campo)
        'superintendenteNome': superintendente, // idem
        'criadoEm': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Distrito cadastrado com sucesso!')),
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

  InputDecoration _dec(String label, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: Colors.grey[50],
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.deepOrange, width: 2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Cadastrar Distrito',
      currentIndex: 4, // mesma posição do menu "Minha Igreja" (ajuste conforme seu menu)
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Material(
              elevation: 1,
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nomeController,
                        decoration: _dec('Nome do Distrito'),
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          final t = v?.trim() ?? '';
                          if (t.isEmpty) return 'Informe o nome do distrito';
                          if (t.length < 3) return 'O nome deve ter pelo menos 3 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bispoController,
                        decoration: _dec('Nome do Bispo', hint: 'Opcional'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _superintendenteController,
                        decoration: _dec('Nome do Superintendente', hint: 'Opcional'),
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 20),

                      _salvando
                          ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
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
