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

  DateTime _focusedDay = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selectedDay;
  String _categoriaSelecionada = 'Todos';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 0,
        title: const Text("Eventos"),
      ),
      body: Column(
        children: [
          // Filtro por categoria
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
            child: Row(
              children: [
                Icon(Icons.filter_alt_outlined, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _categoriaSelecionada,
                    isExpanded: true,
                    style: TextStyle(color: cs.onBackground),
                    dropdownColor: cs.surface,
                    decoration: InputDecoration(
                      labelText: 'Filtrar por categoria',
                      labelStyle: TextStyle(color: cs.onBackground.withOpacity(0.8)),
                      filled: true,
                      fillColor: cs.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: cs.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: cs.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: _categorias
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _categoriaSelecionada = v;
                        // _selectedDay = null; // descomente se quiser limpar a seleção ao trocar o filtro
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Calendário + lista
          Expanded(
            child: _CalendarioELista(
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              onPageChanged: (newMonth) {
                setState(() {
                  _focusedDay = DateTime(newMonth.year, newMonth.month, 1);
                  _selectedDay = null;
                });
              },
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = DateTime(focused.year, focused.month, 1);
                });
              },
              categoriaSelecionada: _categoriaSelecionada,
              dateFormat: dateFormat,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarioELista extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onPageChanged;
  final void Function(DateTime selected, DateTime focused) onDaySelected;
  final String categoriaSelecionada;
  final DateFormat dateFormat;

  const _CalendarioELista({
    required this.focusedDay,
    required this.selectedDay,
    required this.onPageChanged,
    required this.onDaySelected,
    required this.categoriaSelecionada,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Faixa do mês
    final firstDay = DateTime(focusedDay.year, focusedDay.month, 1);
    final lastDay = DateTime(focusedDay.year, focusedDay.month + 1, 0);

    // Consulta por data
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
          return _msgInfo(context, 'Erro ao carregar eventos.');
        }

        // docs do mês
        List<QueryDocumentSnapshot> docs = (snap.data?.docs ?? []);

        // filtro por categoria no cliente (exceto "Todos")
        if (categoriaSelecionada != 'Todos') {
          docs = docs.where((d) {
            final m = d.data() as Map<String, dynamic>? ?? {};
            return (m['classe'] ?? '') == categoriaSelecionada;
          }).toList();
        }

        // Mapa para markers do calendário
        final Map<DateTime, List<QueryDocumentSnapshot>> eventosPorDia = {};
        for (final d in docs) {
          final dataCampo = (d['data'] as Timestamp?)?.toDate();
          if (dataCampo == null) continue;
          final dia = DateTime(dataCampo.year, dataCampo.month, dataCampo.day);
          eventosPorDia.putIfAbsent(dia, () => []).add(d);
        }

        return Column(
          children: [
            // Calendário
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: TableCalendar(
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
                focusedDay: focusedDay,
                currentDay: DateTime.now(),
                calendarFormat: CalendarFormat.month,
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  titleTextStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: cs.onBackground,
                  ),
                  leftChevronIcon: Icon(Icons.chevron_left, color: cs.onBackground),
                  rightChevronIcon: Icon(Icons.chevron_right, color: cs.onBackground),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: cs.onBackground.withOpacity(0.8)),
                  weekendStyle: TextStyle(color: cs.onBackground.withOpacity(0.8)),
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: TextStyle(color: cs.onBackground),
                  weekendTextStyle: TextStyle(color: cs.onBackground),
                  outsideTextStyle: TextStyle(color: cs.onSurface.withOpacity(0.4)),
                  todayDecoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                  markersAlignment: Alignment.bottomCenter,
                  markerDecoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                availableGestures: AvailableGestures.horizontalSwipe,
                startingDayOfWeek: StartingDayOfWeek.monday,
                onPageChanged: onPageChanged,
                selectedDayPredicate: (day) =>
                selectedDay != null &&
                    day.year == selectedDay!.year &&
                    day.month == selectedDay!.month &&
                    day.day == selectedDay!.day,
                onDaySelected: onDaySelected,
                eventLoader: (day) {
                  final key = DateTime(day.year, day.month, day.day);
                  return eventosPorDia[key] ?? const [];
                },
              ),
            ),

            const SizedBox(height: 4),

            // Cabeçalho do mês / contador
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Text(
                    DateFormat('MMMM yyyy', 'pt_BR').format(focusedDay),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${docs.length} evento(s)',
                    style: TextStyle(fontSize: 12, color: cs.onBackground.withOpacity(0.7)),
                  ),
                ],
              ),
            ),

            // Lista
            Expanded(
              child: docs.isEmpty
                  ? _msgInfo(context, 'Sem eventos neste mês.')
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

                  // se um dia foi selecionado, filtra só os daquele dia
                  if (selectedDay != null && data != null) {
                    final sameDay =
                        data.year == selectedDay!.year &&
                            data.month == selectedDay!.month &&
                            data.day == selectedDay!.day;
                    if (!sameDay) return const SizedBox.shrink();
                  }

                  final categoriaVisivel = categoriaSelecionada == 'Todos'
                      ? (classe.isEmpty ? '—' : classe)
                      : categoriaSelecionada;

                  return _EventoCard(
                    titulo: nome,
                    data: data,
                    status: status,
                    dateFormat: dateFormat,
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

  Widget _msgInfo(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: cs.onBackground),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
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
    final cs = Theme.of(context).colorScheme;
    final dataStr = data != null ? dateFormat.format(data!) : 'Sem data';

    return Card(
      color: cs.secondaryContainer, // card/acessório
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.secondary), // borda/realce
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: cs.secondaryContainer,
          child: Icon(Icons.event, color: cs.onSecondaryContainer),
        ),
        title: Text(
          titulo,
          style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSecondaryContainer),
        ),
        subtitle: Text(
          categoria.isEmpty ? dataStr : '$dataStr  •  $categoria',
          maxLines: 2,
          style: TextStyle(color: cs.onSecondaryContainer.withOpacity(0.9)),
        ),
        trailing: _StatusChip(status: status, date: data),
        onTap: () => _mostrarDetalhes(context),
      ),
    );
  }

  void _mostrarDetalhes(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo, style: TextStyle(color: cs.onBackground)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (categoria.isNotEmpty)
              Text('Público-alvo: $categoria', style: TextStyle(color: cs.onBackground)),
            const SizedBox(height: 8),
            if (data != null)
              Text('Data: ${dateFormat.format(data!)}', style: TextStyle(color: cs.onBackground)),
            const SizedBox(height: 8),
            if (status.isNotEmpty)
              Text('Status: $status', style: TextStyle(color: cs.onBackground)),
            const SizedBox(height: 8),
            Text('Descrição:', style: TextStyle(color: cs.onBackground)),
            Text(descricao.isEmpty ? 'Sem descrição' : descricao,
                style: TextStyle(color: cs.onBackground)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar', style: TextStyle(color: cs.primary)),
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
    final cs = Theme.of(context).colorScheme;

    final now = DateTime.now();
    final fallback =
    (date != null && date!.isBefore(DateTime(now.year, now.month, now.day)))
        ? 'Concluído'
        : 'Agendado';
    final resolved = status.isNotEmpty ? status : fallback;
    final isConcluido = resolved.toLowerCase().contains('conclu');

    final bgColor = isConcluido ? cs.surfaceVariant : cs.secondaryContainer;
    final textColor = isConcluido ? cs.onSurfaceVariant : cs.onSecondaryContainer;
    final borderColor = isConcluido ? cs.outlineVariant : cs.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(
        resolved,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
