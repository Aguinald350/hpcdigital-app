import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widgets/detalhes_hino_screen.dart';

class UmbunduSection extends StatefulWidget {
  const UmbunduSection({super.key});

  @override
  State<UmbunduSection> createState() => _UmbunduSectionState();
}

class _UmbunduSectionState extends State<UmbunduSection> {
  String _filtro = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _secoesUmbundu = [
    'Esivayo Lefendelo (1–12)',
    'Espiritu Sandu (13–17)',
    'Ucito wa Yesu Kristu (18–23)',
    'Okufa kua Ñala Yesu Kristu (24–28)',
    'Epinduko lia Yesu Kristu (29–33)',
    'Ekongelo lia Yesu Kristu (34–36)',
    'Epata Lietavo lia Kristu (37–40)',
    'Omesa ya Ñala Yesu Kristu (41–46)',
    'Oku Laleka (47–54)',
    'Oku Likutíllia (55–65)',
    'Oku Litumbika (66–72)',
    'Ekololo Lelembekeleo (73–87)',
    'Uvangi Lupange (88–94)',
    'Olopandu (95–102)',
    'Ovisungo Vioñolosi (103–105)',
    'Embímbiliya (106–109)',
    'Ovisungo Viomala (110–113)',
    'Okufa Kukua Kristu (114–119)',
    'Oku Yalula (120–123)',
    'Oku Tumbangiya (124–129)',
    'Outros',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      // appBar: AppBar(
      //   title: const Text('HPC - Seção em Umbundu'),
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
                    .where('lingua', isEqualTo: 'Umbundu')
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
                    for (var secao in _secoesUmbundu) secao: [],
                  };

                  for (var doc in hinos) {
                    final secao = doc['secao'] ?? 'Outros';
                    if (_secoesUmbundu.contains(secao)) {
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
