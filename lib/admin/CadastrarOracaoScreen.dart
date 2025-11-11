import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'widgets/admin_shell.dart'; // ✅ ajuste o caminho conforme seu projeto

class CadastrarOracaoScreen extends StatefulWidget {
  const CadastrarOracaoScreen({super.key});

  @override
  State<CadastrarOracaoScreen> createState() => _CadastrarOracaoScreenState();
}

class _CadastrarOracaoScreenState extends State<CadastrarOracaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _textoCtrl = TextEditingController();
  final _temaCtrl = TextEditingController();

  String? _editingId;

  final _temaSugestoes = const <String>[
    'manhã',
    'noite',
    'gratidão',
    'perdão',
    'sabedoria',
    'proteção',
    'esperança',
    'cura',
  ];

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final dados = {
      'titulo': _tituloCtrl.text.trim(),
      'texto': _textoCtrl.text.trim(),
      'tema': _temaCtrl.text.trim(),
      'dataCriacao': FieldValue.serverTimestamp(),
    };

    final col = FirebaseFirestore.instance.collection('oracoes');

    if (_editingId == null) {
      await col.add(dados);
      _showMsg('Oração cadastrada com sucesso!', Colors.green);
    } else {
      await col.doc(_editingId).set(dados, SetOptions(merge: true));
      _showMsg('Oração atualizada com sucesso!', Colors.blue);
    }

    _limpar();
  }

  void _limpar() {
    setState(() => _editingId = null);
    _tituloCtrl.clear();
    _textoCtrl.clear();
    _temaCtrl.clear();
  }

  Future<void> _carregarEdicao(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    setState(() {
      _editingId = doc.id;
      _tituloCtrl.text = (data['titulo'] ?? '').toString();
      _textoCtrl.text = (data['texto'] ?? '').toString();
      _temaCtrl.text = (data['tema'] ?? '').toString();
    });
  }

  Future<void> _excluir(DocumentReference ref) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Oração'),
        content: const Text('Deseja realmente excluir esta oração?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;
    await ref.delete();
    if (_editingId == ref.id) _limpar();
    _showMsg('Oração excluída com sucesso.', Colors.red);
  }

  void _showMsg(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  InputDecoration _dec(String label, [String? hint]) => InputDecoration(
    labelText: label,
    hintText: hint,
    border: const OutlineInputBorder(),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.deepOrange, width: 2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: _editingId == null ? 'Cadastrar Oração' : 'Editar Oração',
      currentIndex: 8, // ajuste o índice no menu lateral
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // ===== Formulário =====
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _tituloCtrl,
                        decoration: _dec('Título (opcional)', 'Ex: Oração da manhã'),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _temaCtrl.text.isEmpty ? null : _temaCtrl.text,
                        decoration: _dec('Tema', 'Selecione um tema sugerido'),
                        items: _temaSugestoes
                            .map((t) => DropdownMenuItem<String>(
                          value: t,
                          child: Text(t, overflow: TextOverflow.ellipsis),
                        ))
                            .toList(),
                        onChanged: (v) => setState(() => _temaCtrl.text = v ?? ''),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _temaCtrl,
                        decoration: _dec('Tema personalizado', 'Ex: Esperança em Deus'),
                        validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Informe o tema' : null,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _textoCtrl,
                        minLines: 4,
                        maxLines: 8,
                        decoration: _dec('Texto da oração', 'Digite aqui a oração completa'),
                        validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Digite a oração' : null,
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          icon: Icon(_editingId == null ? Icons.save : Icons.check),
                          label: Text(_editingId == null
                              ? 'Salvar'
                              : 'Salvar alterações'),
                          onPressed: _salvar,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ===== Lista =====
            Text(
              'Orações cadastradas',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepOrange),
            ),
            const SizedBox(height: 8),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('oracoes')
                  .orderBy('dataCriacao', descending: true)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator()));
                }
                if (!snap.hasData || snap.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Nenhuma oração cadastrada ainda.'),
                  );
                }

                final docs = snap.data!.docs;
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final d = docs[i];
                      final data = d.data() as Map<String, dynamic>? ?? {};
                      final titulo = (data['titulo'] ?? '').toString();
                      final tema = (data['tema'] ?? '').toString();
                      final texto = (data['texto'] ?? '').toString();
                      final ts = data['dataCriacao'] as Timestamp?;
                      final dt = ts?.toDate();

                      return ListTile(
                        leading: const Icon(Icons.volunteer_activism_outlined,
                            color: Colors.deepOrange),
                        title: Text(
                          titulo.isEmpty ? '(Sem título)' : titulo,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${tema.isEmpty ? '(Sem tema)' : tema}'
                              '${dt != null ? ' — ${dt.day}/${dt.month}/${dt.year}' : ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _carregarEdicao(d),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                          tooltip: 'Excluir',
                          onPressed: () => _excluir(d.reference),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
