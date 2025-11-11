import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ===== telas do seu projeto (usadas pelo menu do _AdminShell) =====
import '../screens/LoginScreen.dart';
import 'AdminPanelScreen.dart';
import 'AdminVerHinosScreen.dart';
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

// ===================================================================
//  Cadastrar Hino (integrado ao shell do Admin)
// ===================================================================
class CadastrarHinoScreen extends StatefulWidget {
  final String lingua;

  const CadastrarHinoScreen({super.key, required this.lingua});

  @override
  State<CadastrarHinoScreen> createState() => _CadastrarHinoScreenState();
}

class _CadastrarHinoScreenState extends State<CadastrarHinoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _conteudoController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _escritorController = TextEditingController();

  String? _secaoSelecionada;
  bool _salvando = false;

  List<String> get _secoes {
    switch (widget.lingua) {
      case 'Português':
        return [
          'Louvor a Deus',
          'O Evangelho de Jesus Cristo',
          'O Espírito Santo',
          'A Vida Cristã',
          'Evangelização e Avivamento',
          'Unidade e Comunhão Fraternal',
          'Sacramentos - Casamentos, Ministério',
          'Organizações da Igreja',
          'O Testemunho Vivo dos Cristãos',
          'Advento e Natal',
          'Quaresma e Páscoa',
          'O Dia do Senhor e Ações de Graças',
          'Hinos Matutinos e Vespertinos',
          'O Lar Cristão',
          'Despedidas e Viagens',
          'Funerais',
          'Segunda Vinda de Cristo',
          'A Bíblia',
          'O Ano Novo',
          'Dedicações e Aniversários',
          'Finais',
          'Hinos dos Organismos Leigos',
        ];
      case 'Kikongo':
        return [
          'Kembelela Nzambi — Mwanda Helela (1–10)',
          'N’sangu za Yisu Klisto (11–24)',
          'Zingu kia Nkwikizi (25–37)',
          'N’samu ye Nkubameno (38–42)',
          'Hamosi ye Nkutakani ya Nzolua Nzambi (43)',
          'Mvubilu (44)',
          'Lukazalu (45)',
          'Nlekelo a Mfumu (46–48)',
          'Kimbangí kia Moyo wa Nkwikizi (49–66)',
          'Matondo (67–71)',
          'Ngiza yo Luwutuku (72–77)',
          'Lufwa lua Yisu (78–84)',
          'Lufuluku (85–87)',
          'Nkanda Nzambi (88)',
          'Mvo wa Mpa (89)',
          'Nkunga mia mene-mene yo masika (90–92)',
          'Nzó ya Nkwikizi (93)',
          'Lukananu (94)',
          'Nzikilu ya Mafwa/Ezulu (95–100)',
          'Ngiza ya Zole ya Klisto (101–103)',
          'Aleke (104–107)',
        ];
      case 'Kimbundu':
        return [
          'Diximanu dia Nzambi (1–16)',
          'O Njimbu ia Mbote ia Mbuludi (17–41)',
          'Nzumbi Ikola-Mukuatekexi (42–45)',
          'O Mueníu ua Ngeleja ni ua Kidistá (46–103)',
          'Itangana ia Ditungula mu Muvu (104–159)',
          'Dizubilu (160–162)',
        ];
      case 'Umbundu':
        return [
          'Esivayo Lefendelo (1–12)',
          'Espiritu Sandu (13–17)',
          'Ucito wa Yesu Kristu (18–23)',
          'Okufa kua Ñala Yesu Kristu (24–28)',
          'Epinduko lia Yesu Kristu (29–33)',
          'Ekongelo lia Yesu Kristu (34–36)',
          'Epata Lietavo lia Kristu (37–40)',
          'Omesa ya Ñala Yesu Kristu (41–46)',
          'Oku Laleka (47–54)',
          'Oku Likutíllia (55–65)',
          'Oku Litumbika (66–72)',
          'Ekololo Lelembekeleo (73–87)',
          'Uvangi Lupange (88–94)',
          'Olopandu (95–102)',
          'Ovisungo Vioñolosi (103–105)',
          'Embímbiliya (106–109)',
          'Ovisungo Viomala (110–113)',
          'Okufa Kukua Kristu (114–119)',
          'Oku Yalula (120–123)',
          'Oku Tumbangiya (124–129)',
        ];
      default:
        return [];
    }
  }

  Future<void> _salvarHino() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    try {
      await FirebaseFirestore.instance.collection('hinos').add({
        'titulo': _tituloController.text.trim(),
        'numero': _numeroController.text.trim(),
        'conteudo': _conteudoController.text.trim(),
        'secao': _secaoSelecionada,
        'lingua': widget.lingua,
        'escritor': _escritorController.text.trim(),
        'dataCriacao': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hino cadastrado com sucesso!')),
      );

      _formKey.currentState!.reset();
      _tituloController.clear();
      _numeroController.clear();
      _conteudoController.clear();
      _escritorController.clear();
      setState(() {
        _secaoSelecionada = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar hino: $e')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AdminShell(
      currentIndex: 1, // mantemos "Hinos" como selecionado
      title: 'Cadastrar Hino (${widget.lingua})',
      actions: [
        FilledButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SelecionarLinguaScreen()),
            );
          },
          icon: const Icon(Icons.swap_horiz),
          label: const Text('Trocar língua'),
          style: FilledButton.styleFrom(backgroundColor: Colors.deepOrange),
        ),
      ],
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Preencha os dados abaixo para adicionar um novo hino em ${widget.lingua}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _tituloController,
                        decoration: _buildInput('Título do Hino'),
                        validator: (value) =>
                        (value == null || value.isEmpty) ? 'Informe o título' : null,
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (_, c) {
                          final twoCols = c.maxWidth >= 560;
                          if (twoCols) {
                            return Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _numeroController,
                                    decoration: _buildInput('Número (opcional)'),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _escritorController,
                                    decoration: _buildInput('Escritor (opcional)'),
                                  ),
                                ),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              TextFormField(
                                controller: _numeroController,
                                decoration: _buildInput('Número (opcional)'),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _escritorController,
                                decoration: _buildInput('Escritor (opcional)'),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _secaoSelecionada,
                        decoration: _buildInput('Seção / Assunto'),
                        isExpanded: true,
                        items: _secoes
                            .map(
                              (secao) => DropdownMenuItem(
                            value: secao,
                            child: Text(
                              secao,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ),
                        )
                            .toList(),
                        onChanged: (value) => setState(() => _secaoSelecionada = value),
                        validator: (value) =>
                        value == null ? 'Selecione uma seção/assunto' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _conteudoController,
                        decoration: _buildInput('Letra do Hino'),
                        maxLines: 10,
                        validator: (value) =>
                        (value == null || value.isEmpty) ? 'Digite a letra do hino' : null,
                      ),
                      const SizedBox(height: 30),
                      _salvando
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _salvarHino,
                          icon: const Icon(Icons.save),
                          label: const Text(
                            'Salvar Hino',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInput(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.deepOrange, width: 2),
      ),
    );
  }
}

