// lib/screens/igreja/church_screen.dart
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
    final cs = Theme.of(context).colorScheme;
    final temBusca = _filtro.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
        title: const Text("Minha Igreja"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _filtro = v),
              style: TextStyle(color: cs.onBackground),
              decoration: InputDecoration(
                labelText: 'Pesquisar (igreja, intendência ou referência)',
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
                fillColor: cs.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.primary, width: 1.5),
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
    final cs = Theme.of(context).colorScheme;
    final hasDistrito = _distritoSelecionado != null;
    final hasInt = _intendenciaSelecionada != null;

    if (!hasDistrito && !hasInt) return const SizedBox.shrink();

    ChipThemeData chipTheme(Color bg, Color fg, {Color? side}) => ChipThemeData(
      backgroundColor: bg,
      side: BorderSide(color: side ?? bg),
      labelStyle: TextStyle(color: fg),
      iconTheme: IconThemeData(color: fg),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );

    String _safeDocStr(DocumentSnapshot d, String key) {
      final m = (d.data() as Map<String, dynamic>?) ?? {};
      return (m[key] ?? '').toString();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              chipTheme: chipTheme(
                cs.secondaryContainer,
                cs.onSecondaryContainer,
                side: cs.secondary,
              ),
            ),
            child: ActionChip(
              label: const Text('Distritos'),
              avatar: const Icon(Icons.home_work_outlined, size: 18),
              onPressed: () {
                setState(() {
                  _distritoSelecionado = null;
                  _intendenciaSelecionada = null;
                });
              },
            ),
          ),
          if (hasDistrito)
            Theme(
              data: Theme.of(context).copyWith(
                chipTheme: chipTheme(
                  cs.secondaryContainer,
                  cs.onSecondaryContainer,
                  side: cs.secondary,
                ),
              ),
              child: ActionChip(
                label: Text(_safeDocStr(_distritoSelecionado!, 'nome')),
                avatar: const Icon(Icons.account_tree_outlined, size: 18),
                onPressed: () {
                  setState(() => _intendenciaSelecionada = null);
                },
              ),
            ),
          if (hasInt)
            Theme(
              data: Theme.of(context).copyWith(
                chipTheme: chipTheme(
                  cs.secondaryContainer,
                  cs.onSecondaryContainer,
                  side: cs.secondary,
                ),
              ),
              child: Chip(
                label: Text(_safeDocStr(_intendenciaSelecionada!, 'nome')),
                avatar: const Icon(Icons.business_outlined, size: 18),
              ),
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

  String _safeDocStr(DocumentSnapshot d, String key) {
    final m = (d.data() as Map<String, dynamic>?) ?? {};
    return (m[key] ?? '').toString();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Card wrapCard(Widget child) => Card(
      color: cs.secondaryContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.secondary),
      ),
      child: child,
    );

    CircleAvatar leadingIcon(IconData icon) => CircleAvatar(
      backgroundColor: cs.secondaryContainer,
      child: Icon(icon, color: cs.onSecondaryContainer),
    );

    TextStyle titleStyle =
    TextStyle(fontWeight: FontWeight.w600, color: cs.onSecondaryContainer);
    TextStyle subtitleStyle =
    TextStyle(color: cs.onSecondaryContainer.withOpacity(0.9));

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
            return _vazio(context, 'Nenhum distrito cadastrado.');
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (_, i) {
              final d = docs[i];
              final nome = _safeDocStr(d, 'nome');
              return wrapCard(
                ListTile(
                  leading: leadingIcon(Icons.home_work),
                  title: Text(nome, style: titleStyle),
                  trailing: Icon(Icons.chevron_right, color: cs.primary),
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
            return _vazio(context, 'Nenhuma intendência neste distrito.');
          }
          final distritoNome = _safeDocStr(distrito!, 'nome');
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (_, i) {
              final it = docs[i];
              final nome = _safeDocStr(it, 'nome');
              return wrapCard(
                ListTile(
                  leading: leadingIcon(Icons.account_tree),
                  title: Text(nome, style: titleStyle),
                  subtitle: Text(distritoNome, style: subtitleStyle),
                  trailing: Icon(Icons.chevron_right, color: cs.primary),
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
          return _vazio(context, 'Nenhuma igreja nesta intendência.');
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final ig = docs[i];
            return _IgrejaCard(igreja: ig as QueryDocumentSnapshot);
          },
        );
      },
    );
  }

  Widget _vazio(BuildContext context, String msg) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          msg,
          style:
          TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: cs.onBackground),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// RESULTADO DE BUSCA (lista direta de igrejas filtrando por nome de igreja/intendência/referências)
