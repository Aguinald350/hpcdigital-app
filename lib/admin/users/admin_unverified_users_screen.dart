// lib/admin/users/admin_unverified_users_screen.dart
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminUnverifiedUsersScreen extends StatefulWidget {
  const AdminUnverifiedUsersScreen({super.key});

  @override
  State<AdminUnverifiedUsersScreen> createState() => _AdminUnverifiedUsersScreenState();
}

class _AdminUnverifiedUsersScreenState extends State<AdminUnverifiedUsersScreen> {
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _searchCtrl = TextEditingController();
  bool _refreshFlag = false;

  final String _functionsRegion = 'africa-south1';
  String? _cloudFunctionUrl;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _allUsersStream() {
    // Ordena por createdAt (se não existir createdAt, Firestore lança; garante que teus docs tenham createdAt)
    return _fire.collection('usuarios').orderBy('createdAt', descending: true).snapshots();
  }

  bool _matchesSearch(DocumentSnapshot<Map<String, dynamic>> doc, String q) {
    if (q.isEmpty) return true;
    final data = doc.data() ?? {};
    final email = (data['email'] ?? '').toString().toLowerCase();
    final nome = (data['nome'] ?? data['displayName'] ?? '').toString().toLowerCase();
    return email.contains(q) || nome.contains(q);
  }

  void _openDetail(DocumentSnapshot<Map<String, dynamic>> doc) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => UserDetailScreen(userDoc: doc, functionsRegion: _functionsRegion, cloudFunctionUrl: _cloudFunctionUrl),
    )).then((_) {
      setState(() => _refreshFlag = !_refreshFlag);
    });
  }

  @override
  Widget build(BuildContext context) {
    final queryLower = _searchCtrl.text.trim().toLowerCase();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuários (todos)'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState(() => _refreshFlag = !_refreshFlag)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar por e-mail ou nome...'),
                  onSubmitted: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.clear),
                label: const Text('Limpar'),
              ),
            ]),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _allUsersStream(),
              builder: (context, snap) {
                if (snap.hasError) return Center(child: Text('Erro: ${snap.error}'));
                if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                final docs = snap.data?.docs ?? [];
                final filtered = docs.where((d) => _matchesSearch(d, queryLower)).toList();
                if (filtered.isEmpty) return const Center(child: Text('Nenhum usuário encontrado.'));
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final d = filtered[i];
                    final data = d.data() ?? {};
                    final nome = data['nome'] ?? data['displayName'] ?? '<sem nome>';
                    final email = data['email'] ?? '<sem email>';
                    final emailVerified = data['emailVerified'] == true;
                    final adminVerified = data['adminVerified'] == true;
                    return ListTile(
                      onTap: () => _openDetail(d),
                      leading: CircleAvatar(child: Text((nome is String && nome.isNotEmpty) ? nome[0].toUpperCase() : '?')),
                      title: Text(nome),
                      subtitle: Text(email),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          if (emailVerified)
                            const Chip(label: Text('Email ✓'), visualDensity: VisualDensity.compact)
                          else
                            const Chip(label: Text('Email ✗'), visualDensity: VisualDensity.compact),
                          if (adminVerified) const Icon(Icons.verified, color: Colors.green) else const SizedBox.shrink(),
                        ],
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
  }
}

class UserDetailScreen extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>> userDoc;
  final String functionsRegion;
  final String? cloudFunctionUrl;

  const UserDetailScreen({super.key, required this.userDoc, required this.functionsRegion, this.cloudFunctionUrl});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  bool _processing = false;
  late Map<String, dynamic> _data;

  @override
  void initState() {
    super.initState();
    _data = widget.userDoc.data() ?? {};
  }

  Future<void> _refreshDoc() async {
    final re = await widget.userDoc.reference.get();
    if (!mounted) return;
    setState(() => _data = re.data() ?? {});
  }

  Future<void> _requestResend() async {
    await widget.userDoc.reference.set({'reenvioSolicitado': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reenvio solicitado.')));
    await _refreshDoc();
  }

  Future<void> _verifyUser() async {
    // usa uid dentro do doc se existir, senão doc.id
    final uid = _data['uid']?.toString().trim().isNotEmpty == true ? _data['uid'] as String : widget.userDoc.id;
    final email = _data['email'] ?? '<sem email>';
    final emailVerified = _data['emailVerified'] == true;

    // botão sempre aparece, mas não faz nada se já verificado
    if (emailVerified) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário já tem e-mail verificado.')));
      return;
    }

    setState(() => _processing = true);
    try {
      if (widget.cloudFunctionUrl != null) {
        throw Exception('Cloud Function HTTP pública não suportada aqui.');
      } else {
        final functions = FirebaseFunctions.instanceFor(region: widget.functionsRegion);
        final HttpsCallable callable = functions.httpsCallable('adminMarkVerified');
        await callable.call(<String, dynamic>{'uid': uid});
      }

      await _refreshDoc();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verificação aplicada via função.')));
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('permission-denied') || msg.contains('permission denied')) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permissão negada para executar a função.')));
      } else if (msg.contains('unauthenticated') || msg.contains('not authenticated')) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sessão inválida. Faça login novamente.')));
      } else {
        // fallback: marca no Firestore
        await widget.userDoc.reference.set({
          'adminVerified': true,
          'adminVerifiedAt': FieldValue.serverTimestamp(),
          'adminVerifiedBy': FirebaseAuth.instance.currentUser?.uid ?? 'admin-unknown',
        }, SetOptions(merge: true));

        await FirebaseFirestore.instance.collection('admin_actions').add({
          'action': 'mark_email_verified_fallback',
          'uid': uid,
          'email': email,
          'adminUid': FirebaseAuth.instance.currentUser?.uid,
          'timestamp': FieldValue.serverTimestamp(),
          'via': 'client-firestore-fallback',
        });

        await _refreshDoc();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fallback aplicado: marcado como verificado.')));
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nome = _data['nome'] ?? _data['displayName'] ?? '<sem nome>';
    final email = _data['email'] ?? '<sem email>';
    final emailVerified = _data['emailVerified'] == true;
    final adminVerified = _data['adminVerified'] == true;
    final created = (_data['createdAt'] as Timestamp?)?.toDate();

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Usuário')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ListTile(
            leading: CircleAvatar(child: Text((nome is String && nome.isNotEmpty) ? nome[0].toUpperCase() : '?')),
            title: Text(nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            subtitle: Text(email),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Chip(label: Text(emailVerified ? 'Email verificado' : 'Email NÃO verificado')),
            const SizedBox(width: 8),
            if (adminVerified) const Chip(label: Text('Verificado (admin)')),
          ]),
          if (created != null) Padding(padding: const EdgeInsets.only(top: 8.0), child: Text('Criado: ${created.toLocal()}')),
          const SizedBox(height: 24),

          // Ações
          Row(children: [
            ElevatedButton.icon(
              onPressed: _processing ? null : _verifyUser,
              icon: const Icon(Icons.verified),
              label: Text(emailVerified ? 'Já verificado' : 'Verificar usuário'),
              style: ElevatedButton.styleFrom(backgroundColor: emailVerified ? Colors.grey : Colors.green),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(onPressed: _processing ? null : _requestResend, icon: const Icon(Icons.email), label: const Text('Solicitar reenvio')),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                await _refreshDoc();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dados atualizados.')));
              },
              child: const Text('Atualizar'),
            ),
          ]),

          const SizedBox(height: 16),
          if (_processing) const LinearProgressIndicator(),
        ]),
      ),
    );
  }
}
