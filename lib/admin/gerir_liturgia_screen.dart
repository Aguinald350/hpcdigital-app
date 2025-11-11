import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GerirLiturgiaScreen extends StatefulWidget {
  const GerirLiturgiaScreen({super.key});

  @override
  State<GerirLiturgiaScreen> createState() => _GerirLiturgiaScreenState();
}

class _GerirLiturgiaScreenState extends State<GerirLiturgiaScreen> {
  // ----- Form / estado -----
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  String? _editingDocId;

  // ----- Controladores -----
  final _seasonNameCtrl = TextEditingController(); // ex.: "Pentecostes"
  final _colorNameCtrl = TextEditingController(); // ex.: "Vermelho"
  final _titleCtrl = TextEditingController();
  final _subtitleCtrl = TextEditingController();
  final _hymnCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Leituras (chips)
  final _readingInputCtrl = TextEditingController();
  final List<String> _readings = [];

  // Sugestões
  static const _seasonSuggestions = <String>[
    'Advento', 'Natal', 'Epifania', 'Quaresma', 'Semana Santa',
    'Páscoa', 'Ascensão', 'Pentecostes', 'Trindade', 'Tempo Comum',
  ];
  static const _colorSuggestions = <String>[
    'Roxo', 'Branco', 'Vermelho', 'Verde', 'Dourado', 'Preto',
  ];

  // Helpers
  String get _docId => DateFormat('yyyyMMdd').format(_selectedDate);

  String get _dateLabel =>
      DateFormat("EEEE, d 'de' MMMM 'de' y", 'pt_BR').format(_selectedDate);

  String _slug(String v) {
    final lower = v.toLowerCase();
    final noAccents = lower
        .replaceAll(RegExp(r'[áàâã]'), 'a')
        .replaceAll(RegExp(r'[éê]'), 'e')
        .replaceAll(RegExp(r'[í]'), 'i')
        .replaceAll(RegExp(r'[óôõ]'), 'o')
        .replaceAll(RegExp(r'[ú]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c');
    return noAccents
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2100, 12, 31),
      helpText: 'Escolha o dia',
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        // Evita "Null check operator used on a null value"
        if (child == null) return const SizedBox.shrink();
        final cs = Theme
            .of(context)
            .colorScheme;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme
                .of(context)
                .colorScheme
                .copyWith(
              primary: cs.primary,
              onPrimary: cs.onPrimary,
            ),
          ),
          child: child,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _addReading() {
    final txt = _readingInputCtrl.text.trim();
    if (txt.isEmpty) return;
    setState(() {
      _readings.add(txt);
      _readingInputCtrl.clear();
    });
  }

