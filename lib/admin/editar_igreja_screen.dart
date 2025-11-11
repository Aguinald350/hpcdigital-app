// lib/admin/editar_igreja_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EditarIgrejaScreen extends StatefulWidget {
  final DocumentReference<Map<String, dynamic>> ref;
  const EditarIgrejaScreen({super.key, required this.ref});

  @override
  State<EditarIgrejaScreen> createState() => _EditarIgrejaScreenState();
}

class _EditarIgrejaScreenState extends State<EditarIgrejaScreen> {
  final _formKey = GlobalKey<FormState>();

  // Campos principais
  final _nomeCtrl = TextEditingController();
  final _secretarioNomeCtrl = TextEditingController();
  final _secretarioContatoCtrl = TextEditingController(); // fallback p/ telefone
  final _localizacaoUrlCtrl = TextEditingController();    // fallback p/ localizacao
  final _referenciasCtrl = TextEditingController();

  // Novos: Bispo / Superintendente (editáveis e gravados na igreja como cache)
  final _bispoNomeCtrl = TextEditingController();
  final _superintendenteNomeCtrl = TextEditingController();

  // Pastores
  int _numPastores = 0;
  List<TextEditingController> _pastorNomeCtrls = [];
  List<TextEditingController> _pastorContatoCtrls = []; // fallback p/ telefone

  // Intendência/Distrito
  String? _intendenciaId;
  String? _intendenciaNome;
  String? _distritoId;
  String? _distritoNome;

  bool _loading = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final snap = await widget.ref.get();
      final m = snap.data() ?? {};

      _nomeCtrl.text = (m['nome'] ?? '').toString();

      // Secretário (novo + fallback)
      _secretarioNomeCtrl.text = (m['secretarioNome'] ?? '').toString();
      _secretarioContatoCtrl.text =
          (m['secretarioContato'] ?? m['secretarioTelefone'] ?? '').toString();

      // Localização (novo + fallback)
      _localizacaoUrlCtrl.text =
          (m['localizacaoUrl'] ?? m['localizacao'] ?? '').toString();

      // Referências
      _referenciasCtrl.text = (m['referencias'] ?? '').toString();

      // Intendência/Distrito
      _intendenciaId = (m['intendenciaId'] ?? '').toString().isEmpty ? null : m['intendenciaId'];
      _intendenciaNome = (m['intendenciaNome'] ?? '').toString();
      _distritoId = (m['distritoId'] ?? '').toString();
      _distritoNome = (m['distritoNome'] ?? '').toString();

      // Bispo / Superintendente (se a igreja já tem cache, usa; senão busca do distrito)
      _bispoNomeCtrl.text = (m['bispoNome'] ?? '').toString();
      _superintendenteNomeCtrl.text = (m['superintendenteNome'] ?? '').toString();

      if ((_bispoNomeCtrl.text.isEmpty || _superintendenteNomeCtrl.text.isEmpty) &&
          (_distritoId != null && _distritoId!.isNotEmpty)) {
        // busca dados no distrito para pré-preencher
        try {
          final distSnap = await FirebaseFirestore.instance
              .collection('distritos')
              .doc(_distritoId)
              .get();
          final dm = distSnap.data() as Map<String, dynamic>? ?? {};
          if (_bispoNomeCtrl.text.isEmpty) {
            _bispoNomeCtrl.text = (dm['bispoNome'] ?? '').toString();
          }
          if (_superintendenteNomeCtrl.text.isEmpty) {
            _superintendenteNomeCtrl.text = (dm['superintendenteNome'] ?? '').toString();
          }
        } catch (_) {}
      }

      // Pastores (novo campo contato com fallback telefone)
      final pastores = (m['pastores'] ?? []) as List;
      _numPastores = (m['numPastores'] ?? pastores.length) is int
          ? (m['numPastores'] ?? pastores.length)
          : int.tryParse((m['numPastores'] ?? '${pastores.length}').toString()) ?? pastores.length;

      _pastorNomeCtrls = List.generate(_numPastores, (i) {
        String nome = '';
        if (i < pastores.length) {
          final pMap = (pastores[i] as Map?) ?? {};
          nome = (pMap['nome'] ?? '').toString();
        }
        return TextEditingController(text: nome);
      });

