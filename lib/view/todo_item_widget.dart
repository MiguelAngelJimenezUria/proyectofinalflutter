// Archivo: view/todo_item_widget.dart

import 'package:flutter/material.dart';
import '../model/todo.dart';
// Asegúrate de importar styles.dart si no está ya
import 'styles.dart'; 

// Definiciones de Callbacks
typedef ToggleCallback = void Function(String id);
typedef RemoveCallback = void Function(String id);
typedef TodoTapCallback = void Function(Todo todo); // 🆕 NUEVO: Callback para tocar la tarjeta

class TodoItemWidget extends StatelessWidget {
  final Todo todo;
  // Estos callbacks son opcionales si usas Provider dentro de este widget,
  // pero los mantendremos para mayor flexibilidad.
  final ToggleCallback onToggle;
  final RemoveCallback onRemove;
  final TodoTapCallback onTap; // 🆕 NUEVA PROPIEDAD REQUERIDA

  const TodoItemWidget({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onRemove,
    required this.onTap, // 🆕 Requerido
  });

  // Método para obtener el color basado en la categoría (si tienes esta lógica)
  // Placeholder si no tienes la lógica de color:
  Color _getCategoryColor(String? category) {
    if (category == 'Trabajo') return Colors.blue.shade200;
    if (category == 'Estudio') return Colors.green.shade200;
    return AppColors.primary.withOpacity(0.5); 
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        color: AppColors.cardColor,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Checkbox para el Toggle
              InkWell(
                onTap: () {
                  print('🔘 Checkbox tapped for: ${todo.title}');
                  onToggle(todo.id);
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: todo.completed ? AppColors.accent : Colors.transparent,
                    border: Border.all(
                      color: todo.completed ? AppColors.accent : AppColors.textSecondary,
                      width: 2,
                    ),
                  ),
                  child: todo.completed
                      ? const Icon(Icons.check, size: 16.0, color: Colors.white)
                      : null,
                ),
              ),
              
              const SizedBox(width: 12),

              // Contenido de la Tarea (Título y Categoría) - CLICKEABLE
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    print('📝 Texto tapped for: ${todo.title}');
                    onTap(todo);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: AppTextStyles.titleLarge.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: todo.completed ? TextDecoration.lineThrough : null,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (todo.category != null && todo.category!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            todo.category!,
                            style: AppTextStyles.subtitle.copyWith(
                              fontSize: 12, 
                              color: _getCategoryColor(todo.category)
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Botón de Editar
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.textSecondary),
                onPressed: () {
                  print('✏️ Edit button tapped for: ${todo.title}');
                  onTap(todo);
                },
                tooltip: 'Editar Tarea',
              ),
            ],
          ),
        ),
      ),
    );
  }
}