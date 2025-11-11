import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ====== SUAS TELAS EXISTENTES ======
import 'package:hpcdigital/admin/users/admin_requisicoes_screen.dart';
import 'package:hpcdigital/admin/users/admin_user_list_screen.dart';
import '../screens/LoginScreen.dart';
import '../utils/popular_oracoes.dart'; // (mantido se você usa em outro lugar)
import 'AdminVerHinosScreen.dart';
import 'CadastrarEventoScreen.dart';
import 'CadastrarInformacaoScreen.dart';
import 'CadastrarNoticiaScreen.dart';
import 'CadastrarOracaoScreen.dart';
import 'EventosScreenAdmin.dart';
import 'MinhaIgrejaScreen.dart';
import 'SelecionarLinguaScreen.dart';
import 'VerInformacoesAdminScreen.dart';
import 'ver_igrejas_admin_screen.dart';

/// Dashboard completo com:
/// - Sidebar fixa no desktop (Drawer no mobile)
/// - AppBar fixa
/// - Cards de estatísticas com animação
/// - Conteúdo central com grade de atalhos (os mesmos do teu painel)
class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  String _adminName = 'Administrador';
  bool _sidebarCollapsed = false;

  // animação de entrada dos cards
  late final AnimationController _fadeIn;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    _adminName = (user?.email ?? 'Administrador').split('@').first;

    _fadeIn = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _fadeIn, curve: Curves.easeOutCubic);
    _fadeIn.forward();
  }

  @override
  void dispose() {
    _fadeIn.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const Loginscreen()),
          (_) => false,
    );
  }

  // ---- Streams de contagens (animação suave com TweenAnimationBuilder) ----
  Stream<int> _count(String collection) {
    return FirebaseFirestore.instance.collection(collection).snapshots().map((s) => s.size);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1000;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.black87,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (!isDesktop)
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              const SizedBox(width: 8),
              const Icon(Icons.dashboard_customize, color: Colors.deepOrange),
              const SizedBox(width: 10),
              const Text(
                'Painel Administrativo',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              CircleAvatar(
                backgroundColor: Colors.deepOrange.shade50,
                child: const Icon(Icons.person, color: Colors.deepOrange),
              ),
              const SizedBox(width: 8),
              Text(
                _adminName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
                label: const Text('Sair', style: TextStyle(color: Colors.redAccent)),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      drawer: isDesktop ? null : _buildDrawer(context),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(context),
          Expanded(
            child: Column(
              children: [
                // Cabeçalho fixo do conteúdo
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFECECEC)),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Visão Geral',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      // botão colapsar sidebar (desktop)
                      if (isDesktop)
                        IconButton(
                          tooltip:
                          _sidebarCollapsed ? 'Expandir menu' : 'Colapsar menu',
                          onPressed: () => setState(() {
                            _sidebarCollapsed = !_sidebarCollapsed;
                          }),
                          icon: Icon(
                            _sidebarCollapsed
                                ? Icons.chevron_right
                                : Icons.chevron_left,
                          ),
                        ),
                    ],
                  ),
                ),

                // Conteúdo rolável
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: FadeTransition(
                          opacity: _fade,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ====== Cartões de estatísticas com animação ======
                              Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  _StatCardStream(
                                    title: 'Usuários',
                                    icon: Icons.people_outline,
                                    color: Colors.blue,
                                    stream: _count('usuarios'),
                                  ),
                                  _StatCardStream(
                                    title: 'Igrejas',
                                    icon: Icons.church_outlined,
                                    color: Colors.purple,
                                    stream: _count('igrejas'),
                                  ),
                                  _StatCardStream(
                                    title: 'Hinos',
                                    icon: Icons.music_note_outlined,
                                    color: Colors.green,
                                    stream: _count('hinos'),
                                  ),
                                  _StatCardStream(
                                    title: 'Requisições',
                                    icon: Icons.flash_on_outlined,
                                    color: Colors.deepOrange,
                                    stream: FirebaseFirestore.instance
                                        .collection('usuarios')
                                        .where('requisitouAtivacao', isEqualTo: true)
                                        .snapshots()
                                        .map((s) => s.size),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // ====== Grade de atalhos (mantém as tuas ações) ======
                              _SectionTitle('Ações Rápidas'),
                              const SizedBox(height: 12),
                              LayoutBuilder(
                                builder: (ctx, c) {
                                  final cols = c.maxWidth >= 1100
                                      ? 4
                                      : c.maxWidth >= 820
                                      ? 3
                                      : 2;
                                  return GridView.count(
                                    crossAxisCount: cols,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 1.25,
                                    children: [
                                      _ActionCard(
                                        icon: Icons.library_music,
                                        title: 'Cadastrar Hino',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                              const SelecionarLinguaScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                      _ActionCard(
                                        icon: Icons.music_note,
                                        title: 'Ver Hinos',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                              const AdminVerHinosScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                      _ActionCard(
                                        icon: Icons.event,
                                        title: 'Cadastrar Evento',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                              const CadastrarEventoScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                      _ActionCard(
                                        icon: Icons.visibility,
                                        title: 'Ver Eventos',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                              const EventosScreenAdmin(),
                                            ),
                                          );
                                        },
                                      ),
                                      _ActionCard(
                                        icon: Icons.church,
                                        title: 'Minha Igreja',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                              const MinhaIgrejaScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                      _ActionCard(
                                        icon: Icons.location_city,
                                        title: 'Ver Igrejas',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                              const VerIgrejasAdminScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                      _ActionCard(
                                        icon: Icons.info_outline,
                                        title: 'Cadastrar Informação',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                              const CadastrarInformacaoScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                      _ActionCard(
                                        icon: Icons.article_outlined,
                                        title: 'Ver Informações',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                              const VerInformacoesAdminScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                      _ActionCard(
                                        icon: Icons.volunteer_activism_outlined,
                                        title: 'Cadastrar Oração',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                              const CadastrarOracaoScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                      _ActionCard(
                                        icon: Icons.supervised_user_circle,
                                        title: 'Gestor de Usuários',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                              const AdminUserListScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                      _ActionCard(
                                        icon: Icons.notifications_active,
                                        title: 'Requisição de Ativação',
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                              const AdminRequisicoesScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                      _ActionCard(
                                        icon: Icons.logout,
                                        title: 'Sair',
                                        onTap: _logout,
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Sidebar / Drawer ----------------
  Widget _buildSidebar(BuildContext context) {
    final width = _sidebarCollapsed ? 72.0 : 240.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: width,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFECECEC))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          if (!_sidebarCollapsed)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Menu',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _SideItem(
                  collapsed: _sidebarCollapsed,
                  icon: Icons.dashboard_outlined,
                  label: 'Visão Geral',
                  onTap: () {},
                ),
                _SideItem(
                  collapsed: _sidebarCollapsed,
                  icon: Icons.people_outline,
                  label: 'Usuários',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminUserListScreen()),
                    );
                  },
                ),
                _SideItem(
                  collapsed: _sidebarCollapsed,
                  icon: Icons.flash_on_outlined,
                  label: 'Requisições',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminRequisicoesScreen()),
                    );
                  },
                ),
                _SideItem(
                  collapsed: _sidebarCollapsed,
                  icon: Icons.music_note_outlined,
                  label: 'Hinos',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminVerHinosScreen()),
                    );
                  },
                ),
                _SideItem(
                  collapsed: _sidebarCollapsed,
                  icon: Icons.event_outlined,
                  label: 'Eventos',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EventosScreenAdmin()),
                    );
                  },
                ),
                _SideItem(
                  collapsed: _sidebarCollapsed,
                  icon: Icons.church_outlined,
                  label: 'Igrejas',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VerIgrejasAdminScreen()),
                    );
                  },
                ),
                _SideItem(
                  collapsed: _sidebarCollapsed,
                  icon: Icons.info_outline,
                  label: 'Informações',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VerInformacoesAdminScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _SideItem(
            collapsed: _sidebarCollapsed,
            icon: Icons.logout,
            label: 'Sair',
            danger: true,
            onTap: _logout,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            const ListTile(
              title: Text('Menu', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Usuários'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminUserListScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.flash_on_outlined),
              title: const Text('Requisições'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminRequisicoesScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.music_note_outlined),
              title: const Text('Hinos'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminVerHinosScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.event_outlined),
              title: const Text('Eventos'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EventosScreenAdmin()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.church_outlined),
              title: const Text('Igrejas'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VerIgrejasAdminScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Informações'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VerInformacoesAdminScreen()),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Sair', style: TextStyle(color: Colors.redAccent)),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== WIDGETS AUXILIARES =====================

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 16,
        color: Colors.black87,
      ),
    );
  }
}

/// Card de ação (atalhos da grade)
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.orange.shade50,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.deepOrange),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Item do menu lateral
class _SideItem extends StatelessWidget {
  final bool collapsed;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  const _SideItem({
    required this.collapsed,
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Icon(icon, color: danger ? Colors.redAccent : Colors.black87),
        if (!collapsed) ...[
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: danger ? Colors.redAccent : Colors.black87,
              ),
            ),
          ),
        ],
      ],
    );

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: EdgeInsets.symmetric(horizontal: collapsed ? 16 : 20),
        alignment: Alignment.centerLeft,
        child: content,
      ),
    );
  }
}

/// Card de estatística com animação de número
class _StatCardStream extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Stream<int> stream;

  const _StatCardStream({
    required this.title,
    required this.icon,
    required this.color,
    required this.stream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snap) {
        final value = (snap.data ?? 0);
        return _StatCard(
          title: title,
          icon: icon,
          color: color,
          value: value,
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int value;

  const _StatCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withOpacity(.12),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.black54)),
                const SizedBox(height: 6),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: value.toDouble()),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => Text(
                    v.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
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
