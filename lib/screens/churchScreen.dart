import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChurchScreen extends StatefulWidget {
  const ChurchScreen({super.key});

  @override
  State<ChurchScreen> createState() => _ChurchScreenState();
}

class _ChurchScreenState extends State<ChurchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _filtro = '';

  DocumentSnapshot? _distritoSelecionado;
  DocumentSnapshot? _intendenciaSelecionada;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final temBusca = _filtro.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        title: const Text("Minha Igreja", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _filtro = v),
              decoration: InputDecoration(
                labelText: 'Pesquisar (igreja ou intendência)',
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepOrange),
                ),
              ),
            ),
          ),

          // Breadcrumbs / navegação hierárquica
          _buildBreadcrumbs(),

          const SizedBox(height: 6),

          Expanded(
            child: temBusca
                ? _BuscaIgrejasList(filtro: _filtro)
                : _Hierarquia(
              distrito: _distritoSelecionado,
              onDistritoTap: (d) => setState(() {
                _distritoSelecionado = d;
                _intendenciaSelecionada = null;
              }),
              intendencia: _intendenciaSelecionada,
              onIntendenciaTap: (i) => setState(() {
                _intendenciaSelecionada = i;
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbs() {
    final hasDistrito = _distritoSelecionado != null;
    final hasInt = _intendenciaSelecionada != null;

    if (!hasDistrito && !hasInt) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          ActionChip(
            label: const Text('Distritos'),
            avatar: const Icon(Icons.home_work_outlined, size: 18),
            onPressed: () {
              setState(() {
                _distritoSelecionado = null;
                _intendenciaSelecionada = null;
              });
            },
          ),
          if (hasDistrito)
            ActionChip(
              label: Text(_distritoSelecionado!['nome'] ?? ''),
              avatar: const Icon(Icons.account_tree_outlined, size: 18),
              onPressed: () {
                setState(() {
                  _intendenciaSelecionada = null;
                });
              },
            ),
          if (hasInt)
            Chip(
              label: Text(_intendenciaSelecionada!['nome'] ?? ''),
              avatar: const Icon(Icons.business_outlined, size: 18),
            ),
        ],
      ),
    );
  }
}

/// LISTAGEM HIERÁRQUICA (Distritos -> Intendências -> Igrejas)
class _Hierarquia extends StatelessWidget {
  final DocumentSnapshot? distrito;
  final void Function(DocumentSnapshot) onDistritoTap;
  final DocumentSnapshot? intendencia;
  final void Function(DocumentSnapshot) onIntendenciaTap;

  const _Hierarquia({
    required this.distrito,
    required this.onDistritoTap,
    required this.intendencia,
    required this.onIntendenciaTap,
  });

  @override
  Widget build(BuildContext context) {
    if (distrito == null) {
      // Lista de Distritos (ordem alfabética)
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('distritos')
            .orderBy('nome')
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return _vazio('Nenhum distrito cadastrado.');
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (_, i) {
              final d = docs[i];
              final nome = (d['nome'] ?? '').toString();
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFE8D6),
                    child: Icon(Icons.home_work, color: Colors.deepOrange),
                  ),
                  title: Text(nome, style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => onDistritoTap(d),
                ),
              );
            },
          );
        },
      );
    }

    if (intendencia == null) {
      // Lista de Intendências do distrito
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('intendencias')
            .where('distritoId', isEqualTo: distrito!.id)
            .orderBy('nome')
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return _vazio('Nenhuma intendência neste distrito.');
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (_, i) {
              final it = docs[i];
              final nome = (it['nome'] ?? '').toString();
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFE8D6),
                    child: Icon(Icons.account_tree, color: Colors.deepOrange),
                  ),
                  title: Text(nome, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(distrito!['nome'] ?? ''),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => onIntendenciaTap(it),
                ),
              );
            },
          );
        },
      );
    }

    // Lista de Igrejas da intendência
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('igrejas')
          .where('intendenciaId', isEqualTo: intendencia!.id)
          .orderBy('nome')
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return _vazio('Nenhuma igreja nesta intendência.');
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final ig = docs[i];
            return _IgrejaCard(igreja: ig);
          },
        );
      },
    );
  }

  Widget _vazio(String msg) => Center(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        msg,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

/// RESULTADO DE BUSCA (lista direta de igrejas filtrando por nome de igreja ou intendência)
class _BuscaIgrejasList extends StatelessWidget {
  final String filtro;
  const _BuscaIgrejasList({required this.filtro});

  @override
  Widget build(BuildContext context) {
    final f = filtro.trim().toLowerCase();

    // Consulta geral por nome; filtro final feito no cliente
    final query = FirebaseFirestore.instance
        .collection('igrejas')
        .orderBy('nome');

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final all = snap.data?.docs ?? [];
        // filtro: nome da igreja OU nome da intendência
        final list = all.where((d) {
          final m = d.data() as Map<String, dynamic>? ?? {};
          final nome = (m['nome'] ?? '').toString().toLowerCase();
          final intend = (m['intendenciaNome'] ?? '').toString().toLowerCase();
          return nome.contains(f) || intend.contains(f);
        }).toList();

        if (list.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Nenhum resultado para a pesquisa.'),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _IgrejaCard(igreja: list[i]),
        );
      },
    );
  }
}

