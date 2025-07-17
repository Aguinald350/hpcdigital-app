import 'package:flutter/material.dart';
import 'package:hpcdigital/screens/secoes/KimbunduSection.dart';
import 'package:hpcdigital/screens/secoes/UmbunduSection.dart';
import 'secoes/PortuguesSection.dart';

class SecaoScreen extends StatelessWidget {
  final String titulo;

  const SecaoScreen({super.key, required this.titulo});

  Widget _selecionarConteudo(String titulo) {
    switch (titulo) {
      case 'Português':
        return const PortuguesSection();
      case 'Kimbundu':
        return const KimbunduSection();
      case 'Umbundu':
        return const UmbunduSection();
      default:
        return Center(child: Text('Seção "$titulo" ainda não implementada.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text(titulo),
        centerTitle: true,
      ),
      body: _selecionarConteudo(titulo), // Corrigido aqui
    );
  }
}
