// lib/admin/editar_hino_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ⬇️ ajuste o caminho do seu shell
import 'widgets/admin_shell.dart';

class EditarHinoScreen extends StatefulWidget {
  final DocumentSnapshot hino;

  const EditarHinoScreen({super.key, required this.hino});

  @override
  State<EditarHinoScreen> createState() => _EditarHinoScreenState();
}

class _EditarHinoScreenState extends State<EditarHinoScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _tituloController;
  late TextEditingController _numeroController;
  late TextEditingController _conteudoController;
  late TextEditingController _escritorController;
  late TextEditingController _secaoController;

  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.hino['titulo']);
    _numeroController = TextEditingController(text: widget.hino['numero']);
    _conteudoController = TextEditingController(text: widget.hino['conteudo']);
    _escritorController = TextEditingController(text: widget.hino['escritor'] ?? '');
    _secaoController = TextEditingController(text: widget.hino['secao'] ?? '');
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _numeroController.dispose();
    _conteudoController.dispose();
    _escritorController.dispose();
    _secaoController.dispose();
    super.dispose();
  }

  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      await FirebaseFirestore.instance.collection('hinos').doc(widget.hino.id).update({
        'titulo': _tituloController.text.trim(),
        'numero': _numeroController.text.trim(),
        'conteudo': _conteudoController.text.trim(),
        'escritor': _escritorController.text.trim(),
        'secao': _secaoController.text.trim(),
      });

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hino atualizado com sucesso')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar alterações: $e')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _excluirHino() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir este hino?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance.collection('hinos').doc(widget.hino.id).delete();
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hino excluído com sucesso')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir hino: $e')),
      );
    }
  }

  InputDecoration _buildInput(String label) => const InputDecoration(
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
      title: 'Editar Hino',
      currentIndex: 1, // índice do menu “Hinos”
      actions: [
        IconButton(
          tooltip: 'Excluir',
          onPressed: _excluirHino,
          icon: const Icon(Icons.delete, color: Colors.white),
        ),
      ],
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _tituloController,
                    decoration: _buildInput('Título'),
                    validator: (value) => value!.isEmpty ? 'Informe o título' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _numeroController,
                    decoration: _buildInput('Número'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _secaoController,
                    decoration: _buildInput('Seção'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _escritorController,
                    decoration: _buildInput('Escritor'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _conteudoController,
                    maxLines: 8,
                    decoration: _buildInput('Conteúdo'),
                    validator: (value) => value!.isEmpty ? 'Informe o conteúdo' : null,
                  ),
                  const SizedBox(height: 24),
                  _salvando
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    onPressed: _salvarAlteracoes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Salvar Alterações',
                      style: TextStyle(fontSize: 18, color: Colors.white),
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
