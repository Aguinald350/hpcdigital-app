import 'package:flutter/material.dart';

class InvocacoesChamadasScreen extends StatelessWidget {
  const InvocacoesChamadasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final secoes = _conteudo();

    return Scaffold(
      backgroundColor: cs.background, // antes: 0xFFF9F9F9
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
        title: const Text('Invocações e Chamadas de Adoração'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: secoes.length,
        itemBuilder: (context, i) {
          final s = secoes[i];
          return Card(
            color: cs.secondaryContainer, // cards/acessórios
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: cs.secondary), // borda/realce
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: i == 0,
                iconColor: cs.primary,
                collapsedIconColor: cs.primary,
                collapsedTextColor: cs.onSecondaryContainer,
                textColor: cs.onSecondaryContainer,
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                title: Text(
                  '${i + 1}. ${s.titulo}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: cs.onSecondaryContainer,
                  ),
                ),
                children: [
                  const SizedBox(height: 6),
                  ...s.paragrafos.map((p) => _Paragrafo(p)).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Paragrafo extends StatelessWidget {
  final _Bloco b;
  const _Paragrafo(this.b);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasRef = (b.referencia ?? '').trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((b.subtitulo ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                b.subtitulo!,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: cs.onSecondaryContainer,
                ),
              ),
            ),
          SelectableText(
            b.texto.trim(),
            style: TextStyle(
              fontSize: 16,
              height: 1.45,
              color: cs.onSecondaryContainer,
            ),
          ),
          if (hasRef)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                b.referencia!,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: cs.onSecondaryContainer.withOpacity(0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Secao {
  final String titulo;
  final List<_Bloco> paragrafos;
  _Secao({required this.titulo, required this.paragrafos});
}

class _Bloco {
  final String texto;
  final String? referencia;
  final String? subtitulo; // para cabeçalhos tipo "Ministro", "Congregação", "I", "II"…
  _Bloco(this.texto, {this.referencia, this.subtitulo});
}

List<_Secao> _conteudo() {
  return [
    _Secao(
      titulo: 'Advento',
      paragrafos: [
        _Bloco(
          'Levantai, ó portas as vossas cabeças; levantai-vos, ó entradas eternas, e entrará o Rei da Glória.',
          referencia: '(Salmo 24:7)',
          subtitulo: '1.',
        ),
        _Bloco(
          'E a glória do Senhor se manifestará, e toda a carne juntamente verá que foi a boca do Senhor que isto disse.',
          referencia: '(Isaías 40:5)',
          subtitulo: '2.',
        ),
      ],
    ),
    _Secao(
      titulo: 'Natal',
      paragrafos: [
        _Bloco(
          'Deus amou o mundo de tal maneira que deu o seu Filho unigênito, para que todo aquele que nele crê não pereça, mas tenha a vida eterna.',
          referencia: '(João 3:16)',
          subtitulo: '1.',
        ),
        _Bloco(
          'Não temais, porque eis aqui vos trago novas de grande alegria, que será para todo o povo; pois na cidade de Davi, vos nasceu hoje o Salvador, que é Cristo, o Senhor.',
          referencia: '(Lucas 2:10)',
          subtitulo: '2.',
        ),
      ],
    ),
    _Secao(
      titulo: 'Epifânia',
      paragrafos: [
        _Bloco(
          'Levanta-te, resplandece, porque a tua luz, e a glória do Senhor vai nascendo sobre ti. E as nações caminharão à luz, e os reis ao resplendor que te nasceu.',
          referencia: '(Isaías 60:1,3)',
          subtitulo: '1.',
        ),
        _Bloco(
          'Ainda que outras ovelhas que não são deste aprisco; também me convém agregar estas, e elas ouvirão a minha voz, e haverá um rebanho e um Pastor.',
          referencia: '(João 10:16)',
          subtitulo: '2.',
        ),
      ],
    ),
    _Secao(
      titulo: 'Quaresma',
      paragrafos: [
        _Bloco(
          'Vinde, e andemos na luz do Senhor, para que nos ensine o que concerne aos seus caminhos, e andemos nas suas veredas.',
          referencia: '(Isaías 2:53)',
          subtitulo: '1.',
        ),
        _Bloco(
          'Buscai ao Senhor enquanto se pode achar, invocai-o enquanto está perto. Deixe o ímpio o seu caminho, e o homem maligno os seus pensamentos, e se converta ao Senhor, que se compadecerá dele. Torne para o nosso Deus, porque grandioso é em perdoar.',
          referencia: '(Isaías 55:6-7)',
          subtitulo: '2.',
        ),
      ],
    ),
    _Secao(
      titulo: 'Páscoa',
      paragrafos: [
        _Bloco('Ministro – O Senhor Ressuscitou!', subtitulo: '1.'),
        _Bloco('Congregação – O Senhor verdadeiramente ressuscitou!', subtitulo: ''),
        _Bloco(
          'Portanto, se já ressuscitastes com Cristo, buscai as coisas que são de cima, onde Cristo está assentado à destra de Deus.',
          referencia: '(Colossenses 3:1)',
          subtitulo: '2.',
        ),
        _Bloco(
          'Ministro – Bendito seja o Deus e Pai de nosso Senhor Jesus Cristo! Que, segundo a sua grande misericórdia, nos gerou de novo para uma viva esperança, pela ressurreição de Jesus Cristo dentre os mortos.',
          subtitulo: '3.',
        ),
        _Bloco(
          'Congregação – Para uma herança incorruptível, incontaminável, e que se não pode murchar.',
          referencia: '(1 Pedro 1:3-4)',
        ),
      ],
    ),
    _Secao(
      titulo: 'Pentecostes',
      paragrafos: [
        _Bloco(
          'Mas a hora vem, em que os verdadeiros adoradores adorarão o Pai em espírito e em verdade; porque o Pai procura a tais que assim o adorem. Deus é espírito, e importa que os que o adoram o adorem em espírito e em verdade.',
          referencia: '(João 4:23-24)',
          subtitulo: '1.',
        ),
        _Bloco(
          'E há de ser que, depois, derramarei o meu Espírito sobre toda a carne, e vossos filhos e vossas filhas profetizarão, os vossos velhos terão sonhos, e os vossos mancebos terão visões.',
          referencia: '(Joel 2:28)',
          subtitulo: '2.',
        ),
      ],
    ),
    _Secao(
      titulo: 'Confissão e Palavras de Perdão',
      paragrafos: [
        _Bloco(
          'Pois quanto o céu está acima da terra, assim é grande a sua misericórdia para com os que o temem. Quanto está longe o oriente do ocidente, assim afasta de nós as nossas transgressões.',
          referencia: '(Salmo 103:11-12)',
          subtitulo: 'I',
        ),
        _Bloco(
          'Como um pai se compadece de seus filhos, assim o Senhor se compadece daqueles que o temem.',
          referencia: '(Salmo 103:13)',
          subtitulo: 'II',
        ),
        _Bloco(
          'Piedoso e benigno é o Senhor, sofredor e de grande misericórdia.',
          referencia: '(Salmo 145:8)',
          subtitulo: 'III',
        ),
        _Bloco(
          'E esta é a mensagem que dele ouvimos, e vos anunciamos: que Deus é luz, e não há nele trevas nenhumas. Se andarmos na luz, como ele na luz está, temos comunhão uns com os outros, e o sangue de Jesus Cristo seu Filho, nos purifica de todo o pecado.',
          referencia: '(1 João 1:5,7)',
          subtitulo: 'IV',
        ),
        _Bloco(
          'Se confessarmos os nossos pecados, ele é fiel e justo para nos perdoar os pecados e nos purificar de toda a injustiça.',
          referencia: '(1 João 1:9)',
          subtitulo: 'V',
        ),
        _Bloco(
          'Porque pelo seu nome vos são perdoados os pecados.',
          referencia: '(1 João 2:12b)',
          subtitulo: 'VI',
        ),
        _Bloco(
          'Jesus disse: “O que vem a mim de maneira nenhuma o lançarei fora”.',
          referencia: '(João 6:37b)',
          subtitulo: 'VII',
        ),
      ],
    ),
    _Secao(
      titulo: 'Ofertório e Orações',
      paragrafos: [
        _Bloco(
          'Lembremo-nos das palavras do Senhor Jesus, que disse: mais bem-aventurada coisa é dar do que receber.',
          referencia: '(Atos 20:35)',
          subtitulo: 'I',
        ),
        _Bloco(
          'Assim resplandeça a vossa luz diante dos homens, para que vejam as vossas boas obras e glorifiquem a vosso Pai que está nos céus.',
          referencia: '(Mateus 5:16)',
          subtitulo: 'II',
        ),
        _Bloco(
          'Cada qual, conforme ao dom da sua mão, conforme a bênção que o Senhor teu Deus te tiver dado.',
          referencia: '(Deuteronômio 16:17)',
          subtitulo: 'III',
        ),
        _Bloco(
          'E não vos esqueçais da beneficência e comunicação, porque com tais sacrifícios Deus se agrada.',
          referencia: '(Hebreus 13:16)',
          subtitulo: 'IV',
        ),
        _Bloco(
          'O que semeia pouco, pouco também ceifará; e o que semeia em abundância em abundância também ceifará. Cada um contribua segundo propôs no seu coração; não com tristeza, ou por necessidade; porque Deus ama ao que dá com alegria.',
          referencia: '(2 Coríntios 9:6-7)',
          subtitulo: 'V',
        ),
        _Bloco(
          'Tua é, Senhor, a magnificência, e o poder, e a honra, e a vitória, e a majestade, porque teu é tudo quanto há nos céus e na terra. Porque tudo vem de ti, e da tua mão to damos.',
          referencia: '(1 Crônicas 29:11,14)',
          subtitulo: 'VI',
        ),
        _Bloco(
          'Oferece a Deus sacrifício de louvor, e paga ao Altíssimo os teus votos.',
          referencia: '(Salmo 50:14)',
          subtitulo: 'VII',
        ),
      ],
    ),
    _Secao(
      titulo: 'Bênçãos',
      paragrafos: [
        _Bloco(
          'Ora, aquele que é poderoso para fazer tudo muito mais abundantemente além daquilo que pedimos ou pensamos, segundo o poder que em nós opera, a esse glória na Igreja, por Jesus Cristo, em todas as gerações, para todo o sempre. Amém.',
          referencia: '(Efésios 3:20-21)',
          subtitulo: 'I',
        ),
        _Bloco(
          'E o Deus de toda graça, que em Cristo Jesus vos chamou à sua eterna glória, vos aperfeiçoe, confirme, fortifique e fortaleça. A ele seja glória e o poderio para todo o sempre. Amém.',
          referencia: '(1 Pedro 5:10-11)',
          subtitulo: 'II',
        ),
        _Bloco(
          'Ora, aquele que é poderoso para vos guardar de tropeçar, e apresentar-vos irrepreensíveis, com alegria, perante a sua glória, ao único Deus, Salvador nosso por Jesus Cristo, nosso Senhor, seja glória e majestade, domínio e poder, antes de todos os séculos, agora, e para todo o sempre. Amém.',
          referencia: '(Judas 24-25)',
          subtitulo: 'III',
        ),
        _Bloco(
          'A graça do nosso Senhor Jesus Cristo, e o amor de Deus, e a comunhão do Espírito Santo seja com vós todos. Amém.',
          referencia: '(2 Coríntios 13:13)',
          subtitulo: 'IV',
        ),
        _Bloco(
          'O Senhor te abençoe e te guarde; o Senhor faça resplandecer o seu rosto sobre ti, e tenha misericórdia de ti; o Senhor sobre ti levante o seu rosto e te dê a paz.',
          referencia: '(Números 6:24,26)',
          subtitulo: 'V',
        ),
        _Bloco(
          'Ora o Deus de paz, que pelo sangue do concerto eterno tornou a trazer dos mortos a nosso Senhor Jesus Cristo, grande pastor das ovelhas, vos aperfeiçoe em toda boa obra, para fazerdes a sua vontade, operando em vós o que perante ele é agradável por Cristo Jesus, ao qual seja glória para todo o sempre. Amém.',
          referencia: '(Hebreus 13:20-21)',
          subtitulo: 'VI',
        ),
        _Bloco(
          'A paz de Deus que excede toda a compreensão, guarde os vossos corações e mentes no conhecimento e no amor de Deus, e de seu filho Jesus Cristo, nosso Senhor. E a bênção de Deus Omnipotente, Pai, Filho e Espírito Santo, seja convosco, e convosco permaneça eternamente. Amém.',
          subtitulo: 'VII',
        ),
      ],
    ),
  ];
}
