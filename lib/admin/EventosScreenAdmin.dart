// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:table_calendar/table_calendar.dart';
//
// class EventosScreenAdmin extends StatefulWidget {
//   const EventosScreenAdmin({super.key});
//
//   @override
//   State<EventosScreenAdmin> createState() => _EventosScreenAdminState();
// }
//
// class _EventosScreenAdminState extends State<EventosScreenAdmin> {
//   final dateFormat = DateFormat('dd/MM/yyyy');
//
//   static const _categorias = <String>[
//     'Todos',
//     'criancas',
//     'JIMUA',
//     'OJA',
//     'Org.Mulheres',
//     'Org.Homens',
//   ];
//
//   // Compartilha o mês focado entre as abas
//   DateTime _focusedDay = DateTime(DateTime.now().year, DateTime.now().month, 1);
//
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: _categorias.length,
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: Colors.deepOrange,
//           elevation: 0,
//           title: const Text("Eventos (Admin)", style: TextStyle(color: Colors.white)),
//           bottom: PreferredSize(
//             preferredSize: const Size.fromHeight(60),
//             child: Container(
//               alignment: Alignment.centerLeft,
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               child: _StyledTabBar(categories: _categorias),
//             ),
//           ),
//         ),
//         body: TabBarView(
//           children: _categorias.map((cat) {
//             return _CategoriaComCalendarioAdmin(
//               categoria: cat,
//               focusedMonth: _focusedDay,
//               onMonthChanged: (newMonth) {
//                 setState(() => _focusedDay = newMonth);
//               },
//               dateFormat: dateFormat,
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }
//
// class _StyledTabBar extends StatelessWidget {
//   final List<String> categories;
//   const _StyledTabBar({required this.categories});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 42,
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: TabBar(
//         isScrollable: true,
//         indicator: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(18),
//         ),
//         labelColor: Colors.deepOrange,
//         unselectedLabelColor: Colors.white,
//         labelStyle: const TextStyle(fontWeight: FontWeight.w700),
//         unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
//         tabs: categories.map((c) => Tab(text: c)).toList(),
//       ),
//     );
//   }
// }
//
// class _CategoriaComCalendarioAdmin extends StatefulWidget {
//   final String categoria;
//   final DateTime focusedMonth;
//   final ValueChanged<DateTime> onMonthChanged;
//   final DateFormat dateFormat;
//
//   const _CategoriaComCalendarioAdmin({
//     required this.categoria,
//     required this.focusedMonth,
//     required this.onMonthChanged,
//     required this.dateFormat,
//   });
//
//   @override
//   State<_CategoriaComCalendarioAdmin> createState() => _CategoriaComCalendarioAdminState();
// }
//
// class _CategoriaComCalendarioAdminState extends State<_CategoriaComCalendarioAdmin> {
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;
//
//   // mesmas opções usadas no cadastro
//   static const _classes = <String>[
//     'criancas',
//     'JIMUA',
//     'OJA',
//     'Org.Mulheres',
//     'Org.Homens',
//   ];
//
//   static const _statusList = <String>['Agendado', 'Concluído'];
//
//   @override
//   void initState() {
//     super.initState();
//     _focusedDay = DateTime(widget.focusedMonth.year, widget.focusedMonth.month, 1);
//   }
//
//   @override
//   void didUpdateWidget(covariant _CategoriaComCalendarioAdmin oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.focusedMonth.year != widget.focusedMonth.year ||
//         oldWidget.focusedMonth.month != widget.focusedMonth.month) {
//       setState(() {
//         _focusedDay = DateTime(widget.focusedMonth.year, widget.focusedMonth.month, 1);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
//     final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
//
//     // Query APENAS por data (evita índice composto).
//     final query = FirebaseFirestore.instance
//         .collection('eventos')
//         .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDay))
//         .where('data', isLessThanOrEqualTo: Timestamp.fromDate(lastDay))
//         .orderBy('data', descending: false);
//
//     return StreamBuilder<QuerySnapshot>(
//       stream: query.snapshots(),
//       builder: (context, snap) {
//         if (snap.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (snap.hasError) {
//           return _msgInfo('Erro ao carregar "${widget.categoria}".');
//         }
//
//         // Eventos do mês
//         List<QueryDocumentSnapshot> docs = (snap.data?.docs ?? []);
//
//         // Filtrar por categoria no cliente (exceto "Todos")
//         if (widget.categoria != 'Todos') {
//           docs = docs.where((d) {
//             final m = d.data() as Map<String, dynamic>? ?? {};
//             return (m['classe'] ?? '') == widget.categoria;
//           }).toList();
//         }
//
//         // Mapa p/ markers
//         final Map<DateTime, List<QueryDocumentSnapshot>> eventosPorDia = {};
//         for (final d in docs) {
//           final dataCampo = (d['data'] as Timestamp?)?.toDate();
//           if (dataCampo == null) continue;
//           final dia = DateTime(dataCampo.year, dataCampo.month, dataCampo.day);
//           eventosPorDia.putIfAbsent(dia, () => []).add(d);
//         }
//
//         return Column(
//           children: [
//             // Calendário
//             Padding(
//               padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
//               child: TableCalendar(
//                 firstDay: DateTime(2000),
//                 lastDay: DateTime(2100),
//                 focusedDay: _focusedDay,
//                 currentDay: DateTime.now(),
//                 calendarFormat: CalendarFormat.month,
//                 headerStyle: const HeaderStyle(
//                   titleCentered: true,
//                   formatButtonVisible: false,
//                 ),
//                 availableGestures: AvailableGestures.horizontalSwipe,
//                 startingDayOfWeek: StartingDayOfWeek.monday,
//                 onPageChanged: (newFocused) {
//                   setState(() {
//                     _focusedDay = DateTime(newFocused.year, newFocused.month, 1);
//                     _selectedDay = null;
//                   });
//                   widget.onMonthChanged(_focusedDay);
//                 },
//                 selectedDayPredicate: (day) =>
//                 _selectedDay != null &&
//                     day.year == _selectedDay!.year &&
//                     day.month == _selectedDay!.month &&
//                     day.day == _selectedDay!.day,
//                 onDaySelected: (selected, focused) {
//                   setState(() {
//                     _selectedDay = selected;
//                     _focusedDay = DateTime(focused.year, focused.month, 1);
//                   });
//                 },
//                 eventLoader: (day) {
//                   final key = DateTime(day.year, day.month, day.day);
//                   return eventosPorDia[key] ?? const [];
//                 },
//                 calendarStyle: CalendarStyle(
//                   todayDecoration: BoxDecoration(
//                     color: Colors.deepOrange.withOpacity(0.2),
//                     shape: BoxShape.circle,
//                   ),
//                   selectedDecoration: const BoxDecoration(
//                     color: Colors.deepOrange,
//                     shape: BoxShape.circle,
//                   ),
//                   markersAlignment: Alignment.bottomCenter,
//                   markerDecoration: const BoxDecoration(
//                     color: Colors.deepOrange,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 4),
//
//             // Cabeçalho do mês
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//               child: Row(
//                 children: [
//                   Text(
//                     DateFormat('MMMM yyyy', 'pt_BR').format(_focusedDay),
//                     style: const TextStyle(
//                         fontSize: 16, fontWeight: FontWeight.w700, color: Colors.deepOrange),
//                   ),
//                   const Spacer(),
//                   Text(
//                     '${docs.length} evento(s)',
//                     style: const TextStyle(fontSize: 12, color: Colors.black54),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Lista
//             Expanded(
//               child: docs.isEmpty
//                   ? _msgInfo('Sem eventos neste mês.')
//                   : ListView.separated(
//                 padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
//                 itemCount: docs.length,
//                 separatorBuilder: (_, __) => const SizedBox(height: 8),
//                 itemBuilder: (context, i) {
//                   final doc = docs[i];
//                   final map = doc.data() as Map<String, dynamic>? ?? {};
//                   final nome = (map['nome'] ?? 'Sem nome').toString();
//                   final descricao = (map['descricao'] ?? '').toString();
//                   final ts = map['data'] as Timestamp?;
//                   final DateTime? data = ts?.toDate();
//                   final status = (map['status'] ?? '').toString();
//                   final classe = (map['classe'] ?? '').toString();
//
//                   // Se clicou num dia do calendário, mostra só os daquele dia
//                   if (_selectedDay != null && data != null) {
//                     final sameDay = data.year == _selectedDay!.year &&
//                         data.month == _selectedDay!.month &&
//                         data.day == _selectedDay!.day;
//                     if (!sameDay) return const SizedBox.shrink();
//                   }
//
//                   final categoriaVisivel =
//                   widget.categoria == 'Todos' ? (classe.isEmpty ? '—' : classe) : widget.categoria;
//
//                   return _EventoCardAdmin(
//                     doc: doc,
//                     titulo: nome,
//                     data: data,
//                     status: status,
//                     dateFormat: widget.dateFormat,
//                     descricao: descricao,
//                     categoria: categoriaVisivel,
//                     onEdit: () => _openEditSheet(doc, initialClasse: classe, initialStatus: status),
//                     onDelete: () => _confirmDelete(doc),
//                   );
//                 },
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _msgInfo(String text) => Center(
//     child: Padding(
//       padding: const EdgeInsets.all(16),
//       child: Text(
//         text,
//         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//         textAlign: TextAlign.center,
//       ),
//     ),
//   );
//
//   Future<void> _confirmDelete(QueryDocumentSnapshot doc) async {
//     final ok = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Apagar evento'),
//         content: const Text('Tem certeza que deseja apagar este evento? Esta ação não pode ser desfeita.'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
//             child: const Text('Apagar'),
//           ),
//         ],
//       ),
//     );
//     if (ok == true) {
//       try {
//         await doc.reference.delete();
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evento apagado.')));
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao apagar: $e')));
//         }
//       }
//     }
//   }
//
//   Future<void> _openEditSheet(
//       QueryDocumentSnapshot doc, {
//         required String initialClasse,
//         required String initialStatus,
//       }) async {
//     final map = doc.data() as Map<String, dynamic>? ?? {};
//     final nomeCtrl = TextEditingController(text: (map['nome'] ?? '').toString());
//     final descCtrl = TextEditingController(text: (map['descricao'] ?? '').toString());
//     DateTime? data = (map['data'] as Timestamp?)?.toDate();
//     String classe = initialClasse;
//     String status = initialStatus.isEmpty ? _statusList.first : initialStatus;
//
//     await showModalBottomSheet(
//       context: context,
//       showDragHandle: true,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (ctx) {
//         return Padding(
//           padding: EdgeInsets.only(
//             left: 16,
//             right: 16,
//             top: 8,
//             bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
//           ),
//           child: StatefulBuilder(
//             builder: (ctx, setS) {
//               return SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('Editar Evento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
//                     const SizedBox(height: 16),
//
//                     TextField(
//                       controller: nomeCtrl,
//                       decoration: const InputDecoration(
//                         labelText: 'Nome',
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//
//                     TextField(
//                       controller: descCtrl,
//                       minLines: 2,
//                       maxLines: 5,
//                       decoration: const InputDecoration(
//                         labelText: 'Descrição',
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//
//                     DropdownButtonFormField<String>(
//                       value: classe.isEmpty ? null : classe,
//                       items: _classes
//                           .map((c) => DropdownMenuItem(value: c, child: Text(c)))
//                           .toList(),
//                       onChanged: (v) => setS(() => classe = v ?? ''),
//                       decoration: const InputDecoration(
//                         labelText: 'Classe / Público-alvo',
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (v) => v == null ? 'Selecione a classe' : null,
//                     ),
//                     const SizedBox(height: 12),
//
//                     DropdownButtonFormField<String>(
//                       value: status.isEmpty ? _statusList.first : status,
//                       items: _statusList
//                           .map((s) => DropdownMenuItem(value: s, child: Text(s)))
//                           .toList(),
//                       onChanged: (v) => setS(() => status = v ?? _statusList.first),
//                       decoration: const InputDecoration(
//                         labelText: 'Status',
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//
//                     ListTile(
//                       contentPadding: EdgeInsets.zero,
//                       title: Text(
//                         data == null ? 'Sem data selecionada' : 'Data: ${DateFormat('dd/MM/yyyy').format(data!)}',
//                       ),
//                       trailing: ElevatedButton(
//                         onPressed: () async {
//                           final picked = await showDatePicker(
//                             context: ctx,
//                             initialDate: data ?? DateTime.now(),
//                             firstDate: DateTime(2000),
//                             lastDate: DateTime(2100),
//                           );
//                           if (picked != null) setS(() => data = picked);
//                         },
//                         style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
//                         child: const Text('Selecionar Data'),
//                       ),
//                     ),
//
//                     const SizedBox(height: 16),
//
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         icon: const Icon(Icons.save),
//                         label: const Text('Salvar alterações'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.deepOrange,
//                           minimumSize: const Size(double.infinity, 48),
//                         ),
//                         onPressed: () async {
//                           try {
//                             final Map<String, dynamic> update = {
//                               'nome': nomeCtrl.text.trim(),
//                               'descricao': descCtrl.text.trim(),
//                               'classe': classe,
//                               'status': status,
//                             };
//                             if (data != null) {
//                               update['data'] = Timestamp.fromDate(data!);
//                               // Se não escolher status explicitamente, recalcula:
//                               if (status.isEmpty) {
//                                 final now = DateTime.now();
//                                 final isPast = data!.isBefore(DateTime(now.year, now.month, now.day));
//                                 update['status'] = isPast ? 'Concluído' : 'Agendado';
//                               }
//                             }
//                             await doc.reference.update(update);
//                             if (mounted) {
//                               Navigator.pop(ctx);
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(content: Text('Evento atualizado.')),
//                               );
//                             }
//                           } catch (e) {
//                             if (mounted) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text('Erro ao atualizar: $e')),
//                               );
//                             }
//                           }
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }
//
// class _EventoCardAdmin extends StatelessWidget {
//   final QueryDocumentSnapshot doc;
//   final String titulo;
//   final String descricao;
//   final DateTime? data;
//   final String status;
//   final String categoria;
//   final DateFormat dateFormat;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//
//   const _EventoCardAdmin({
//     required this.doc,
//     required this.titulo,
//     required this.descricao,
//     required this.data,
//     required this.status,
//     required this.categoria,
//     required this.dateFormat,
//     required this.onEdit,
//     required this.onDelete,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final dataStr = data != null ? dateFormat.format(data!) : 'Sem data';
//
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ListTile(
//         leading: const CircleAvatar(
//           backgroundColor: Color(0xFFFFE8D6),
//           child: Icon(Icons.event, color: Colors.deepOrange),
//         ),
//         title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w700)),
//         subtitle: Text(
//           categoria.isEmpty ? dataStr : '$dataStr  •  $categoria',
//           maxLines: 2,
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _StatusChip(status: status, date: data),
//             const SizedBox(width: 8),
//             PopupMenuButton<String>(
//               tooltip: 'Ações',
//               onSelected: (value) {
//                 if (value == 'edit') onEdit();
//                 if (value == 'delete') onDelete();
//               },
//               itemBuilder: (_) => [
//                 const PopupMenuItem(value: 'edit', child: ListTile(
//                   leading: Icon(Icons.edit), title: Text('Editar'),
//                 )),
//                 const PopupMenuItem(value: 'delete', child: ListTile(
//                   leading: Icon(Icons.delete_outline), title: Text('Apagar'),
//                 )),
//               ],
//             ),
//           ],
//         ),
//         onTap: () => _mostrarDetalhes(context),
//       ),
//     );
//   }
//
//   void _mostrarDetalhes(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(titulo),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (categoria.isNotEmpty) Text('Público-alvo: $categoria'),
//             const SizedBox(height: 8),
//             if (data != null) Text('Data: ${dateFormat.format(data!)}'),
//             const SizedBox(height: 8),
//             if (status.isNotEmpty) Text('Status: $status'),
//             const SizedBox(height: 8),
//             const Text('Descrição:'),
//             Text(descricao.isEmpty ? 'Sem descrição' : descricao),
//           ],
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
//         ],
//       ),
//     );
//   }
// }
//
// class _StatusChip extends StatelessWidget {
//   final String status;
//   final DateTime? date;
//
//   const _StatusChip({required this.status, required this.date});
//
//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now();
//     final fallback =
//     (date != null && date!.isBefore(DateTime(now.year, now.month, now.day)))
//         ? 'Concluído'
//         : 'Agendado';
//     final resolved = status.isNotEmpty ? status : fallback;
//     final isConcluido = resolved.toLowerCase().contains('conclu');
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: isConcluido ? Colors.grey.shade300 : Colors.orange.shade100,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: isConcluido ? Colors.grey.shade400 : Colors.deepOrange,
//           width: 1,
//         ),
//       ),
//       child: Text(
//         resolved,
//         style: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//           color: isConcluido ? Colors.black87 : Colors.deepOrange,
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

// ajuste o caminho conforme seu projeto
import 'editar_evento_screen.dart';

class EventosScreenAdmin extends StatefulWidget {
  const EventosScreenAdmin({super.key});

  @override
  State<EventosScreenAdmin> createState() => _EventosScreenAdminState();
}

class _EventosScreenAdminState extends State<EventosScreenAdmin> {
  final dateFormat = DateFormat('dd/MM/yyyy');

  static const _categorias = <String>[
    'Todos',
    'criancas',
    'JIMUA',
    'OJA',
    'Org.Mulheres',
    'Org.Homens',
  ];

  // mês focado compartilhado entre as abas
  DateTime _focusedDay = DateTime(DateTime.now().year, DateTime.now().month, 1);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _categorias.length,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          elevation: 0,
          title: const Text("Eventos (Admin)", style: TextStyle(color: Colors.white)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: _StyledTabBar(categories: _categorias),
            ),
          ),
        ),
        body: TabBarView(
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
    );
  }
}

