
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// class CadastrarHinoScreen extends StatefulWidget {
//   const CadastrarHinoScreen({super.key});
//
//   @override
//   State<CadastrarHinoScreen> createState() => _CadastrarHinoScreenState();
// }
//
// class _CadastrarHinoScreenState extends State<CadastrarHinoScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _tituloController = TextEditingController();
//   final TextEditingController _conteudoController = TextEditingController();
//   final TextEditingController _numeroController = TextEditingController();
//   final TextEditingController _escritorController = TextEditingController();
//
//   String? _linguaSelecionada;
//   final List<String> _linguas = ['Português', 'Umbundu', 'Kimbundu', 'Outros'];
//
//   String? _secaoSelecionada;
//
//   final List<String> _secoes = [
//     // I — O Evangelho e a Experiência Cristã
//     'Louvor a Deus',
//     'O Evangelho de Jesus Cristo',
//     'O Espírito Santo',
//     'A Vida Cristã',
//
//     // II — A Igreja Viva e o Testemunho dos Cristãos
//     'Evangelização e Avivamento',
//     'Unidade e Comunhão Fraternal',
//     'Sacramentos - Casamentos',
//     'Ministério',
//     'Organizações da Igreja',
//     'O Testemunho Vivo dos Cristãos',
//
//     // III — O Ano Cristão e Ocasiões Especiais
//     'Advento e Natal',
//     'Quaresma e Páscoa',
//     'O Dia do Senhor e Ações de Graças',
//     'Hinos Matutinos e Vespertinos',
//     'O Lar Cristão',
//     'Despedidas e Viagens',
//     'Funerais',
//     'Segunda Vinda de Cristo',
//     'A Bíblia',
//     'O Ano Novo',
//     'Dedicações e Aniversários',
//     'Finais',
//   ];
//
//   bool _salvando = false;
//
//   Future<void> _salvarHino() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() => _salvando = true);
//
//       try {
//         await FirebaseFirestore.instance.collection('hinos').add({
//           'titulo': _tituloController.text.trim(),
//           'numero': _numeroController.text.trim(),
//           'conteudo': _conteudoController.text.trim(),
//           'secao': _secaoSelecionada,
//           'lingua': _linguaSelecionada,
//           'escritor': _escritorController.text.trim(),
//           'dataCriacao': FieldValue.serverTimestamp(),
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Hino cadastrado com sucesso!')),
//         );
//
//         _formKey.currentState!.reset();
//         _tituloController.clear();
//         _numeroController.clear();
//         _conteudoController.clear();
//         _escritorController.clear();
//         setState(() {
//           _linguaSelecionada = null;
//           _secaoSelecionada = null;
//         });
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Erro ao salvar hino: $e')),
//         );
//       }
//
//       setState(() => _salvando = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Cadastrar Novo Hino'),
//         backgroundColor: Colors.deepOrange,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 TextFormField(
//                   controller: _tituloController,
//                   decoration: _buildInput('Título do Hino'),
//                   validator: (value) => value!.isEmpty ? 'Informe o título' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _numeroController,
//                   decoration: _buildInput('Número (opcional)'),
//                   keyboardType: TextInputType.number,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _escritorController,
//                   decoration: _buildInput('Escritor (opcional)'),
//                 ),
//                 const SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   value: _secaoSelecionada,
//                   decoration: _buildInput('Seção / Assunto'),
//                   items: _secoes
//                       .map((secao) => DropdownMenuItem(value: secao, child: Text(secao)))
//                       .toList(),
//                   onChanged: (value) => setState(() => _secaoSelecionada = value),
//                   validator: (value) => value == null ? 'Selecione uma seção/assunto' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 DropdownButtonFormField<String>(
//                   value: _linguaSelecionada,
//                   decoration: _buildInput('Língua'),
//                   items: _linguas
//                       .map((lingua) => DropdownMenuItem(value: lingua, child: Text(lingua)))
//                       .toList(),
//                   onChanged: (value) => setState(() => _linguaSelecionada = value),
//                   validator: (value) => value == null ? 'Selecione a língua do hino' : null,
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _conteudoController,
//                   decoration: _buildInput('Letra do Hino'),
//                   maxLines: 10,
//                   validator: (value) => value!.isEmpty ? 'Digite a letra do hino' : null,
//                 ),
//                 const SizedBox(height: 24),
//                 _salvando
//                     ? const CircularProgressIndicator()
//                     : ElevatedButton(
//                   onPressed: _salvarHino,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.deepOrange,
//                     minimumSize: const Size(double.infinity, 50),
//                   ),
//                   child: const Text(
//                     'Salvar Hino',
//                     style: TextStyle(fontSize: 18, color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   InputDecoration _buildInput(String label) {
//     return InputDecoration(
//       labelText: label,
//       border: const OutlineInputBorder(),
//       focusedBorder: const OutlineInputBorder(
//         borderSide: BorderSide(color: Colors.deepOrange, width: 2),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CadastrarHinoScreen extends StatefulWidget {
  final String lingua;

  const CadastrarHinoScreen({super.key, required this.lingua});

  @override
  State<CadastrarHinoScreen> createState() => _CadastrarHinoScreenState();
}

