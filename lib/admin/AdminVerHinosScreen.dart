import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'editar_hino_screen.dart';

class AdminVerHinosScreen extends StatefulWidget {
  const AdminVerHinosScreen({super.key});

  @override
  State<AdminVerHinosScreen> createState() => _AdminVerHinosScreenState();
}

class _AdminVerHinosScreenState extends State<AdminVerHinosScreen> {
  String _filtro = '';
  final TextEditingController _searchController = TextEditingController();

  Future<void> _confirmarExcluir(DocumentSnapshot hino) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Hino'),
        content: Text('Tem certeza que deseja excluir o hino "${hino['titulo']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('hinos').doc(hino.id).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hino excluído com sucesso')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir hino: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Hinos'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _filtro = value.trim().toLowerCase()),
              decoration: InputDecoration(
                labelText: 'Buscar por número ou título',
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

                  return ListView.separated(
                    itemCount: hinos.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final hino = hinos[index];
                      final numero = hino['numero'] ?? '';
                      final titulo = hino['titulo'] ?? '';

                      return ListTile(
                        leading: const Icon(Icons.library_music, color: Colors.deepOrange),
                        title: Text('Hino $numero - $titulo'),
                        subtitle: Text(hino['lingua'] ?? 'Sem idioma'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditarHinoScreen(hino: hino),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmarExcluir(hino),
                            ),
                          ],
                        ),
                      );
                    },
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
