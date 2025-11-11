// import 'package:flutter/material.dart';
//
// class ReconhecimentoScreen extends StatelessWidget {
//   const ReconhecimentoScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;
//
//     const base = TextStyle(fontSize: 16, height: 1.6);
//     final accent = base.copyWith(fontWeight: FontWeight.w700, color: cs.primary);
//
//     Widget sectionTitle(String t) => Padding(
//       padding: const EdgeInsets.only(top: 4, bottom: 8),
//       child: Text(t,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w900,
//             color: cs.primary,
//           )),
//     );
//
//     Widget bankCard({
//       required String title,
//       required List<InlineSpan> lines,
//       IconData icon = Icons.volunteer_activism,
//     }) {
//       return Card(
//         color: cs.surface,
//         elevation: 1.5,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(children: [
//                 Icon(icon, color: cs.primary),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     title,
//                     style: TextStyle(
//                       color: cs.onSurface,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                 ),
//               ]),
//               const SizedBox(height: 10),
//               SelectableText.rich(
//                 TextSpan(style: base.copyWith(color: cs.onSurfaceVariant), children: lines),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     return Scaffold(
//       backgroundColor: cs.background,
//       appBar: AppBar(
//         backgroundColor: cs.primary,
//         foregroundColor: cs.onPrimary,
//         elevation: 0,
//         title: const Text('Agradecimentos & Doação'),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Agradecimentos
//             Text(
//               'Agradecemos a Deus, fonte de inspiração deste trabalho.',
//               style: base.copyWith(color: cs.onBackground),
//             ),
//             const SizedBox(height: 12),
//             Text.rich(
//               TextSpan(
//                 style: base.copyWith(color: cs.onBackground),
//                 children: [
//                   const TextSpan(text: 'Reconhecemos o empenho de '),
//                   TextSpan(text: 'Manuel Rodrigo Matemba Praia', style: accent),
//                   const TextSpan(text: ', '),
//                   TextSpan(text: 'Aguinaldo Madeira', style: accent),
//                   const TextSpan(text: ' e '),
//                   TextSpan(text: 'Imaculada Miguel', style: accent),
//                   const TextSpan(
//                     text:
//                     ', e de todos que contribuíram para este grandioso Projecto.',
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             // Doações
//             sectionTitle('Doações'),
//             Text(
//               'Para manter este projecto vivo, aceitamos doações voluntárias. '
//                   'Contribua para a continuidade e expansão do Projecto.',
//               style: base.copyWith(color: cs.onBackground),
//             ),
//             const SizedBox(height: 12),
//
//             // Kwanzas (BAI)
//             bankCard(
//               title: '💰 Kwanzas — BAI',
//               lines: [
//                 TextSpan(text: 'Titular: ', style: accent),
//                 const TextSpan(text: 'REGINUEL BUSINESS\n'),
//                 TextSpan(text: 'Conta: ', style: accent),
//                 const TextSpan(text: '08823979810002\n'),
//                 TextSpan(text: 'IBAN: ', style: accent),
//                 const TextSpan(text: 'AO06004000008823979810264'),
//               ],
//               icon: Icons.account_balance,
//             ),
//             const SizedBox(height: 12),
//
//             // USD / EUR (BANCO ATLÂNTICO EUROPA)
//             bankCard(
//               title: '💰 USD / EUR — Banco Atlântico Europa',
//               lines: [
//                 TextSpan(text: 'Titular: ', style: accent),
//                 const TextSpan(text: 'Manuel Rodrigo Matemba Praia\n'),
//                 TextSpan(text: 'Nº de conta: ', style: accent),
//                 const TextSpan(text: '302101210001\n'),
//                 TextSpan(text: 'IBAN: ', style: accent),
//                 const TextSpan(text: 'PT50018900030210121000118'),
//               ],
//               icon: Icons.public,
//             ),
//             const SizedBox(height: 20),
//
//             // Fecho
//             Text(
//               'Que este seja um instrumento de adoração e unidade no corpo de Cristo.',
//               style: base.copyWith(color: cs.onBackground, fontStyle: FontStyle.italic),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// lib/screens/reconhecimento_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReconhecimentoScreen extends StatelessWidget {
  const ReconhecimentoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    const baseItalico = TextStyle(
      fontSize: 16,
      height: 1.6,
      fontStyle: FontStyle.italic,
    );

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
        title: const Text('Agradecimentos & Doação'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agradecemos a Deus, fonte de inspiração deste trabalho.\n',
              style: baseItalico.copyWith(color: cs.onBackground),
            ),
            Text.rich(
              TextSpan(
                style: baseItalico.copyWith(color: cs.onBackground),
                children: [
                  const TextSpan(text: 'Reconhecemos o empenho de '),
                  TextSpan(
                    text: 'Manuel Rodrigo Matemba Praia',
                    style: baseItalico.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                  const TextSpan(text: ', '),
                  TextSpan(
                    text: 'Aguinaldo de Jesus Martins Madeira',
                    style: baseItalico.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                  const TextSpan(text: ' e '),
                  TextSpan(
                    text: 'Imaculada Miguel Zongo',
                    style: baseItalico.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                  const TextSpan(
                    text:
                    ', e de todos que contribuíram para este grandioso Projecto.\n',
                  ),
                ],
              ),
            ),
            Text(
              'Para manter este projecto vivo, aceitamos doações voluntárias. '
                  'Contribua para a continuidade e expansão do Projecto.\n',
              style: baseItalico.copyWith(color: cs.onBackground),
            ),

            // ==== Doações em KZ (BAI) ====
            _DoacaoCard(
              titulo: '💰 Kwanzas — BAI',
              linhas: const [
                _LinhaDoacao(rotulo: 'Titular', valor: 'REGINUEL BUSINESS'),
                _LinhaDoacao(rotulo: 'Conta', valor: '08823979810002'),
                _LinhaDoacao(
                  rotulo: 'IBAN',
                  valor: 'AO06004000008823979810264',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ==== Doações em USD / EUR (Atlântico Europa) ====
            _DoacaoCard(
              titulo: '💰 USD / EUR — Banco Atlântico Europa',
              linhas: const [
                _LinhaDoacao(
                  rotulo: 'Titular',
                  valor: 'Manuel Rodrigo Matemba Praia',
                ),
                _LinhaDoacao(rotulo: 'Nº de conta', valor: '302101210001'),
                _LinhaDoacao(
                  rotulo: 'IBAN',
                  valor: 'PT50018900030210121000118',
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'Que este seja um instrumento de adoração e unidade no corpo de Cristo.',
              style: baseItalico.copyWith(color: cs.onBackground),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoacaoCard extends StatelessWidget {
  final String titulo;
  final List<_LinhaDoacao> linhas;
  const _DoacaoCard({required this.titulo, required this.linhas});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo,
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                )),
            const SizedBox(height: 8),
            ...linhas.map((l) => _LinhaDoacaoWidget(linha: l)).toList(),
          ],
        ),
      ),
    );
  }
}

class _LinhaDoacao {
  final String rotulo;
  final String valor;
  const _LinhaDoacao({required this.rotulo, required this.valor});
}

class _LinhaDoacaoWidget extends StatelessWidget {
  final _LinhaDoacao linha;
  const _LinhaDoacaoWidget({required this.linha});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '${linha.rotulo}:',
              style: TextStyle(
                color: cs.onBackground.withOpacity(.7),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              linha.valor,
              style: TextStyle(
                fontSize: 16,
                color: cs.onBackground,
              ),
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'Copiar ${linha.rotulo}',
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: linha.valor));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text('${linha.rotulo} copiado(a)'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
