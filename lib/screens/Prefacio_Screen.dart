// lib/screens/prefacio_screen.dart
import 'package:flutter/material.dart';

class Prefacio_Screen extends StatelessWidget {
  const Prefacio_Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    const base = TextStyle(fontSize: 16, height: 1.6);
    final italic = base.copyWith(fontStyle: FontStyle.italic);
    final strong = base.copyWith(fontWeight: FontWeight.w700);

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
        title: const Text('Prefácio'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho em itálico
            Text(
              '',
              style: italic.copyWith(color: cs.onBackground),
            ),

            // Novo prefácio - introdução ao Programa e ao HOSANA DIGITAL
            Text(
              'No âmbito do seu propósito missionário e transformador, o '
                  'PROGRAMA MISSÃO DIGITAL 360º - CONECTANDO IGREJAS, TRANSFORMANDO VIDAS, '
                  'abrange três projectos estruturantes, destinados a promover a renovação tecnológica, '
                  'a unidade administrativa e o fortalecimento espiritual.\n',
              style: base.copyWith(color: cs.onBackground),
            ),
            const SizedBox(height: 8),
            Text(
              'Deste Programa, surgiu o HOSANA PROJECTO CRISTÃO (HPC) DIGITAL, '
                  'uma plataforma cristã moderna e inovadora que une fé, adoração e tecnologia, '
                  'criando um espaço interativo de adoração.\n',
              style: base.copyWith(color: cs.onBackground),
            ),
            const SizedBox(height: 8),
            Text(
              'A Plataforma HPC, ou simplesmente HOSANA DIGITAL, disponibilizará letras de '
                  'diferentes hinos das denominações em Angola, orações, palavras de reflexão, '
                  'o Credo Apostólico e a Oração do Pai Nosso em várias línguas nacionais. '
                  'Além disso, reunirá informações pontuais, localização de igrejas, gestão de '
                  'contactos de líderes ministeriais e eventos cristãos, centralizando recursos '
                  'úteis para a comunidade de fé.\n',
              style: base.copyWith(color: cs.onBackground),
            ),
            const SizedBox(height: 8),
            Text(
              'Nesta primeira fase, o projecto é lançado como piloto na comunidade Metodista. '
                  'Nas fases seguintes, será estendido a outras denominações cristãs — IECA, '
                  'Baptista e Tocoista — com o objectivo de promover unidade, comunhão e '
                  'uma evangelização digital mais ampla.\n',
              style: base.copyWith(color: cs.onBackground),
            ),

            const SizedBox(height: 12),

            // Citação bíblica destacada
            Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border(left: BorderSide(color: cs.primary, width: 4)),
              ),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"E aqueles que iam adiante e os que seguiam clamavam, dizendo: Hosana! Bendito o que vem em nome do Senhor! Bendito o Reino do nosso pai Davi, que vem em nome do Senhor! Hosana nas alturas!"',
                    style: italic.copyWith(
                      color: cs.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '(Marcos 11:9-10)',
                    style: italic.copyWith(
                      color: cs.onSurface.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Parágrafo reflexivo / missão
            Text(
              'Os tempos que atravessamos exigem novas formas de estar junto: precisamos '
                  'adorar juntos, não importando o lugar. Se permanecermos unidos pela fé e '
                  'conectados em Cristo, seremos fortalecidos para levar a Palavra e o cuidado '
                  'pastoral a mais pessoas. Por isso afirmamos: ',
              style: base.copyWith(color: cs.onBackground),
            ),
            const SizedBox(height: 8),
            Text(
              '“Adorando juntos em qualquer lugar, unidos pela fé e conectados em Cristo.”',
              style: italic.copyWith(color: cs.onBackground, fontSize: 15),
            ),

            const SizedBox(height: 16),

            // Descrição mais curta (resumo)
            Text(
              'O HOSANA DIGITAL é uma plataforma inovadora que une fé, adoração e tecnologia. '
                  'Letras de hinos, localizações de igrejas, contactos ministeriais, orações e eventos — '
                  'um espaço digital a serviço da comunidade.',
              style: base.copyWith(color: cs.onBackground),
            ),

            const SizedBox(height: 20),

            // Nota final curta
            Text(
              'Agradecemos a todos os parceiros, equipes e comunidades que acolhem este projeto. '
                  'Que o HOSANA DIGITAL seja instrumento de edificação, comunhão e serviço cristão.',
              style: base.copyWith(color: cs.onBackground),
            ),

            // Local, data e assinaturas
            const SizedBox(height: 8),

            Text(
              'Luanda – Novembro de 2025\n',
              style: base.copyWith(color: cs.onBackground),
            ),
            const SizedBox(height: 6),

            Text(
              'Assinaturas / Equipa do Programa:',
              style: strong.copyWith(color: cs.onBackground),
            ),
            const SizedBox(height: 8),

            // Lista de responsáveis
            _personRow('Manuel Rodrigo Matemba Praia', 'Gestor do Programa', cs),
            const SizedBox(height: 8),
            _personRow('Aguinaldo de Jesus Martins Madeira', 'Desenvolvedor / Programador', cs),
            const SizedBox(height: 8),
            _personRow('Imaculada Miguel Zongo', 'Analista de dados / Gestora de contas', cs),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _personRow(String name, String role, ColorScheme cs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.person, color: cs.primary, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontWeight: FontWeight.w700, color: cs.onBackground)),
              const SizedBox(height: 2),
              Text(role, style: TextStyle(color: cs.onBackground.withOpacity(0.85), fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}