class _BuscaIgrejasList extends StatelessWidget {
  final String filtro;
  const _BuscaIgrejasList({required this.filtro});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final f = filtro.trim().toLowerCase();

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
        final list = all.where((d) {
          final m = (d.data() as Map<String, dynamic>?) ?? {};
          final nome = (m['nome'] ?? '').toString().toLowerCase();
          final intend = (m['intendenciaNome'] ?? '').toString().toLowerCase();
          final refs = (m['referencias'] ?? '').toString().toLowerCase();
          return nome.contains(f) || intend.contains(f) || refs.contains(f);
        }).toList();

        if (list.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Nenhum resultado para a pesquisa.',
                  style: TextStyle(color: cs.onBackground)),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _IgrejaCard(igreja: list[i] as QueryDocumentSnapshot),
        );
      },
    );
  }
}

/// CARD DE IGREJA + DETALHES (somente leitura)
class _IgrejaCard extends StatelessWidget {
  final QueryDocumentSnapshot igreja;

  const _IgrejaCard({required this.igreja});

  String _safeStr(Map<String, dynamic> m, String key) =>
      (m[key] ?? '').toString();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final m = (igreja.data() as Map<String, dynamic>?) ?? {};
    final nome = _safeStr(m, 'nome');
    final distritoNome = _safeStr(m, 'distritoNome');
    final intendenciaNome = _safeStr(m, 'intendenciaNome');

    // Novos campos (podem vir do documento da igreja OU ficar vazios)
    final bispoNomeDoc = _safeStr(m, 'bispoNome');
    final superintendenteNomeDoc = _safeStr(m, 'superintendenteNome');

    // Precisamos do distritoId para fallback
    final distritoId = _safeStr(m, 'distritoId');

    final pastores = (m['pastores'] ?? []) as List?; // [{nome, contato/telefone}]
    final secretarioNome = _safeStr(m, 'secretarioNome');
    final secretarioContato = _safeStr(m, 'secretarioContato').isNotEmpty
        ? _safeStr(m, 'secretarioContato')
        : _safeStr(m, 'secretarioTelefone');

    final localizacaoUrl = _safeStr(m, 'localizacaoUrl').isNotEmpty
        ? _safeStr(m, 'localizacaoUrl')
        : _safeStr(m, 'localizacao');
    final referencias = _safeStr(m, 'referencias');

    TextStyle titleStyle =
    TextStyle(fontWeight: FontWeight.w700, color: cs.onSecondaryContainer);
    TextStyle subStyle =
    TextStyle(color: cs.onSecondaryContainer.withOpacity(0.9));

    return Card(
      color: cs.secondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.secondary),
      ),
      elevation: 0,
      child: ExpansionTile(
        collapsedTextColor: cs.onSecondaryContainer,
        textColor: cs.onSecondaryContainer,
        iconColor: cs.primary,
        collapsedIconColor: cs.primary,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: cs.secondaryContainer,
          child: Icon(Icons.church, color: cs.onSecondaryContainer),
        ),
        title: Text(nome.isEmpty ? 'Igreja' : nome, style: titleStyle),
        subtitle: Text(
          [
            if (distritoNome.isNotEmpty) distritoNome,
            if (intendenciaNome.isNotEmpty) intendenciaNome,
          ].join(' • '),
          style: subStyle,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          const SizedBox(height: 8),

          // 🔹 Bispo e Superintendente com fallback para o Distrito
          _DistritoLeaders(
            distritoId: distritoId,
            bispoFromChurch: bispoNomeDoc,
            superFromChurch: superintendenteNomeDoc,
          ),

          const SizedBox(height: 12),

          // 🔹 Pastores
          _secTitle(context, 'Pastor(es)'),
          const SizedBox(height: 6),
          if ((pastores?.isNotEmpty ?? false))
            ...pastores!.map((p) {
              final pMap = (p is Map) ? p as Map : {};
              final pNome = (pMap['nome'] ?? '').toString();
              final pContato =
              (pMap['contato'] ?? pMap['telefone'] ?? '').toString();
              return ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(Icons.person_outline,
                    color: cs.onSecondaryContainer),
                title: Text(pNome.isEmpty ? '—' : pNome,
                    style: TextStyle(color: cs.onSecondaryContainer)),
                subtitle: pContato.isEmpty
                    ? null
                    : Text(pContato,
                    style: TextStyle(
                        color:
                        cs.onSecondaryContainer.withOpacity(0.9))),
                trailing: pContato.isEmpty
                    ? null
                    : IconButton(
                  icon: Icon(Icons.call, color: cs.primary),
                  onPressed: () => _call(pContato),
                ),
              );
            })
          else
            Text('Sem pastores cadastrados.',
                style: TextStyle(color: cs.onSecondaryContainer)),

          const SizedBox(height: 12),

          // 🔹 Secretário
          _secTitle(context, 'Secretário'),
          const SizedBox(height: 6),
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Icon(Icons.badge_outlined, color: cs.onSecondaryContainer),
            title: Text(
              secretarioNome.isEmpty ? '—' : secretarioNome,
              style: TextStyle(color: cs.onSecondaryContainer),
            ),
            subtitle: secretarioContato.isEmpty
                ? null
                : Text(secretarioContato,
                style:
                TextStyle(color: cs.onSecondaryContainer.withOpacity(0.9))),
            trailing: secretarioContato.isEmpty
                ? null
                : IconButton(
              icon: Icon(Icons.call, color: cs.primary),
              onPressed: () => _call(secretarioContato),
            ),
          ),

          const SizedBox(height: 12),

          // 🔹 Localização
          _secTitle(context, 'Localização'),
          const SizedBox(height: 6),
          _LocationCard(
            mapLink: localizacaoUrl,
            referencias: referencias,
          ),
        ],
      ),
    );
  }

  Widget _secTitle(BuildContext context, String t) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      t,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        color: cs.primary,
      ),
    );
  }

  void _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

