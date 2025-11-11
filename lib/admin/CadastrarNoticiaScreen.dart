import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CadastrarNoticiaScreen extends StatefulWidget {
  const CadastrarNoticiaScreen({super.key});

  @override
  State<CadastrarNoticiaScreen> createState() => _CadastrarNoticiaScreenState();
}

class _CadastrarNoticiaScreenState extends State<CadastrarNoticiaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  final _autorCtrl = TextEditingController();
  final _imagemCtrl = TextEditingController();
  String _categoria = 'geral';
  String? _editingId;

  final _categorias = ['geral', 'eventos', 'aviso', 'destaque'];

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final payload = {
      'titulo': _tituloCtrl.text.trim(),
      'descricao': _descricaoCtrl.text.trim(),
      'autor': _autorCtrl.text.trim(),
      'imagemUrl': _imagemCtrl.text.trim(),
      'categoria': _categoria,
      'publicadoEm': FieldValue.serverTimestamp(),
    };

    final col = FirebaseFirestore.instance.collection('noticias');

    if (_editingId == null) {
      await col.add(payload);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notícia adicionada!')),
      );
    } else {
      await col.doc(_editingId).set(payload, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notícia atualizada!')),
      );
    }

    _limparCampos();
  }

  void _limparCampos() {
    setState(() => _editingId = null);
    _tituloCtrl.clear();
    _descricaoCtrl.clear();
    _autorCtrl.clear();
    _imagemCtrl.clear();
    _categoria = 'geral';
  }

  Future<void> _carregarEdicao(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    setState(() {
      _editingId = doc.id;
      _tituloCtrl.text = data['titulo'] ?? '';
      _descricaoCtrl.text = data['descricao'] ?? '';
      _autorCtrl.text = data['autor'] ?? '';
      _imagemCtrl.text = data['imagemUrl'] ?? '';
      _categoria = data['categoria'] ?? 'geral';
    });
  }

  Future<void> _excluir(DocumentReference ref) async {
    await ref.delete();
    if (_editingId == ref.id) _limparCampos();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notícia removida.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Notícias / Destaques'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _tituloCtrl,
                      decoration: const InputDecoration(labelText: 'Título'),
                      validator: (v) =>
                      v == null || v.isEmpty ? 'Informe o título' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descricaoCtrl,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      minLines: 3,
                      maxLines: 6,
                      validator: (v) =>
                      v == null || v.isEmpty ? 'Informe a descrição' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _autorCtrl,
                      decoration: const InputDecoration(labelText: 'Autor'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _categoria,
                      items: _categorias
                          .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _categoria = v ?? 'geral'),
                      decoration:
                      const InputDecoration(labelText: 'Categoria'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _imagemCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Imagem (URL opcional)',
                        hintText: 'https://exemplo.com/imagem.jpg',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: Text(
                            _editingId == null ? 'Salvar Notícia' : 'Salvar alterações'),
                        onPressed: _salvar,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('📰 Notícias recentes', style: TextStyle(color: cs.primary)),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('noticias')
                .orderBy('publicadoEm', descending: true)
                .snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snap.data!.docs;
              if (docs.isEmpty) {
                return const Text('Nenhuma notícia cadastrada.');
              }
              return ListView.builder(
                itemCount: docs.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, i) {
                  final d = docs[i];
                  final data = d.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(data['titulo'] ?? ''),
                    subtitle: Text(data['descricao'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _excluir(d.reference),
                    ),
                    onTap: () => _carregarEdicao(d),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