  void _removeReading(int i) {
    setState(() => _readings.removeAt(i));
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final seasonName = _seasonNameCtrl.text.trim();
    final colorName = _colorNameCtrl.text.trim();

    final payload = <String, dynamic>{
      'seasonKey': _slug(seasonName),
      'seasonName': seasonName,
      'colorKey': _slug(colorName),
      'colorName': colorName,
      'title': _titleCtrl.text.trim(),
      'subtitle': _subtitleCtrl.text.trim(),
      'readings': List<String>.from(_readings),
      'hymnSuggestion': _hymnCtrl.text.trim(),
      'notes': _notesCtrl.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('liturgia_dias')
        .doc(_docId)
        .set(payload, SetOptions(merge: true));

    setState(() => _editingDocId = null);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro salvo com sucesso!')),
      );
    }
    _limparForm();
  }

  void _limparForm() {
    _seasonNameCtrl.clear();
    _colorNameCtrl.clear();
    _titleCtrl.clear();
    _subtitleCtrl.clear();
    _hymnCtrl.clear();
    _notesCtrl.clear();
    _readingInputCtrl.clear();
    _readings.clear();
  }

  Future<void> _carregarParaEdicao(DocumentSnapshot d) async {
    final data = (d.data() as Map<String, dynamic>?) ?? {};
    setState(() {
      _editingDocId = d.id;

      // Se o id não for yyyyMMdd válido, cai no DateTime.now()
      DateTime guess = DateTime.now();
      if (RegExp(r'^\d{8}$').hasMatch(d.id)) {
        // yyyyMMdd + "000000" só para o parser aceitar hhmmss
        guess = DateTime.tryParse('${d.id}000000') ?? DateTime.now();
      }
      _selectedDate = guess;

      _seasonNameCtrl.text = (data['seasonName'] ?? '').toString();
      _colorNameCtrl.text = (data['colorName'] ?? '').toString();
      _titleCtrl.text = (data['title'] ?? '').toString();
      _subtitleCtrl.text = (data['subtitle'] ?? '').toString();
      _hymnCtrl.text = (data['hymnSuggestion'] ?? '').toString();
      _notesCtrl.text = (data['notes'] ?? '').toString();

      _readings
        ..clear()
        ..addAll(((data['readings'] ?? []) as List).map((e) => e.toString()));
    });
  }

  Future<void> _excluir(DocumentReference ref) async {
    await ref.delete();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Dia removido')));
    if (_editingDocId == ref.id) {
      setState(() => _editingDocId = null);
      _limparForm();
    }
  }

  @override
  void dispose() {
    _seasonNameCtrl.dispose();
    _colorNameCtrl.dispose();
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _hymnCtrl.dispose();
    _notesCtrl.dispose();
    _readingInputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme
        .of(context)
        .colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário Litúrgico — Administração'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _editingDocId = null;
            _selectedDate = DateTime.now();
          });
          _limparForm();
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo dia'),
      ),
      body: Column(
        children: [
          // ----------- PARTE SUPERIOR (FORMULÁRIO) -----------
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: cs.secondaryContainer,
                              child: Icon(Icons.calendar_month,
                                  color: cs.onSecondaryContainer),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_dateLabel,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700)),
                                  Text('ID: $_docId',
                                      style:
                                      TextStyle(color: cs.onSurfaceVariant)),
                                ],
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _pickDate,
                              icon: const Icon(Icons.edit_calendar),
                              label: const Text('Escolher data'),
                            ),
                          ],
                        ),
                        const Divider(),

                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Estação litúrgica',
                          ),
                          value: _seasonNameCtrl.text.isEmpty
                              ? null
                              : _seasonNameCtrl.text,
                          items: _seasonSuggestions
                              .map((s) =>
                              DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) {
                            _seasonNameCtrl.text = v ?? '';
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _seasonNameCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Estação (personalizar)'),
                          validator: (v) =>
                          (v == null || v
                              .trim()
                              .isEmpty)
                              ? 'Informe a estação litúrgica'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          decoration:
                          const InputDecoration(labelText: 'Cor litúrgica'),
                          value: _colorNameCtrl.text.isEmpty
                              ? null
                              : _colorNameCtrl.text,
                          items: _colorSuggestions
                              .map((s) =>
                              DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) {
                            _colorNameCtrl.text = v ?? '';
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _colorNameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Cor litúrgica (personalizar)',
                          ),
                          validator: (v) =>
                          (v == null || v
                              .trim()
                              .isEmpty)
                              ? 'Informe a cor litúrgica'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _titleCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Título do dia',
                          ),
                          validator: (v) =>
                          (v == null || v
                              .trim()
                              .isEmpty)
                              ? 'Informe o título'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _subtitleCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Subtítulo (opcional)',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Leituras bíblicas',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: cs.primary),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _readingInputCtrl,
                                decoration: const InputDecoration(
                                  hintText: 'Ex.: At 2:1-21',
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (_) => _addReading(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _addReading,
                              icon: const Icon(Icons.add),
                              label: const Text('Adicionar'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (int i = 0; i < _readings.length; i++)
                              Chip(
                                label: Text(_readings[i]),
                                backgroundColor: cs.secondaryContainer,
                                labelStyle:
                                TextStyle(color: cs.onSecondaryContainer),
                                deleteIcon: const Icon(Icons.close),
                                onDeleted: () => _removeReading(i),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _hymnCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Sugestão de hino',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _notesCtrl,
                          decoration: const InputDecoration(labelText: 'Notas'),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _salvar,
                            icon: const Icon(Icons.save),
                            label: const Text('Salvar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ----------- PARTE INFERIOR (LISTA) -----------
          Container(
            color: Theme
                .of(context)
                .colorScheme
                .surface,
            height: 280,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.list_alt, color: cs.primary),
                  title: const Text('Dias cadastrados'),
                  trailing: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => setState(() {}),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('liturgia_dias')
                        .orderBy('updatedAt', descending: true)
                        .limit(50)
                        .snapshots(),
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return Center(child: Text('Erro: ${snap.error}'));
                      }
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      final docs = snap.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return const Center(
                            child: Text('Nenhum dia cadastrado ainda.'));
                      }
                      return ListView.separated(
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final d = docs[i];
                          final data =
                              (d.data() as Map<String, dynamic>?) ?? {};
                          final season =
                          (data['seasonName'] ?? '').toString();
                          final title = (data['title'] ?? '').toString();
                          return ListTile(
                            title: Text('${d.id} — $season'),
                            subtitle: Text(title),
                            leading: const Icon(Icons.event_note),
                            onTap: () => _carregarParaEdicao(d),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_forever,
                                  color: Colors.redAccent),
                              onPressed: () => _excluir(d.reference),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
