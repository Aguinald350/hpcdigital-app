import 'package:flutter/material.dart';

import 'SecaoScreen.dart';

class Hinario_Screen extends StatefulWidget {
  const Hinario_Screen({super.key});

  @override
  State<Hinario_Screen> createState() => _Hinario_ScreenState();
}

class _Hinario_ScreenState extends State<Hinario_Screen> {
  void _abrirSecao(BuildContext context, String titulo) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: SecaoScreen(titulo: titulo),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final secoes = [
      'Português',
      'Kikongo',
      'Umbundu',
      'Kimbundu',
      'Leitura Responsiva',
      'Invocações e Chamadas de Adoração',
      'Ritual da Santa Ceia',
      'Oração Dominical',
      'Credo Apostólico',
    ];

    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        title: const Text("Hinário", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: secoes.length,
        itemBuilder: (context, index) {
          final titulo = secoes[index];

          return GestureDetector(
            onTap: () => _abrirSecao(context, titulo),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepOrange,
                  child: Icon(Icons.music_note, color: Colors.white),
                ),
                title: Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.deepOrange),
              ),
            ),
          );
        },
      ),
    );
  }
}
