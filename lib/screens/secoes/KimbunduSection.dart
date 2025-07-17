import 'package:flutter/material.dart';

class KimbunduSection extends StatelessWidget {
  const KimbunduSection({super.key});

  @override
  Widget build(BuildContext context) {
    final assuntos = [
      'Diximanu dia Nzambi (1–16)',
      'O Njimbu ia Mbote ia Mbuludi (17–41)',
      'Nzumbi Ikola-Mukuatekexi (42–45)',
      'O Mueníu ua Ngeleja ni ua Kidistá (46–103)',
      'Itangana ia Ditungula mu Muvu (104–159)',
      'Dizubilu (160–162)',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(
              children: const [
                Icon(Icons.category, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text(
                  'Assuntos dos Hinos - Kimbundu',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...assuntos.map((assunto) => Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.music_note, color: Colors.deepOrange),
                title: Text(assunto),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