class _StyledTabBar extends StatelessWidget {
  final List<String> categories;
  const _StyledTabBar({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TabBar(
        isScrollable: true,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        labelColor: Colors.deepOrange,
        unselectedLabelColor: Colors.white,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        tabs: categories.map((c) => Tab(text: c)).toList(),
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
  State<_CategoriaComCalendarioAdmin> createState() => _CategoriaComCalendarioAdminState();
}

class _CategoriaComCalendarioAdminState extends State<_CategoriaComCalendarioAdmin> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime(widget.focusedMonth.year, widget.focusedMonth.month, 1);
  }

  @override
  void didUpdateWidget(covariant _CategoriaComCalendarioAdmin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedMonth.year != widget.focusedMonth.year ||
        oldWidget.focusedMonth.month != widget.focusedMonth.month) {
      setState(() {
        _focusedDay = DateTime(widget.focusedMonth.year, widget.focusedMonth.month, 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    // consulta apenas por faixa de datas (evita índice composto)
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

        // eventos do mês
        List<QueryDocumentSnapshot> docs = (snap.data?.docs ?? []);

        // filtra por categoria no cliente (exceto "Todos")
        if (widget.categoria != 'Todos') {
          docs = docs.where((d) {
            final m = d.data() as Map<String, dynamic>? ?? {};
            return (m['classe'] ?? '') == widget.categoria;
          }).toList();
        }

        // markers do calendário
        final Map<DateTime, List<QueryDocumentSnapshot>> eventosPorDia = {};
        for (final d in docs) {
          final dataCampo = (d['data'] as Timestamp?)?.toDate();
          if (dataCampo == null) continue;
          final dia = DateTime(dataCampo.year, dataCampo.month, dataCampo.day);
          eventosPorDia.putIfAbsent(dia, () => []).add(d);
        }

        return Column(
          children: [
            // calendário
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: TableCalendar(
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
                    _focusedDay = DateTime(newFocused.year, newFocused.month, 1);
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
                    _focusedDay = DateTime(focused.year, focused.month, 1);
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

            const SizedBox(height: 4),

            // cabeçalho do mês
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Text(
                    DateFormat('MMMM yyyy', 'pt_BR').format(_focusedDay),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700, color: Colors.deepOrange),
                  ),
                  const Spacer(),
                  Text(
                    '${docs.length} evento(s)',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),

            // lista de eventos
            Expanded(
              child: docs.isEmpty
                  ? _msgInfo('Sem eventos neste mês.')
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final doc = docs[i];
                  final map = doc.data() as Map<String, dynamic>? ?? {};
                  final nome = (map['nome'] ?? 'Sem nome').toString();
                  final descricao = (map['descricao'] ?? '').toString();
                  final ts = map['data'] as Timestamp?;
                  final DateTime? data = ts?.toDate();
                  final status = (map['status'] ?? '').toString();
                  final classe = (map['classe'] ?? '').toString();

                  // se clicou num dia, mostra só os daquele dia
                  if (_selectedDay != null && data != null) {
                    final sameDay = data.year == _selectedDay!.year &&
                        data.month == _selectedDay!.month &&
                        data.day == _selectedDay!.day;
                    if (!sameDay) return const SizedBox.shrink();
                  }

                  final categoriaVisivel =
                  widget.categoria == 'Todos' ? (classe.isEmpty ? '—' : classe) : widget.categoria;

                  return _EventoCardAdmin(
                    doc: doc,
                    titulo: nome,
                    data: data,
                    status: status,
                    dateFormat: widget.dateFormat,
                    descricao: descricao,
                    categoria: categoriaVisivel,
                    onEdit: () async {
                      // navega para a tela de edição separada
                      final ref = doc.reference.withConverter<Map<String, dynamic>>(
                        fromFirestore: (snapshot, _) => snapshot.data() ?? {},
                        toFirestore: (data, _) => data,
                      );
                      final updated = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditarEventoScreen(ref: ref),
                        ),
                      );
                      // se algo foi salvo/apagado, você pode forçar um refresh visual (opcional)
                      if (updated == true && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Evento atualizado.')),
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

  Widget _msgInfo(String text) => Center(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    ),
  );

  Future<void> _confirmDelete(QueryDocumentSnapshot doc) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Apagar evento'),
        content: const Text('Tem certeza que deseja apagar este evento? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await doc.reference.delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evento apagado.')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao apagar: $e')));
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
  final String status;
  final String categoria;
  final DateFormat dateFormat;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EventoCardAdmin({
    required this.doc,
    required this.titulo,
    required this.descricao,
    required this.data,
    required this.status,
    required this.categoria,
    required this.dateFormat,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dataStr = data != null ? dateFormat.format(data!) : 'Sem data';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFFE8D6),
          child: Icon(Icons.event, color: Colors.deepOrange),
        ),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          categoria.isEmpty ? dataStr : '$dataStr  •  $categoria',
          maxLines: 2,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusChip(status: status, date: data),
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
                  child: ListTile(leading: Icon(Icons.edit), title: Text('Editar')),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Apagar')),
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
            if (status.isNotEmpty) Text('Status: $status'),
            const SizedBox(height: 8),
            const Text('Descrição:'),
            Text(descricao.isEmpty ? 'Sem descrição' : descricao),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final DateTime? date;

  const _StatusChip({required this.status, required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final fallback =
    (date != null && date!.isBefore(DateTime(now.year, now.month, now.day)))
        ? 'Concluído'
        : 'Agendado';
    final resolved = status.isNotEmpty ? status : fallback;
    final isConcluido = resolved.toLowerCase().contains('conclu');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isConcluido ? Colors.grey.shade300 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConcluido ? Colors.grey.shade400 : Colors.deepOrange,
          width: 1,
        ),
      ),
      child: Text(
        resolved,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isConcluido ? Colors.black87 : Colors.deepOrange,
        ),
      ),
    );
  }
}
