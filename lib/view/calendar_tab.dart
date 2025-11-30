import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../model/todo.dart';
import '../viewmodel/todo_viewmodel.dart';
import 'styles.dart';

// La función 'CalendarTab' ya existe en home_page.dart como StatelessWidget.
// La convertimos a StatefulWidget para manejar el estado del calendario.
class CalendarTab extends StatefulWidget {
  const CalendarTab({super.key});

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late final ValueNotifier<List<Todo>> _selectedEvents;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  // --- Funciones de Gestión de Eventos (Tareas) ---

  // 1. Obtiene las tareas para un día específico
  List<Todo> _getEventsForDay(DateTime day) {
    // Usamos el ViewModel para obtener la lista completa de tareas
    final viewModel = Provider.of<TodoViewModel>(context, listen: false);
    
    // Filtramos las tareas que tienen una fecha de vencimiento que coincide con 'day'
    return viewModel.todos.where((todo) {
      if (todo.dueDate == null) return false;
      // Compara solo la fecha (año, mes, día)
      return isSameDay(todo.dueDate, day);
    }).toList();
  }

  // 2. Maneja la selección de un día
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  // --- Constructor de UI ---

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios en el ViewModel (cuando se agrega/elimina una tarea)
    return Consumer<TodoViewModel>(
      builder: (context, viewModel, child) {
        // Asegurarse de que _selectedEvents se actualice si la lista de todos cambia
        if (_selectedDay != null) {
          _selectedEvents.value = _getEventsForDay(_selectedDay!);
        }

        return Column(
          children: [
            // 1. Calendario (Inspirado en el diseño superior del ejemplo)
            _buildCalendar(viewModel.todos),

            // Línea separadora como en el diseño de referencia
            const Divider(height: 1, color: Colors.grey),
            
            // 2. Título de Eventos (Similar a "The Emirates Wedding Party")
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Tareas para el ${_selectedDay != null ? _selectedDay!.day : ''}/${_selectedDay != null ? _selectedDay!.month : ''}',
                style: AppTextStyles.titleLarge.copyWith(fontSize: 22),
              ),
            ),

            // 3. Lista de Tareas para el Día Seleccionado
            Expanded(
              child: ValueListenableBuilder<List<Todo>>(
                valueListenable: _selectedEvents,
                builder: (context, value, _) {
                  if (value.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay tareas pendientes para este día.',
                        style: AppTextStyles.subtitle,
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      final todo = value[index];
                      return _buildTaskCard(todo, context); // Usa el estilo de tarjeta del diseño de referencia
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // --- Widgets Auxiliares ---

  Widget _buildCalendar(List<Todo> allTodos) {
    // Función local para obtener marcadores (puntos) para los días que tienen tareas
    List<Todo> getEventMarkers(DateTime day) {
      return allTodos.where((todo) {
        if (todo.dueDate == null) return false;
        return isSameDay(todo.dueDate, day);
      }).toList();
    }

    return TableCalendar<Todo>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      calendarFormat: _calendarFormat,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Mes',
        CalendarFormat.week: 'Semana',
      },
      // Estilo de calendario
      headerStyle: HeaderStyle(
        formatButtonDecoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10.0),
        ),
        formatButtonTextStyle: const TextStyle(color: Colors.white),
        titleTextStyle: AppTextStyles.titleLarge.copyWith(fontSize: 18),
        leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
        rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
      ),
      calendarStyle: CalendarStyle(
        // Días de la semana
        weekendTextStyle: TextStyle(color: AppColors.accent), 
        // Número del día seleccionado
        selectedDecoration: const BoxDecoration(
          color: AppColors.primary, 
          shape: BoxShape.circle
        ),
        // Número del día enfocado (actual)
        todayDecoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.5), 
          shape: BoxShape.circle
        ),
        // Marcador de eventos (puntos debajo del número)
        markerDecoration: BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
      ),
      onDaySelected: _onDaySelected,
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      eventLoader: getEventMarkers, // Usa la función de marcador de eventos
    );
  }
  
  // Widget de tarjeta de tarea (inspirado en la parte inferior del diseño de referencia)
  Widget _buildTaskCard(Todo todo, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: AppColors.cardColor,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono o indicador (similar a la campana del diseño de referencia)
            Icon(
              todo.completed ? Icons.check_circle : Icons.access_time_filled,
              color: todo.completed ? Colors.green.shade600 : AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 15),

            // Título y detalles
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontSize: 16, 
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      decoration: todo.completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (todo.category != null)
                    Text(
                      'Categoría: ${todo.category}',
                      style: AppTextStyles.subtitle.copyWith(fontSize: 12, color: AppColors.primary),
                    ),
                  Text(
                    todo.description.isNotEmpty ? todo.description : 'Sin descripción.',
                    style: AppTextStyles.subtitle.copyWith(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Sección de tiempo/estado (como la sección de precio en el diseño de referencia)
            if (todo.dueDate != null)
              Container(
                padding: const EdgeInsets.only(left: 8),
                alignment: Alignment.centerRight,
                child: Column(
                  children: [
                    Text(
                      '${todo.dueDate!.hour.toString().padLeft(2, '0')}:${todo.dueDate!.minute.toString().padLeft(2, '0')}',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontSize: 16,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Hora',
                      style: AppTextStyles.subtitle.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}