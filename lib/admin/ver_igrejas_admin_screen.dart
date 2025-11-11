// lib/screens/admin/ver_igrejas_admin_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widgets/admin_shell.dart';
import 'editar_igreja_screen.dart';

class VerIgrejasAdminScreen extends StatefulWidget {
  const VerIgrejasAdminScreen({super.key});

  @override
  State<VerIgrejasAdminScreen> createState() => _VerIgrejasAdminScreenState();
}

class _VerIgrejasAdminScreenState extends State<VerIgrejasAdminScreen> {
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

    return AdminShell(
      title: 'Igrejas',
      currentIndex: 5, // ajuste para o índice do menu "Ver Igrejas"
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _filtro = v),
              decoration: InputDecoration(
                labelText: 'Pesquisar (igreja / intendência / referência)',
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

          _buildBreadcrumbs(),

          const SizedBox(height: 6),

          Expanded(
            child: temBusca
                ? _BuscaIgrejasListAdmin(filtro: _filtro)
                : _HierarquiaAdmin(
              distrito: _distritoSelecionado,
              onDistritoTap: (d) => setState(() {
                _distritoSelecionado = d;
                _intendenciaSelecionada = null;
              }),
              intendencia: _intendenciaSelecionada,
              onIntendenciaTap: (i) =>
                  setState(() => _intendenciaSelecionada = i),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbs() {
    final hasDistrito = _distritoSelecionado != null;
    final hasInt = _intendenciaSelecionada != null;

    if (!hasDistrito && !hasInt) return const SizedBox.shrink();

    final dm =
    (_distritoSelecionado?.data() as Map<String, dynamic>? ?? {});
    final distritoNome = (dm['nome'] ?? '').toString();

    final im =
    (_intendenciaSelecionada?.data() as Map<String, dynamic>? ?? {});
    final intendenciaNome = (im['nome'] ?? '').toString();

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
              label: Text(distritoNome),
              avatar: const Icon(Icons.account_tree_outlined, size: 18),
              onPressed: () {
                setState(() => _intendenciaSelecionada = null);
              },
            ),
          if (hasInt)
            Chip(
              label: Text(intendenciaNome),
              avatar: const Icon(Icons.business_outlined, size: 18),
            ),
        ],
      ),
    );
  }
}

/// LISTAGEM HIERÁRQUICA (Distritos -> Intendências -> Igrejas)
class _HierarquiaAdmin extends StatelessWidget {
  final DocumentSnapshot? distrito;
  final void Function(DocumentSnapshot) onDistritoTap;
  final DocumentSnapshot? intendencia;
  final void Function(DocumentSnapshot) onIntendenciaTap;

  const _HierarquiaAdmin({
    required this.distrito,
    required this.onDistritoTap,
    required this.intendencia,
    required this.onIntendenciaTap,
  });

  @override
  Widget build(BuildContext context) {
    if (distrito == null) {
      // Distritos
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('distritos').snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = (snap.data?.docs ?? []).toList();

          // Ordena com segurança
          docs.sort((a, b) {
            final am = (a.data() as Map<String, dynamic>? ?? {});
            final bm = (b.data() as Map<String, dynamic>? ?? {});
            final an = (am['nome'] ?? '').toString().toLowerCase();
            final bn = (bm['nome'] ?? '').toString().toLowerCase();
            return an.compareTo(bn);
          });

          if (docs.isEmpty) {
            return _vazio('Nenhum distrito cadastrado.');
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (_, i) {
              final d = docs[i];
              final dm = (d.data() as Map<String, dynamic>? ?? {});
              final nome = (dm['nome'] ?? '').toString();
              final bispo = (dm['bispoNome'] ?? '').toString();
              final superint = (dm['superintendenteNome'] ?? '').toString();

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFE8D6),
                    child: Icon(Icons.home_work, color: Colors.deepOrange),
                  ),
                  title: Text(nome, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (bispo.isNotEmpty) Text('Bispo: $bispo'),
                      if (superint.isNotEmpty) Text('Superintendente: $superint'),
                    ],
                  ),
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
      // Intendências do distrito selecionado
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('intendencias')
            .where('distritoId', isEqualTo: distrito!.id)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = (snap.data?.docs ?? []).toList();

          // Ordena com segurança
          docs.sort((a, b) {
            final am = (a.data() as Map<String, dynamic>? ?? {});
            final bm = (b.data() as Map<String, dynamic>? ?? {});
            final an = (am['nome'] ?? '').toString().toLowerCase();
            final bn = (bm['nome'] ?? '').toString().toLowerCase();
            return an.compareTo(bn);
          });

          if (docs.isEmpty) {
            return _vazio('Nenhuma intendência neste distrito.');
          }

          final dm = (distrito!.data() as Map<String, dynamic>? ?? {});
          final distritoNome = (dm['nome'] ?? '').toString();

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (_, i) {
              final it = docs[i];
              final im = (it.data() as Map<String, dynamic>? ?? {});
              final nome = (im['nome'] ?? '').toString();

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFE8D6),
                    child: Icon(Icons.account_tree, color: Colors.deepOrange),
                  ),
                  title: Text(nome, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(distritoNome),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => onIntendenciaTap(it),
                ),
              );
            },
          );
        },
      );
    }

    // Igrejas da intendência selecionada
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('igrejas')
          .where('intendenciaId', isEqualTo: intendencia!.id)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = (snap.data?.docs ?? []).toList();

        // Ordena com segurança
        docs.sort((a, b) {
          final am = (a.data() as Map<String, dynamic>? ?? {});
          final bm = (b.data() as Map<String, dynamic>? ?? {});
          final an = (am['nome'] ?? '').toString().toLowerCase();
          final bn = (bm['nome'] ?? '').toString().toLowerCase();
          return an.compareTo(bn);
        });

        if (docs.isEmpty) {
          return _vazio('Nenhuma igreja nesta intendência.');
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _IgrejaCardAdmin(igreja: docs[i]),
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

/// 🔎 RESULTADO DE BUSCA – ADMIN (filtra no cliente)
class _BuscaIgrejasListAdmin extends StatelessWidget {
  final String filtro;
  const _BuscaIgrejasListAdmin({required this.filtro});

  @override
  Widget build(BuildContext context) {
    final f = filtro.trim().toLowerCase();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('igrejas').snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        var all = snap.data?.docs ?? [];
        if (all.isEmpty) {
          return const Center(child: Text('Sem igrejas cadastradas.'));
        }

        // ordena + filtra no cliente
        all.sort((a, b) {
          final am = (a.data() as Map<String, dynamic>? ?? {});
          final bm = (b.data() as Map<String, dynamic>? ?? {});
          final an = (am['nome'] ?? '').toString().toLowerCase();
          final bn = (bm['nome'] ?? '').toString().toLowerCase();
          return an.compareTo(bn);
        });

        final list = all.where((d) {
          final m = d.data() as Map<String, dynamic>? ?? {};
          final nome = (m['nome'] ?? '').toString().toLowerCase();
          final intend = (m['intendenciaNome'] ?? '').toString().toLowerCase();
          final refs = (m['referencias'] ?? '').toString().toLowerCase();
          return nome.contains(f) || intend.contains(f) || refs.contains(f);
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
          itemBuilder: (_, i) =>
              _IgrejaCardAdmin(igreja: list[i] as QueryDocumentSnapshot),
        );
      },
    );
  }
}

