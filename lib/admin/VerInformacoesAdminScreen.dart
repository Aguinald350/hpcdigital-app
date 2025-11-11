// lib/admin/VerInformacoesAdminScreen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'CadastrarInformacaoScreen.dart';
import 'editar_informacao_screen.dart';

// ✅ importe o seu shell público
// ajuste o caminho conforme sua estrutura, por exemplo:
// import 'widgets/admin_shell.dart';
import 'widgets/admin_shell.dart'; // <-- ajuste se necessário

class VerInformacoesAdminScreen extends StatefulWidget {
  const VerInformacoesAdminScreen({super.key});

  @override
  State<VerInformacoesAdminScreen> createState() => _VerInformacoesAdminScreenState();
}

class _VerInformacoesAdminScreenState extends State<VerInformacoesAdminScreen> {
  final _searchCtrl = TextEditingController();
  String _filtro = '';
  String _classeSelecionada = 'Todos';

  static const _classes = <String>[
    'Todos',
    'criancas',
    'JIMUA',
    'OJA',
    'Org.Mulheres',
    'Org.Homens',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final temBusca = _filtro.trim().isNotEmpty;

    return AdminShell( // ✅ trocado de _AdminShell para AdminShell
      currentIndex: 7, // "Ver Informações" no seu NavigationRail
      title: 'Informações',
      actions: [
        FilledButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CadastrarInformacaoScreen()),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Nova informação'),
          style: FilledButton.styleFrom(backgroundColor: Colors.deepOrange),
        ),
      ],
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Busca
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _filtro = v),
                    decoration: InputDecoration(
                      labelText: 'Pesquisar por título ou descrição',
                      prefixIcon: const Icon(Icons.search, color: Colors.deepOrange),
                      suffixIcon: _filtro.isEmpty
                          ? null
                          : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _filtro = '');
                        },
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepOrange),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),

                // Filtro por classe (chips)
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, i) {
                      final c = _classes[i];
                      final selected = c == _classeSelecionada;
                      return ChoiceChip(
                        label: Text(c),
                        selected: selected,
                        selectedColor: Colors.orange.shade100,
                        onSelected: (_) => setState(() => _classeSelecionada = c),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: _classes.length,
                  ),
                ),

                const SizedBox(height: 10),

                // Lista
                Expanded(
                  child: Material(
                    color: Colors.white,
                    elevation: 1,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('informacoes')
                            .orderBy('updatedAt', descending: true)
                            .snapshots(),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snap.hasError) {
                            return _msg('Erro ao carregar informações.');
                          }

                          // filtro cliente (classe + texto)
                          List<QueryDocumentSnapshot> docs = (snap.data?.docs ?? []).toList();

                          if (_classeSelecionada != 'Todos') {
                            docs = docs.where((d) {
                              final m = d.data() as Map<String, dynamic>? ?? {};
                              return (m['classe'] ?? '') == _classeSelecionada;
                            }).toList();
                          }

                          if (temBusca) {
                            final f = _filtro.toLowerCase();
                            docs = docs.where((d) {
                              final m = d.data() as Map<String, dynamic>? ?? {};
                              final t = (m['titulo'] ?? '').toString().toLowerCase();
                              final desc = (m['descricao'] ?? '').toString().toLowerCase();
                              return t.contains(f) || desc.contains(f);
                            }).toList();
                          }

                          if (docs.isEmpty) {
                            return _msg('Nenhum resultado.');
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                            itemCount: docs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (_, i) => _InfoCard(
                              doc: docs[i],
                              onEdit: () => _editar(docs[i]),
                              onDelete: () => _apagar(docs[i]),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _msg(String t) => Center(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    ),
  );

  Future<void> _editar(QueryDocumentSnapshot doc) async {
    final ref = doc.reference.withConverter<Map<String, dynamic>>(
      fromFirestore: (s, _) => s.data() ?? {},
      toFirestore: (data, _) => data,
    );

    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditarInformacaoScreen(ref: ref)),
    );

    if (updated == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informação atualizada.')),
      );
    }
  }

  Future<void> _apagar(QueryDocumentSnapshot doc) async {
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
        await doc.reference.delete();
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Informação apagada.')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Erro ao apagar: $e')));
        }
      }
    }
  }
}

class _InfoCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _InfoCard({
    required this.doc,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final m = doc.data() as Map<String, dynamic>? ?? {};
    final titulo = (m['titulo'] ?? '').toString();
    final descricao = (m['descricao'] ?? '').toString();
    final classe = (m['classe'] ?? '').toString();
    final updatedAt = (m['updatedAt'] as Timestamp?)?.toDate();
    final createdAt = (m['createdAt'] as Timestamp?)?.toDate();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1.5,
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFFE8D6),
          child: Icon(Icons.info_outline, color: Colors.deepOrange),
        ),
        title: Text(
          titulo.isEmpty ? '(Sem título)' : titulo,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (classe.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    border: Border.all(color: Colors.deepOrange),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    classe,
                    style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            if (descricao.isNotEmpty)
              Text(
                descricao,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if ((updatedAt ?? createdAt) != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Atualizado: ${_fmt(updatedAt ?? createdAt!)}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          tooltip: 'Ações',
          onSelected: (v) {
            if (v == 'edit') onEdit();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'edit',
              child: ListTile(leading: Icon(Icons.edit), title: Text('Editar')),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Apagar')),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }
}
