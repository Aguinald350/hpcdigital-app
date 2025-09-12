// Versao 1
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import '../../widgets/detalhes_hino_screen.dart';
//
// class PortuguesSection extends StatefulWidget {
//   const PortuguesSection({super.key});
//
//   @override
//   State<PortuguesSection> createState() => _PortuguesSectionState();
// }
//
// class _PortuguesSectionState extends State<PortuguesSection> {
//   String _filtro = '';
//   final TextEditingController _searchController = TextEditingController();
//
//   // Lista oficial de seções
//   final List<String> _secoesOficiais = [
//     'Louvor a Deus',
//     'O Evangelho de Jesus Cristo',
//     'O Espírito Santo',
//     'A Vida Cristã',
//     'Evangelização e Avivamento',
//     'Unidade e Comunhão Fraternal',
//     'Sacramentos - Casamentos',
//     'Ministério',
//     'Organizações da Igreja',
//     'O Testemunho Vivo dos Cristãos',
//     'Advento e Natal',
//     'Quaresma e Páscoa',
//     'O Dia do Senhor e Ações de Graças',
//     'Hinos Matutinos e Vespertinos',
//     'O Lar Cristão',
//     'Despedidas e Viagens',
//     'Funerais',
//     'Segunda Vinda de Cristo',
//     'A Bíblia',
//     'O Ano Novo',
//     'Dedicações e Aniversários',
//     'Finais',
//     'Outros',
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF9F9F9),
//       // appBar: AppBar(
//       //   title: const Text('HPC - Seção em Português'),
//       //   backgroundColor: Colors.deepOrange,
//       // ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: _searchController,
//               onChanged: (value) => setState(() => _filtro = value.trim().toLowerCase()),
//               decoration: InputDecoration(
//                 labelText: 'Buscar por número ou nome',
//                 prefixIcon: const Icon(Icons.search, color: Colors.deepOrange),
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 focusedBorder: const OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.deepOrange),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('hinos')
//                     .where('lingua', isEqualTo: 'Português')
//                     .orderBy('numero')
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//
//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return const Center(child: Text('Nenhum hino encontrado.'));
//                   }
//
//                   final hinos = snapshot.data!.docs.where((doc) {
//                     final titulo = doc['titulo'].toString().toLowerCase();
//                     final numero = doc['numero'].toString().toLowerCase();
//                     return titulo.contains(_filtro) || numero.contains(_filtro);
//                   }).toList();
//
//                   if (hinos.isEmpty) {
//                     return const Center(child: Text('Nenhum resultado para essa busca.'));
//                   }
//
//                   // Agrupar hinos por seção oficial
//                   final Map<String, List<QueryDocumentSnapshot>> hinosPorSecao = {};
//                   for (var secao in _secoesOficiais) {
//                     hinosPorSecao[secao] = [];
//                   }
//
//                   for (var doc in hinos) {
//                     final secao = doc['secao'] ?? 'Outros';
//                     if (_secoesOficiais.contains(secao)) {
//                       hinosPorSecao[secao]?.add(doc);
//                     } else {
//                       hinosPorSecao['Outros']?.add(doc);
//                     }
//                   }
//
//                   return ListView(
//                     children: hinosPorSecao.entries
//                         .where((entry) => entry.value.isNotEmpty)
//                         .map((entry) {
//                       return Card(
//                         margin: const EdgeInsets.symmetric(vertical: 8),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         elevation: 3,
//                         child: ExpansionTile(
//                           iconColor: Colors.deepOrange,
//                           collapsedIconColor: Colors.deepOrange,
//                           title: Text(
//                             entry.key,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.deepOrange,
//                             ),
//                           ),
//                           children: entry.value.map((hinoDoc) {
//                             final numero = hinoDoc['numero'] ?? '';
//                             final titulo = hinoDoc['titulo'];
//                             return ListTile(
//                               leading: const Icon(Icons.library_music, color: Colors.deepOrange),
//                               title: Text('Hino $numero - $titulo'),
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) => DetalhesHinoScreen(hino: hinoDoc),
//                                   ),
//                                 );
//                               },
//                             );
//                           }).toList(),
//                         ),
//                       );
//                     }).toList(),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//////////////versao 2///////////
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import '../../widgets/detalhes_hino_screen.dart';
//
// class PortuguesSection extends StatefulWidget {
//   const PortuguesSection({super.key});
//
//   @override
//   State<PortuguesSection> createState() => _PortuguesSectionState();
// }
//
// class _PortuguesSectionState extends State<PortuguesSection> {
//   String _filtro = '';
//   final TextEditingController _searchController = TextEditingController();
//
//   // Lista oficial de seções
//   final List<String> _secoesOficiais = const [
//     'Louvor a Deus',
//     'O Evangelho de Jesus Cristo',
//     'O Espírito Santo',
//     'A Vida Cristã',
//     'Evangelização e Avivamento',
//     'Unidade e Comunhão Fraternal',
//     'Sacramentos - Casamentos',
//     'Ministério',
//     'Organizações da Igreja',
//     'O Testemunho Vivo dos Cristãos',
//     'Advento e Natal',
//     'Quaresma e Páscoa',
//     'O Dia do Senhor e Ações de Graças',
//     'Hinos Matutinos e Vespertinos',
//     'O Lar Cristão',
//     'Despedidas e Viagens',
//     'Funerais',
//     'Segunda Vinda de Cristo',
//     'A Bíblia',
//     'O Ano Novo',
//     'Dedicações e Aniversários',
//     'Finais',
//     'Outros',
//   ];
//
//   int _toInt(dynamic numero) {
//     // converte numero (int, String, null) em int seguro para ordenação
//     if (numero is int) return numero;
//     if (numero is String) {
//       final n = int.tryParse(numero.trim());
//       return n ?? 0;
//     }
//     return 0;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF9F9F9),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: _searchController,
//               onChanged: (value) => setState(() => _filtro = value.trim().toLowerCase()),
//               decoration: InputDecoration(
//                 labelText: 'Buscar por número ou nome',
//                 prefixIcon: const Icon(Icons.search, color: Colors.deepOrange),
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 focusedBorder: const OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.deepOrange),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('hinos')
//                     .where('lingua', isEqualTo: 'Português')
//                 // essa ordenação é global, mas vamos garantir a ordenação por seção abaixo
//                     .orderBy('numero')
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//
//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return const Center(child: Text('Nenhum hino encontrado.'));
//                   }
//
//                   // filtro por número ou título
//                   final hinosFiltrados = snapshot.data!.docs.where((doc) {
//                     final titulo = (doc['titulo'] ?? '').toString().toLowerCase();
//                     final numeroStr = (doc['numero'] ?? '').toString().toLowerCase();
//                     return titulo.contains(_filtro) || numeroStr.contains(_filtro);
//                   }).toList();
//
//                   if (hinosFiltrados.isEmpty) {
//                     return const Center(child: Text('Nenhum resultado para essa busca.'));
//                   }
//
//                   // Agrupar por seção oficial
//                   final Map<String, List<QueryDocumentSnapshot>> hinosPorSecao = {
//                     for (final sec in _secoesOficiais) sec: <QueryDocumentSnapshot>[],
//                   };
//
//                   for (var doc in hinosFiltrados) {
//                     final secao = (doc['secao'] ?? 'Outros').toString();
//                     if (_secoesOficiais.contains(secao)) {
//                       hinosPorSecao[secao]!.add(doc);
//                     } else {
//                       hinosPorSecao['Outros']!.add(doc);
//                     }
//                   }
//
//                   // Ordenar numericamente dentro de cada seção
//                   for (final entry in hinosPorSecao.entries) {
//                     entry.value.sort((a, b) {
//                       final na = _toInt(a['numero']);
//                       final nb = _toInt(b['numero']);
//                       return na.compareTo(nb);
//                     });
//                   }
//
//                   return ListView(
//                     children: hinosPorSecao.entries
//                         .where((entry) => entry.value.isNotEmpty)
//                         .map((entry) {
//                       return Card(
//                         margin: const EdgeInsets.symmetric(vertical: 8),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         elevation: 3,
//                         child: ExpansionTile(
//                           iconColor: Colors.deepOrange,
//                           collapsedIconColor: Colors.deepOrange,
//                           title: Text(
//                             entry.key,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.deepOrange,
//                             ),
//                           ),
//                           children: entry.value.map((hinoDoc) {
//                             final numero = hinoDoc['numero'];
//                             final titulo = hinoDoc['titulo'] ?? '';
//                             return ListTile(
//                               leading: const Icon(Icons.library_music, color: Colors.deepOrange),
//                               title: Text('Hino ${_toInt(numero)} - $titulo'),
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) => DetalhesHinoScreen(hino: hinoDoc),
//                                   ),
//                                 );
//                               },
//                             );
//                           }).toList(),
//                         ),
//                       );
//                     }).toList(),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

