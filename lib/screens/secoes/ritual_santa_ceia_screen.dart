import 'package:flutter/material.dart';

class RitualSantaCeiaScreen extends StatelessWidget {
  const RitualSantaCeiaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final itens = _ritualItens(); // 13 blocos

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
        title: const Text('Ritual da Santa Ceia'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: itens.length,
        itemBuilder: (context, i) {
          final it = itens[i];
          final indice = i + 1; // 1..13
          final pagina = _paginaDoBloco(indice);

          return Card(
            color: cs.secondaryContainer,
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: cs.secondary),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                textTheme: Theme.of(context).textTheme.apply(
                  bodyColor: cs.onSecondaryContainer,
                  displayColor: cs.onSecondaryContainer,
                ),
              ),
              child: ExpansionTile(
                initiallyExpanded: i == 0,
                iconColor: cs.primary,
                collapsedIconColor: cs.primary,
                collapsedTextColor: cs.onSecondaryContainer,
                textColor: cs.onSecondaryContainer,
                tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                childrenPadding:
                const EdgeInsets.fromLTRB(16, 0, 16, 16),

                // ===== título com página à direita =====
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$indice. ${it.titulo}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: cs.onSecondaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _PaginaBadge(pagina: pagina),
                  ],
                ),

                // subtítulo (se existir)
                subtitle: it.subtitulo == null
                    ? null
                    : Text(
                  it.subtitulo!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: cs.onSecondaryContainer.withOpacity(0.9),
                  ),
                ),

                children: [
                  const SizedBox(height: 6),
                  SelectableText.rich(
                    _formatarConteudo(
                        it.conteudo, Theme.of(context).colorScheme),
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.45,
                      fontStyle: FontStyle.italic,
                      color: cs.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Badge de página (ex.: “Pág. 583”)
class _PaginaBadge extends StatelessWidget {
  final int pagina;
  const _PaginaBadge({required this.pagina});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary, width: 1),
      ),
      child: Text(
        'Pág. $pagina',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: cs.primary,
        ),
      ),
    );
  }
}

/// Regras de página por blocos:
/// 1–3: 583 | 4–6: 584 | 7–8: 585 | 9: 586 | 10: 587 | 11–13: 588
int _paginaDoBloco(int indice) {
  if (indice >= 1 && indice <= 3) return 583;
  if (indice >= 4 && indice <= 6) return 584;
  if (indice >= 7 && indice <= 8) return 585;
  if (indice == 9) return 586;
  if (indice == 10) return 587;
  if (indice >= 11 && indice <= 13) return 588;
  return 0; // fallback (não deve acontecer)
}

/// Aplica negrito+itálico aos rótulos “Ministro:”, “O Ministro:”, “Todos:” e “Congregação:”
TextSpan _formatarConteudo(String texto, ColorScheme cs) {
  final spans = <TextSpan>[];
  final linhas = texto.split('\n');

  TextSpan rotulo(String r) => TextSpan(
    text: '$r ',
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic,
      color: cs.primary,
    ),
  );

  for (var l in linhas) {
    final t = l.trimRight();

    if (t.isEmpty) {
      spans.add(const TextSpan(text: '\n'));
      continue;
    }

    if (t.startsWith('Ministro:')) {
      final resto = t.substring('Ministro:'.length).trimLeft();
      spans.add(rotulo('Ministro:'));
      spans.add(TextSpan(text: resto));
    } else if (t.startsWith('O Ministro:')) {
      final resto = t.substring('O Ministro:'.length).trimLeft();
      spans.add(rotulo('O Ministro:'));
      spans.add(TextSpan(text: resto));
    } else if (t.startsWith('Todos:')) {
      final resto = t.substring('Todos:'.length).trimLeft();
      spans.add(rotulo('Todos:'));
      spans.add(TextSpan(text: resto));
    } else if (t.startsWith('Congregação:')) {
      final resto = t.substring('Congregação:'.length).trimLeft();
      spans.add(rotulo('Congregação:'));
      spans.add(TextSpan(text: resto));
    } else {
      spans.add(TextSpan(text: t));
    }

    spans.add(const TextSpan(text: '\n'));
  }

  return TextSpan(children: spans);
}

class _RitualItem {
  final String titulo;
  final String? subtitulo;
  final String conteudo;
  _RitualItem({required this.titulo, this.subtitulo, required this.conteudo});
}