class _IgrejaCardAdmin extends StatelessWidget {
  final QueryDocumentSnapshot igreja;
  const _IgrejaCardAdmin({required this.igreja});

  @override
  Widget build(BuildContext context) {
    final m = igreja.data() as Map<String, dynamic>? ?? {};
    final nome = (m['nome'] ?? '').toString();
    final distritoNome = (m['distritoNome'] ?? '').toString();
    final intendenciaNome = (m['intendenciaNome'] ?? '').toString();

    final bispoNome = (m['bispoNome'] ?? '').toString();
    final superintendenteNome = (m['superintendenteNome'] ?? '').toString();

    final pastores = (m['pastores'] ?? []) as List?;
    final secretarioNome = (m['secretarioNome'] ?? '').toString();
    final secretarioContato = (m['secretarioContato'] ?? '').toString();
    final localizacaoUrl = (m['localizacaoUrl'] ?? '').toString();
    final referencias = (m['referencias'] ?? '').toString();

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
          [distritoNome, intendenciaNome].where((e) => e.isNotEmpty).join(' • '),
        ),
        trailing: PopupMenuButton<String>(
          tooltip: 'Ações',
          onSelected: (value) async {
            if (value == 'edit') {
              final ref = igreja.reference.withConverter<Map<String, dynamic>>(
                fromFirestore: (snap, _) => snap.data() ?? {},
                toFirestore: (data, _) => data,
              );
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditarIgrejaScreen(ref: ref)),
              );
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'edit',
              child: ListTile(leading: Icon(Icons.edit), title: Text('Editar')),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          const SizedBox(height: 8),

          if (bispoNome.isNotEmpty) ...[
            _secTitle('Bispo'),
            const SizedBox(height: 6),
            Text(bispoNome),
            const SizedBox(height: 12),
          ],

          if (superintendenteNome.isNotEmpty) ...[
            _secTitle('Superintendente'),
            const SizedBox(height: 6),
            Text(superintendenteNome),
            const SizedBox(height: 12),
          ],

          _secTitle('Pastor(es)'),
          const SizedBox(height: 6),
          if ((pastores?.isNotEmpty ?? false))
            ...pastores!.map((p) {
              final pMap = (p is Map) ? p as Map : {};
              final pNome = (pMap['nome'] ?? '').toString();
              final pContato = (pMap['contato'] ?? '').toString();
              return ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: const Icon(Icons.person_outline),
                title: Text(pNome.isEmpty ? '—' : pNome),
                subtitle: pContato.isEmpty ? null : Text(pContato),
                trailing: pContato.isEmpty
                    ? null
                    : IconButton(
                  icon: const Icon(Icons.call, color: Colors.deepOrange),
                  onPressed: () => _call(pContato),
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
            subtitle: secretarioContato.isEmpty ? null : Text(secretarioContato),
            trailing: secretarioContato.isEmpty
                ? null
                : IconButton(
              icon: const Icon(Icons.call, color: Colors.deepOrange),
              onPressed: () => _call(secretarioContato),
            ),
          ),

          const SizedBox(height: 12),
          _secTitle('Localização'),
          const SizedBox(height: 6),
          _LocationCard(mapLink: localizacaoUrl, referencias: referencias),
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
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _LocationCard extends StatelessWidget {
  final String mapLink;
  final String referencias;
  const _LocationCard({required this.mapLink, required this.referencias});

  @override
  Widget build(BuildContext context) {
    final hasLink = mapLink.trim().isNotEmpty;
    final hasRef = referencias.trim().isNotEmpty;

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
          const Text('Mapa / Endereço salvo', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            hasLink ? mapLink : 'Sem link de mapa cadastrado.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (hasRef) ...[
            const SizedBox(height: 10),
            const Text('Referências', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(referencias),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: hasLink ? () => _openMap(mapLink) : null,
              icon: const Icon(Icons.map_outlined),
              label: const Text('Ver no mapa'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
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
