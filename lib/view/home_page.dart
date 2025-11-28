import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/todo_viewmodel.dart';
import 'todo_item_widget.dart';
import 'add_todo_dialog.dart';
import 'styles.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TodoViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('To‑Do App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Limpiar completadas',
            onPressed: vm.clearCompleted,
          )
        ],
      ),
      backgroundColor: AppColors.bg,
      body: vm.todos.isEmpty
          ? const Center(child: Text('No hay tareas. Agrega una usando +'))
          : ListView.separated(
              itemCount: vm.todos.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final t = vm.todos[index];
                return TodoItemWidget(
                  todo: t,
                  onToggle: vm.toggleTodo,
                  onRemove: vm.removeTodo,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await showAddTodoDialog(context, categories: vm.categories, onAddCategory: vm.addCategory);
          if (res != null) {
            vm.addTodo(title: res.title, description: res.description, dueDate: res.dueDate, category: res.category);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
