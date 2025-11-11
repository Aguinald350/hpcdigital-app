import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

// telas usadas no menu do admin
import '../screens/LoginScreen.dart';
import 'AdminPanelScreen.dart';
import 'AdminVerHinosScreen.dart';
import 'CadastrarHinoScreen.dart';
import 'CadastrarEventoScreen.dart';
import 'EventosScreenAdmin.dart' show EventosScreenAdmin; // auto-ref
import 'MinhaIgrejaScreen.dart';
import 'ver_igrejas_admin_screen.dart';
import 'CadastrarInformacaoScreen.dart';
import 'VerInformacoesAdminScreen.dart';
import 'CadastrarOracaoScreen.dart';
import 'users/admin_user_list_screen.dart';
import 'users/admin_requisicoes_screen.dart';

import 'editar_evento_screen.dart';

class EventosScreenAdmin extends StatefulWidget {
  const EventosScreenAdmin({super.key});
  @override
  State<EventosScreenAdmin> createState() => _EventosScreenAdminState();
}

class _EventosScreenAdminState extends State<EventosScreenAdmin> {
  final dateFormat = DateFormat('dd/MM/yyyy');

  // mantenho as categorias que você já usava nesta tela
  static const _categorias = <String>[
    'Todos',
    'criancas',
    'JIMUA',
    'OJA',
    'Org.Mulheres',
    'Org.Homens',
  ];

  DateTime _focusedDay =
  DateTime(DateTime.now().year, DateTime.now().month, 1);

