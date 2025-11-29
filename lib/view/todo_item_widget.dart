import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../model/todo.dart';
import 'styles.dart';

typedef ToggleCallback = void Function(String id);
typedef RemoveCallback = void Function(String id);

// ✅ CORRECCIÓN DE ÁMBITO: Función auxiliar fuera de la clase
Color _getCategoryColor(String? category) {
  if (category == null || category.isEmpty) return Colors.grey;
  final colors = [
    Colors.blueAccent,
    AppColors.accent,
    Colors.green,
    Colors.purpleAccent,
    Colors.orange,
  ];
  final index = category.length % colors.length;
  return colors[index];
}

class TodoItemWidget extends StatelessWidget {
  final Todo todo;
  final ToggleCallback onToggle;
  final RemoveCallback onRemove;

  const TodoItemWidget({super.key, required this.todo, required this.onToggle, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(todo.category);
    // ✅ formattedDate ahora se utiliza en el widget
    final formattedDate = todo.dueDate == null 
      ? 'Creada: ${DateFormat.yMd().format(todo.createdAt)}'
      : 'Vence: ${DateFormat.yMd().add_jm().format(todo.dueDate!)}';

    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(todo.id),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      child: Card(
        color: AppColors.cardColor,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        shadowColor: AppColors.shadowColor.withOpacity(0.15),
        child: InkWell(
          onTap: () => onToggle(todo.id),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 15),

                Checkbox(
                  value: todo.completed,
                  onChanged: (_) => onToggle(todo.id), // Recibe bool, llama a onToggle(id)
                  activeColor: color,
                  shape: const CircleBorder(),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: todo.completed ? Colors.grey : AppColors.textPrimary,
                          decoration: todo.completed ? TextDecoration.lineThrough : null,
                          decorationColor: Colors.grey,
                        ),
                      ),
                      
                      if (todo.description.isNotEmpty) 
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            todo.description,
                            style: AppTextStyles.subtitle.copyWith(fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          if (todo.category != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                todo.category!, 
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)
                              ),
                            ),
                          
                          Icon(
                            todo.dueDate != null ? Icons.schedule : Icons.history,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          // formattedDate USADA
                          Text(
                            formattedDate, 
                            style: AppTextStyles.subtitle.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}