/// CARD DE IGREJA + DETALHES
class _IgrejaCard extends StatelessWidget {
  final QueryDocumentSnapshot igreja;

  const _IgrejaCard({required this.igreja});

  @override
  Widget build(BuildContext context) {
    final m = igreja.data() as Map<String, dynamic>? ?? {};
    final nome = (m['nome'] ?? '').toString();
    final distritoNome = (m['distritoNome'] ?? '').toString();
    final intendenciaNome = (m['intendenciaNome'] ?? '').toString();
    final numPastores = (m['numPastores'] ?? 0) is int
        ? (m['numPastores'] as int)
        : int.tryParse((m['numPastores'] ?? '0').toString()) ?? 0;
    final pastores = (m['pastores'] ?? []) as List?; // [{nome, telefone}, ...]
    final secretarioNome = (m['secretarioNome'] ?? '').toString();
    final secretarioTelefone = (m['secretarioTelefone'] ?? '').toString();
    final localizacao = (m['localizacao'] ?? '').toString(); // link (maps)

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFFE8D6),
          child: Icon(Icons.church, color: Colors.deepOrange),
        ),
        title: Text(
          nome.isEmpty ? 'Igreja' : nome,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          [
            if (distritoNome.isNotEmpty) distritoNome,
            if (intendenciaNome.isNotEmpty) intendenciaNome,
          ].join(' • '),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          const SizedBox(height: 8),
          _secTitle('Pastor(es)'),
          const SizedBox(height: 6),
          if ((pastores?.isNotEmpty ?? false))
            ...pastores!.map((p) {
              final pNome = (p['nome'] ?? '').toString();
              final pFone = (p['telefone'] ?? '').toString();
              return ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: const Icon(Icons.person_outline),
                title: Text(pNome.isEmpty ? '—' : pNome),
                subtitle: pFone.isEmpty ? null : Text(pFone),
                trailing: pFone.isEmpty
                    ? null
                    : IconButton(
                  icon: const Icon(Icons.call, color: Colors.deepOrange),
                  onPressed: () => _call(pFone),
                ),
              );
            })
          else
            const Text('Sem pastores cadastrados.'),

          const SizedBox(height: 12),
          _secTitle('Secretário'),
          const SizedBox(height: 6),
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: const Icon(Icons.badge_outlined),
            title: Text(secretarioNome.isEmpty ? '—' : secretarioNome),
            subtitle: secretarioTelefone.isEmpty ? null : Text(secretarioTelefone),
            trailing: secretarioTelefone.isEmpty
                ? null
                : IconButton(
              icon: const Icon(Icons.call, color: Colors.deepOrange),
              onPressed: () => _call(secretarioTelefone),
            ),
          ),

          const SizedBox(height: 12),
          _secTitle('Localização'),
          const SizedBox(height: 6),
          _LocationCard(mapLink: localizacao),
        ],
      ),
    );
  }

  Widget _secTitle(String t) => Text(
    t,
    style: const TextStyle(
      fontWeight: FontWeight.w700,
      color: Colors.deepOrange,
    ),
  );

  void _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

/// BLOCO VISUAL DE LOCALIZAÇÃO
class _LocationCard extends StatelessWidget {
  final String mapLink;
  const _LocationCard({required this.mapLink});

  @override
  Widget build(BuildContext context) {
    final hasLink = mapLink.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange.shade100),
        borderRadius: BorderRadius.circular(12),
        color: Colors.orange.shade50,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mapa / Endereço salvo',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            hasLink ? mapLink : 'Sem link de mapa cadastrado.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: hasLink ? () => _openMap(mapLink) : null,
              icon: const Icon(Icons.map_outlined),
              label: const Text('Ver no mapa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openMap(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
