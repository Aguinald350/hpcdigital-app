import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widgets/detalhes_hino_screen.dart';

class KikongoSection extends StatefulWidget {
  const KikongoSection({super.key});

  @override
  State<KikongoSection> createState() => _KikongoSectionState();
}

class _KikongoSectionState extends State<KikongoSection> {
  String _filtro = '';
  final TextEditingController _searchController = TextEditingController();

  // Lista oficial (use exatamente estes textos que você grava no Firestore)
  final List<String> _secoesKikongo = const [
    'Kembelela Nzambi — Mwanda Helela (1–10)',
    'N’sangu za Yisu Klisto (11–24)',
    'Zingu kia Nkwikizi (25–37)',
    'N’samu ye Nkubameno (38–42)',
    'Hamosi ye Nkutakani ya Nzolua Nzambi (43)',
    'Mvubilu (44)',
    'Lukazalu (45)',
    'Nlekelo a Mfumu (46–48)',
    'Kimbangí kia Moyo wa Nkwikizi (49–66)',
    'Matondo (67–71)',
    'Ngiza yo Luwutuku (72–77)',
    'Lufwa lua Yisu (78–84)',
    'Lufuluku (85–87)',
    'Nkanda Nzambi (88)',
    'Mvo wa Mpa (89)',
    'Nkunga mia mene-mene yo masika (90–92)',
    'Nzó ya Nkwikizi (93)',
    'Lukananu (94)',
    'Nzikilu ya Mafwa/Ezulu (95–100)',
    'Ngiza ya Zole ya Klisto (101–103)',
    'Aleke (104–107)',
    'Outros',
  ];

  int _toInt(dynamic numero) {
    if (numero is int) return numero;
    if (numero is String) {
      final n = int.tryParse(numero.trim());
      return n ?? 0;
    }
    return 0;
    // 0 serve para manter ordenação sem crash.
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
                    .where('lingua', isEqualTo: 'Kikongo')
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

                  // Filtro por número ou título
                  final filtrados = todos.where((doc) {
                    final titulo = (doc['titulo'] ?? '').toString().toLowerCase();
                    final numeroStr = (doc['numero'] ?? '').toString().toLowerCase();
                    return titulo.contains(_filtro) || numeroStr.contains(_filtro);
                  }).toList();

                  if (temBusca) {
                    if (filtrados.isEmpty) {
                      return _msg(context, 'Nenhum resultado para essa busca.');
                    }

                    // Ordena numericamente
                    filtrados.sort((a, b) {
                      final na = _toInt(a['numero']);
                      final nb = _toInt(b['numero']);
                      return na.compareTo(nb);
                    });

                    // Lista plana (mais prática para busca)
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
                            style: TextStyle(color: cs.onBackground.withOpacity(0.8)),
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

                  // Sem busca: agrupa por seção oficial
                  final Map<String, List<QueryDocumentSnapshot>> hinosPorSecao = {
                    for (final sec in _secoesKikongo) sec: <QueryDocumentSnapshot>[],
                  };

                  for (var doc in todos) {
                    final secao = (doc['secao'] ?? 'Outros').toString();
                    if (_secoesKikongo.contains(secao)) {
                      hinosPorSecao[secao]!.add(doc);
                    } else {
                      hinosPorSecao['Outros']!.add(doc);
                    }
                  }

                  // Ordena numericamente dentro de cada seção
                  for (final entry in hinosPorSecao.entries) {
                    entry.value.sort((a, b) {
                      final na = _toInt(a['numero']);
                      final nb = _toInt(b['numero']);
                      return na.compareTo(nb);
                    });
                  }

                  final gruposVisiveis =
                  hinosPorSecao.entries.where((e) => e.value.isNotEmpty).toList();

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
