// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class CadastrarEventoScreen extends StatefulWidget {
//   const CadastrarEventoScreen({super.key});
//
//   @override
//   State<CadastrarEventoScreen> createState() => _CadastrarEventoScreenState();
// }
//
// class _CadastrarEventoScreenState extends State<CadastrarEventoScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nomeController = TextEditingController();
//   final _descricaoController = TextEditingController();
//   DateTime? _dataSelecionada;
//   String? _classeSelecionada;
//
//   bool _salvando = false;
//
//   final List<String> _classes = [
//     'Jovens',
//     'Jovens Adultos',
//     'Mamas',
//     'Papas',
//     'Gerais',
//   ];
//
//   Future<void> _salvarEvento() async {
//     if (_formKey.currentState!.validate() &&
//         _dataSelecionada != null &&
//         _classeSelecionada != null) {
//       setState(() => _salvando = true);
//
//       try {
//         await FirebaseFirestore.instance.collection('eventos').add({
//           'nome': _nomeController.text.trim(),
//           'descricao': _descricaoController.text.trim(),
//           'data': _dataSelecionada,
//           'classe': _classeSelecionada,
//           'criadoEm': FieldValue.serverTimestamp(),
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Evento cadastrado com sucesso!')),
//         );
//
//         _formKey.currentState!.reset();
//         _nomeController.clear();
//         _descricaoController.clear();
//         setState(() {
//           _dataSelecionada = null;
//           _classeSelecionada = null;
//         });
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Erro ao salvar evento: $e')),
//         );
//       }
//
//       setState(() => _salvando = false);
//     }
//   }
//
//   Future<void> _selecionarData() async {
//     final hoje = DateTime.now();
//     final dataEscolhida = await showDatePicker(
//       context: context,
//       initialDate: hoje,
//       firstDate: DateTime(2000), // <-- agora aceita datas passadas
//       lastDate: DateTime(2100),
//     );
//
//     if (dataEscolhida != null) {
//       setState(() => _dataSelecionada = dataEscolhida);
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Cadastrar Evento'),
//         backgroundColor: Colors.deepOrange,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               TextFormField(
//                 controller: _nomeController,
//                 decoration: _buildInput('Nome do Evento'),
//                 validator: (value) => value!.isEmpty ? 'Informe o nome' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _descricaoController,
//                 decoration: _buildInput('Descrição'),
//                 maxLines: 4,
//                 validator: (value) => value!.isEmpty ? 'Informe a descrição' : null,
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: _classeSelecionada,
//                 decoration: _buildInput('Classe / Público-alvo'),
//                 items: _classes
//                     .map((classe) =>
//                     DropdownMenuItem(value: classe, child: Text(classe)))
//                     .toList(),
//                 onChanged: (value) => setState(() => _classeSelecionada = value),
//                 validator: (value) =>
//                 value == null ? 'Selecione a classe do evento' : null,
//               ),
//               const SizedBox(height: 16),
//               ListTile(
//                 title: Text(
//                   _dataSelecionada == null
//                       ? 'Nenhuma data selecionada'
//                       : 'Data selecionada: ${_dataSelecionada!.day}/${_dataSelecionada!.month}/${_dataSelecionada!.year}',
//                 ),
//                 trailing: ElevatedButton(
//                   onPressed: _selecionarData,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.deepOrange,
//                   ),
//                   child: const Text('Selecionar Data'),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               _salvando
//                   ? const Center(child: CircularProgressIndicator())
//                   : ElevatedButton(
//                 onPressed: _salvarEvento,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.deepOrange,
//                   minimumSize: const Size(double.infinity, 50),
//                 ),
//                 child: const Text(
//                   'Salvar Evento',
//                   style: TextStyle(fontSize: 18, color: Colors.white),
//                 ),
//               ),
//             ],
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CadastrarEventoScreen extends StatefulWidget {
  const CadastrarEventoScreen({super.key});

  @override
  State<CadastrarEventoScreen> createState() => _CadastrarEventoScreenState();
}

class _CadastrarEventoScreenState extends State<CadastrarEventoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  DateTime? _dataSelecionada;
  String? _classeSelecionada;

  bool _salvando = false;

  final List<String> _classes = [
    'Jovens',
    'Jovens Adultos',
    'Mamas',
    'Papas',
    'criancas',
    'Gerais',
  ];

  Future<void> _salvarEvento() async {
    if (_formKey.currentState!.validate() &&
        _dataSelecionada != null &&
        _classeSelecionada != null) {
      setState(() => _salvando = true);

      try {
        await FirebaseFirestore.instance.collection('eventos').add({
          'nome': _nomeController.text.trim(),
          'descricao': _descricaoController.text.trim(),
          'data': Timestamp.fromDate(_dataSelecionada!), // garante compatibilidade Firestore
          'classe': _classeSelecionada,
          'status': _dataSelecionada!.isBefore(DateTime.now())
              ? 'Concluído'
              : 'Agendado', // marca automaticamente se é passado ou futuro
          'criadoEm': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento cadastrado com sucesso!')),
        );

        _formKey.currentState!.reset();
        _nomeController.clear();
        _descricaoController.clear();
        setState(() {
          _dataSelecionada = null;
          _classeSelecionada = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar evento: $e')),
        );
      }

      setState(() => _salvando = false);
    }
  }

  Future<void> _selecionarData() async {
    final dataEscolhida = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000), // aceita datas passadas
      lastDate: DateTime(2100),  // aceita datas futuras
    );

    if (dataEscolhida != null) {
      setState(() => _dataSelecionada = dataEscolhida);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Evento'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: _buildInput('Nome do Evento'),
                validator: (value) => value!.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: _buildInput('Descrição'),
                maxLines: 4,
                validator: (value) => value!.isEmpty ? 'Informe a descrição' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _classeSelecionada,
                decoration: _buildInput('Classe / Público-alvo'),
                items: _classes
                    .map((classe) =>
                    DropdownMenuItem(value: classe, child: Text(classe)))
                    .toList(),
                onChanged: (value) => setState(() => _classeSelecionada = value),
                validator: (value) =>
                value == null ? 'Selecione a classe do evento' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  _dataSelecionada == null
                      ? 'Nenhuma data selecionada'
                      : 'Data selecionada: ${_dataSelecionada!.day.toString().padLeft(2, '0')}/${_dataSelecionada!.month.toString().padLeft(2, '0')}/${_dataSelecionada!.year}',
                ),
                trailing: ElevatedButton(
                  onPressed: _selecionarData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                  ),
                  child: const Text('Selecionar Data'),
                ),
              ),
              const SizedBox(height: 24),
              _salvando
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _salvarEvento,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Salvar Evento',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
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
