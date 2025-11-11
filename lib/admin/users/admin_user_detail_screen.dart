// lib/admin/admin_user_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// 🔧 ajuste este import se o caminho do seu shell for diferente
import '../widgets/admin_shell.dart';

class AdminUserDetailScreen extends StatefulWidget {
  final QueryDocumentSnapshot userDoc;

  const AdminUserDetailScreen({super.key, required this.userDoc});

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  static const int DEFAULT_TRIAL_DAYS = 15; // pode alterar
  late DocumentReference<Map<String, dynamic>> _ref;

  Map<String, dynamic> _data = {};
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ref = widget.userDoc.reference.withConverter<Map<String, dynamic>>(
      fromFirestore: (snap, _) => snap.data() ?? {},
      toFirestore: (data, _) => data,
    );
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final snap = await _ref.get();
      _data = snap.data() ?? {};
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  DateTime? _tsToDate(dynamic v) => v is Timestamp ? v.toDate() : null;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final nome = (_data['nome'] ?? '—').toString();
    final email = (_data['email'] ?? '—').toString();
    final role = (_data['role'] ?? 'user').toString();

    final trialEndsAt = _tsToDate(_data['trialEndsAt']);
    final activeFrom  = _tsToDate(_data['activeFrom']);
    final activeUntil = _tsToDate(_data['activeUntil']);

    final status = _statusDoUsuario(trialEndsAt, activeFrom, activeUntil);