// ===================================================================
//  SHELL / LAYOUT PADRÃO DO ADMIN (mesmo usado nas outras telas)
//  - NavigationRail com correção do extended/labelType
//  - Cabeçalho fixo
// ===================================================================

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
    final bool extended = w >= 1200;

    final rail = NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: (i) => _onTapItem(context, i),
      // ⚠️ Regra do NavigationRail:
      // quando extended=true NÃO defina labelType diferente de null/none.
      labelType: extended ? null : NavigationRailLabelType.all,
      extended: extended,
      minExtendedWidth: 220,
      leading: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            const Icon(Icons.admin_panel_settings, color: Colors.deepOrange),
            const SizedBox(width: 8),
            if (extended)
              const Text(
                'HPC Admin',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
          ],
        ),
      ),
      destinations: _menuItems
          .map((m) => NavigationRailDestination(
        icon: Icon(m.icon),
        label: Text(m.label),
      ))
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
                  // Cabeçalho fixo
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
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
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
    final item = _menuItems[i];
    switch (item.route) {
      case _RouteTarget.dashboard:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
        );
        break;
      case _RouteTarget.hinos:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminVerHinosScreen()),
        );
        break;
      case _RouteTarget.eventoCadastrar:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CadastrarEventoScreen()),
        );
        break;
      case _RouteTarget.eventoVer:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EventosScreenAdmin()),
        );
        break;
      case _RouteTarget.minhaIgreja:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MinhaIgrejaScreen()),
        );
        break;
      case _RouteTarget.verIgrejas:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VerIgrejasAdminScreen()),
        );
        break;
      case _RouteTarget.infoCadastrar:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CadastrarInformacaoScreen()),
        );
        break;
      case _RouteTarget.infoVer:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VerInformacoesAdminScreen()),
        );
        break;
      case _RouteTarget.oracaoCadastrar:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CadastrarOracaoScreen()),
        );
        break;
      case _RouteTarget.usuarios:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminUserListScreen()),
        );
        break;
      case _RouteTarget.requisicoes:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminRequisicoesScreen()),
        );
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

// Drawer (mobile)
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
              Text('HPC Admin',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
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

// ===== Menu model / itens =====

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
