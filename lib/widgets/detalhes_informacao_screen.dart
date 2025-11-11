import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetalhesInformacaoScreen extends StatelessWidget {
  final DocumentSnapshot info;
  const DetalhesInformacaoScreen({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final data = info.data() as Map<String, dynamic>? ?? {};

    final titulo = (data['titulo'] ?? 'Sem título').toString();
    final descricao = (data['descricao'] ?? '').toString();
    final classe = (data['classe'] ?? '').toString();
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (createdAt != null)
              Text(
                'Criado em: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                style: TextStyle(color: cs.primary),
              ),
            if (updatedAt != null)
              Text(
                'Atualizado em: ${updatedAt.day}/${updatedAt.month}/${updatedAt.year}',
                style: TextStyle(color: cs.primary),
              ),
            const SizedBox(height: 8),
            Text('Classe: $classe'),
            const Divider(height: 32),
            Text(
              descricao,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