/////////versao 3 /////////////////
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widgets/detalhes_hino_screen.dart';

class PortuguesSection extends StatefulWidget {
  const PortuguesSection({super.key});

  @override
  State<PortuguesSection> createState() => _PortuguesSectionState();
}

class _PortuguesSectionState extends State<PortuguesSection> {
  String _filtro = '';
  final TextEditingController _searchController = TextEditingController();

  // Lista oficial de seções
  final List<String> _secoesOficiais = const [
    'Louvor a Deus',
    'O Evangelho de Jesus Cristo',
    'O Espírito Santo',
    'A Vida Cristã',
    'Evangelização e Avivamento',
    'Unidade e Comunhão Fraternal',
    'Sacramentos - Casamentos',
    'Ministério',
    'Organizações da Igreja',
    'O Testemunho Vivo dos Cristãos',
    'Advento e Natal',
    'Quaresma e Páscoa',
    'O Dia do Senhor e Ações de Graças',
    'Hinos Matutinos e Vespertinos',
    'O Lar Cristão',
    'Despedidas e Viagens',
    'Funerais',
    'Segunda Vinda de Cristo',
    'A Bíblia',
    'O Ano Novo',
    'Dedicações e Aniversários',
    'Finais',
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
    final temBusca = _filtro.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
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
                    .where('lingua', isEqualTo: 'Português')
                    .orderBy('numero')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Nenhum hino encontrado.'));
                  }