  @override
  Widget build(BuildContext context) {
    return _AdminShell(
      currentIndex: 3,
      title: 'Eventos',
      actions: [
        FilledButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CadastrarEventoScreen()),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Novo evento'),
          style: FilledButton.styleFrom(backgroundColor: Colors.deepOrange),
        ),
      ],
      body: DefaultTabController(
        length: _categorias.length,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    height: 44,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TabBar(
                      isScrollable: true,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black12,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      labelColor: Colors.deepOrange,
                      unselectedLabelColor: Colors.deepOrange.shade700,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                      unselectedLabelStyle:
                      const TextStyle(fontWeight: FontWeight.w500),
                      tabs: _categorias.map((c) => Tab(text: c)).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TabBarView(
                      children: _categorias.map((cat) {
                        return _CategoriaComCalendarioAdmin(
                          categoria: cat,
                          focusedMonth: _focusedDay,
                          onMonthChanged: (newMonth) {
                            setState(() => _focusedDay = newMonth);
                          },
                          dateFormat: dateFormat,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoriaComCalendarioAdmin extends StatefulWidget {
  final String categoria;
  final DateTime focusedMonth;
  final ValueChanged<DateTime> onMonthChanged;
  final DateFormat dateFormat;

  const _CategoriaComCalendarioAdmin({
    required this.categoria,
    required this.focusedMonth,
    required this.onMonthChanged,
    required this.dateFormat,
  });

  @override
  State<_CategoriaComCalendarioAdmin> createState() =>
      _CategoriaComCalendarioAdminState();
}

class _CategoriaComCalendarioAdminState
    extends State<_CategoriaComCalendarioAdmin> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay =
        DateTime(widget.focusedMonth.year, widget.focusedMonth.month, 1);
  }

  @override
  void didUpdateWidget(covariant _CategoriaComCalendarioAdmin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedMonth.year != widget.focusedMonth.year ||
        oldWidget.focusedMonth.month != widget.focusedMonth.month) {
      setState(() {
        _focusedDay =
            DateTime(widget.focusedMonth.year, widget.focusedMonth.month, 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    final query = FirebaseFirestore.instance
        .collection('eventos')
        .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDay))
        .where('data', isLessThanOrEqualTo: Timestamp.fromDate(lastDay))
        .orderBy('data', descending: false);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return _msgInfo('Erro ao carregar "${widget.categoria}".');
        }

        List<QueryDocumentSnapshot> docs = (snap.data?.docs ?? []);

        if (widget.categoria != 'Todos') {
          docs = docs.where((d) {
            final m = d.data() as Map<String, dynamic>? ?? {};
            return (m['classe'] ?? '') == widget.categoria;
          }).toList();
        }

        final Map<DateTime, List<QueryDocumentSnapshot>> eventosPorDia = {};
        for (final d in docs) {
          final dataCampo = (d['data'] as Timestamp?)?.toDate();
          if (dataCampo == null) continue;
          final dia = DateTime(dataCampo.year, dataCampo.month, dataCampo.day);
          eventosPorDia.putIfAbsent(dia, () => []).add(d);
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Material(
                color: Colors.white,
                elevation: 1,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TableCalendar(
                    locale: 'pt_BR',
                    firstDay: DateTime(2000),
                    lastDay: DateTime(2100),
                    focusedDay: _focusedDay,
                    currentDay: DateTime.now(),
                    calendarFormat: CalendarFormat.month,
                    headerStyle: const HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                    ),
                    availableGestures: AvailableGestures.horizontalSwipe,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    onPageChanged: (newFocused) {
                      setState(() {
                        _focusedDay =
                            DateTime(newFocused.year, newFocused.month, 1);
                        _selectedDay = null;
                      });
                      widget.onMonthChanged(_focusedDay);
                    },
                    selectedDayPredicate: (day) =>
                    _selectedDay != null &&
                        day.year == _selectedDay!.year &&
                        day.month == _selectedDay!.month &&
                        day.day == _selectedDay!.day,
                    onDaySelected: (selected, focused) {
                      setState(() {
                        _selectedDay = selected;
                        _focusedDay =
                            DateTime(focused.year, focused.month, 1);
                      });
                    },
                    eventLoader: (day) {
                      final key = DateTime(day.year, day.month, day.day);
                      return eventosPorDia[key] ?? const [];
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.deepOrange.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Colors.deepOrange,
                        shape: BoxShape.circle,
                      ),
                      markersAlignment: Alignment.bottomCenter,
                      markerDecoration: const BoxDecoration(
                        color: Colors.deepOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Text(
                    DateFormat('MMMM yyyy', 'pt_BR').format(_focusedDay),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${docs.length} evento(s)',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Expanded(
              child: docs.isEmpty
                  ? _msgInfo('Sem eventos neste mês.')
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final doc = docs[i];
                  final map =
                      doc.data() as Map<String, dynamic>? ?? {};
                  final nome =
                  (map['nome'] ?? 'Sem nome').toString();
                  final descricao =
                  (map['descricao'] ?? '').toString();
                  final ts = map['data'] as Timestamp?;
                  final DateTime? data = ts?.toDate();
                  final classe = (map['classe'] ?? '').toString();

                  // NOVO: Ler "estado" (com fallback)
                  final estado = _resolveEstado(map, data);

                  if (_selectedDay != null && data != null) {
                    final sameDay = data.year == _selectedDay!.year &&
                        data.month == _selectedDay!.month &&
                        data.day == _selectedDay!.day;
                    if (!sameDay) {
                      return const SizedBox.shrink();
                    }
                  }

                  final categoriaVisivel = widget.categoria == 'Todos'
                      ? (classe.isEmpty ? '—' : classe)
                      : widget.categoria;

                  return _EventoCardAdmin(
                    doc: doc,
                    titulo: nome,
                    data: data,
                    estado: estado,
                    dateFormat: widget.dateFormat,
                    descricao: descricao,
                    categoria: categoriaVisivel,
                    onEdit: () async {
                      final ref = doc.reference
                          .withConverter<Map<String, dynamic>>(
                        fromFirestore: (snapshot, _) =>
                        snapshot.data() ?? {},
                        toFirestore: (data, _) => data,
                      );
                      final updated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditarEventoScreen(ref: ref),
                        ),
                      );
                      if (updated == true && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Evento atualizado.')),
                        );
                      }
                    },
                    onDelete: () => _confirmDelete(doc),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // resolve "estado" com compatibilidade
  String _resolveEstado(Map<String, dynamic> map, DateTime? data) {
    String estado = (map['estado'] ?? '').toString().trim();
    if (estado.isNotEmpty) return estado;

    // fallback p/ coleções antigas: "status"
    estado = (map['status'] ?? '').toString().trim();
    if (estado.isNotEmpty) return estado;

    // fallback final: deduz pela data
    if (data == null) return 'Planeado';
    final hoje = DateTime.now();
    final hojeSemHora = DateTime(hoje.year, hoje.month, hoje.day);
    final dataSemHora = DateTime(data.year, data.month, data.day);
    return dataSemHora.isBefore(hojeSemHora) ? 'Realizado' : 'Planeado';
  }

  Widget _msgInfo(String text) => Center(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style:
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    ),
  );

  Future<void> _confirmDelete(QueryDocumentSnapshot doc) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Apagar evento'),
        content: const Text(
            'Tem certeza que deseja apagar este evento? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await doc.reference.delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Evento apagado.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao apagar: $e')),
          );
        }
      }
    }
  }
}

class _EventoCardAdmin extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final String titulo;
  final String descricao;
  final DateTime? data;
  final String estado;
  final String categoria;
  final DateFormat dateFormat;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EventoCardAdmin({
    required this.doc,
    required this.titulo,
    required this.descricao,
    required this.data,
    required this.estado,
    required this.categoria,
    required this.dateFormat,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dataStr = data != null ? dateFormat.format(data!) : 'Sem data';

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFFE8D6),
          child: Icon(Icons.event, color: Colors.deepOrange),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          categoria.isEmpty ? dataStr : '$dataStr  •  $categoria',
          maxLines: 2,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _EstadoChip(estado: estado),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              tooltip: 'Ações',
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.deepOrange),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Text('Apagar'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _mostrarDetalhes(context),
      ),
    );
  }

  void _mostrarDetalhes(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (categoria.isNotEmpty) Text('Público-alvo: $categoria'),
            const SizedBox(height: 8),
            if (data != null) Text('Data: ${dateFormat.format(data!)}'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Estado: '),
                const SizedBox(width: 6),
                _EstadoChip(estado: estado),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Descrição:'),
            Text(descricao.isEmpty ? 'Sem descrição' : descricao),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

class _EstadoChip extends StatelessWidget {
  final String estado;
  const _EstadoChip({required this.estado});

  @override
  Widget build(BuildContext context) {
    final label = _estadoLabel(estado);
    final color = _estadoColor(estado);
    final icon = _estadoIcon(estado);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // normaliza e traduz label final (caso venha "status" antigo ou lowercase)
  String _estadoLabel(String raw) {
    final e = raw.trim().toLowerCase();
    switch (e) {
      case 'planeado':
      case 'planejado':
      case 'agendado':
        return 'Planeado';
      case 'realizado':
      case 'concluído':
      case 'concluido':
        return 'Realizado';
      case 'adiado':
        return 'Adiado';
      case 'antecipado':
        return 'Antecipado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return raw.isEmpty ? 'Planeado' : raw;
    }
  }

  Color _estadoColor(String raw) {
    final e = raw.trim().toLowerCase();
    switch (e) {
      case 'planeado':
      case 'planejado':
      case 'agendado':
        return Colors.blueGrey;
      case 'realizado':
      case 'concluído':
      case 'concluido':
        return Colors.green;
      case 'adiado':
        return Colors.orange;
      case 'antecipado':
        return Colors.teal;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.deepPurple; // fallback discreto
    }
  }

  IconData _estadoIcon(String raw) {
    final e = raw.trim().toLowerCase();
    switch (e) {
      case 'planeado':
      case 'planejado':
      case 'agendado':
        return Icons.calendar_today_outlined;
      case 'realizado':
      case 'concluído':
      case 'concluido':
        return Icons.check_circle_outline;
      case 'adiado':
        return Icons.schedule_outlined;
      case 'antecipado':
        return Icons.arrow_upward_outlined;
      case 'cancelado':
        return Icons.cancel_outlined;
      default:
        return Icons.event;
    }
  }
}

// ============== SHELL DO ADMIN (mantido) ==============
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
          .map((m) =>
          NavigationRailDestination(icon: Icon(m.icon), label: Text(m.label)))
          .toList(),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      drawer:
      showRail ? null : Drawer(child: _DrawerMenu(currentIndex: currentIndex)),
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
                        const SizedBox(width: 8),
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CadastrarEventoScreen()),
        );
        break;
      case _RouteTarget.eventoVer:
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
          leading: Icon(
            m.icon,
            color: i == currentIndex ? Colors.deepOrange : Colors.black54,
          ),
          title: Text(m.label),
          selected: i == currentIndex,
          onTap: () {
            Navigator.pop(context);
            _AdminShell(body: const SizedBox(), title: '')
                ._onTapItem(context, i);
          },
        );
      },
    );
  }
}

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
