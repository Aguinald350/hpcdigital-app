import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetalhesHinoScreen extends StatelessWidget {
  final DocumentSnapshot hino;

  const DetalhesHinoScreen({super.key, required this.hino});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final numero   = (hino['numero']   ?? '').toString();
    final titulo   = (hino['titulo']   ?? 'Sem título').toString();
    final conteudo = (hino['conteudo'] ?? 'Conteúdo indisponível').toString();
    final secao    = (hino['secao']    ?? 'Sem seção').toString();
    final escritor = (hino['escritor'] ?? 'Desconhecido').toString();
    final lingua   = (hino['lingua']   ?? 'Idioma indefinido').toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Hino'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: Text(
                'Hino $numero - $titulo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: cs.primary, // destaque pelo tema
                ),
              ),
            ),
            const SizedBox(height: 16),

            // “Ficha técnica”
            _buildItem(context, 'Idioma', lingua),
            _buildItem(context, 'Seção', secao),
            _buildItem(context, 'Escritor', escritor),

            const SizedBox(height: 8),
            Divider(color: cs.secondary.withOpacity(0.35), height: 32),

            Text(
              'Letra do Hino:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: cs.onBackground,
              ),
            ),
            const SizedBox(height: 12),

            // bloco de conteúdo com leve contraste do tema
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                conteudo,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: cs.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, String label, String value) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: cs.primary, // realce pelo tema
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: cs.onBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
