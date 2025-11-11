import 'package:flutter/material.dart';

enum CredoLang { pt, kk, kb, ub }

class CredoApostolicoScreen extends StatefulWidget {
  const CredoApostolicoScreen({super.key});

  @override
  State<CredoApostolicoScreen> createState() => _CredoApostolicoScreenState();
}

class _CredoApostolicoScreenState extends State<CredoApostolicoScreen> {
  CredoLang _lang = CredoLang.pt;

  static const String _credoPT = '''
Credo Apostólico

Creio em Deus, Pai todo Poderoso, Criador do Céu e da terra; em Jesus Cristo seu único filho, nosso Senhor; o qual foi concebido pelo Espirito Santo; nasceu da virgem Maria e padeceu sob o Pôncio Pilatos; foi crucificado, morto e sepultado; no terceiro dia resurgiu dos mortos, subiu aos céus, e está sentado a mão direita de Deus, Pai Todo Poderoso, donde há-de vir julgar os vivos e os mortos.

Creio no Espírito Santo; na Santa Igreja de Cristo; na comunhão dos Santos; na remissão dos pecados; na ressurreição do corpo; e na vida eterna.

AMÉM.
''';

  static const String _credoKK = '''
Credo Apostólico

Kwikidi muna Nzambi w’eSe, Mpungu Nengolo, Nsemi zulu ye ntoto.
Nkwikidi muna Yisu Klisto wa Mwan’andi mosi kaka wa Mfumu eto;
Ona wawutwa kwa ndumba mwenze Malia, muna nkuma Mwand’avelela, wamwesewa e mpasi kwa Pontio Pilatu;
Wakomwa vana kuluzu, wafwa ye wazikwa;
Muna lumbu kiantatu wafuluka mu bafwa;
Watombuka kun’e zulu, kukavvandanga kuna koko kwa lunene kwa Nzambi, Mpungu Wisa, se kavutuka diaka yo kwiza fundisa wana bena moyo yo wana bafwa.
Nkwikidi muna Mwand’avelela;
Muna dibundu di’aveledi;
Muna luloloko lwa masumu, muna lufuluku lwa nitu;
Yo muna moyo wa mvu ya mvu.

AMÉM.
''';

  static const String _credoKB = '''
Credo Apostólico

Eme nga xikana Nzambi;
Tata ua tena ioso, Mubangi a diulu ni oxi, ni Jezu Kristo;
Mon’ê umoxi êlele, Ngana ietu;
Mutu a mu imita kua Nzambi Ikôla;
A mu vuala kua muxeletete Nga Madiia;
U bhita ku jiphaxi kua Pônso Pilatu;
A mu phaphela ku diklusu ufua anga a mu funda kizua kiá katatu anga ufukunuka ku’alunga;
U banda ku diulu, anga u xikama ku lukuaku lua kûdia lua Nzambi;
Tata ua tena ioso, kuenhoko phe hinu ua kà tunda-ku;
Kuiza kufundisa oso ala hanji ni muenhu, ni iá afua kiá;
Nga xikana Nzumbi ikôla ia Nzambi ó Ngeleja iê imoxi mu ngongo ioso;
O kisangela mudiâ kiá athu oso a mu tokala;
O ituxi ku iloloka;
O mukutu kufukunuka, ni muenhu ki u moneka dizubilu.

AMÉM.
''';

  static const String _credoUB = '''
Credo Apostólico

Nala ku Suku Tate, o kola, Usovoli wovailu kuenda osi,
Loku Yesu Kristo, omola a Suku wongunga, eye Ñala yetu.
Ha eye wa eciwa le Espiritu Sandu.
Wa citiwa lufeko Maria;
Wa tala ohali ku Pondio Pilatu, wa nyoñamisua komindikiso, wa fa, wa kendiwa;
Eteke lia tatu wa pinduka puiwa londa kilu wa tumala kondio ya Suku, o kola, Isiahe;
Haiko a ka tunda ha yali ekenga liomanu, ava va kasi lomuenyo lava va fa.
Nava ke Espiritu Sandu;
Lokekongelo li kola liokolofeka viosi;
Lokongongela yavakuesunga lia Suku;
Loku ecelua akandu;
Kuenda kepinduko lietimba lomuenyo kopui.

AMÉM.
''';

  String get _textoAtual {
    switch (_lang) {
      case CredoLang.pt:
        return _credoPT;
      case CredoLang.kk:
        return _credoKK;
      case CredoLang.kb:
        return _credoKB;
      case CredoLang.ub:
        return _credoUB;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Quebra em título (primeira linha) e corpo
    final lines = _textoAtual.trim().split("\n");
    final titulo = lines.first.trim();
    final corpo = lines.skip(1).join("\n").trim();

    return Scaffold(
      backgroundColor: cs.background, // antes: 0xFFF9F9F9
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
        title: const Text('Credo Apostólico'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _LanguageChips(
              value: _lang,
              onChanged: (v) => setState(() => _lang = v),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Card(
                color: cs.secondaryContainer, // cards/acessórios
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: cs.secondary), // borda/realce
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        titulo,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          height: 1.5,
                          color: cs.onSecondaryContainer,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SelectableText(
                        corpo,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 16,
                          height: 1.6,
                          color: cs.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageChips extends StatelessWidget {
  final CredoLang value;
  final ValueChanged<CredoLang> onChanged;

  const _LanguageChips({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final entries = <(CredoLang, String, IconData)>[
      (CredoLang.pt, 'Português', Icons.language),
      (CredoLang.kk, 'Kikongo', Icons.translate),
      (CredoLang.kb, 'Kimbundu', Icons.translate),
      (CredoLang.ub, 'Umbundu', Icons.translate),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: entries.map((e) {
        final selected = value == e.$1;
        final iconColor = selected ? cs.onPrimary : cs.primary;
        final labelColor = selected ? cs.onPrimary : cs.primary;

        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(e.$3, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(e.$2),
            ],
          ),
          selected: selected,
          // Cores respeitando o tema:
          selectedColor: cs.primary,                 // chip ativo
          backgroundColor: cs.secondaryContainer,    // chip inativo
          labelStyle: TextStyle(
            color: labelColor,
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide(color: selected ? cs.primary : cs.secondary),
          onSelected: (_) => onChanged(e.$1),
        );
      }).toList(),
    );
  }
}