class _CadastrarHinoScreenState extends State<CadastrarHinoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _conteudoController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _escritorController = TextEditingController();

  String? _secaoSelecionada;
  bool _salvando = false;

  List<String> get _secoes {
    switch (widget.lingua) {
      case 'Português':
        return [
          'Louvor a Deus',
          'O Evangelho de Jesus Cristo',
          'O Espírito Santo',
          'A Vida Cristã',
          'Evangelização e Avivamento',
          'Unidade e Comunhão Fraternal',
          'Sacramentos - Casamentos',
          'Ministério',
          'Organizações da Igreja',
          'O Testemunho Vivo dos Cristãos',
          'Advento e Natal',
          'Quaresma e Páscoa',
          'O Dia do Senhor e Ações de Graças',
          'Hinos Matutinos e Vespertinos',
          'O Lar Cristão',
          'Despedidas e Viagens',
          'Funerais',
          'Segunda Vinda de Cristo',
          'A Bíblia',
          'O Ano Novo',
          'Dedicações e Aniversários',
          'Finais',
        ];
      case 'Kikongo':
        return [
          'Kembelela Nzambi — Mwanda Helela (1–10)',
          'N’sangu za Yisu Klisto (11–24)',
          'Zingu kia Nkwikizi (25–37)',
          'N’samu ye Nkubameno (38–42)',
          'Hamosi ye Nkutakani ya Nzolua Nzambi (43)',
          'Mvubilu (44)',
          'Lukazalu (45)',
          'Nlekelo a Mfumu (46–48)',
          'Kimbangí kia Moyo wa Nkwikizi (49–66)',
          'Matondo (67–71)',
          'Ngiza yo Luwutuku (72–77)',
          'Lufwa lua Yisu (78–84)',
          'Lufuluku (85–87)',
          'Nkanda Nzambi (88)',
          'Mvo wa Mpa (89)',
          'Nkunga mia mene-mene yo masika (90–92)',
          'Nzó ya Nkwikizi (93)',
          'Lukananu (94)',
          'Nzikilu ya Mafwa/Ezulu (95–100)',
          'Ngiza ya Zole ya Klisto (101–103)',
          'Aleke (104–107)',
        ];
      case 'Kimbundu':
        return [
          'Diximanu dia Nzambi (1–16)',
          'O Njimbu ia Mbote ia Mbuludi (17–41)',
          'Nzumbi Ikola-Mukuatekexi (42–45)',
          'O Mueníu ua Ngeleja ni ua Kidistá (46–103)',
          'Itangana ia Ditungula mu Muvu (104–159)',
          'Dizubilu (160–162)',
        ];
      case 'Umbundu':
        return [
          'Esivayo Lefendelo (1–12)',
          'Espiritu Sandu (13–17)',
          'Ucito wa Yesu Kristu (18–23)',
          'Okufa kua Ñala Yesu Kristu (24–28)',
          'Epinduko lia Yesu Kristu (29–33)',
          'Ekongelo lia Yesu Kristu (34–36)',
          'Epata Lietavo lia Kristu (37–40)',
          'Omesa ya Ñala Yesu Kristu (41–46)',
          'Oku Laleka (47–54)',
          'Oku Likutíllia (55–65)',
          'Oku Litumbika (66–72)',
          'Ekololo Lelembekeleo (73–87)',
          'Uvangi Lupange (88–94)',
          'Olopandu (95–102)',
          'Ovisungo Vioñolosi (103–105)',
          'Embímbiliya (106–109)',
          'Ovisungo Viomala (110–113)',
          'Okufa Kukua Kristu (114–119)',
          'Oku Yalula (120–123)',
          'Oku Tumbangiya (124–129)',
        ];
      default:
        return [];
    }
  }

  Future<void> _salvarHino() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _salvando = true);
      try {
        await FirebaseFirestore.instance.collection('hinos').add({
          'titulo': _tituloController.text.trim(),
          'numero': _numeroController.text.trim(),
          'conteudo': _conteudoController.text.trim(),
          'secao': _secaoSelecionada,
          'lingua': widget.lingua,
          'escritor': _escritorController.text.trim(),
          'dataCriacao': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hino cadastrado com sucesso!')),
        );

        _formKey.currentState!.reset();
        _tituloController.clear();
        _numeroController.clear();
        _conteudoController.clear();
        _escritorController.clear();
        setState(() {
          _secaoSelecionada = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar hino: $e')),
        );
      }

      setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar Hino - ${widget.lingua}'),
        backgroundColor: Colors.deepOrange,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _tituloController,
                    decoration: _buildInput('Título do Hino'),
                    validator: (value) =>
                    value!.isEmpty ? 'Informe o título' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _numeroController,
                    decoration: _buildInput('Número (opcional)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _escritorController,
                    decoration: _buildInput('Escritor (opcional)'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _secaoSelecionada,
                    decoration: _buildInput('Seção / Assunto'),
                    isExpanded: true,
                    items: _secoes
                        .map((secao) => DropdownMenuItem(
                      value: secao,
                      child: Text(
                        secao,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _secaoSelecionada = value),
                    validator: (value) =>
                    value == null ? 'Selecione uma seção/assunto' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _conteudoController,
                    decoration: _buildInput('Letra do Hino'),
                    maxLines: 10,
                    validator: (value) =>
                    value!.isEmpty ? 'Digite a letra do hino' : null,
                  ),
                  const SizedBox(height: 24),
                  _salvando
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: _salvarHino,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Salvar Hino',
                      style: TextStyle(
                          fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInput(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.deepOrange, width: 2),
      ),
    );
  }
}


