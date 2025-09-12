// lib/minha_igreja/cadastrar_distrito_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CadastrarDistritoScreen extends StatefulWidget {
  const CadastrarDistritoScreen({super.key});

  @override
  State<CadastrarDistritoScreen> createState() => _CadastrarDistritoScreenState();
}

class _CadastrarDistritoScreenState extends State<CadastrarDistritoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  bool _salvando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    try {
      final nome = _nomeController.text.trim();

      // (Opcional) Verificar se já existe um distrito com o mesmo nome
      final jaExiste = await FirebaseFirestore.instance
          .collection('distritos')
          .where('nome', isEqualTo: nome)
          .limit(1)
          .get();

      if (jaExiste.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Já existe um distrito com esse nome.')),
        );
        setState(() => _salvando = false);
        return;
      }

      await FirebaseFirestore.instance.collection('distritos').add({
        'nome': nome,
        'criadoEm': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Distrito cadastrado com sucesso!')),
      );

      Navigator.pop(context, true); // retorna sucesso para a tela anterior
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.deepOrange, width: 2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Distrito'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: _dec('Nome do Distrito'),
                textInputAction: TextInputAction.done,
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return 'Informe o nome do distrito';
                  if (t.length < 3) return 'O nome deve ter pelo menos 3 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _salvando
                  ? const CircularProgressIndicator()
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
