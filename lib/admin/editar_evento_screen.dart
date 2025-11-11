// lib/admin/editar_evento_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// importa do seu constants.dart
import 'package:hpcdigital/constantes/constants.dart'
    show gerarListaComValorLegado;

// ajuste o caminho do seu AdminShell se necessário
import 'widgets/admin_shell.dart';

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

  // ---- ESTADO (substitui o "status")
  static const _estados = <String>[
    'Planeado',
    'Realizado',
    'Adiado',
    'Antecipado',
    'Cancelado',
  ];
  String _estadoSelecionado = 'Planeado';

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

      // Lê "estado" com fallback para "status" e, por fim, deduz pela data
      final ts = data['data'];
      if (ts is Timestamp) _dataSelecionada = ts.toDate();
      if (ts is DateTime) _dataSelecionada = ts;

      String rawEstado = (data['estado'] ?? '').toString().trim();
      if (rawEstado.isEmpty) {
        rawEstado = (data['status'] ?? '').toString().trim();
      }
      if (rawEstado.isEmpty) {
        rawEstado = _deduzEstadoPelaData(_dataSelecionada);
      }
      _estadoSelecionado = _labelEstadoNormalizado(rawEstado);
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

  String _deduzEstadoPelaData(DateTime? d) {
    if (d == null) return 'Planeado';
    final hoje = DateTime.now();
    final h = DateTime(hoje.year, hoje.month, hoje.day);
    final dd = DateTime(d.year, d.month, d.day);
    return dd.isBefore(h) ? 'Realizado' : 'Planeado';
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
      // Compat: gravamos ambos os campos "estado" (novo) e "status" (legado)
      await widget.ref.update({
        'nome': _nomeController.text.trim(),
        'descricao': _descricaoController.text.trim(),
        'classe': _classeSelecionada,
        'estado': _estadoSelecionado,
        'status': _estadoSelecionado, // compat p/ telas antigas
        'data': Timestamp.fromDate(_dataSelecionada!),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento atualizado com sucesso!')),
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

  Future<void> _apagar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Apagar evento'),
        content: const Text('Tem certeza que deseja apagar este evento?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style:
            ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
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

  InputDecoration _dec(String label) => const InputDecoration(
    labelText: '',
  ).copyWith(
    labelText: label,
    border: const OutlineInputBorder(),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.deepOrange, width: 2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final classes = gerarListaComValorLegado(_classeSelecionada);

    return AdminShell(
      title: 'Editar Evento',
      currentIndex: 3,
      actions: [
        IconButton(
          tooltip: 'Apagar',
          onPressed: _salvando ? null : _apagar,
          icon: const Icon(Icons.delete_outline, color: Colors.white),
        ),
      ],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _nomeController,
                    decoration: _dec('Nome do Evento'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Informe o nome'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descricaoController,
                    decoration: _dec('Descrição'),
                    minLines: 3,
                    maxLines: 6,
                    validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Informe a descrição'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: classes.contains(_classeSelecionada)
                        ? _classeSelecionada
                        : null,
                    decoration: _dec('Classe / Público-alvo'),
                    isExpanded: true,
                    items: classes
                        .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _classeSelecionada = v),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Selecione a classe'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // ===== Dropdown de ESTADO com ícone e cor =====
                  DropdownButtonFormField<String>(
                    value: _estadoSelecionado,
                    decoration: _dec('Estado do evento'),
                    isExpanded: true,
                    items: _estados
                        .map(
                          (e) => DropdownMenuItem<String>(
                        value: e,
                        child: Row(
                          children: [
                            Icon(
                              _iconDoEstado(e),
                              color: _corDoEstado(e),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              e,
                              style: TextStyle(
                                color: _corDoEstado(e),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .toList(),
                    onChanged: (v) => setState(() {
                      _estadoSelecionado =
                          _labelEstadoNormalizado(v ?? 'Planeado');
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Linha com texto + botão (botão com tamanho finito)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _dataSelecionada == null
                                ? 'Sem data selecionada'
                                : 'Data: ${_dateFmt.format(_dataSelecionada!)}',
                            style: const TextStyle(fontSize: 16),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: _selecionarData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              minimumSize: const Size(140, 40),
                              tapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Selecionar Data'),
                          ),
                        ),
                      ],
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
                      minimumSize:
                      const Size(double.infinity, 50),
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

  // ---------- helpers de ESTADO ----------
  String _labelEstadoNormalizado(String raw) {
    final e = raw.trim().toLowerCase();
    switch (e) {
      case 'planeado':
      case 'planejado':
      case 'agendado':
        return 'Planeado';
      case 'realizado':
      case 'concluído':
      case 'concluido':
        return 'Realizado';
      case 'adiado':
        return 'Adiado';
      case 'antecipado':
        return 'Antecipado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return 'Planeado';
    }
  }

  Color _corDoEstado(String raw) {
    final e = raw.trim().toLowerCase();
    switch (e) {
      case 'planeado':
      case 'planejado':
      case 'agendado':
        return Colors.blueGrey;
      case 'realizado':
      case 'concluído':
      case 'concluido':
        return Colors.green;
      case 'adiado':
        return Colors.orange;
      case 'antecipado':
        return Colors.teal;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.deepPurple;
    }
  }

  IconData _iconDoEstado(String raw) {
    final e = raw.trim().toLowerCase();
    switch (e) {
      case 'planeado':
      case 'planejado':
      case 'agendado':
        return Icons.calendar_today_outlined;
      case 'realizado':
      case 'concluído':
      case 'concluido':
        return Icons.check_circle_outline;
      case 'adiado':
        return Icons.schedule_outlined;
      case 'antecipado':
        return Icons.arrow_upward_outlined;
      case 'cancelado':
        return Icons.cancel_outlined;
      default:
        return Icons.event;
    }
  }
}
