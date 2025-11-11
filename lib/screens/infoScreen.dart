import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class infoScreen extends StatefulWidget {
  const infoScreen({super.key});

  @override
  State<infoScreen> createState() => _infoScreenState();
}

class _infoScreenState extends State<infoScreen> {
  final _searchCtrl = TextEditingController();
  String _filtro = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Limites do mês atual
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);

    final temBusca = _filtro.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        title: const Text('Informações'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: Column(
        children: [
          // Busca
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _filtro = v),
              style: TextStyle(color: cs.onBackground),
              decoration: InputDecoration(
                labelText: 'Pesquisar por título ou descrição',
                labelStyle: TextStyle(color: cs.onBackground.withOpacity(0.8)),
                prefixIcon: Icon(Icons.search, color: cs.primary),
                suffixIcon: _filtro.isEmpty
                    ? null
                    : IconButton(
                  icon: Icon(Icons.clear, color: cs.onBackground),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _filtro = '');
                  },
                ),
                filled: true,
                fillColor: cs.surface, // leve contraste no campo
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.primary, width: 1.5), // -> primary
                ),
              ),
            ),
          ),

          // Cabeçalho do mês
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Row(
              children: [
                Text(
                  _fmtMes(now),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: cs.primary, // -> primary
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Lista do mês atual
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('informacoes')
              // filtra por updatedAt dentro do mês atual
                  .where('updatedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDay))
                  .where('updatedAt', isLessThanOrEqualTo: Timestamp.fromDate(lastDay))
                  .orderBy('updatedAt', descending: true)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return _msg(context, 'Erro ao carregar informações.');
                }

                List<QueryDocumentSnapshot> docs = (snap.data?.docs ?? []).toList();

                if (temBusca) {
                  final f = _filtro.toLowerCase();
                  docs = docs.where((d) {
                    final m = d.data() as Map<String, dynamic>? ?? {};
                    final t = (m['titulo'] ?? '').toString().toLowerCase();
                    final desc = (m['descricao'] ?? '').toString().toLowerCase();
                    final classe = (m['classe'] ?? '').toString().toLowerCase();
                    return t.contains(f) || desc.contains(f) || classe.contains(f);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return _msg(context, 'Nenhuma informação neste mês.');
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _InfoCardUser(doc: docs[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _msg(BuildContext context, String t) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          t,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: cs.onBackground),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _fmtMes(DateTime d) {
    // Ex.: "Setembro 2025"
    const meses = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
    ];
    final nome = meses[d.month - 1];
    return '${nome[0].toUpperCase()}${nome.substring(1)} ${d.year}';
  }
}

class _InfoCardUser extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  const _InfoCardUser({required this.doc});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final m = doc.data() as Map<String, dynamic>? ?? {};
    final titulo = (m['titulo'] ?? '').toString();
    final descricao = (m['descricao'] ?? '').toString();
    final classe = (m['classe'] ?? '').toString();
    final updatedAt = (m['updatedAt'] as Timestamp?)?.toDate();

    return Card(
      color: cs.secondaryContainer, // -> card/acessório
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.secondary), // realce opcional
      ),
      elevation: 0,
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
        leading: CircleAvatar(
          backgroundColor: cs.secondaryContainer,
          child: Icon(Icons.info_outline, color: cs.onSecondaryContainer),
        ),
        title: Text(
          titulo.isEmpty ? '(Sem título)' : titulo,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: cs.onSecondaryContainer,
          ),
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
                    color: cs.secondaryContainer,                // badge em secondaryContainer
                    border: Border.all(color: cs.primary),       // borda/realce -> primary
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    classe,
                    style: TextStyle(
                      color: cs.onSecondaryContainer,            // texto do badge
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            if (descricao.isNotEmpty)
              Text(
                descricao,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: cs.onSecondaryContainer.withOpacity(0.9)),
              ),
            if (updatedAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Atualizado: ${_fmtData(updatedAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSecondaryContainer.withOpacity(0.7),
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _detalhe(context, titulo, classe, descricao, updatedAt),
      ),
    );
  }

  void _detalhe(BuildContext context, String t, String c, String d, DateTime? dt) {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          t.isEmpty ? '(Sem título)' : t,
          style: TextStyle(color: cs.onBackground),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (c.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Classe: $c',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: cs.primary, // realce
                    ),
                  ),
                ),
              if (dt != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Atualizado: ${_fmtData(dt)}',
                    style: TextStyle(color: cs.onBackground.withOpacity(0.8)),
                  ),
                ),
              Text('Descrição:', style: TextStyle(color: cs.onBackground)),
              const SizedBox(height: 4),
              Text(d.isEmpty ? '—' : d, style: TextStyle(color: cs.onBackground)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar', style: TextStyle(color: cs.primary)),
          ),
        ],
      ),
    );
  }

  String _fmtData(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }
}
