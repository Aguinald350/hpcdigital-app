// lib/admin/widgets/admin_shell.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// telas usadas no menu
import '../../screens/LoginScreen.dart';
import '../AdminPanelScreen.dart';
import '../AdminVerHinosScreen.dart';
import '../CadastrarHinoScreen.dart';
import '../CadastrarEventoScreen.dart';
import '../EventosScreenAdmin.dart' show EventosScreenAdmin;
import '../MinhaIgrejaScreen.dart';
import '../ver_igrejas_admin_screen.dart';
import '../CadastrarInformacaoScreen.dart';
import '../VerInformacoesAdminScreen.dart';
import '../CadastrarOracaoScreen.dart';
import '../users/admin_user_list_screen.dart';
import '../users/admin_requisicoes_screen.dart';
import '../users/admin_unverified_users_screen.dart'; // opcional: disponível no menu

/// Rotas do menu lateral
enum AdminRouteTarget {
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

class _AdminMenuItem {
  final IconData icon;
  final String label;
  final AdminRouteTarget route;
  const _AdminMenuItem(this.icon, this.label, this.route);
}

/// Itens do menu (ordem fixa)
const adminMenuItems = <_AdminMenuItem>[
  _AdminMenuItem(Icons.dashboard, 'Painel', AdminRouteTarget.dashboard),
  _AdminMenuItem(Icons.music_note, 'Hinos', AdminRouteTarget.hinos),
  _AdminMenuItem(Icons.event, 'Cadastrar Evento', AdminRouteTarget.eventoCadastrar),
  _AdminMenuItem(Icons.visibility, 'Ver Eventos', AdminRouteTarget.eventoVer),
  _AdminMenuItem(Icons.church, 'Minha Igreja', AdminRouteTarget.minhaIgreja),
  _AdminMenuItem(Icons.location_city, 'Ver Igrejas', AdminRouteTarget.verIgrejas),
  _AdminMenuItem(Icons.info_outline, 'Cadastrar Informação', AdminRouteTarget.infoCadastrar),
  _AdminMenuItem(Icons.article_outlined, 'Ver Informações', AdminRouteTarget.infoVer),
  _AdminMenuItem(Icons.volunteer_activism_outlined, 'Cadastrar Oração', AdminRouteTarget.oracaoCadastrar),
  _AdminMenuItem(Icons.supervised_user_circle, 'Gestor de Usuários', AdminRouteTarget.usuarios),
  _AdminMenuItem(Icons.notifications_active, 'Requisições de Ativação', AdminRouteTarget.requisicoes),
  _AdminMenuItem(Icons.logout, 'Sair', AdminRouteTarget.logout),
];

/// Shell padrão do Admin com NavigationRail + header
class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.currentIndex = 0,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final bool showRail = w >= 1000;
    final bool extended = w >= 1200;

    final rail = NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: (i) => _onTapItem(context, i),
      labelType: extended ? null : NavigationRailLabelType.all,
      extended: extended,
      minExtendedWidth: 220,
      leading: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.admin_panel_settings, color: Colors.deepOrange),
            if (extended)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text('HPC Admin', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
      destinations: adminMenuItems
          .map((m) => NavigationRailDestination(icon: Icon(m.icon), label: Text(m.label)))
          .toList(),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      drawer: showRail ? null : Drawer(child: _DrawerMenu(currentIndex: currentIndex, onTap: _onTapItem)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12, offset: Offset(0, 2))],
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
                        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
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
                  // Conteúdo
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
    final item = adminMenuItems[i];
    switch (item.route) {
      case AdminRouteTarget.dashboard:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminPanelScreen()));
        break;
      case AdminRouteTarget.hinos:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminVerHinosScreen()));
        break;
      case AdminRouteTarget.eventoCadastrar:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CadastrarEventoScreen()));
        break;
      case AdminRouteTarget.eventoVer:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const EventosScreenAdmin()));
        break;
      case AdminRouteTarget.minhaIgreja:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MinhaIgrejaScreen()));
        break;
      case AdminRouteTarget.verIgrejas:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const VerIgrejasAdminScreen()));
        break;
      case AdminRouteTarget.infoCadastrar:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CadastrarInformacaoScreen()));
        break;
      case AdminRouteTarget.infoVer:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const VerInformacoesAdminScreen()));
        break;
      case AdminRouteTarget.oracaoCadastrar:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CadastrarOracaoScreen()));
        break;
      case AdminRouteTarget.usuarios:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUserListScreen()));
        break;
      case AdminRouteTarget.requisicoes:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRequisicoesScreen()));
        break;
      case AdminRouteTarget.logout:
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

class _DrawerMenu extends StatelessWidget {
  const _DrawerMenu({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final void Function(BuildContext, int) onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: adminMenuItems.length,
      itemBuilder: (_, i) {
        final m = adminMenuItems[i];
        return ListTile(
          leading: Icon(m.icon, color: i == currentIndex ? Colors.deepOrange : Colors.black54),
          title: Text(m.label),
          selected: i == currentIndex,
          onTap: () {
            Navigator.pop(context);
            onTap(context, i);
          },
        );
      },
    );
  }
}
