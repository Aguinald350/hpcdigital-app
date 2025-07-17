import 'package:flutter/material.dart';

class PortuguesSection extends StatelessWidget {
  const PortuguesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final hinos = [
      'Hino 1 - Grande é o Senhor',
      'Hino 2 - Cantarei Teu Amor',
      'Hino 3 - Guia-me Sempre',
      'Hino 4 - Vem Espírito de Deus',
    ];

    final List<Map<String, dynamic>> secoesAssuntos = [
      {
        'titulo': 'I — O Evangelho e a Experiência Cristã',
        'itens': [
          'Louvor a Deus (1–16)',
          'O Evangelho de Jesus Cristo (17–31)',
          'O Espírito Santo (32–36)',
          'A Vida Cristã (37–60)',
        ]
      },
      {
        'titulo': 'II — A Igreja Viva e o Testemunho dos Cristãos',
        'itens': [
          'Evangelização e Avivamento (61–71)',
          'Unidade e Comunhão Fraternal (72–75)',
          'Sacramentos - Casamentos / Ministério (76–83)',
          'Organizações da Igreja (84–93)',
          'O Testemunho Vivo dos Cristãos (94–104)',
        ]
      },
      {
        'titulo': 'III — O Ano Cristão e Ocasiões Especiais',
        'itens': [
          'Advento e Natal (105–115)',
          'Quaresma e Páscoa (116–130)',
          'O Dia do Senhor e Ações de Graças (131–133)',
          'Hinos Matutinos e Vespertinos (134–139)',
          'O Lar Cristão (140–142)',
          'Despedidas e Viagens (143)',
          'Funerais (144–147)',
          'Segunda Vinda de Cristo (148)',
          'A Bíblia (149–152)',
          'O Ano Novo (153)',
          'Dedicações e Aniversários (154–158)',
          'Finais (159–167)',
        ]
      },
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
                  'Assuntos dos Hinos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ...secoesAssuntos.map((secao) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: ExpansionTile(
                  iconColor: Colors.deepOrange,
                  collapsedIconColor: Colors.deepOrange,
                  title: Text(
                    secao['titulo'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  children: List<Widget>.from(
                    secao['itens'].map<Widget>(
                          (item) => ListTile(
                        title: Text(item),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Abrindo "$item"'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),
            Row(
              children: const [
                Icon(Icons.music_note, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text(
                  'Hinos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...hinos.map((hino) => Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.library_music, color: Colors.deepOrange),
                title: Text(hino),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Abrindo "$hino"'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            )),
          ],
        ),
      ),
    );
  }
}
