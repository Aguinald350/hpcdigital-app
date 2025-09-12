// ///////////////////////////////////////Modelo 1////////////////////////////////////////////

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class EventosScreen extends StatefulWidget {
//   const EventosScreen({super.key});
//
//   @override
//   State<EventosScreen> createState() => _EventosScreenState();
// }
//
// class _EventosScreenState extends State<EventosScreen> {
//   final List<String> categorias = const [
//     'Jovens',
//     'Jovens Adultos',
//     'Mamas',
//     'Papas',
//     'Gerais',
//   ];
//
//   final dateFormat = DateFormat('dd/MM/yyyy');
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.deepOrange,
//         elevation: 0,
//         title: const Text("Eventos", style: TextStyle(color: Colors.white)),
//       ),
//       body: ListView(
//         children: categorias.map(_buildCategoriaSection).toList(),
//       ),
//     );
//   }
//
//   Widget _buildCategoriaSection(String categoria) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('eventos')
//           .where('classe', isEqualTo: categoria)
//           .orderBy('data', descending: false)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Padding(
//             padding: EdgeInsets.all(16),
//             child: Center(child: CircularProgressIndicator()),
//           );
//         }
//
//         if (snapshot.hasError) {
//           return _msgInfo('Erro ao carregar "$categoria".');
//         }
//
//         final docs = snapshot.data?.docs ?? [];
//         if (docs.isEmpty) {
//           return _msgInfo('Sem eventos para "$categoria".');
//         }
//
//         return Card(
//           margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           elevation: 2,
//           child: ExpansionTile(
//             iconColor: Colors.deepOrange,
//             collapsedIconColor: Colors.deepOrange,
//             title: Text(
//               categoria,
//               style: const TextStyle(
//                   fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepOrange),
//             ),
//             children: docs.map((doc) {
//               final map = doc.data() as Map<String, dynamic>? ?? {};
//               final nome = (map['nome'] ?? 'Sem nome').toString();
//               final descricao = (map['descricao'] ?? '').toString();
//               final classe = (map['classe'] ?? categoria).toString();
//               final status = (map['status'] ?? '').toString();
//               final ts = map['data'];
//               final DateTime? data =
//               ts is Timestamp ? ts.toDate() : (ts is DateTime ? ts : null);
//               final dataStr = data != null ? dateFormat.format(data) : 'Sem data';
//
//               return ListTile(
//                 leading: const Icon(Icons.event, color: Colors.deepOrange),
//                 title: Text(nome),
//                 subtitle: Text(dataStr),
//                 trailing: _StatusChip(status: status, date: data),
//                 onTap: () => _mostrarDetalhesEvento(
//                   context,
//                   nome: nome,
//                   descricao: descricao,
//                   classe: classe,
//                   data: data,
//                   status: status,
//                 ),
//               );
//             }).toList(),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _msgInfo(String text) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Text(
//         text,
//         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//       ),
//     );
//   }
//
//   void _mostrarDetalhesEvento(
//       BuildContext context, {
//         required String nome,
//         required String descricao,
//         required String classe,
//         required DateTime? data,
//         required String status,
//       }) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(nome),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Classe: $classe'),
//             const SizedBox(height: 8),
//             if (data != null) Text('Data: ${dateFormat.format(data)}'),
//             const SizedBox(height: 8),
//             if (status.isNotEmpty) Text('Status: $status'),
//             const SizedBox(height: 8),
//             const Text('Descrição:'),
//             Text(descricao.isEmpty ? 'Sem descrição' : descricao),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Fechar'),
//           )
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
//     // fallback: se não veio status, deduz pela data
//     final now = DateTime.now();
//     final resolved = status.isNotEmpty
//         ? status
//         : (date != null && date!.isBefore(DateTime(now.year, now.month, now.day)))
//         ? 'Concluído'
//         : 'Agendado';
//
//     final isConcluido = resolved.toLowerCase().contains('conclu');
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

//////////////////////////////////Modelo 2///////////////////////////////////////////////

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class EventosScreen extends StatefulWidget {
//   const EventosScreen({super.key});
//
//   @override
//   State<EventosScreen> createState() => _EventosScreenState();
// }
//
// class _EventosScreenState extends State<EventosScreen> {
//   final dateFormat = DateFormat('dd/MM/yyyy');
//
//   static const _categorias = <String>[
//     'Mamas',
//     'Papas',
//     'Jovens',
//     'Jovens Adultos',
//     'criancas',
//     'Gerais',
//   ];
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
//           title: const Text("Eventos", style: TextStyle(color: Colors.white)),
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
//           children: _categorias.map((cat) => _CategoriaLista(
//             categoria: cat,
//             dateFormat: dateFormat,
//           )).toList(),
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
// class _CategoriaLista extends StatelessWidget {
//   final String categoria;
//   final DateFormat dateFormat;
//
//   const _CategoriaLista({
//     required this.categoria,
//     required this.dateFormat,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final query = FirebaseFirestore.instance
//         .collection('eventos')
//         .where('classe', isEqualTo: categoria)
//         .orderBy('data', descending: false);
//
//     return StreamBuilder<QuerySnapshot>(
//       stream: query.snapshots(),
//       builder: (context, snap) {
//         if (snap.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (snap.hasError) {
//           return _msgInfo('Erro ao carregar "$categoria".');
//         }
//
//         final docs = snap.data?.docs ?? [];
//         if (docs.isEmpty) {
//           return _msgInfo('Sem eventos em "$categoria".');
//         }
//
//         return ListView.separated(
//           padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
//           itemCount: docs.length,
//           separatorBuilder: (_, __) => const SizedBox(height: 8),
//           itemBuilder: (context, i) {
//             final dataMap = (docs[i].data() as Map<String, dynamic>?) ?? {};
//             final nome = (dataMap['nome'] ?? 'Sem nome').toString();
//             final descricao = (dataMap['descricao'] ?? '').toString();
//             final ts = dataMap['data'];
//             final DateTime? data = ts is Timestamp
//                 ? ts.toDate()
//                 : (ts is DateTime ? ts : null);
//             final status = (dataMap['status'] ?? '').toString();
//
//             return _EventoTile(
//               titulo: nome,
//               data: data,
//               status: status,
//               dateFormat: dateFormat,
//               descricao: descricao,
//               categoria: categoria,
//             );
//           },
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
// }
//
// class _EventoTile extends StatelessWidget {
//   final String titulo;
//   final String descricao;
//   final DateTime? data;
//   final String status;
//   final String categoria;
//   final DateFormat dateFormat;
//
//   const _EventoTile({
//     required this.titulo,
//     required this.descricao,
//     required this.data,
//     required this.status,
//     required this.categoria,
//     required this.dateFormat,
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
//         title: Text(
//           titulo,
//           style: const TextStyle(fontWeight: FontWeight.w700),
//         ),
//         subtitle: Text(dataStr),
//         trailing: _StatusChip(status: status, date: data),
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
//             Text('Público-alvo: $categoria'),
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
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Fechar'),
//           )
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
//     final fallback = (date != null &&
//         date!.isBefore(DateTime(now.year, now.month, now.day)))
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
/////////////////////////////////Modelo 3/////////////////////////////////////////////////

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:table_calendar/table_calendar.dart';
//
// class EventosScreen extends StatefulWidget {
//   const EventosScreen({super.key});
//
//   @override
//   State<EventosScreen> createState() => _EventosScreenState();
// }
//
// class _EventosScreenState extends State<EventosScreen> {
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
//   // Estado do calendário
//   DateTime _focusedDay = DateTime(DateTime.now().year, DateTime.now().month, 1);
//   DateTime? _selectedDay;
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
//           title: const Text("Eventos", style: TextStyle(color: Colors.white)),
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
//             return _CategoriaComCalendario(
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
// // class _CategoriaComCalendario extends StatefulWidget {
// //   final String categoria;
// //   final DateTime focusedMonth;
// //   final ValueChanged<DateTime> onMonthChanged;
// //   final DateFormat dateFormat;
// //
// //   const _CategoriaComCalendario({
// //     required this.categoria,
// //     required this.focusedMonth,
// //     required this.onMonthChanged,
// //     required this.dateFormat,
// //   });
// //
// //   @override
// //   State<_CategoriaComCalendario> createState() => _CategoriaComCalendarioState();
// // }
//
// // class _CategoriaComCalendarioState extends State<_CategoriaComCalendario> {
// //   DateTime _focusedDay = DateTime.now();
// //   DateTime? _selectedDay;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _focusedDay = DateTime(widget.focusedMonth.year, widget.focusedMonth.month, 1);
// //   }
// //
// //   @override
// //   void didUpdateWidget(covariant _CategoriaComCalendario oldWidget) {
// //     super.didUpdateWidget(oldWidget);
// //     if (oldWidget.focusedMonth.year != widget.focusedMonth.year ||
// //         oldWidget.focusedMonth.month != widget.focusedMonth.month) {
// //       setState(() {
// //         _focusedDay = DateTime(widget.focusedMonth.year, widget.focusedMonth.month, 1);
// //       });
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     // Faixa do mês visível
// //     final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
// //     final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0); // último dia do mês
// //
// //     // Query: eventos da categoria no mês atual
// //     final query = FirebaseFirestore.instance
// //         .collection('eventos')
// //         .where('classe', isEqualTo: widget.categoria)
// //         .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDay))
// //         .where('data', isLessThanOrEqualTo: Timestamp.fromDate(lastDay))
// //         .orderBy('data', descending: false);
// //
// //     return StreamBuilder<QuerySnapshot>(
// //       stream: query.snapshots(),
// //       builder: (context, snap) {
// //         if (snap.connectionState == ConnectionState.waiting) {
// //           return const Center(child: CircularProgressIndicator());
// //         }
// //         if (snap.hasError) {
// //           return _msgInfo('Erro ao carregar "${widget.categoria}".');
// //         }
// //
// //         final docs = snap.data?.docs ?? [];
// //
// //         // Mapeia os eventos por dia (yyyy-mm-dd sem hora)
// //         final Map<DateTime, List<QueryDocumentSnapshot>> eventosPorDia = {};
// //         for (final d in docs) {
// //           final dataCampo = (d['data'] as Timestamp?)?.toDate();
// //           if (dataCampo == null) continue;
// //           final dia = DateTime(dataCampo.year, dataCampo.month, dataCampo.day);
// //           eventosPorDia.putIfAbsent(dia, () => []).add(d);
// //         }
// //
// //         return Column(
// //           children: [
// //             // Calendário com marcadores
// //             Padding(
// //               padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
// //               child: TableCalendar(
// //                 firstDay: DateTime(2000),
// //                 lastDay: DateTime(2100),
// //                 focusedDay: _focusedDay,
// //                 currentDay: DateTime.now(),
// //                 calendarFormat: CalendarFormat.month,
// //                 headerStyle: const HeaderStyle(
// //                   titleCentered: true,
// //                   formatButtonVisible: false,
// //                 ),
// //                 availableGestures: AvailableGestures.horizontalSwipe,
// //                 startingDayOfWeek: StartingDayOfWeek.monday,
// //                 // Quando muda de mês
// //                 onPageChanged: (newFocused) {
// //                   setState(() {
// //                     _focusedDay = DateTime(newFocused.year, newFocused.month, 1);
// //                     _selectedDay = null;
// //                   });
// //                   widget.onMonthChanged(_focusedDay);
// //                 },
// //                 selectedDayPredicate: (day) =>
// //                 _selectedDay != null &&
// //                     day.year == _selectedDay!.year &&
// //                     day.month == _selectedDay!.month &&
// //                     day.day == _selectedDay!.day,
// //                 onDaySelected: (selected, focused) {
// //                   setState(() {
// //                     _selectedDay = selected;
// //                     _focusedDay = DateTime(focused.year, focused.month, 1);
// //                   });
// //                 },
// //                 // Mostra bolinhas nos dias com evento
// //                 eventLoader: (day) {
// //                   final key = DateTime(day.year, day.month, day.day);
// //                   return eventosPorDia[key] ?? const [];
// //                 },
// //                 calendarStyle: CalendarStyle(
// //                   todayDecoration: BoxDecoration(
// //                     color: Colors.deepOrange.withOpacity(0.2),
// //                     shape: BoxShape.circle,
// //                   ),
// //                   selectedDecoration: const BoxDecoration(
// //                     color: Colors.deepOrange,
// //                     shape: BoxShape.circle,
// //                   ),
// //                   markersAlignment: Alignment.bottomCenter,
// //                   markerDecoration: const BoxDecoration(
// //                     color: Colors.deepOrange,
// //                     shape: BoxShape.circle,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //
// //             const SizedBox(height: 4),
// //
// //             // Título/linha do mês
// //             Padding(
// //               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
// //               child: Row(
// //                 children: [
// //                   Text(
// //                     DateFormat('MMMM yyyy', 'pt_BR').format(_focusedDay),
// //                     style: const TextStyle(
// //                         fontSize: 16, fontWeight: FontWeight.w700, color: Colors.deepOrange),
// //                   ),
// //                   const Spacer(),
// //                   Text(
// //                     '${docs.length} evento(s)',
// //                     style: const TextStyle(fontSize: 12, color: Colors.black54),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //
// //             // Lista de eventos do mês (e, se um dia for selecionado, filtra por aquele dia)
// //             Expanded(
// //               child: docs.isEmpty
// //                   ? _msgInfo('${widget.categoria}')
// //                   : ListView.separated(
// //                 padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
// //                 itemCount: docs.length,
// //                 separatorBuilder: (_, __) => const SizedBox(height: 8),
// //                 itemBuilder: (context, i) {
// //                   final map = docs[i].data() as Map<String, dynamic>? ?? {};
// //                   final nome = (map['nome'] ?? 'Sem nome').toString();
// //                   final descricao = (map['descricao'] ?? '').toString();
// //                   final ts = map['data'] as Timestamp?;
// //                   final DateTime? data = ts?.toDate();
// //                   final status = (map['status'] ?? '').toString();
// //
// //                   // Se um dia estiver selecionado, mostra só os daquele dia
// //                   if (_selectedDay != null && data != null) {
// //                     final sameDay = data.year == _selectedDay!.year &&
// //                         data.month == _selectedDay!.month &&
// //                         data.day == _selectedDay!.day;
// //                     if (!sameDay) return const SizedBox.shrink();
// //                   }
// //
// //                   return _EventoCard(
// //                     titulo: nome,
// //                     data: data,
// //                     status: status,
// //                     dateFormat: widget.dateFormat,
// //                     descricao: descricao,
// //                     categoria: widget.categoria,
// //                   );
// //                 },
// //               ),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }
// //
// //   Widget _msgInfo(String text) => Center(
// //     child: Padding(
// //       padding: const EdgeInsets.all(16),
// //       child: Text(
// //         text,
// //         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
// //         textAlign: TextAlign.center,
// //       ),
// //     ),
// //   );
// // }
// class _CategoriaComCalendario extends StatefulWidget {
//   final String categoria;
//   final DateTime focusedMonth;
//   final ValueChanged<DateTime> onMonthChanged;
//   final DateFormat dateFormat;
//
//   const _CategoriaComCalendario({
//     required this.categoria,
//     required this.focusedMonth,
//     required this.onMonthChanged,
//     required this.dateFormat,
//   });
//
//   @override
//   State<_CategoriaComCalendario> createState() => _CategoriaComCalendarioState();
// }
//
// class _CategoriaComCalendarioState extends State<_CategoriaComCalendario> {
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;
//
//   @override
//   void initState() {
//     super.initState();
//     _focusedDay = DateTime(widget.focusedMonth.year, widget.focusedMonth.month, 1);
//   }
//
//   @override
//   void didUpdateWidget(covariant _CategoriaComCalendario oldWidget) {
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
//     // intervalo do mês visível
//     final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
//     final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
//
//     // 🔎 Query SEM filtro de classe (evita índice composto).
//     // No separador "Todos" isso já atende; nos demais, filtramos no cliente.
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
//         // 🔧 Filtra por categoria SOMENTE se não for "Todos".
//         List<QueryDocumentSnapshot> docs = (snap.data?.docs ?? []);
//         if (widget.categoria != 'Todos') {
//           docs = docs.where((d) {
//             final m = d.data() as Map<String, dynamic>? ?? {};
//             return (m['classe'] ?? '') == widget.categoria;
//           }).toList();
//         }
//
//         // Mapa de eventos por dia (para markers do calendário)
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
//             Expanded(
//               child: docs.isEmpty
//                   ? _msgInfo('Sem eventos neste mês.')
//                   : ListView.separated(
//                 padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
//                 itemCount: docs.length,
//                 separatorBuilder: (_, __) => const SizedBox(height: 8),
//                 itemBuilder: (context, i) {
//                   final map = docs[i].data() as Map<String, dynamic>? ?? {};
//                   final nome = (map['nome'] ?? 'Sem nome').toString();
//                   final descricao = (map['descricao'] ?? '').toString();
//                   final ts = map['data'] as Timestamp?;
//                   final DateTime? data = ts?.toDate();
//                   final status = (map['status'] ?? '').toString();
//                   final classe = (map['classe'] ?? '').toString();
//
//                   // Se um dia foi clicado no calendário, mostra só os daquele dia
//                   if (_selectedDay != null && data != null) {
//                     final sameDay = data.year == _selectedDay!.year &&
//                         data.month == _selectedDay!.month &&
//                         data.day == _selectedDay!.day;
//                     if (!sameDay) return const SizedBox.shrink();
//                   }
//
//                   return _EventoCard(
//                     titulo: nome,
//                     data: data,
//                     status: status,
//                     dateFormat: widget.dateFormat,
//                     descricao: descricao,
//                     categoria: widget.categoria == 'Todos' ? (classe.isEmpty ? '—' : classe) : widget.categoria,
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
// }
//
//
//
// class _EventoCard extends StatelessWidget {
//   final String titulo;
//   final String descricao;
//   final DateTime? data;
//   final String status;
//   final String categoria;
//   final DateFormat dateFormat;
//
//   const _EventoCard({
//     required this.titulo,
//     required this.descricao,
//     required this.data,
//     required this.status,
//     required this.categoria,
//     required this.dateFormat,
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
//         subtitle: Text(dataStr),
//         trailing: _StatusChip(status: status, date: data),
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
//             Text('Público-alvo: $categoria'),
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
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Fechar'),
//           )
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

/////////////////////////////////Modelo 4///////////////////////////////////////////

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  final dateFormat = DateFormat('dd/MM/yyyy');

  static const _categorias = <String>[
    'Todos',
    'criancas',
    'JIMUA',
    'OJA',
    'Org.Mulheres',
    'Org.Homens',
  ];

  // Estado compartilhado do mês focado entre as abas
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
          title: const Text("Eventos", style: TextStyle(color: Colors.white)),
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
            return _CategoriaComCalendario(
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

class _CategoriaComCalendario extends StatefulWidget {
  final String categoria;
  final DateTime focusedMonth;
  final ValueChanged<DateTime> onMonthChanged;
  final DateFormat dateFormat;

  const _CategoriaComCalendario({
    required this.categoria,
    required this.focusedMonth,
    required this.onMonthChanged,
    required this.dateFormat,
  });

  @override
  State<_CategoriaComCalendario> createState() => _CategoriaComCalendarioState();
}

class _CategoriaComCalendarioState extends State<_CategoriaComCalendario> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime(widget.focusedMonth.year, widget.focusedMonth.month, 1);
  }

  @override
  void didUpdateWidget(covariant _CategoriaComCalendario oldWidget) {
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
    // Faixa do mês visível
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    // 🔎 Query APENAS por faixa de datas (evita índice composto).
    // "Todos" usa tudo; nas outras abas filtramos por classe no cliente.
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

        // Docs do mês
        List<QueryDocumentSnapshot> docs = (snap.data?.docs ?? []);

        // Filtra por categoria no cliente quando não for "Todos"
        if (widget.categoria != 'Todos') {
          docs = docs.where((d) {
            final m = d.data() as Map<String, dynamic>? ?? {};
            return (m['classe'] ?? '') == widget.categoria;
          }).toList();
        }

        // Mapeia eventos por dia (para markers no calendário)
        final Map<DateTime, List<QueryDocumentSnapshot>> eventosPorDia = {};
        for (final d in docs) {
          final dataCampo = (d['data'] as Timestamp?)?.toDate();
          if (dataCampo == null) continue;
          final dia = DateTime(dataCampo.year, dataCampo.month, dataCampo.day);
          eventosPorDia.putIfAbsent(dia, () => []).add(d);
        }

        return Column(
          children: [
            // Calendário com marcadores
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

            // Cabeçalho do mês
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

            // Lista de eventos
            Expanded(
              child: docs.isEmpty
                  ? _msgInfo('Sem eventos neste mês.')
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final map = docs[i].data() as Map<String, dynamic>? ?? {};
                  final nome = (map['nome'] ?? 'Sem nome').toString();
                  final descricao = (map['descricao'] ?? '').toString();
                  final ts = map['data'] as Timestamp?;
                  final DateTime? data = ts?.toDate();
                  final status = (map['status'] ?? '').toString();
                  final classe = (map['classe'] ?? '').toString();

                  // Se clicou num dia do calendário, mostra só os daquele dia
                  if (_selectedDay != null && data != null) {
                    final sameDay = data.year == _selectedDay!.year &&
                        data.month == _selectedDay!.month &&
                        data.day == _selectedDay!.day;
                    if (!sameDay) return const SizedBox.shrink();
                  }

                  // No separador "Todos", mostramos também a classe na linha
                  final categoriaVisivel = widget.categoria == 'Todos'
                      ? (classe.isEmpty ? '—' : classe)
                      : widget.categoria;

                  return _EventoCard(
                    titulo: nome,
                    data: data,
                    status: status,
                    dateFormat: widget.dateFormat,
                    descricao: descricao,
                    categoria: categoriaVisivel,
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
}

class _EventoCard extends StatelessWidget {
  final String titulo;
  final String descricao;
  final DateTime? data;
  final String status;
  final String categoria;
  final DateFormat dateFormat;

  const _EventoCard({
    required this.titulo,
    required this.descricao,
    required this.data,
    required this.status,
    required this.categoria,
    required this.dateFormat,
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
        trailing: _StatusChip(status: status, date: data),
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          )
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
