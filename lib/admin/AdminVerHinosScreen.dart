import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// telas do seu projeto
import '../screens/LoginScreen.dart';
import 'AdminPanelScreen.dart';
import 'CadastrarEventoScreen.dart';
import 'EventosScreenAdmin.dart';
import 'MinhaIgrejaScreen.dart';
import 'ver_igrejas_admin_screen.dart';
import 'CadastrarInformacaoScreen.dart';
import 'VerInformacoesAdminScreen.dart';
import 'CadastrarOracaoScreen.dart';
import 'users/admin_user_list_screen.dart';
import 'users/admin_requisicoes_screen.dart';
import 'SelecionarLinguaScreen.dart';
import 'editar_hino_screen.dart';

/// Página: Gerenciar Hinos (responsiva para Desktop e Mobile)
class AdminVerHinosScreen extends StatefulWidget {
  const AdminVerHinosScreen({super.key});

  @override
  State<AdminVerHinosScreen> createState() => _AdminVerHinosScreenState();
}

class _AdminVerHinosScreenState extends State<AdminVerHinosScreen> {
  String _filtro = '';
  final TextEditingController _searchController = TextEditingController();

  // ✅ ScrollController para o Grid, evitando avisos do Scrollbar
  final ScrollController _gridController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _gridController.dispose();
    super.dispose();
  }

  Future<void> _confirmarExcluir(DocumentSnapshot hino) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Hino'),
        content: Text('Tem certeza que deseja excluir o hino "${hino['titulo']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('hinos').doc(hino.id).delete();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hino excluído com sucesso')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir hino: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AdminShell(
      currentIndex: 1, // marca "Hinos" como selecionado
      title: 'Gerenciar Hinos',
      actions: [
        FilledButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SelecionarLinguaScreen()),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Cadastrar Hino'),
          style: FilledButton.styleFrom(backgroundColor: Colors.deepOrange),
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔍 Campo de busca
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _filtro = value.trim().toLowerCase()),
              decoration: InputDecoration(
                labelText: 'Buscar por número ou título',
                prefixIcon: const Icon(Icons.search, color: Colors.deepOrange),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepOrange, width: 1.8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Lista / Grade de hinos
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('hinos')
                    .orderBy('numero')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum hino cadastrado.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  }

                  final hinos = snapshot.data!.docs.where((doc) {
                    final titulo = (doc['titulo'] ?? '').toString().toLowerCase();
                    final numero = (doc['numero'] ?? '').toString().toLowerCase();
                    return titulo.contains(_filtro) || numero.contains(_filtro);
                  }).toList();

                  if (hinos.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum resultado para essa busca.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  }

                  final w = MediaQuery.of(context).size.width;
                  final isDesktop = w >= 900;

                  if (isDesktop) {
                    final crossCount = w >= 1400
                        ? 4
                        : (w >= 1100)
                        ? 3
                        : 2;

                    return Scrollbar(
                      controller: _gridController,
                      thumbVisibility: true,
                      child: GridView.builder(
                        controller: _gridController,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.4,
                        ),
                        itemCount: hinos.length,
                        itemBuilder: (_, i) => _buildHinoCard(hinos[i]),
                      ),
                    );
                  } else {
                    // Lista simples no mobile
                    return ListView.separated(
                      itemCount: hinos.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) => _buildHinoTile(hinos[i]),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔸 Card visual (para desktop)
  Widget _buildHinoCard(DocumentSnapshot hino) {
    final numero = hino['numero'] ?? '';
    final titulo = hino['titulo'] ?? '';
    final lingua = hino['lingua'] ?? 'Sem idioma';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.library_music, color: Colors.deepOrange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hino $numero',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            titulo,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            'Idioma: $lingua',
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 10),

          // ✅ Corrigido: sem largura infinita.
          // Usamos Align + Wrap e ainda limitamos a largura de cada botão com ConstrainedBox.
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Editar', overflow: TextOverflow.ellipsis),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      minimumSize: const Size(0, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EditarHinoScreen(hino: hino)),
                      );
                    },
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: TextButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      'Excluir',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(0, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => _confirmarExcluir(hino),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔸 Item de lista simples (para mobile)
  Widget _buildHinoTile(DocumentSnapshot hino) {
    final numero = hino['numero'] ?? '';
    final titulo = hino['titulo'] ?? '';
    return ListTile(
      leading: const Icon(Icons.library_music, color: Colors.deepOrange),
      title: Text('Hino $numero - $titulo'),
      subtitle: Text(hino['lingua'] ?? 'Sem idioma'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditarHinoScreen(hino: hino)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmarExcluir(hino),
          ),
        ],
      ),
    );
  }
}

/// ===============================
/// SHELL/CONTAINER DO ADMIN (MENU + HEADER)
/// ===============================

class _AdminShell extends StatelessWidget {
  const _AdminShell({
    required this.body,
    required this.title,
    this.actions,
    this.currentIndex = 0,
  });

