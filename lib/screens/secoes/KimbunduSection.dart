import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widgets/detalhes_hino_screen.dart';

class KimbunduSection extends StatefulWidget {
  const KimbunduSection({super.key});

  @override
  State<KimbunduSection> createState() => _KimbunduSectionState();
}

class _KimbunduSectionState extends State<KimbunduSection> {
  String _filtro = '';
  final TextEditingController _searchController = TextEditingController();

  // Seções oficiais (os textos precisam bater com o que está salvo no Firestore)
  final List<String> _secoesKimbundu = const [
    'Diximanu dia Nzambi (1–16)',
    'O Njimbu ia Mbote ia Mbuludi (17–41)',
    'Nzumbi Ikola-Mukuatekexi (42–45)',
    'O Mueníu ua Ngeleja ni ua Kidistá (46–103)',
    'Itangana ia Ditungula mu Muvu (104–159)',
    'Dizubilu (160–162)',
    'Outros',
  ];

  int _toInt(dynamic numero) {
    if (numero is int) return numero;
    if (numero is String) {
      final n = int.tryParse(numero.trim());
      return n ?? 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final temBusca = _filtro.isNotEmpty;

    return Scaffold(
      backgroundColor: cs.background, // antes: Color(0xFFF9F9F9)
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _filtro = value.trim().toLowerCase()),
              style: TextStyle(color: cs.onBackground),
              decoration: InputDecoration(
                labelText: 'Buscar por número ou nome',
                labelStyle: TextStyle(color: cs.onBackground.withOpacity(0.8)),
                prefixIcon: Icon(Icons.search, color: cs.primary),
                filled: true,
                fillColor: cs.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('hinos')
                    .where('lingua', isEqualTo: 'Kimbundu')
                    .orderBy('numero')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _msg(context, 'Nenhum hino encontrado.');
                  }

                  final todos = snapshot.data!.docs;

                  // filtro por número ou título
                  final filtrados = todos.where((doc) {
                    final titulo = (doc['titulo'] ?? '').toString().toLowerCase();
                    final numeroStr = (doc['numero'] ?? '').toString().toLowerCase();
                    return titulo.contains(_filtro) || numeroStr.contains(_filtro);
                  }).toList();

                  if (temBusca) {
                    if (filtrados.isEmpty) {
                      return _msg(context, 'Nenhum resultado para essa busca.');
                    }

                    // ordena numericamente
                    filtrados.sort((a, b) {
                      final na = _toInt(a['numero']);
                      final nb = _toInt(b['numero']);
                      return na.compareTo(nb);
                    });

                    // lista plana (melhor para busca)
                    return ListView.separated(
                      itemCount: filtrados.length,
                      separatorBuilder: (_, __) => Divider(height: 0, color: cs.outlineVariant),
                      itemBuilder: (context, i) {
                        final doc = filtrados[i];
                        final numero = _toInt(doc['numero']);
                        final titulo = (doc['titulo'] ?? '').toString();
                        final secao = (doc['secao'] ?? '').toString();

                        return ListTile(
                          leading: Icon(Icons.library_music, color: cs.primary),
                          title: Text(
                            'Hino $numero - $titulo',
                            style: TextStyle(
                              color: cs.onBackground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: secao.isEmpty
                              ? null
                              : Text(
                            secao,
                            style: TextStyle(
                              color: cs.onBackground.withOpacity(0.8),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetalhesHinoScreen(hino: doc),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }

                  // Sem busca: agrupar por seção
                  final Map<String, List<QueryDocumentSnapshot>> hinosPorSecao = {
                    for (final sec in _secoesKimbundu) sec: <QueryDocumentSnapshot>[],
                  };

                  for (var doc in todos) {
                    final secao = (doc['secao'] ?? 'Outros').toString();
                    if (_secoesKimbundu.contains(secao)) {
                      hinosPorSecao[secao]!.add(doc);
                    } else {
                      hinosPorSecao['Outros']!.add(doc);
                    }
                  }

                  // Ordenar numericamente dentro de cada seção
                  for (final entry in hinosPorSecao.entries) {
                    entry.value.sort((a, b) {
                      final na = _toInt(a['numero']);
                      final nb = _toInt(b['numero']);
                      return na.compareTo(nb);
                    });
                  }

                  final gruposVisiveis = hinosPorSecao.entries
                      .where((e) => e.value.isNotEmpty)
                      .toList();

                  if (gruposVisiveis.isEmpty) {
                    return _msg(context, 'Nenhum hino encontrado.');
                  }

                  return ListView(
                    children: gruposVisiveis.map((entry) {
                      return Card(
                        color: cs.secondaryContainer, // cards/acessórios
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: cs.secondary), // borda/realce
                        ),
                        elevation: 0,
                        child: ExpansionTile(
                          iconColor: cs.primary,
                          collapsedIconColor: cs.primary,
                          collapsedTextColor: cs.onSecondaryContainer,
                          textColor: cs.onSecondaryContainer,
                          title: Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: cs.onSecondaryContainer,
                            ),
                          ),
                          children: entry.value.map((hinoDoc) {
                            final numero = _toInt(hinoDoc['numero']);
                            final titulo = (hinoDoc['titulo'] ?? '').toString();
                            return ListTile(
                              leading: Icon(Icons.library_music, color: cs.onSecondaryContainer),
                              title: Text(
                                'Hino $numero - $titulo',
                                style: TextStyle(
                                  color: cs.onSecondaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetalhesHinoScreen(hino: hinoDoc),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: cs.onBackground,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
