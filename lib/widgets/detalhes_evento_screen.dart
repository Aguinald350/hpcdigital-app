import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetalhesEventoScreen extends StatelessWidget {
  final DocumentSnapshot evento;
  const DetalhesEventoScreen({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final data = evento.data() as Map<String, dynamic>? ?? {};

    final nome = (data['nome'] ?? 'Evento sem nome').toString();
    final descricao = (data['descricao'] ?? '').toString();
    final classe = (data['classe'] ?? '').toString();
    final dataEvento = (data['data'] as Timestamp?)?.toDate();
    final status = (data['status'] ?? '').toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(nome),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              nome,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (dataEvento != null)
              Text(
                'Data: ${dataEvento.day}/${dataEvento.month}/${dataEvento.year}',
                style: TextStyle(color: cs.primary),
              ),
            const SizedBox(height: 8),
            Text('Classe: $classe'),
            Text('Status: $status'),
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
