import 'package:flutter/material.dart';

enum ODumLang { kk, kb, pt, ub }

class OracaoDominicalScreen extends StatefulWidget {
  const OracaoDominicalScreen({super.key});

  @override
  State<OracaoDominicalScreen> createState() => _OracaoDominicalScreenState();
}

class _OracaoDominicalScreenState extends State<OracaoDominicalScreen> {
  // idioma inicial
  ODumLang _lang = ODumLang.pt;

  static const String _kk = '''
Oração Dominical
E sê dieto koko zulu, bika nkumbu aku ya zitiswa ye kimfumu kiakiza;
O luzolo luaku lwa vangama;
Vava ntsi ne i koko zulu oh dia kweto kwalumbu kié lumbu utu 'vana;
Utuloloka masumu meto;
Endoloka tu lolokanga a tanto etu kutu yambudi ko twa bwa mu mpukimini kansi utu vuluza muna mbi;
Kadi kiaku i kinfumu, Ye ngongo;
Ye nkembo, a mvu ya mvu.

AMÉM.

Mateus 6:9–13
''';

  static const String _kb = '''
Oração Dominical
Tata ietu uene mu diulu, dijina dia a dixile,
Utuminu ue uize;
Vondadi ie a i bhange mu ngongo;
Kala kia i bhanga ku diulu;
Kudia kuetu kua kizua tu bhane-ku lelu;
Tu loloke o ikuma ietu, kala ki tu loloka akuetu oso a tu bhanga kiaibha;
Ku tu ehele ku dibhata mu mibhetu ia diabhu;
Maji tumbhuletu mu ituxi, mbata eie ngana;
Ni nguzu, ni fuma se dizubhilu.

AMÉM.

Mateus 6:9–13
''';

  static const String _pt = '''
Oração Dominical
Pai nosso, que estás nos Céus, santificado seja o teu Nome;
Venha ao teu reino;
Seja feita a tua vontade assim na terra, como nos Céus;
O pão nosso de cada dia nos dá hoje;
Perdoa as nossas dívidas, assim como nós perdoamos os nossos devedores;
Não nos deixes cair em tentação, mas livra-nos do mal;
Pois teu é o reino;
O poder e a glória para sempre.

AMÉM.

Mateus 6:9–13
''';

  static const String _ub = '''
Oração Dominical
A lsietu o kasi kilu, onduku yeve yi sumbiwe, usoma wovewiyei;
Tu ihe o kuilia kuetu kuetaili;
Tu ecele okulueya kuetu ndeci tu ecoila ava va tu lueyela;
Ku ka tu singuile veyonjo;
Puãi tu popele kuvi, Mona Usoma, wove;
Unene wove, ulamba wove;
Olonene vi enda ñoo hu.

AMÉM.

Mateus 6:9–13
''';

  String get _textoAtual {
    switch (_lang) {
      case ODumLang.kk:
        return _kk;
      case ODumLang.kb:
        return _kb;
      case ODumLang.pt:
        return _pt;
      case ODumLang.ub:
        return _ub;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Quebrar em título (1ª linha) e corpo
    final lines = _textoAtual.trim().split("\n");
    final titulo = lines.first.trim();
    final corpo = lines.skip(1).join("\n").trim();

    return Scaffold(
      backgroundColor: cs.background, // antes: Color(0xFFF9F9F9)
      appBar: AppBar(
        backgroundColor: cs.primary,   // antes: Colors.deepOrange
        foregroundColor: cs.onPrimary, // texto/ícones
        elevation: 0,
        title: const Text('Oração Dominical'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _LanguageChipsOD(
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
                          color: cs.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SelectableText(
                        corpo,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: cs.onSecondaryContainer,
                          fontStyle: FontStyle.italic,
                          fontSize: 16,
                          height: 1.6,
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

class _LanguageChipsOD extends StatelessWidget {
  final ODumLang value;
  final ValueChanged<ODumLang> onChanged;

  const _LanguageChipsOD({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final entries = <(ODumLang, String, IconData)>[
      (ODumLang.pt, 'Português', Icons.language),
      (ODumLang.kk, 'Kikongo', Icons.translate),
      (ODumLang.kb, 'Kimbundu', Icons.translate),
      (ODumLang.ub, 'Umbundu', Icons.translate),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: entries.map((e) {
        final selected = value == e.$1;
        final bg = selected ? cs.primary : cs.secondaryContainer;
        final fg = selected ? cs.onPrimary : cs.onSecondaryContainer;

        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(e.$3, size: 16, color: fg),
              const SizedBox(width: 6),
              Text(e.$2),
            ],
          ),
          selected: selected,
          backgroundColor: cs.secondaryContainer,
          selectedColor: cs.primary,
          labelStyle: TextStyle(
            color: fg,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: selected ? cs.primary : cs.secondary),
          ),
          onSelected: (_) => onChanged(e.$1),
          // Para manter o contraste correto em Material 3:
          // overriding via Theme for icon/label color já foi feito acima
          // e as cores bg/fg vêm do colorScheme.
        );
      }).toList(),
    );
  }
}
