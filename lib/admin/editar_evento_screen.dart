import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// importe o constants.dart do seu projeto
import 'package:hpcdigital/constantes/constants.dart';

class EditarEventoScreen extends StatefulWidget {
  final DocumentReference<Map<String, dynamic>> ref;

  const EditarEventoScreen({super.key, required this.ref});

  @override
  State<EditarEventoScreen> createState() => _EditarEventoScreenState();
}

class _EditarEventoScreenState extends State<EditarEventoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _dateFmt = DateFormat('dd/MM/yyyy');

  bool _loading = true;
  bool _salvando = false;

  DateTime? _dataSelecionada;
  String? _classeSelecionada;
  String _statusSelecionado = 'Agendado';

  static const _statusList = <String>['Agendado', 'Concluído'];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final snap = await widget.ref.get();
      final data = snap.data() ?? {};

      _nomeController.text = (data['nome'] ?? '').toString();
      _descricaoController.text = (data['descricao'] ?? '').toString();

      final classe = (data['classe'] ?? '').toString().trim();
      _classeSelecionada = classe.isEmpty ? null : classe;

      final status = (data['status'] ?? '').toString().trim();
      _statusSelecionado = status.isEmpty ? 'Agendado' : status;

      final ts = data['data'];
      if (ts is Timestamp) _dataSelecionada = ts.toDate();
      if (ts is DateTime) _dataSelecionada = ts;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar: $e')),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dataSelecionada = picked);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dataSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data do evento.')),
      );
      return;
    }
    setState(() => _salvando = true);
    try {
      await widget.ref.update({
        'nome': _nomeController.text.trim(),
        'descricao': _descricaoController.text.trim(),
        'classe': _classeSelecionada,
        'status': _statusSelecionado,
        'data': Timestamp.fromDate(_dataSelecionada!),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento atualizado com sucesso!')),
        );
        Navigator.pop(context, true); // retorna sucesso
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _apagar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Apagar evento'),
        content: const Text('Tem certeza que deseja apagar este evento?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _salvando = true);
    try {
      await widget.ref.delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento apagado.')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao apagar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Gera a lista de classes mesclando oficiais + valor legado (se houver)
    final classes = gerarListaComValorLegado(_classeSelecionada);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Evento'),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            tooltip: 'Apagar',
            onPressed: _salvando ? null : _apagar,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: _dec('Nome do Evento'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descricaoController,
                decoration: _dec('Descrição'),
                minLines: 3,
                maxLines: 6,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe a descrição' : null,
              ),
              const SizedBox(height: 16),

              // Dropdown de Classe usando constants.dart
              DropdownButtonFormField<String>(
                value: classes.contains(_classeSelecionada) ? _classeSelecionada : null,
                decoration: _dec('Classe / Público-alvo'),
                isExpanded: true,
                items: classes
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _classeSelecionada = v),
                validator: (v) => v == null || v.isEmpty ? 'Selecione a classe' : null,
              ),
              const SizedBox(height: 16),

              // Dropdown de Status
              DropdownButtonFormField<String>(
                value: _statusSelecionado,
                decoration: _dec('Status'),
                items: _statusList
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _statusSelecionado = v ?? 'Agendado'),
              ),
              const SizedBox(height: 16),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _dataSelecionada == null
                      ? 'Sem data selecionada'
                      : 'Data: ${_dateFmt.format(_dataSelecionada!)}',
                ),
                trailing: ElevatedButton(
                  onPressed: _selecionarData,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                  child: const Text('Selecionar Data'),
                ),
              ),

              const SizedBox(height: 24),

              _salvando
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                onPressed: _salvar,
                icon: const Icon(Icons.save),
                label: const Text('Salvar alterações'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.deepOrange, width: 2),
    ),
  );
}
