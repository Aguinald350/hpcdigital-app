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

  final List<String> _secoesKikongo = [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      // appBar: AppBar(
      //   title: const Text('HPC - Seção em Kikongo'),
      //   backgroundColor: Colors.deepOrange,
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _filtro = value.trim().toLowerCase()),
              decoration: InputDecoration(
                labelText: 'Buscar por número ou nome',
                prefixIcon: const Icon(Icons.search, color: Colors.deepOrange),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepOrange),
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
                    return const Center(child: Text('Nenhum hino encontrado.'));
                  }

                  final hinos = snapshot.data!.docs.where((doc) {
                    final titulo = doc['titulo'].toString().toLowerCase();
                    final numero = doc['numero'].toString().toLowerCase();
                    return titulo.contains(_filtro) || numero.contains(_filtro);
                  }).toList();

                  if (hinos.isEmpty) {
                    return const Center(child: Text('Nenhum resultado para essa busca.'));
                  }

                  final Map<String, List<QueryDocumentSnapshot>> hinosPorSecao = {
                    for (var secao in _secoesKikongo) secao: [],
                  };

                  for (var doc in hinos) {
                    final secao = doc['secao'] ?? 'Outros';
                    if (_secoesKikongo.contains(secao)) {
                      hinosPorSecao[secao]?.add(doc);
                    } else {
                      hinosPorSecao['Outros']?.add(doc);
                    }
                  }

                  return ListView(
                    children: hinosPorSecao.entries
                        .where((entry) => entry.value.isNotEmpty)
                        .map((entry) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: ExpansionTile(
                          iconColor: Colors.deepOrange,
                          collapsedIconColor: Colors.deepOrange,
                          title: Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                          children: entry.value.map((hinoDoc) {
                            final numero = hinoDoc['numero'] ?? '';
                            final titulo = hinoDoc['titulo'];
                            return ListTile(
                              leading: const Icon(Icons.library_music, color: Colors.deepOrange),
                              title: Text('Hino $numero - $titulo'),
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
}
