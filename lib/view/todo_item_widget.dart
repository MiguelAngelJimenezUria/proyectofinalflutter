import 'package:flutter/material.dart';
import '../model/todo.dart';

typedef ToggleCallback = void Function(String id);
typedef RemoveCallback = void Function(String id);

class TodoItemWidget extends StatelessWidget {
  final Todo todo;
  final ToggleCallback onToggle;
  final RemoveCallback onRemove;

  const TodoItemWidget({super.key, required this.todo, required this.onToggle, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(todo.id),
      background: Container(
        color: Colors.redAccent,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        leading: Checkbox(
          value: todo.completed,
          onChanged: (_) => onToggle(todo.id),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description.isNotEmpty) Text(todo.description),
            const SizedBox(height: 4),
            Row(
              children: [
                if (todo.category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                    child: Text(todo.category!, style: const TextStyle(fontSize: 12)),
                  ),
                Text(
                  todo.dueDate == null ? todo.createdAt.toLocal().toString().split('.').first : todo.dueDate!.toLocal().toString().split('.').first,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
