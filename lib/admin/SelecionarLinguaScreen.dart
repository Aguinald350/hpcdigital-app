import 'package:flutter/material.dart';
import 'CadastrarHinoScreen.dart';

class SelecionarLinguaScreen extends StatelessWidget {
  const SelecionarLinguaScreen({super.key});

  final List<String> linguas = const ['Português', 'Kikongo', 'Kimbundu', 'Umbundu'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Língua'),
        backgroundColor: Colors.deepOrange,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: linguas.length,
        itemBuilder: (context, index) {
          final lingua = linguas[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              leading: const Icon(Icons.language, color: Colors.deepOrange),
              title: Text(lingua, style: const TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CadastrarHinoScreen(lingua: lingua),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
