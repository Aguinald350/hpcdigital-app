import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../admin/widgets/admin_shell.dart';

class CadastrarIgrejaScreen extends StatefulWidget {
  const CadastrarIgrejaScreen({super.key});

  @override
  State<CadastrarIgrejaScreen> createState() => _CadastrarIgrejaScreenState();
}

class _CadastrarIgrejaScreenState extends State<CadastrarIgrejaScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeIgrejaCtrl = TextEditingController();
  final _secretarioNomeCtrl = TextEditingController();
  final _secretarioContatoCtrl = TextEditingController();
  final _localizacaoUrlCtrl = TextEditingController();
  final _referenciasCtrl = TextEditingController();

  int _numPastores = 1;
  final List<TextEditingController> _pastorNomeCtrls = [];
  final List<TextEditingController> _pastorContatoCtrls = [];

  String? _intendenciaId;
  String? _intendenciaNome;
  String? _distritoId;
  String? _distritoNome;

  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _syncPastorControllers(_numPastores);
  }

  @override
  void dispose() {
    _nomeIgrejaCtrl.dispose();
    _secretarioNomeCtrl.dispose();
    _secretarioContatoCtrl.dispose();
    _localizacaoUrlCtrl.dispose();
    _referenciasCtrl.dispose();
    for (final c in _pastorNomeCtrls) c.dispose();
    for (final c in _pastorContatoCtrls) c.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: Colors.grey[50],
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.deepOrange, width: 2),
    ),
  );

  void _syncPastorControllers(int n) {
    while (_pastorNomeCtrls.length < n) {
      _pastorNomeCtrls.add(TextEditingController());
      _pastorContatoCtrls.add(TextEditingController());
    }
    while (_pastorNomeCtrls.length > n) {
      _pastorNomeCtrls.removeLast().dispose();
      _pastorContatoCtrls.removeLast().dispose();
    }
    setState(() {});
  }

  String? _validaUrl(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Informe o link da localização (Google Maps, por ex.)';
    final uri = Uri.tryParse(t);
    if (uri == null || !uri.hasScheme || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return 'Informe uma URL válida (http/https)';
    }
    return null;
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_intendenciaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a Intendência.')),
      );
      return;
    }

    final List<Map<String, dynamic>> pastores = [];
    for (int i = 0; i < _numPastores; i++) {
      final nome = _pastorNomeCtrls[i].text.trim();
      final contato = _pastorContatoCtrls[i].text.trim();
      if (nome.isEmpty || contato.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Preencha nome e contato do pastor ${i + 1}.')),
        );
        return;
      }
      pastores.add({'nome': nome, 'contato': contato});
    }

    setState(() => _salvando = true);
    try {
      final nomeIgreja = _nomeIgrejaCtrl.text.trim();
      await FirebaseFirestore.instance.collection('igrejas').add({
        'nome': nomeIgreja,
        'nomeLower': nomeIgreja.toLowerCase(),
        'numPastores': _numPastores,
        'pastores': pastores,
        'secretarioNome': _secretarioNomeCtrl.text.trim(),
        'secretarioContato': _secretarioContatoCtrl.text.trim(),
        'intendenciaId': _intendenciaId,
        'intendenciaNome': _intendenciaNome,
        'distritoId': _distritoId,
        'distritoNome': _distritoNome,
        'localizacaoUrl': _localizacaoUrlCtrl.text.trim(),
        'referencias': _referenciasCtrl.text.trim(),
        'criadoEm': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Igreja cadastrada com sucesso!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ Sem orderBy — compatível com docs antigos; ordenamos por 'nome' no cliente
    final intendenciasStream =
    FirebaseFirestore.instance.collection('intendencias').snapshots();

    return AdminShell(
      title: 'Cadastrar Igreja',
      currentIndex: 4,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 950),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Material(
              color: Colors.white,
              elevation: 1,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _nomeIgrejaCtrl,
                        decoration: _dec('Nome da Igreja'),
                        validator: (v) {
                          final t = v?.trim() ?? '';
                          if (t.isEmpty) return 'Informe o nome da igreja';
                          if (t.length < 3) return 'O nome deve ter pelo menos 3 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          const Expanded(
                            child: Text('Número de Pastores', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          DropdownButton<int>(
                            value: _numPastores,
                            items: List.generate(10, (i) => i + 1)
                                .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                                .toList(),
                            onChanged: (v) {
                              if (v == null) return;
                              _numPastores = v;
                              _syncPastorControllers(v);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      ...List.generate(_numPastores, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: TextFormField(
                                  controller: _pastorNomeCtrls[i],
                                  decoration: _dec('Pastor ${i + 1} - Nome'),
                                  validator: (v) =>
                                  (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 5,
                                child: TextFormField(
                                  controller: _pastorContatoCtrls[i],
                                  decoration: _dec('Contato'),
                                  keyboardType: TextInputType.phone,
                                  validator: (v) =>
                                  (v == null || v.trim().isEmpty) ? 'Informe o contato' : null,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _secretarioNomeCtrl,
                        decoration: _dec('Nome do Secretário'),
                        validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Informe o nome do secretário' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _secretarioContatoCtrl,
                        decoration: _dec('Contato do Secretário'),
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Informe o contato do secretário' : null,
                      ),

                      const SizedBox(height: 16),

                      StreamBuilder<QuerySnapshot>(
                        stream: intendenciasStream,
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          if (snap.hasError) return const Text('Erro ao carregar intendências');

                          var docs = snap.data?.docs ?? [];
                          if (docs.isEmpty) {
                            return const Text(
                              'Nenhuma Intendência cadastralda.\nCadastre uma intendência antes de continuar.',
                              style: TextStyle(fontSize: 14),
                            );
                          }

                          // Ordena por 'nome' no cliente
                          docs.sort((a, b) {
                            final an = ((a['nome'] ?? '') as String).toLowerCase();
                            final bn = ((b['nome'] ?? '') as String).toLowerCase();
                            return an.compareTo(bn);
                          });

                          if (_intendenciaId != null && !docs.any((d) => d.id == _intendenciaId)) {
                            _intendenciaId = null;
                            _intendenciaNome = null;
                            _distritoId = null;
                            _distritoNome = null;
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<String>(
                                value: _intendenciaId,
                                isExpanded: true,
                                decoration: _dec('Intendência'),
                                items: docs.map((d) {
                                  final nome = (d['nome'] ?? '').toString();
                                  return DropdownMenuItem<String>(
                                    value: d.id,
                                    child: Text(nome.isEmpty ? '(Sem nome)' : nome),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _intendenciaId = val;
                                    final doc = docs.firstWhere((d) => d.id == val);
                                    _intendenciaNome = (doc['nome'] ?? '').toString();

                                    _distritoId = (doc['distritoId'] ?? '').toString().isEmpty
                                        ? null
                                        : (doc['distritoId'] as String);
                                    _distritoNome = (doc['distritoNome'] ?? '').toString().isEmpty
                                        ? null
                                        : (doc['distritoNome'] as String);
                                  });
                                },
                                validator: (v) => v == null ? 'Selecione uma intendência' : null,
                              ),
                              if (_distritoNome != null && _distritoNome!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text('Distrito detectado: $_distritoNome',
                                    style: const TextStyle(color: Colors.black54)),
                              ],
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _localizacaoUrlCtrl,
                        decoration: _dec(
                          'Link da Localização (Maps)',
                          hint: 'Cole o link do Google Maps (ex.: https://maps.app.goo.gl/....)',
                        ),
                        keyboardType: TextInputType.url,
                        validator: _validaUrl,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _referenciasCtrl,
                        decoration: _dec(
                          'Referências / pontos ao redor',
                          hint: 'Ex.: Próximo à Escola XYZ; na rua do mercado ABC; caminho por…',
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 24),

                      _salvando
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text('Salvar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: _salvar,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