/// Mostra Bispo e Superintendente.
/// Se não existirem no doc da igreja, faz fallback para o doc do distrito (via distritoId).
class _DistritoLeaders extends StatelessWidget {
  final String distritoId;
  final String bispoFromChurch;
  final String superFromChurch;

  const _DistritoLeaders({
    required this.distritoId,
    required this.bispoFromChurch,
    required this.superFromChurch,
  });

  String _safeStr(Map<String, dynamic> m, String key) =>
      (m[key] ?? '').toString();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Se já veio tudo do doc da igreja, só renderiza
    if (bispoFromChurch.isNotEmpty || superFromChurch.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bispoFromChurch.isNotEmpty) ...[
            _secTitle(context, 'Bispo'),
            const SizedBox(height: 6),
            Text(bispoFromChurch, style: TextStyle(color: cs.onSecondaryContainer)),
            const SizedBox(height: 12),
          ],
          if (superFromChurch.isNotEmpty) ...[
            _secTitle(context, 'Superintendente'),
            const SizedBox(height: 6),
            Text(superFromChurch, style: TextStyle(color: cs.onSecondaryContainer)),
            const SizedBox(height: 12),
          ],
        ],
      );
    }

    // Caso contrário, buscar no Distrito
    if (distritoId.isEmpty) {
      // Sem distritoId, não há como buscar — apenas não mostra
      return const SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('distritos')
          .doc(distritoId)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        final m = (snap.data?.data() as Map<String, dynamic>?) ?? {};
        final bispo = _safeStr(m, 'bispoNome');
        final superint = _safeStr(m, 'superintendenteNome');

        if (bispo.isEmpty && superint.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (bispo.isNotEmpty) ...[
              _secTitle(context, 'Bispo'),
              const SizedBox(height: 6),
              Text(bispo, style: TextStyle(color: cs.onSecondaryContainer)),
              const SizedBox(height: 12),
            ],
            if (superint.isNotEmpty) ...[
              _secTitle(context, 'Superintendente'),
              const SizedBox(height: 6),
              Text(superint, style: TextStyle(color: cs.onSecondaryContainer)),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }

  Widget _secTitle(BuildContext context, String t) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      t,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        color: cs.primary,
      ),
    );
  }
}

/// BLOCO VISUAL DE LOCALIZAÇÃO
class _LocationCard extends StatelessWidget {
  final String mapLink;
  final String referencias;
  const _LocationCard({required this.mapLink, required this.referencias});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final hasLink = mapLink.trim().isNotEmpty;
    final hasRefs = referencias.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: cs.primary),
        borderRadius: BorderRadius.circular(12),
        color: cs.secondaryContainer,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mapa / Endereço salvo',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: cs.onSecondaryContainer)),
          const SizedBox(height: 6),
          Text(
            hasLink ? mapLink : 'Sem link de mapa cadastrado.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: cs.onSecondaryContainer),
          ),
          if (hasRefs) ...[
            const SizedBox(height: 10),
            Text('Referências / Vizinhança',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: cs.onSecondaryContainer)),
            const SizedBox(height: 4),
            Text(referencias, style: TextStyle(color: cs.onSecondaryContainer)),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: hasLink ? () => _openMap(mapLink) : null,
              icon: const Icon(Icons.map_outlined),
              label: const Text('Ver no mapa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
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
