import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LeituraResponsivaScreen extends StatefulWidget {
  const LeituraResponsivaScreen({super.key});

  @override
  State<LeituraResponsivaScreen> createState() => _LeituraResponsivaScreenState();
}

class _LeituraResponsivaScreenState extends State<LeituraResponsivaScreen> {
  bool _full = false;

  // Tamanhos de fonte base
  static const double _fontBase = 16;     // normal
  static const double _fontBaseFull = 22; // tela inteira

  // controla UI do sistema ao entrar/sair
  Future<void> _enterFull() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    setState(() => _full = true);
  }

  Future<void> _exitFull() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    setState(() => _full = false);
  }

  double get _font => _full ? _fontBaseFull : _fontBase;
  double get _lineHeight => _full ? 1.6 : 1.5;
  EdgeInsets get _pagePadding =>
      _full ? const EdgeInsets.fromLTRB(16, 16, 16, 24) : const EdgeInsets.fromLTRB(16, 12, 16, 24);

  @override
  void dispose() {
    // garante que as barras do sistema voltem ao normal ao sair da tela
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final secoes = _conteudo();

    return WillPopScope(
      onWillPop: () async {
        if (_full) {
          await _exitFull();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: cs.background,
        appBar: _full
            ? null
            : AppBar(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 0,
          title: const Text('Leitura Responsiva'),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'Tela inteira',
              onPressed: _enterFull,
              icon: const Icon(Icons.fullscreen),
            ),
          ],
        ),
        body: ListView.builder(
          padding: _pagePadding,
          itemCount: secoes.length,
          itemBuilder: (context, i) {
            final s = secoes[i];
            return Card(
              elevation: 1.5,
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: cs.secondaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: cs.secondary.withOpacity(0.7)),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: !_full && i == 0,
                  iconColor: cs.primary,
                  collapsedIconColor: cs.primary,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  title: Text(
                    s.titulo,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic, // título em itálico
                      color: cs.onSecondaryContainer,
                      fontSize: _font + 3,
                      height: 1.2,
                    ),
                  ),
                  subtitle: (s.referencia ?? '').isEmpty
                      ? null
                      : Text(
                    s.referencia!,
                    style: TextStyle(
                      color: cs.onSecondaryContainer.withOpacity(0.78),
                      fontStyle: FontStyle.italic, // subtítulo em itálico
                      fontSize: _font - 1,
                    ),
                  ),
                  children: [
                    const SizedBox(height: 6),
                    ...s.linhas.map(
                          (l) => _LinhaResponsiva(
                        l,
                        fontSize: _font,
                        lineHeight: _lineHeight,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: _full
            ? FloatingActionButton.extended(
          onPressed: _exitFull,
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          icon: const Icon(Icons.fullscreen_exit),
          label: const Text('Sair do modo tela'),
        )
            : null,
      ),
    );
  }
}

class _LinhaResponsiva extends StatelessWidget {
  final _Linha l;
  final double fontSize;
  final double lineHeight;

  const _LinhaResponsiva(
      this.l, {
        required this.fontSize,
        required this.lineHeight,
      });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDirigente = l.speaker == 'D';

    // Cápsula do locutor (D/C) com leve destaque
    final rotulo = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      margin: const EdgeInsets.only(right: 10, top: 2),
      decoration: BoxDecoration(
        color: (isDirigente ? cs.primary : cs.secondary)
            .withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDirigente ? cs.primary : cs.secondary,
          width: 1,
        ),
      ),
      child: Text(
        '${l.speaker} –',
        style: TextStyle(
          fontStyle: FontStyle.italic, // rótulo em itálico
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
          color: isDirigente ? cs.primary : cs.onSecondaryContainer.withOpacity(0.85),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          rotulo,
          // Texto selecionável em itálico
          Expanded(
            child: SelectableText(
              l.texto.trim(),
              textAlign: TextAlign.left,
              textWidthBasis: TextWidthBasis.parent,
              style: TextStyle(
                fontStyle: FontStyle.italic,     // corpo em itálico
                fontWeight: isDirigente ? FontWeight.w600 : FontWeight.w400,
                fontSize: fontSize,
                height: lineHeight,
                color: cs.onSecondaryContainer,
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
  final String? referencia;
  final List<_Linha> linhas;
  _Secao({required this.titulo, this.referencia, required this.linhas});
}

class _Linha {
  final String speaker; // 'D' (Dirigente) ou 'C' (Congregação)
  final String texto;
  _Linha(this.speaker, this.texto);
}

// ------------------------------------------------------
// Conteúdo em ordem
// ------------------------------------------------------
List<_Secao> _conteudo() {
  return [
    _Secao(
      titulo: '📖 Salmo 1',
      linhas: [
        _Linha('D', 'Bem-aventurado o varão que não anda segundo o concelho dos ímpios.'),
        _Linha('C', 'Nem se detém no caminho dos pecadores, nem se assenta na roda dos escarnecedores.'),
        _Linha('D', 'Antes tem o seu prazer na lei do Senhor,'),
        _Linha('C', 'e na sua lei medita de dia e de noite.'),
        _Linha('D', 'Pois será como a árvore plantada junto a ribeiro de águas,'),
        _Linha('C', 'a qual dá o seu fruto na estação própria,'),
        _Linha('D', 'e cujas folhas não caem.'),
        _Linha('C', 'e tudo quanto fizer prosperará.'),
        _Linha('D', 'Não são assim os ímpios,'),
        _Linha('C', 'mas são como a moinha que o vento espalha.'),
        _Linha('D', 'Pelo que os ímpios não subsistirão no juízo,'),
        _Linha('C', 'nem os pecadores na congregação dos justos.'),
        _Linha('D', 'Porque o Senhor conhece o caminho dos justos,'),
        _Linha('C', 'mas o caminho dos ímpios perecerá.'),
      ],
    ),
    _Secao(
      titulo: '📖 Salmo 8',
      linhas: [
        _Linha('D', 'Ó Senhor, Senhor nosso, quão admirável é o teu nome em toda a terra!'),
        _Linha('C', 'pois puseste a tua glória sobre os céus! Da boca das crianças e dos que mamam,'),
        _Linha('D', 'tu suscitaste força, por causa dos teus adversários,'),
        _Linha('C', 'para fazeres calar o inimigo e vingativo.'),
        _Linha('D', 'Quando vejo os teus céus, obra dos teus dedos,'),
        _Linha('C', 'a lua e as estrelas que preparaste,'),
        _Linha('D', 'Que é o homem mortal para que te lembres dele?'),
        _Linha('C', 'e o filho do homem para que o visites?'),
        _Linha('D', 'Contudo, pouco menor o fizeste do que os anjos,'),
        _Linha('C', 'e de glória e de honra o coroaste.'),
        _Linha('D', 'Fazes com que ele tenha domínio sobre as obras das tuas mãos;'),
        _Linha('C', 'tudo puseste debaixo dos seus pés:'),
        _Linha('D', 'todas as ovelhas e bois,'),
        _Linha('C', 'assim como os animais do campo,'),
        _Linha('D', 'As aves dos céus, e os peixes do mar,'),
        _Linha('C', 'e tudo o que passa pelas veredas dos mares.'),
        _Linha('D', 'Ó Senhor, Senhor nosso,'),
        _Linha('C', 'Quão admirável é o teu nome sobre toda a terra!'),
      ],
    ),
    _Secao(
      titulo: '📖 Salmo 15',
      linhas: [
        _Linha('D', 'Senhor, quem habitará no teu tabernáculo?'),
        _Linha('C', 'Aquele que anda em sinceridade, e pratica a justiça, e fala verazmente, segundo o seu coração;'),
        _Linha('D', 'Aquele que não difama com a sua língua, nem faz mal ao seu próximo,'),
        _Linha('C', 'nem aceita nenhuma afronta contra o seu próximo;'),
        _Linha('D', 'Aquele a cujos olhos o réprobo é desprezado,'),
        _Linha('C', 'mas honra os que temem ao Senhor;'),
        _Linha('D', 'Aquele que, mesmo que jure com dano seu, não muda;'),
        _Linha('C', 'nem recebe peitas contra o inocente.'),
        _Linha('D', 'Quem faz isto,'),
        _Linha('C', 'nunca será abalado.'),
      ],
    ),
    _Secao(
      titulo: '📖 Salmo 23',
      linhas: [
        _Linha('D', 'O Senhor é meu pastor;'),
        _Linha('C', 'nada me faltará.'),
        _Linha('D', 'Deitar-me faz em verdes pastos,'),
        _Linha('C', 'guia-me mansamente a águas tranquilas.'),
        _Linha('D', 'Refrigera a minha alma;'),
        _Linha('C', 'guia-me pelas veredas da justiça, por amor do seu nome.'),
        _Linha('D', 'Ainda que eu andasse pelo vale da sombra da morte, não temeria mal algum,'),
        _Linha('C', 'Porque tu estás comigo; a tua vara e o teu cajado me consolam.'),
        _Linha('D', 'Preparas uma mesa perante mim na presença dos meus inimigos:'),
        _Linha('C', 'unges a minha cabeça com óleo, e meu cálice trasborda.'),
        _Linha('D', 'Certamente que a bondade e a misericórdia me seguirão todos os dias da minha vida,'),
        _Linha('C', 'e habitarei na casa do Senhor por longos dias.'),
      ],
    ),
    _Secao(
      titulo: '📖 Salmo 46',
      linhas: [
        _Linha('D', 'Deus é o nosso refúgio e fortaleza,'),
        _Linha('C', 'socorro bem presente na angústia.'),
        _Linha('D', 'Pelo que não temeremos, ainda que a terra se mude,'),
        _Linha('C', 'e ainda que os montes se transportem para o meio dos mares;'),
        _Linha('D', 'Ainda que as águas rujam e se perturbem,'),
        _Linha('C', 'ainda que os montes se abalem pela sua braveza.'),
        _Linha('D', 'Há um rio cujas correntes alegram a cidade de Deus,'),
        _Linha('C', 'o santuário das moradas do Altíssimo.'),
        _Linha('D', 'Deus está no meio dela; não será abalada;'),
        _Linha('C', 'Deus a ajudará ao romper da manhã.'),
        _Linha('D', 'As nações se embraveceram, os reinos se moveram;'),
        _Linha('C', 'Ele levantou a sua voz e a terra se derreteu.'),
        _Linha('D', 'O Senhor dos exércitos está conosco;'),
        _Linha('C', 'O Deus de Jacob é o nosso refúgio.'),
        _Linha('D', 'Vinde, contemplai as obras do Senhor;'),
        _Linha('C', 'que desolações têm feito na terra!'),
        _Linha('D', 'Ele faz cessar as guerras até ao fim da terra;'),
        _Linha('C', 'quebra o arco e corta a lança; queima os carros no fogo!'),
        _Linha('D', 'Aquietai-vos, e sabei que eu sou Deus,'),
        _Linha('C', 'serei exaltado entre as nações, serei exaltado sobre a terra.'),
        _Linha('D', 'O Senhor dos exércitos está conosco;'),
        _Linha('C', 'o Deus de Jacob é o nosso refúgio.'),
      ],
    ),
    _Secao(
      titulo: '📖 Salmo 67',
      linhas: [
        _Linha('D', 'Deus tenha misericórdia de nós e nos abençoe,'),
        _Linha('C', 'e faça resplandecer o seu rosto sobre nós.'),
        _Linha('D', 'Para que se conheça na terra o teu caminho,'),
        _Linha('C', 'e em todas as nações a tua salvação.'),
        _Linha('D', 'Louvem-te a ti, ó Deus, os povos;'),
        _Linha('C', 'Louvem-te os povos todos!'),
        _Linha('D', 'Alegrem-se e regozijem-se as nações,'),
        _Linha('C', 'pois julgarás os povos com equidade, e governarás as Nações sobre a terra.'),
        _Linha('D', 'Louvem-te a ti, ó Deus, os povos;'),
        _Linha('C', 'Louvem-te os povos todos!'),
        _Linha('D', 'Então a terra dará o seu fruto;'),
        _Linha('C', 'e Deus, o nosso Deus, nos abençoará.'),
        _Linha('D', 'Deus nos abençoará,'),
        _Linha('C', 'e todas as extremidades da terra o temerão.'),
      ],
    ),
    _Secao(
      titulo: '📖 Salmo 72',
      linhas: [
        _Linha('D', 'Ó Deus. Dá ao rei os teus juízos,'),
        _Linha('C', 'e a tua justiça ao filho do rei!'),
        _Linha('D', 'Ele julgará o teu povo com justiça,'),
        _Linha('C', 'e aos teus pobres com juízo.'),
        _Linha('D', 'Julgará os aflitos do povo,'),
        _Linha('C', 'salvará os filhos do necessitado e quebrantará o opressor.'),
        _Linha('D', 'Nos seus dias florescerá o justo,'),
        _Linha('C', 'e abundância de paz haverá enquanto durar a lua.'),
        _Linha('D', 'Porque ele livrará ao necessitado quando clamar,'),
        _Linha('C', 'como também ao pobre e ao que não tem quem o ajude.'),
        _Linha('D', 'Libertará as suas vidas da opressão e da violência,'),
        _Linha('C', 'e precioso será o seu sangue aos olhos dele.'),
        _Linha('D', 'O seu nome permanecerá eternamente,'),
        _Linha('C', 'e o seu nome se irá propagando de pais a filhos, enquanto o sol durar!'),
        _Linha('D', 'Bendito seja o Senhor Deus, o Deus de Israel,'),
        _Linha('C', 'que só Ele faz maravilhas,'),
        _Linha('D', 'E bendito seja para sempre o seu nome glorioso,'),
        _Linha('C', 'e encha-se toda a terra da sua glória. Amém e Amém!'),
      ],
    ),
    _Secao(
      titulo: '📖 Salmo 90',
      linhas: [
        _Linha('D', 'Senhor, tu tens sido o nosso refúgio.'),
        _Linha('C', 'De geração em geração.'),
        _Linha('D', 'Antes que os montes nascessem, ou que tu formasses a terra e o mundo,'),
        _Linha('C', 'sim, de eternidade a eternidade, tu és Deus.'),
        _Linha('D', 'Tu reduzes o homem à destruição,'),
        _Linha('C', 'e dizes: Volvei, filhos dos homens.'),
        _Linha('D', 'Porque mil anos são aos teus olhos como o dia de ontem que passou,'),
        _Linha('C', 'e como a vigília da noite.'),
        _Linha('D', 'Tu os levas como corrente de água; são como um sono;'),
        _Linha('C', 'são como a erva que cresce de madrugada:'),
        _Linha('D', 'de madrugada cresce e floresce;'),
        _Linha('C', 'à tarde corta-se e seca.'),
        _Linha('D', 'A duração da nossa vida é de setenta anos,'),
        _Linha('C', 'e se alguns pela robustez, chegam a oitenta anos,'),
        _Linha('D', 'o melhor deles é canseira e enfado;'),
        _Linha('C', 'pois passa rapidamente, e nós voamos.'),
        _Linha('D', 'Ensina-nos a contar os nossos dias,'),
        _Linha('C', 'de tal maneira que alcancemos corações sábios.'),
        _Linha('D', 'E seja sobre nós a graça do Senhor nosso Deus,'),
        _Linha('C', 'e confirma sobre nós a obra das nossas mãos; sim, confirma a obra das nossas mãos.'),
      ],
    ),
    _Secao(
      titulo: '📖 Salmo 100',
      linhas: [
        _Linha('D', 'Celebrai com júbilo ao Senhor todos os moradores da terra.'),
        _Linha('C', 'Servi ao Senhor com alegria, e apresentai-vos a ele com canto.'),
        _Linha('D', 'Sabei que o Senhor é Deus: foi ele, não nós, que nos fez seu e ovelhas do seu pasto.'),
        _Linha('C', 'Entrai pelas portas dele com louvor, e em seus átrios com hinos;'),
        _Linha('D', 'Louvai-o e bendizei o Seu Nome. Porque o Senhor é bom e eterna a sua misericórdia;'),
        _Linha('C', 'e a sua verdade estende-se de geração a geração.'),
      ],
    ),
    _Secao(
      titulo: '📖 Salmo 103',
      linhas: [
        _Linha('D', 'Bendize, ó minha alma ao Senhor,'),
        _Linha('C', 'e tudo o que há entre mim bendigam o seu santo nome.'),
        _Linha('D', 'Bendize, ó minha alma, ao Senhor,'),
        _Linha('C', 'e não te esqueças de nenhum dos seus benefícios.'),
        _Linha('D', 'É ele que perdoa todas as tuas iniquidades,'),
        _Linha('C', 'e sara todas as tuas enfermidades;'),
        _Linha('D', 'Quem redime a tua vida da perdição,'),
        _Linha('C', 'e te coroa de benignidade e de misericórdia;'),
        _Linha('D', 'Quem enche a tua boca de bens,'),
        _Linha('C', 'de sorte que a tua mocidade se renova como a águia.'),
        _Linha('D', 'O Senhor fará justiça e juízo'),
        _Linha('C', 'a todos os oprimidos.'),
        _Linha('D', 'Fez notórios os seus caminhos a Moisés,'),
        _Linha('C', 'e os seus feitos aos filhos de Israel.'),
        _Linha('D', 'Bendize, ó minha alma ao Senhor!'),
      ],
    ),
    _Secao(
      titulo: '📖 Salmo 139',
      linhas: [
        _Linha('D', 'Senhor, tu me sondaste e me conheces!'),
        _Linha('C', 'tu conheces o meu assentar e o meu levantar, de longe entendes o meu pensamento.'),
        _Linha('D', 'sem que haja uma palavra na minha língua,'),
        _Linha('C', 'eis que, ó Senhor, tudo conheces.'),
        _Linha('D', 'para onde irei do teu espírito?'),
        _Linha('C', 'Ou para onde fugirei da tua face?'),
        _Linha('D', 'Sonda-me, ó Deus, e conhece o meu coração!'),
        _Linha('C', 'prova-me, e conheces os meus pensamentos;'),
        _Linha('D', 'E vê se em mim algum caminho mau,'),
        _Linha('C', 'e guia-me pelo caminho eterno.'),
      ],
    ),
    _Secao(
      titulo: '📖 Salmo 150',
      linhas: [
        _Linha('D', 'Louvai ao Senhor, Louvai a Deus no seu santuário;'),
        _Linha('C', 'Louvai-o no firmamento do seu poder!'),
        _Linha('D', 'Louvai-o pelos seus actos poderosos;'),
        _Linha('C', 'Louvai-o conforme a excelência da sua grandeza.'),
        _Linha('D', 'Louvai-o com som de trombeta;'),
        _Linha('C', 'Louvai-o com o saltério e a harpa!'),
        _Linha('D', 'Louvai-o com o adufe e a flauta;'),
        _Linha('C', 'Louvai-o com instrumento de cordas e com a marimba;'),
        _Linha('D', 'Louvai-o com o quissange e com a ngoma;'),
        _Linha('C', 'Louvai-o com o batuque trepidante.'),
        _Linha('D', 'Tudo quanto tem fôlego louve ao Senhor.'),
        _Linha('C', 'Louvai-o ao Senhor!'),
      ],
    ),
    _Secao(
      titulo: '📖 São Lucas 1:68–79',
      linhas: [
        _Linha('D', 'Bendito o Senhor de Israel,'),
        _Linha('C', 'porque visitou e remiu o seu povo,'),
        _Linha('D', 'E nos levantou uma salvação poderosa'),
        _Linha('C', 'na casa de David seu servo.'),
        _Linha('D', 'Como falou pela boca dos seus santos profetas,'),
        _Linha('C', 'desde o princípio do mundo;'),
        _Linha('D', 'para nos livrar dos nossos inimigos'),
        _Linha('C', 'e da mão de todos os que nos aborrecem.'),
        _Linha('D', 'E tu, ó menino, serás chamado profeta do altíssimo,'),
        _Linha('C', 'porque hás-de ir ante a fece do Senhor, a preparar os seus caminhos,'),
        _Linha('D', 'Para dar ao seu povo conhecimento da salvação,'),
        _Linha('C', 'na remissão dos seus pecados,'),
        _Linha('D', 'Para ilumiar os que estão sentados em trevas e sombras de morte,'),
        _Linha('C', 'a fim de dirigir os nossos pés pelo caminho da paz.'),
      ],
    ),
    _Secao(
      titulo: '📖 São Lucas 2:29–35',
      linhas: [
        _Linha('D', 'Agora, Senhor, despedes em paz o teu servo,'),
        _Linha('C', 'segundo a tua palavra;'),
        _Linha('D', 'pois já os meus olhos viram'),
        _Linha('C', 'a tua salvação,'),
        _Linha('D', 'a qual tu preparaste,'),
        _Linha('C', 'perante a face de todos os povos;'),
        _Linha('D', 'luz para alumiar as nações,'),
        _Linha('C', 'E para glória do teu povo Israel.'),
        _Linha('D', 'Glória ao Pai, e ao Filho e ao Espírito Santo;'),
        _Linha('C', 'Como era no princípio, agora e para sempre, séculos sem fim. Amém.'),
      ],
    ),
    _Secao(
      titulo: '📖 São Mateus 5:3–12 (As Bem-aventuranças)',
      linhas: [
        _Linha('D', 'Bem-aventurados os pobres de espírito,'),
        _Linha('C', 'porque deles é o reino dos céus.'),
        _Linha('D', 'Bem-aventurados os que choram,'),
        _Linha('C', 'porque eles serão consolados.'),
        _Linha('D', 'Bem-aventurados os mansos,'),
        _Linha('C', 'porque eles herdarão a terra.'),
        _Linha('D', 'Bem-aventurados os que têm fome e sede de justiça,'),
        _Linha('C', 'porque eles serão fartos.'),
        _Linha('D', 'Bem-aventurados os misericordiosos,'),
        _Linha('C', 'porque eles alcançarão misericórdia.'),
        _Linha('D', 'Bem-aventurados os limpos de coração,'),
        _Linha('C', 'porque eles verão a Deus.'),
        _Linha('D', 'Bem-aventurados os pacificadores,'),
        _Linha('C', 'porque eles serão chamados filhos de Deus.'),
        _Linha('D', 'Bem-aventurados os que sofrem perseguição por causa da justiça,'),
        _Linha('C', 'porque deles é o reino dos céus.'),
        _Linha('D', 'Bem-aventurados sois vós,'),
        _Linha('C', 'quando vos injuriarem e perseguirem, e mentindo, disserem todo o mal contra vós por minha causa.'),
        _Linha('D', 'Exultai e alegrai-vos, porque é grande o vosso galardão nos céus;'),
        _Linha('C', 'porque assim perseguiram os profetas que foram antes de vós.'),
      ],
    ),
    _Secao(
      titulo: '📖 Apocalipse',
      linhas: [
        _Linha('D', 'Santo, santo, santo é o Senhor Deus, o Todo-Poderoso, que era, e que é, e que há-de vir.'),
        _Linha('C', 'Grande e maravilhosas são as tuas obras, Senhor Deus Todo-Poderoso!'),
        _Linha('D', 'Justos e verdadeiros são os teus caminhos, ó Rei dos santos!'),
        _Linha('C', 'Quem te não temerá, ó Senhor, e não magnificará o teu Nome? Porque só tu és santo.'),
        _Linha('D', 'Digno és Senhor de receber glória, e honra, e poder; porque tu criaste todas as coisas, e por tua vontade são e foram criadas.'),
        _Linha('C', 'Digno é o Cordeiro, que foi morto, de receber o poder, e riquezas, e sabedoria, e força, e honra, e glória, e acções de graças.'),
        _Linha('D', 'Louvor e glória, e sabedoria, e acções de graças, e honra, e poder, e força ao nosso Deus, para todo o sempre.'),
        _Linha('C', 'Ao que está assentado sobre o trono, e ao Cordeiro sejam dadas acções de graças, e honra, e glória, e poder para todo sempre!'),
        _Linha('D', 'Graças te damos, Senhor Deus Todo-Poderoso, que és e que eras, que hás-de vir, que tomaste o teu grande poder, e reinaste.'),
        _Linha('C', 'Aleluia! pois já o Senhor Deus Todo-Poderoso reina. Regozijamo-nos e alegremo-nos, e demos-lhe glória.'),
      ],
    ),
  ];
}
