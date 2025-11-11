import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// telas usadas no menu do admin
import '../screens/LoginScreen.dart';
import 'AdminPanelScreen.dart';
import 'AdminVerHinosScreen.dart';
import 'CadastrarHinoScreen.dart';
import 'EventosScreenAdmin.dart';
import 'MinhaIgrejaScreen.dart';
import 'ver_igrejas_admin_screen.dart';
import 'CadastrarInformacaoScreen.dart';
import 'VerInformacoesAdminScreen.dart';
import 'CadastrarOracaoScreen.dart';
import 'users/admin_user_list_screen.dart';
import 'users/admin_requisicoes_screen.dart';

class CadastrarEventoScreen extends StatefulWidget {
  const CadastrarEventoScreen({super.key});

  @override
  State<CadastrarEventoScreen> createState() => _CadastrarEventoScreenState();
}

class _CadastrarEventoScreenState extends State<CadastrarEventoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  DateTime? _dataSelecionada;
  String? _classeSelecionada;
  String? _estadoSelecionado;

  bool _salvando = false;

  final List<String> _classes = [
    'Jovens',
    'Jovens Adultos',
    'Mamas',
    'Papas',
    'Crianças',
    'Gerais',
  ];

  final List<String> _estadosEvento = [
    'Planeado',
    'Realizado',
    'Adiado',
    'Antecipado',
    'Cancelado',
  ];

  Future<void> _salvarEvento() async {
    if (_formKey.currentState!.validate() &&
        _dataSelecionada != null &&
        _classeSelecionada != null &&
        _estadoSelecionado != null) {
      setState(() => _salvando = true);

      try {
        await FirebaseFirestore.instance.collection('eventos').add({
          'nome': _nomeController.text.trim(),
          'descricao': _descricaoController.text.trim(),
          'data': Timestamp.fromDate(_dataSelecionada!),
          'classe': _classeSelecionada,
          'estado': _estadoSelecionado,
          'criadoEm': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento cadastrado com sucesso!')),
        );

        _formKey.currentState!.reset();
        _nomeController.clear();
        _descricaoController.clear();
        setState(() {
          _dataSelecionada = null;
          _classeSelecionada = null;
          _estadoSelecionado = null;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar evento: $e')),
          );
        }
      }

      setState(() => _salvando = false);
    } else {
      String msg = 'Preencha todos os campos obrigatórios.';
      if (_dataSelecionada == null) msg = 'Selecione uma data para o evento.';
      else if (_classeSelecionada == null) msg = 'Selecione a classe/público.';
      else if (_estadoSelecionado == null) msg = 'Selecione o estado do evento.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _selecionarData() async {
    final dataEscolhida = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (dataEscolhida != null) {
      setState(() => _dataSelecionada = dataEscolhida);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AdminShell(
      currentIndex: 2,
      title: 'Cadastrar Evento',
      actions: const [],
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
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Text(
                      'Preencha os detalhes do novo evento da igreja.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 24),

                    // Nome
                    TextFormField(
                      controller: _nomeController,
                      decoration: _buildInput('Nome do Evento'),
                      validator: (value) =>
                      value!.isEmpty ? 'Informe o nome' : null,
                    ),
                    const SizedBox(height: 16),

                    // Descrição
                    TextFormField(
                      controller: _descricaoController,
                      decoration: _buildInput('Descrição'),
                      maxLines: 4,
                      validator: (value) =>
                      value!.isEmpty ? 'Informe a descrição' : null,
                    ),
                    const SizedBox(height: 16),

                    // Classe / Público
                    DropdownButtonFormField<String>(
                      value: _classeSelecionada,
                      decoration: _buildInput('Classe / Público-alvo'),
                      items: _classes
                          .map((classe) =>
                          DropdownMenuItem(value: classe, child: Text(classe)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _classeSelecionada = value),
                      validator: (value) =>
                      value == null ? 'Selecione a classe do evento' : null,
                    ),
                    const SizedBox(height: 16),

                    // Estado
                    DropdownButtonFormField<String>(
                      value: _estadoSelecionado,
                      decoration: _buildInput('Estado do Evento'),
                      items: _estadosEvento
                          .map((estado) => DropdownMenuItem(
                        value: estado,
                        child: Row(
                          children: [
                            Icon(
                              _iconForEstado(estado),
                              color: _colorForEstado(estado),
                            ),
                            const SizedBox(width: 8),
                            Text(estado),
                          ],
                        ),
                      ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _estadoSelecionado = value),
                      validator: (value) =>
                      value == null ? 'Selecione o estado do evento' : null,
                    ),
                    const SizedBox(height: 16),

                    // Data
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            _dataSelecionada == null
                                ? 'Nenhuma data selecionada'
                                : 'Data: ${_dataSelecionada!.day.toString().padLeft(2, '0')}/${_dataSelecionada!.month.toString().padLeft(2, '0')}/${_dataSelecionada!.year}',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 160,
                          child: ElevatedButton(
                            onPressed: _selecionarData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Selecionar Data'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _salvando
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                      onPressed: _salvarEvento,
                      icon: const Icon(Icons.save),
                      label: const Text(
                        'Salvar Evento',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding:
                        const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconForEstado(String estado) {
    switch (estado) {
      case 'Planeado':
        return Icons.calendar_today_outlined;
      case 'Realizado':
        return Icons.check_circle_outline;
      case 'Adiado':
        return Icons.schedule_outlined;
      case 'Antecipado':
        return Icons.arrow_upward_outlined;
      case 'Cancelado':
        return Icons.cancel_outlined;
      default:
        return Icons.event;
    }
  }

  Color _colorForEstado(String estado) {
    switch (estado) {
      case 'Planeado':
        return Colors.blueGrey;
      case 'Realizado':
        return Colors.green;
      case 'Adiado':
        return Colors.orange;
      case 'Antecipado':
        return Colors.teal;
      case 'Cancelado':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  InputDecoration _buildInput(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.deepOrange, width: 2),
      ),
    );
  }
}


// =============================
// LAYOUT DO ADMIN (mesmo shell)
// =============================
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
                child: Text(
                  'HPC Admin',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
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
                  Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black12,
                          offset: Offset(0, 2),
                        ),
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
                        Text(title,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        ...?actions,
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.deepOrange,
                          child:
                          Icon(Icons.person, color: Colors.white, size: 18),
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
            context, MaterialPageRoute(builder: (_) => const AdminPanelScreen()));
        break;
      case _RouteTarget.hinos:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const AdminVerHinosScreen()));
        break;
      case _RouteTarget.eventoCadastrar:
      // já aqui
        break;
      case _RouteTarget.eventoVer:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const EventosScreenAdmin()));
        break;
      case _RouteTarget.minhaIgreja:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MinhaIgrejaScreen()));
        break;
      case _RouteTarget.verIgrejas:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const VerIgrejasAdminScreen()));
        break;
      case _RouteTarget.infoCadastrar:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CadastrarInformacaoScreen()));
        break;
      case _RouteTarget.infoVer:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const VerInformacoesAdminScreen()));
        break;
      case _RouteTarget.oracaoCadastrar:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CadastrarOracaoScreen()));
        break;
      case _RouteTarget.usuarios:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AdminUserListScreen()));
        break;
      case _RouteTarget.requisicoes:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AdminRequisicoesScreen()));
        break;
      case _RouteTarget.logout:
        await FirebaseAuth.instance.signOut();
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const Loginscreen()),
                  (route) => false);
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
    return ListView.builder(
      itemCount: _menuItems.length,
      itemBuilder: (_, i) {
        final m = _menuItems[i];
        return ListTile(
          leading: Icon(m.icon,
              color: i == currentIndex ? Colors.deepOrange : Colors.black54),
          title: Text(m.label),
          selected: i == currentIndex,
          onTap: () {
            Navigator.pop(context);
            _AdminShell(body: const SizedBox(), title: '')._onTapItem(context, i);
          },
        );
      },
    );
  }
}

// Itens do menu
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
