import 'package:flutter/material.dart';
import 'SecaoScreen.dart';

// telas fixas dentro de lib/screens/secoes/
import 'secoes/credo_apostolico_screen.dart';
import 'secoes/oracao_dominical_screen.dart';
import 'secoes/ritual_santa_ceia_screen.dart';
import 'secoes/invocacoes_chamadas_screen.dart';
import 'secoes/leitura_responsiva_screen.dart';

class Hinario_Screen extends StatefulWidget {
  const Hinario_Screen({super.key});

  @override
  State<Hinario_Screen> createState() => _Hinario_ScreenState();
}

class _Hinario_ScreenState extends State<Hinario_Screen> {
  void _abrirSecao(BuildContext context, String titulo) {
    Widget? destino;

    if (titulo == 'Credo Apostólico') {
      destino = const CredoApostolicoScreen();
    } else if (titulo == 'Oração Dominical') {
      destino = const OracaoDominicalScreen();
    } else if (titulo == 'Ritual da Santa Ceia') {
      destino = const RitualSantaCeiaScreen();
    } else if (titulo == 'Invocações e Chamadas de Adoração') {
      destino = const InvocacoesChamadasScreen();
    } else if (titulo == 'Leitura Responsiva') {
      destino = const LeituraResponsivaScreen();
    }

    if (destino != null) {
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (_, animation, __) =>
              FadeTransition(opacity: animation, child: destino!),
        ),
      );
      return;
    }

    // Demais seções dinâmicas
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: SecaoScreen(titulo: titulo),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.primary,      // era: Colors.deepOrange
        foregroundColor: cs.onPrimary,     // texto/ícones do AppBar
        elevation: 0,
        title: const Text("Hinário"),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: secoes.length,
        itemBuilder: (context, index) {
          final titulo = secoes[index];
          return Card(
            color: cs.secondaryContainer, // cards/acessórios
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: cs.secondary), // borda/realce
            ),
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              onTap: () => _abrirSecao(context, titulo),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: cs.secondaryContainer,
                child: Icon(Icons.music_note, color: cs.onSecondaryContainer),
              ),
              title: Text(
                titulo,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: cs.onSecondaryContainer,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: cs.primary),
            ),
          );
        },
      ),
    );
  }
}
