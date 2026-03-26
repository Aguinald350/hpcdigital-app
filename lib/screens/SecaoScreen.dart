// import 'package:flutter/material.dart';
// import 'package:hpcdigital/screens/secoes/KikongoSection.dart';
// import 'package:hpcdigital/screens/secoes/KimbunduSection.dart';
// import 'package:hpcdigital/screens/secoes/UmbunduSection.dart';
// import 'secoes/PortuguesSection.dart';
//
// class SecaoScreen extends StatelessWidget {
//   final String titulo;
//
//   const SecaoScreen({super.key, required this.titulo});
//
//   Widget _selecionarConteudo(String titulo) {
//     switch (titulo) {
//       case 'Português':
//         return const PortuguesSection();
//       case 'Kimbundu':
//         return const KimbunduSection();
//       case 'Umbundu':
//         return const UmbunduSection();
//       case 'Kikongo':
//         return const KikongoSection();
//       default:
//         return Center(child: Text('Seção "$titulo" ainda não implementada.'));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: cs.primary,      // was: Colors.deepOrange
//         foregroundColor: cs.onPrimary,     // texto/ícones do AppBar
//         title: Text(titulo),
//         centerTitle: true,
//       ),
//       body: _selecionarConteudo(titulo), // Corrigido aqui
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:hpcdigital/screens/secoes/KikongoSection.dart';
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
      case 'Kikongo':
        return const KikongoSection();
      default:
        return Center(
          child: Text('Seção "$titulo" ainda não implementada.'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        title: Text(titulo),
        centerTitle: true,
      ),
      body: _selecionarConteudo(titulo),
    );
  }
}
