import 'package:flutter/material.dart';
import '../models/hymn_models.dart';

class DetalhesHinoScreenOffline extends StatelessWidget {
  final HymnOfDay hino;

  const DetalhesHinoScreenOffline({super.key, required this.hino});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hino ${hino.numero}'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: Text(
                '${hino.titulo}\n(Nº ${hino.numero})',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hino.conteudo,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: cs.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
