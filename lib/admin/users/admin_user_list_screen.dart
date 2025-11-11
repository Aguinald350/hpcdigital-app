// lib/admin/admin_user_list_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'admin_user_detail_screen.dart';
import 'admin_requisicoes_screen.dart';

// ⬇️ ajuste o import do seu shell, se necessário
import '../widgets/admin_shell.dart';

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _filtro = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AdminShell(
      title: 'Gerir Usuários',
      currentIndex: 8, // ✅ ajuste para o índice correto do seu menu
      actions: [
        // Botão de REQUISIÇÕES na AppBar com contador em tempo real
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('usuarios')
              .where('requisitouAtivacao', isEqualTo: true)
              .snapshots(),
          builder: (context, snap) {
            final qtd = snap.data?.docs.length ?? 0;

            return FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepOrange,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminRequisicoesScreen()),
                );
              },
              icon: const Icon(Icons.flash_on),
              label: Row(
                children: [
                  const Text('Requisições'),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$qtd',
                      style: const TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 🔎 Busca
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _filtro = v.trim().toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome ou email...',
                      prefixIcon: const Icon(Icons.search, color: Colors.deepOrange),
                      filled: true,
                      fillColor: cs.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // Lista
                Expanded(
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('usuarios')
                            .orderBy('nome')
                            .snapshots(),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snap.hasError) {
                            return _msg('Erro ao carregar usuários.');
                          }

                          final docs = snap.data?.docs ?? [];
                          // Filtro no cliente (simples)
                          final filtered = docs.where((d) {
                            final m = (d.data() as Map<String, dynamic>? ?? {});
                            final nome = (m['nome'] ?? '').toString().toLowerCase();
                            final email = (m['email'] ?? '').toString().toLowerCase();
                            if (_filtro.isEmpty) return true;
                            return nome.contains(_filtro) || email.contains(_filtro);
                          }).toList();

                          if (filtered.isEmpty) {
                            return _msg('Nenhum usuário encontrado.');
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, i) {
                              final doc = filtered[i];
                              final m = (doc.data() as Map<String, dynamic>? ?? {});
                              final nome = (m['nome'] ?? 'Sem nome').toString();
                              final email = (m['email'] ?? '—').toString();

                              final status = _statusDoUsuario(m);
                              final requisitou = (m['requisitouAtivacao'] ?? false) == true;

                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  // avatar com iniciais
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.deepOrange.shade100,
                                    child: Text(
                                      (nome.isNotEmpty ? nome[0] : '?').toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.deepOrange,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          nome,
                                          style: const TextStyle(fontWeight: FontWeight.w700),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (requisitou)
                                        const Padding(
                                          padding: EdgeInsets.only(left: 6),
                                          child: Icon(Icons.flash_on,
                                              color: Colors.orange, size: 18),
                                        ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    email,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // ✅ Chip ao invés de Text puro no trailing (evita overflow)
                                  trailing: _StatusChip(status: status),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AdminUserDetailScreen(userDoc: doc),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _msg(String t) => Center(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        t,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
  );

  // ------------ Status helpers ------------
  _UserStatus _statusDoUsuario(Map<String, dynamic> m) {
    final now = DateTime.now();

    DateTime? trialEndsAt;
    final te = m['trialEndsAt'];
    if (te is Timestamp) trialEndsAt = te.toDate();

    DateTime? activeFrom;
    final af = m['activeFrom'];
    if (af is Timestamp) activeFrom = af.toDate();

    DateTime? activeUntil;
    final au = m['activeUntil'];
    if (au is Timestamp) activeUntil = au.toDate();

    // Em Teste?
    if (trialEndsAt != null &&
        now.isBefore(trialEndsAt.add(const Duration(days: 1)))) {
      final diasRest = trialEndsAt
          .difference(DateTime(now.year, now.month, now.day))
          .inDays;
      return _UserStatus('Em teste (${diasRest.clamp(0, 999)}d)', _UserState.trial);
    }

    // Ativo (pago)?
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
}

// --------- Widgets auxiliares ---------
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
      side: BorderSide(color: color.withOpacity(0.4)),
      backgroundColor: color.withOpacity(0.08),
      shape: StadiumBorder(side: BorderSide(color: color.withOpacity(0.3))),
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