    return AdminShell(
      title: 'Usuário',
      currentIndex: 8, // ✅ ajuste ao índice correto do seu menu
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Cabeçalho
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.deepOrange.shade100,
                        child: Text(
                          (nome.isNotEmpty ? nome[0] : '?').toUpperCase(),
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nome,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(email, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _StatusChip(status: status), // ✅ evita overflow
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Dados resumidos
              Material(
                elevation: 1,
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _kv('Função', role),
                      _kv('Teste grátis até', trialEndsAt != null ? _fmtDate(trialEndsAt) : '—'),
                      _kv('Ativo de',         activeFrom  != null ? _fmtDate(activeFrom)   : '—'),
                      _kv('Ativo até',        activeUntil != null ? _fmtDate(activeUntil)  : '—'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Ações rápidas
              Text('Ações rápidas',
                  style: TextStyle(fontWeight: FontWeight.w800, color: cs.primary)),
              const SizedBox(height: 8),
              Material(
                elevation: 1,
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _btn('Conceder teste (${DEFAULT_TRIAL_DAYS}d)', _grantTrial),
                      _btn('Ativar agora…', _activateNow),
                      _btn('Desativar agora', _deactivateNow),
                      _btn('Programar período…', _schedule),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Observação
              Text('Observação (opcional)',
                  style: TextStyle(fontWeight: FontWeight.w800, color: cs.primary)),
              const SizedBox(height: 8),
              Material(
                elevation: 1,
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _StatusNoteField(
                    initial: (_data['statusNote'] ?? '').toString(),
                    onSave: (text) => _update({'statusNote': text}),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              if (_saving) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }

  // ---- helpers de UI ----
  Widget _kv(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        SizedBox(
          width: 160,
          child: Text('$k:', style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        Expanded(child: Text(v)),
      ],
    ),
  );

  Widget _btn(String label, VoidCallback onTap) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 160, minHeight: 40),
      child: ElevatedButton(
        onPressed: _saving ? null : onTap,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
        child: Text(label, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  // ---- ações ----
  Future<void> _grantTrial() async {
    final days = await _askDays(context, DEFAULT_TRIAL_DAYS, 'Dias de teste');
    if (days == null) return;
    final trialEnds = DateTime.now().add(Duration(days: days));
    await _update({
      'trialEndsAt': Timestamp.fromDate(trialEnds),
      'activeFrom': null,
      'activeUntil': null,
    });
  }

  Future<void> _activateNow() async {
    final until = await _pickDate(context, label: 'Ativar até');
    if (until == null) return;

    final today = DateTime.now();
    final from = DateTime(today.year, today.month, today.day);
    await _update({
      'activeFrom': Timestamp.fromDate(from),
      'activeUntil': Timestamp.fromDate(DateTime(until.year, until.month, until.day)),
      'trialEndsAt': null,
    });
  }

  Future<void> _deactivateNow() async {
    final ok = await _confirm(context, 'Desativar usuário agora?');
    if (ok != true) return;

    await _update({
      'activeFrom': null,
      'activeUntil': null,
      // se quiser bloquear também trial, setar trialEndsAt para ontem
      // 'trialEndsAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
    });
  }

  Future<void> _schedule() async {
    final from = await _pickDate(context, label: 'Ativar a partir de');
    if (from == null) return;
    final until = await _pickDate(context, label: 'Ativar até', firstDate: from);
    if (until == null) return;

    await _update({
      'activeFrom': Timestamp.fromDate(DateTime(from.year, from.month, from.day)),
      'activeUntil': Timestamp.fromDate(DateTime(until.year, until.month, until.day)),
      'trialEndsAt': null,
    });
  }

  Future<void> _update(Map<String, dynamic> patch) async {
    setState(() => _saving = true);
    try {
      await _ref.update(patch);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados atualizados.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  // ---- status helpers ----
  _UserStatus _statusDoUsuario(DateTime? trialEndsAt, DateTime? activeFrom, DateTime? activeUntil) {
    final now = DateTime.now();

    if (trialEndsAt != null && now.isBefore(trialEndsAt.add(const Duration(days: 1)))) {
      final hoje = DateTime(now.year, now.month, now.day);
      final dias = trialEndsAt.difference(hoje).inDays;
      return _UserStatus('Em teste (${dias.clamp(0, 999)}d)', _UserState.trial);
    }

    if (activeFrom != null && activeUntil != null) {
      final hoje = DateTime(now.year, now.month, now.day);
      final ini = DateTime(activeFrom.year, activeFrom.month, activeFrom.day);
      final fim = DateTime(activeUntil.year, activeUntil.month, activeUntil.day);
      if ((hoje.isAfter(ini) || hoje.isAtSameMomentAs(ini)) &&
          (hoje.isBefore(fim) || hoje.isAtSameMomentAs(fim))) {
        final dias = fim.difference(hoje).inDays;
        return _UserStatus('Ativo (${dias}d)', _UserState.paid);
      }
    }
    return _UserStatus('Inativo', _UserState.inactive);
  }

  // ---- diálogos auxiliares ----
  Future<bool?> _confirm(BuildContext context, String msg) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmação'),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _pickDate(BuildContext context, {String? label, DateTime? firstDate}) async {
    final now = DateTime.now();
    final initial = firstDate ?? now;
    final chosen = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: label,
    );
    return chosen;
  }

  Future<int?> _askDays(BuildContext context, int initial, String label) async {
    final ctrl = TextEditingController(text: initial.toString());
    return showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(label),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Ex.: 15',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            onPressed: () {
              final v = int.tryParse(ctrl.text.trim());
              Navigator.pop(context, v);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// --------- modelos e widgets auxiliares ---------
enum _UserState { trial, paid, inactive }

class _UserStatus {
  final String statusLabel;
  final _UserState state;
  _UserStatus(this.statusLabel, this.state);
}

class _StatusChip extends StatelessWidget {
  final _UserStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status, context);
    return Chip(
      label: Text(
        status.statusLabel,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
      side: BorderSide(color: color.withOpacity(0.35)),
      backgroundColor: color.withOpacity(0.08),
      shape: StadiumBorder(side: BorderSide(color: color.withOpacity(0.25))),
    );
  }

  Color _statusColor(_UserStatus s, BuildContext context) {
    switch (s.state) {
      case _UserState.trial:
        return Colors.orange;
      case _UserState.paid:
        return Colors.green;
      case _UserState.inactive:
      default:
        return Theme.of(context).colorScheme.error;
    }
  }
}

// Campo de observação simples com “Salvar”
class _StatusNoteField extends StatefulWidget {
  final String initial;
  final Future<void> Function(String) onSave; // assíncrono
  const _StatusNoteField({required this.initial, required this.onSave});

  @override
  State<_StatusNoteField> createState() => _StatusNoteFieldState();
}

class _StatusNoteFieldState extends State<_StatusNoteField> {
  late TextEditingController _ctrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _ctrl,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Ex.: comprovante recebido em 12/03',
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: _saving
              ? const SizedBox(height: 36, width: 36, child: CircularProgressIndicator())
              : ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            onPressed: () async {
              setState(() => _saving = true);
              await widget.onSave(_ctrl.text.trim());
              if (mounted) setState(() => _saving = false);
            },
            child: const Text('Salvar observação'),
          ),
        ),
      ],
    );
  }
}
