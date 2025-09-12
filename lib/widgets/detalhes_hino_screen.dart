import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetalhesHinoScreen extends StatelessWidget {
  final DocumentSnapshot hino;

  const DetalhesHinoScreen({super.key, required this.hino});

  @override
  Widget build(BuildContext context) {
    final numero = hino['numero'] ?? '';
    final titulo = hino['titulo'] ?? 'Sem título';
    final conteudo = hino['conteudo'] ?? 'Conteúdo indisponível';
    final secao = hino['secao'] ?? 'Sem seção';
    final escritor = hino['escritor'] ?? 'Desconhecido';
    final lingua = hino['lingua'] ?? 'Idioma indefinido';
    // final data = (hino['dataCriacao'] as Timestamp?)?.toDate(); // Removido para usuários

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Hino'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: Text(
                'Hino $numero - $titulo',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepOrange),
              ),
            ),
            const SizedBox(height: 16),
            _buildItem('Idioma', lingua),
            _buildItem('Seção', secao),
            _buildItem('Escritor', escritor),
            const Divider(height: 32),
            const Text(
              'Letra do Hino:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              conteudo,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