                  // Filtrar por número ou título
                  final todos = snapshot.data!.docs;
                  final filtrados = todos.where((doc) {
                    final titulo = (doc['titulo'] ?? '').toString().toLowerCase();
                    final numeroStr = (doc['numero'] ?? '').toString().toLowerCase();
                    return titulo.contains(_filtro) || numeroStr.contains(_filtro);
                  }).toList();

                  if (temBusca) {
                    // Modo lista simples para busca
                    if (filtrados.isEmpty) {
                      return const Center(child: Text('Nenhum resultado para essa busca.'));
                    }

                    filtrados.sort((a, b) {
                      final na = _toInt(a['numero']);
                      final nb = _toInt(b['numero']);
                      return na.compareTo(nb);
                    });

                    return ListView.separated(
                      itemCount: filtrados.length,
                      separatorBuilder: (_, __) => const Divider(height: 0),
                      itemBuilder: (context, i) {
                        final doc = filtrados[i];
                        final numero = _toInt(doc['numero']);
                        final titulo = (doc['titulo'] ?? '').toString();
                        final secao = (doc['secao'] ?? '').toString();

                        return ListTile(
                          leading: const Icon(Icons.library_music, color: Colors.deepOrange),
                          title: Text('Hino $numero - $titulo'),
                          subtitle: secao.isEmpty ? null : Text(secao),
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

                  // Sem busca: agrupar por seção e expandir
                  final Map<String, List<QueryDocumentSnapshot>> hinosPorSecao = {
                    for (final sec in _secoesOficiais) sec: <QueryDocumentSnapshot>[],
                  };

                  for (var doc in todos) {
                    final secao = (doc['secao'] ?? 'Outros').toString();
                    if (_secoesOficiais.contains(secao)) {
                      hinosPorSecao[secao]!.add(doc);
                    } else {
                      hinosPorSecao['Outros']!.add(doc);
                    }
                  }

                  for (final entry in hinosPorSecao.entries) {
                    entry.value.sort((a, b) {
                      final na = _toInt(a['numero']);
                      final nb = _toInt(b['numero']);
                      return na.compareTo(nb);
                    });
                  }

                  final gruposVisiveis = hinosPorSecao.entries
                      .where((entry) => entry.value.isNotEmpty)
                      .toList();

                  if (gruposVisiveis.isEmpty) {
                    return const Center(child: Text('Nenhum hino encontrado.'));
                  }

                  return ListView(
                    children: gruposVisiveis.map((entry) {
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
                            final numero = _toInt(hinoDoc['numero']);
                            final titulo = (hinoDoc['titulo'] ?? '').toString();
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