  final Widget body;
  final String title;
  final List<Widget>? actions;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final bool showRail = w >= 1000;

    final rail = NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: (i) => _onTapItem(context, i),
      // Quando extended=true, labelType deve ser null/none
      labelType: w >= 1200 ? null : NavigationRailLabelType.all,
      minExtendedWidth: 220,
      extended: w >= 1200,
      leading: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            const Icon(Icons.admin_panel_settings, color: Colors.deepOrange),
            const SizedBox(width: 8),
            if (w >= 1200)
              const Text('HPC Admin', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
      destinations: _menuItems
          .map((m) => NavigationRailDestination(icon: Icon(m.icon), label: Text(m.label)))
          .toList(),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      drawer: showRail ? null : Drawer(child: _DrawerMenu(currentIndex: currentIndex)),
      body: SafeArea(
        child: Row(
          children: [
            if (showRail) rail,
            Expanded(
              child: Column(
                children: [
                  // Header
                  Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black12,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        if (!showRail)
                          Builder(
                            builder: (ctx) => IconButton(
                              icon: const Icon(Icons.menu),
                              onPressed: () => Scaffold.of(ctx).openDrawer(),
                            ),
                          ),
                        Text(
                          title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        ...?actions,
                        const SizedBox(width: 8),
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.deepOrange,
                          child: Icon(Icons.person, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTapItem(BuildContext context, int i) async {
    final item = _menuItems[i];
    switch (item.route) {
      case _RouteTarget.dashboard:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
        );
        break;
      case _RouteTarget.hinos:
      // já está nesta página
        break;
      case _RouteTarget.eventoCadastrar:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CadastrarEventoScreen()));
        break;
      case _RouteTarget.eventoVer:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const EventosScreenAdmin()));
        break;
      case _RouteTarget.minhaIgreja:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MinhaIgrejaScreen()));
        break;
      case _RouteTarget.verIgrejas:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const VerIgrejasAdminScreen()));
        break;
      case _RouteTarget.infoCadastrar:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CadastrarInformacaoScreen()));
        break;
      case _RouteTarget.infoVer:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const VerInformacoesAdminScreen()));
        break;
      case _RouteTarget.oracaoCadastrar:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CadastrarOracaoScreen()));
        break;
      case _RouteTarget.usuarios:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUserListScreen()));
        break;
      case _RouteTarget.requisicoes:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRequisicoesScreen()));
        break;
      case _RouteTarget.logout:
        await FirebaseAuth.instance.signOut();
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const Loginscreen()),
                (route) => false,
          );
        }
        break;
    }
  }
}

/// Drawer (mobile)
class _DrawerMenu extends StatelessWidget {
  const _DrawerMenu({required this.currentIndex});
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const DrawerHeader(
          child: Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Colors.deepOrange),
              SizedBox(width: 8),
              Text('HPC Admin', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _menuItems.length,
            itemBuilder: (_, i) {
              final m = _menuItems[i];
              final selected = i == currentIndex;
              return ListTile(
                leading: Icon(m.icon, color: selected ? Colors.deepOrange : null),
                title: Text(m.label),
                selected: selected,
                onTap: () {
                  Navigator.pop(context);
                  _AdminShell(body: const SizedBox(), title: '')._onTapItem(context, i);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Model do menu
class _MenuItem {
  final IconData icon;
  final String label;
  final _RouteTarget route;

  const _MenuItem(this.icon, this.label, this.route);
}

enum _RouteTarget {
  dashboard,
  hinos,
  eventoCadastrar,
  eventoVer,
  minhaIgreja,
  verIgrejas,
  infoCadastrar,
  infoVer,
  oracaoCadastrar,
  usuarios,
  requisicoes,
  logout,
}

const _menuItems = <_MenuItem>[
  _MenuItem(Icons.dashboard, 'Painel', _RouteTarget.dashboard),
  _MenuItem(Icons.music_note, 'Hinos', _RouteTarget.hinos),
  _MenuItem(Icons.event, 'Cadastrar Evento', _RouteTarget.eventoCadastrar),
  _MenuItem(Icons.visibility, 'Ver Eventos', _RouteTarget.eventoVer),
  _MenuItem(Icons.church, 'Minha Igreja', _RouteTarget.minhaIgreja),
  _MenuItem(Icons.location_city, 'Ver Igrejas', _RouteTarget.verIgrejas),
  _MenuItem(Icons.info_outline, 'Cadastrar Informação', _RouteTarget.infoCadastrar),
  _MenuItem(Icons.article_outlined, 'Ver Informações', _RouteTarget.infoVer),
  _MenuItem(Icons.volunteer_activism_outlined, 'Cadastrar Oração', _RouteTarget.oracaoCadastrar),
  _MenuItem(Icons.supervised_user_circle, 'Gestor de Usuários', _RouteTarget.usuarios),
  _MenuItem(Icons.notifications_active, 'Requisições de Ativação', _RouteTarget.requisicoes),
  _MenuItem(Icons.logout, 'Sair', _RouteTarget.logout),
];