      _pastorContatoCtrls = List.generate(_numPastores, (i) {
        String contato = '';
        if (i < pastores.length) {
          final pMap = (pastores[i] as Map?) ?? {};
          contato = (pMap['contato'] ?? pMap['telefone'] ?? '').toString();
        }
        return TextEditingController(text: contato);
      });
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

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _secretarioNomeCtrl.dispose();
    _secretarioContatoCtrl.dispose();
    _localizacaoUrlCtrl.dispose();
    _referenciasCtrl.dispose();
    _bispoNomeCtrl.dispose();
    _superintendenteNomeCtrl.dispose();
    for (final c in _pastorNomeCtrls) c.dispose();
    for (final c in _pastorContatoCtrls) c.dispose();
    super.dispose();
  }

  void _rebuildPastores(int n) {
    if (n < 0) n = 0;
    setState(() {
      _numPastores = n;
      while (_pastorNomeCtrls.length < n) {
        _pastorNomeCtrls.add(TextEditingController());
      }
      while (_pastorContatoCtrls.length < n) {
        _pastorContatoCtrls.add(TextEditingController());
      }
      if (_pastorNomeCtrls.length > n) {
        _pastorNomeCtrls = _pastorNomeCtrls.sublist(0, n);
      }
      if (_pastorContatoCtrls.length > n) {
        _pastorContatoCtrls = _pastorContatoCtrls.sublist(0, n);
      }
    });
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    try {
      // Pastores: gravar tanto 'contato' (novo) quanto 'telefone' (compat.)
      final pastores = List.generate(_numPastores, (i) {
        final nome = _pastorNomeCtrls[i].text.trim();
        final contato = _pastorContatoCtrls[i].text.trim();
        return {
          'nome': nome,
          'contato': contato,     // novo
          'telefone': contato,    // compat. legado
        };
      });

      final link = _localizacaoUrlCtrl.text.trim();
      final secretarioContato = _secretarioContatoCtrl.text.trim();

      final payload = <String, dynamic>{
        'nome': _nomeCtrl.text.trim(),
        'secretarioNome': _secretarioNomeCtrl.text.trim(),
        'secretarioContato': secretarioContato,  // novo
        'secretarioTelefone': secretarioContato, // compat.
        'localizacaoUrl': link,  // novo
        'localizacao': link,     // compat.
        'referencias': _referenciasCtrl.text.trim(),
        'numPastores': _numPastores,
        'pastores': pastores,

        // cache local p/ listagens (mesmo que o canônico esteja no distrito)
        'bispoNome': _bispoNomeCtrl.text.trim(),
        'superintendenteNome': _superintendenteNomeCtrl.text.trim(),
      };

      // Se mudou intendência, manter consistentes distrito e nomes
      if (_intendenciaId != null && _intendenciaId!.isNotEmpty) {
        payload['intendenciaId'] = _intendenciaId;
        payload['intendenciaNome'] = _intendenciaNome ?? '';
        payload['distritoId'] = _distritoId ?? '';
        payload['distritoNome'] = _distritoNome ?? '';
      }

      await widget.ref.update(payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Igreja atualizada com sucesso!')),
        );
        Navigator.pop(context, true);
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

  Future<void> _selecionarIntendencia() async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.7,
          child: Column(
            children: [
              const SizedBox(height: 8),
              const Text('Selecionar Intendência',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('intendencias')
                      .orderBy('distritoNome')
                      .orderBy('nome')
                      .snapshots(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = (snap.data?.docs ?? []).toList();

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (_, i) {
                        final it = docs[i];
                        final im = (it.data() as Map<String, dynamic>? ?? {});
                        final nome = (im['nome'] ?? '').toString();
                        final dNome = (im['distritoNome'] ?? '').toString();
                        final dId = (im['distritoId'] ?? '').toString();

                        return Card(
                          child: ListTile(
                            title: Text(nome,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: dNome.isEmpty ? null : Text(dNome),
                            onTap: () async {
                              // ao selecionar, definimos ids e nomes
                              setState(() {
                                _intendenciaId = it.id;
                                _intendenciaNome = nome;
                                _distritoId = dId;
                                _distritoNome = dNome;
                              });

                              // tenta preencher Bispo/Super a partir do distrito escolhido
                              try {
                                if (_distritoId != null && _distritoId!.isNotEmpty) {
                                  final distSnap = await FirebaseFirestore.instance
                                      .collection('distritos')
                                      .doc(_distritoId)
                                      .get();
                                  final dm = distSnap.data() as Map<String, dynamic>? ?? {};
                                  final bispo = (dm['bispoNome'] ?? '').toString();
                                  final superint = (dm['superintendenteNome'] ?? '').toString();

                                  if (mounted) {
                                    setState(() {
                                      if (_bispoNomeCtrl.text.trim().isEmpty) {
                                        _bispoNomeCtrl.text = bispo;
                                      }
                                      if (_superintendenteNomeCtrl.text.trim().isEmpty) {
                                        _superintendenteNomeCtrl.text = superint;
                                      }
                                    });
                                  }
                                }
                              } catch (_) {}

                              Navigator.pop(ctx);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _abrirMapa() async {
    final raw = _localizacaoUrlCtrl.text.trim();
    final uri = Uri.tryParse(raw);
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL inválida. Cole um link do Google Maps.')),
      );
      return;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o link.')),
      );
    }
  }

  String? _validaNome(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Informe o nome';
    if (t.length < 3) return 'O nome deve ter pelo menos 3 caracteres';
    return null;
  }

  String? _validaUrl(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return null; // opcional
    final u = Uri.tryParse(t);
    if (u == null || (!u.isScheme('http') && !u.isScheme('https'))) {
      return 'Informe uma URL válida (http/https)';
    }
    return null;
  }

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.deepOrange, width: 2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Igreja'),
        backgroundColor: Colors.deepOrange,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Nome
              TextFormField(
                controller: _nomeCtrl,
                decoration: _dec('Nome da igreja'),
                validator: _validaNome,
              ),
              const SizedBox(height: 16),

              // Intendência (com trailing limitado)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                title: const Text('Intendência'),
                subtitle: Text(
                  (_intendenciaNome ?? '').isEmpty
                      ? 'Não selecionada'
                      : '$_intendenciaNome  •  ${_distritoNome ?? ''}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: SizedBox(
                  width: 140, // ✅ limita a largura do botão
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: _salvando ? null : _selecionarIntendencia,
                    icon: const Icon(Icons.apartment_outlined),
                    label: const Text('Selecionar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Distrito (somente leitura, se houver)
              if ((_distritoNome ?? '').isNotEmpty)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  title: const Text('Distrito'),
                  subtitle: Text(_distritoNome!),
                ),

              const Divider(height: 24),

              // Bispo / Superintendente (editáveis, gravados na igreja como cache)
              Text('Liderança do Distrito (cache nesta igreja)',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.deepOrange)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bispoNomeCtrl,
                decoration: _dec('Bispo (opcional)'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _superintendenteNomeCtrl,
                decoration: _dec('Superintendente (opcional)'),
              ),

              const Divider(height: 24),

              // Número de pastores
              Row(
                children: [
                  const Expanded(
                    child: Text('Número de pastores',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  IconButton(
                    onPressed: _salvando
                        ? null
                        : () => _rebuildPastores(_numPastores - 1),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$_numPastores',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: _salvando
                        ? null
                        : () => _rebuildPastores(_numPastores + 1),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Campos dos pastores
              for (int i = 0; i < _numPastores; i++) ...[
                Text('Pastor ${i + 1}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _pastorNomeCtrls[i],
                  decoration: _dec('Nome do pastor'),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _pastorContatoCtrls[i],
                  decoration: _dec('Contato do pastor (telefone/WhatsApp)'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
              ],

              const Divider(height: 24),

              // Secretário
              Text('Secretário',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.deepOrange)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _secretarioNomeCtrl,
                decoration: _dec('Nome do secretário'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _secretarioContatoCtrl,
                decoration:
                _dec('Contato do secretário (telefone/WhatsApp)'),
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),

              // Localização (apenas link) + Referências
              Text('Localização',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.deepOrange)),
              const SizedBox(height: 8),

              // ⬇️ Fixo com SizedBox no botão (evita overflow em Row)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _localizacaoUrlCtrl,
                      decoration:
                      _dec('Link do Google Maps (colar URL)'),
                      keyboardType: TextInputType.url,
                      validator: _validaUrl,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 120, // ✅ largura fixa
                    height: 40,  // ✅ altura fixa
                    child: ElevatedButton.icon(
                      onPressed: _salvando ? null : _abrirMapa,
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Abrir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _referenciasCtrl,
                decoration:
                _dec('Referências / vizinhança (opcional)'),
                maxLines: 3,
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
}