List<_RitualItem> _ritualItens() {
  return [
    _RitualItem(
      titulo: 'Convite',
      subtitulo: 'Estando todos de pé, o Ministro faz o seguinte convite:',
      conteudo: '''
Vós que verdadeira e sinceramente vos arrependeis dos vossos pecados;
que estais em caridade e amor para com o próximo;
e que tencionais viver uma vida nova em harmonia com a vontade de Deus
e caminhar de hoje em diante por suas veredas santas,
aproximai-vos com fé e tomai este santo sacramento para vosso conforto,
fazendo antes humilde confissão a Deus Todo-Poderoso.
''',
    ),
    _RitualItem(
      titulo: 'Oração Inicial',
      subtitulo:
      'A Congregação assenta-se, em recolhimento espiritual, em exame da consciência, enquanto o Oficiante faz a seguinte oração:',
      conteudo: '''
Ó Deus, nosso Pai celestial,
esclarece com o teu Santo Espírito a nossa mente
e revela-nos ao coração todos os pecados que temos cometido
contra Ti, contra o nosso próximo e contra nós mesmos.
''',
    ),
    _RitualItem(
      titulo: 'Confissão',
      subtitulo:
      'Ajoelhados ou como queiram, o Ministro e a Congregação fazem, em uníssono, a seguinte confissão:',
      conteudo: '''
Deus omnipotente, Pai de nosso Senhor Jesus Cristo,
Criador de todas as coisas, Juiz de todos os seres humanos,
nós confessamos e choramos os nossos muitos pecados e maldades
que muitas vezes temos cometido contra a tua divina majestade,
por pensamentos, palavras e obras,
provocando justamente a tua ira e indignação contra nós.
De todo o coração nos arrependemos,
e amargamente choramos as nossas culpas;
a memória delas nos atormenta
e o seu peso nos é incomportável.
Compadece-te de nós, compadece-te de nós,
e por amor do Teu Filho, nosso Senhor Jesus Cristo,
perdoa-nos todo o passado e permite que, daqui em diante,
te sirvamos e te agradeçamos com um novo teor de vida
para glória e honra do teu Nome;
mediante Jesus Cristo, nosso Senhor.
Amém.
''',
    ),
    _RitualItem(
      titulo: 'Absolvição',
      subtitulo: 'Depois o Ministro dirá:',
      conteudo: '''
Ó Deus Todo-Poderoso, nosso Pai celestial,
que por tua grande misericórdia prometeste perdoar os pecados
a todos os que, com sincero arrependimento e verdadeira fé a Ti se converterem;
tem misericórdia de nós;
perdoa-nos e livra-nos de todos os nossos pecados;
confirma-nos e fortalece-nos em toda a virtude
e conduz-nos à vida eterna;
mediante Jesus Cristo, nosso Senhor.
Amém.
''',
    ),
    _RitualItem(
      titulo: 'Oração Conjunta',
      subtitulo: 'O Ministro e a Congregação, em uníssono:',
      conteudo: '''
Ó Deus Omnipotente,
que sondas todos os corações e conheces todos os desejos
sem que haja segredos ocultos para ti;
purifica os nossos corações por influência do teu Espírito Santo,
para que possamos amar-Te perfeitamente
e engrandecer o teu santo Nome como devemos;
por Jesus Cristo, nosso Senhor.
Amém.
''',
    ),
    _RitualItem(
      titulo: 'Prefácio',
      conteudo: '''
Ministro:
Elevai os vossos corações.
Congregação:
Elevemo-los ao Senhor.
Ministro:
Demos graças ao Senhor nosso Deus.
Congregação:
Dêmo-las, pois é digno e justo.
O Ministro:
É verdadeiramente digno e justo e do nosso estrito dever, 
que em todos os tempos e lugares te rendamos graças, ó Senhor, 
Santo Pai, Omnipotente e eterno Deus. Portanto, 
com os anjos e arcanjos e com toda a corte celestial, 
louvamos e magnificamos o teu glorioso Nome, exaltando-te sempre e dizendo:
''',
    ),
    _RitualItem(
      titulo: 'Sanctus',
      conteudo: '''
Congregação:
Santo, Santo, Santo, Senhor Deus dos Exércitos;
os céus e a terra estão cheios da tua glória.
Glória te seja dada, ó Senhor Altíssimo.
Amém.
''',
    ),
    _RitualItem(
      titulo: 'Oração de Humildade',
      subtitulo: 'Aqui o Ministro dirá:',
      conteudo: '''
Não ousamos, ó Senhor, aproximar-nos da tua santa mesa,
confiados na nossa própria rectidão,
mas na multidão das tuas misericórdias;
pois não nos julgamos dignos
nem mesmo de apanhar as migalhas caídas da tua mesa.
Mas tu, ó Senhor, cuja natureza é ser misericordioso,
concede que de tal modo participemos destes elementos
e que, pela fé, nos apropriemos dos méritos da paixão e morte do teu amado Filho, nosso Salvador,
e que as nossas almas e corpos pecaminosos
sejam purificados pelo seu precioso sangue
e que sempre vivamos n’Ele e Ele em nós.
Amém.
''',
    ),
    _RitualItem(
      titulo: 'Oração Memorial de Consagração',
      subtitulo:
      'O Ministro, voltado para a Mesa, descobre os elementos e pronuncia a seguinte oração:',
      conteudo: '''
Toda a glória seja a Ti, Senhor Deus Omnipotente,
que em Teu amor nos deste o teu Unigénito Filho Jesus Cristo
a fim de morrer na cruz para nossa redenção;
O qual de uma vez para sempre entregou o seu corpo
em sacrifício pleno, perfeito e suficiente pelas iniquidades de todo o mundo;
e Ele próprio instituiu um memorial perpétuo de Sua preciosa morte,
ordenando-nos no seu Santo Evangelho
que o continuemos até à Sua Segunda Vinda.
Concede-nos, ó Pai misericordioso,
que ao tomarmos estes elementos de pão e vinho,
segundo a instituição de teu Filho, nosso Salvador Jesus Cristo,
em memória de sua paixão e morte,
participemos do abençoadíssimo corpo e sangue de Cristo.
Pois Ele, na mesma noite em que foi entregue,
tomou o pão e, havendo dado graças,
o partiu e deu a seus discípulos, dizendo:
«Tomai, comei, isto é o meu corpo que é dado por vós;
fazei isto em memória de mim.»
Semelhantemente, terminada a ceia,
tomou também o cálice e, havendo dado graça,
o deu a todos, dizendo:
«Bebei dele todos, porque isto é o meu sangue do novo testamento,
derramado por vós e por muitos para remissão dos pecados;
fazei isto quantas vezes o beberdes, em memória de mim.»
Amém.
''',
    ),
    _RitualItem(
      titulo: 'Comunhão',
      subtitulo:
      'O Ministro, depois de tomar os elementos, passa-os aos demais ministros presentes e repete, acompanhando pela Congregação, a Oração Dominical.',
      conteudo: '''
Ao entregar o pão:
O corpo de nosso Senhor Jesus Cristo, que foi dado por ti,
conserve o teu corpo e a tua alma para a vida eterna.
TOMA E COME este em memória de haver Cristo morrido por ti,
e dele alimenta-te em teu coração, pela fé, com acções de graça.

Ao entregar o cálice:
O sangue de nosso Senhor Jesus Cristo, que foi derramado por ti,
conserve o teu corpo e a tua alma para a vida eterna.
BEBE este em memória de haver Cristo derramado seu sangue por ti
e sê agradecido.
''',
    ),
    _RitualItem(
      titulo: 'Oração Final',
      conteudo: '''
Ó Senhor nosso Pai celestial,
nós, teus servos, te suplicamos que, por tua paternal bondade,
te dignes receber este nosso sacrifício de louvor e acções de graças,
rogando-te humildemente que, pelos merecimentos da obra e morte de teu Filho Jesus Cristo,
recebamos o perdão dos nossos pecados com todos os demais benefícios de sua morte e paixão.
E aqui, Senhor, te dedicamos e apresentamos os nossos corpos e almas
em sacrifício vivo, santo e agradável;
suplicando-te humildemente que todos os que participamos deste santo sacramento
fiquemos cheios da tua graça e bênção celestial.
E, embora sejamos indignos de oferecer-te qualquer coisa por causa dos nossos pecados,
nós te suplicamos que aceites este nosso serviço e obrigação que te são devidos,
não tomando em consideração os nossos méritos,
mas perdoando as nossas ofensas,
por Jesus Cristo, nosso Senhor,
por quem e com quem, na unidade do Espírito Santo,
sejam dadas a Ti, ó Pai Altíssimo, toda a honra e glória, pelos séculos dos séculos.
Amém.
''',
    ),
    _RitualItem(
      titulo: 'Gloria in Excelsis',
      subtitulo: 'Concluindo, todos de pé, recitam ou cantam:',
      conteudo: '''
Glória a Deus nas alturas,
paz na terra e boa vontade para com os homens.
Nós te louvamos, te bendizemos, te adoramos,
te glorificamos e te damos graças pela tua glória,
Senhor Deus, Rei do Céu, Deus Pai Omnipotente.
Ó Senhor, Unigénito Filho de Deus, Jesus Cristo,
Cordeiro de Deus, Filho eterno do Pai,
que tiras os pecados do mundo;
Todos:
Tem compaixão de nós.
Ministro:
Tu que tiras os pecados do mundo;
Todos:
Tem misericórdia de nós.
Ministro:
Tu que tiras os pecados do mundo;
Todos:
Recebe as nossas súplicas.
Ministro:
Tu que estás à destra do Pai;
Todos:
Tem compaixão de nós,
porque só Tu és santo;
só Tu és Senhor;
só Tu, ó Jesus Cristo, com o Espírito Santo,
és o Altíssimo na glória de Deus Pai.
Amém.
''',
    ),
    _RitualItem(
      titulo: 'Bênção Final',
      subtitulo: 'O Ministro despede a Congregação com a bênção:',
      conteudo: '''
A paz de Deus, que excede toda a compreensão,
guarde os vossos corações e mentes
no conhecimento e no amor de Deus,
e de Seu Filho Jesus Cristo, nosso Senhor.
E a bênção de Deus Omnipotente, Pai, Filho e Espírito Santo,
seja convosco, e convosco permaneça eternamente.
AMÉM.
''',
    ),
  ];
}
