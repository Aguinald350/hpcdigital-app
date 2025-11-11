// lib/admin/admin_requisicoes_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// 🔧 ajuste o import conforme o caminho do seu shell
import '../widgets/admin_shell.dart';

/// Tela que mostra os usuários que requisitaram ativação
class AdminRequisicoesScreen extends StatelessWidget {
  const AdminRequisicoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AdminShell(
      title: 'Requisições de Ativação',
      currentIndex: 8, // ✅ ajuste conforme o índice do menu lateral
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('usuarios')
                  .where('requisitouAtivacao', isEqualTo: true)
                  .orderBy('nome')
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snap.hasData || snap.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhuma requisição de ativação encontrada.',
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  );
                }

                final docs = snap.data!.docs;

                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  elevation: 1,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final m = docs[i].data() as Map<String, dynamic>? ?? {};
                      final nome = (m['nome'] ?? 'Sem nome').toString();
                      final email = (m['email'] ?? '—').toString();
                      final uid = docs[i].id;

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0.5,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepOrange.shade100,
                            child: const Icon(Icons.person, color: Colors.deepOrange),
                          ),
                          title: Text(
                            nome,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                          subtitle: Text(
                            email,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black54),
                          ),
                          trailing: SizedBox(
                            width: 180,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Marcar atendido'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(160, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Confirmar ação'),
                                    content: Text(
                                        'Deseja marcar a requisição de $nome como atendida?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green),
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Confirmar'),
                                      ),
                                    ],
                                  ),
                                );

                                if (ok == true) {
                                  await FirebaseFirestore.instance
                                      .collection('usuarios')
                                      .doc(uid)
                                      .update({'requisitouAtivacao': false});

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: cs.primary,
                                        content: Text(
                                            'Requisição de $nome marcada como atendida.'),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
