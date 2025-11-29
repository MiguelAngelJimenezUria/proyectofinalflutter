import 'package:flutter/foundation.dart';
import '../model/todo.dart';
import 'dart:math';

class TodoViewModel extends ChangeNotifier {
  final List<Todo> _todos = [
    // Agregamos algunos datos de prueba
    Todo(id: '1', title: 'Comprar frutas', description: 'Manzanas y plátanos', category: 'Casa', dueDate: DateTime.now().add(const Duration(days: 1))),
    Todo(id: '2', title: 'Terminar informe', category: 'Trabajo', completed: true),
    Todo(id: '3', title: 'Clase de Flutter', description: 'Revisar Provider y State Management', category: 'Estudio'),
  ];
  final List<String> _categories = ['General', 'Casa', 'Trabajo', 'Estudio'];

  List<Todo> get todos => List.unmodifiable(_todos);
  List<String> get categories => List.unmodifiable(_categories);

  void addCategory(String name) {
    final n = name.trim();
    if (n.isEmpty) return;
    if (_categories.contains(n)) return;
    _categories.add(n);
    notifyListeners();
  }

  void addTodo({required String title, String? description, DateTime? dueDate, String? category}) {
    if (title.trim().isEmpty) return;
    final id = _generateId();
    _todos.insert(
      0,
      Todo(
        id: id,
        title: title.trim(),
        description: description ?? '',
        dueDate: dueDate,
        category: category,
      ),
    );
    notifyListeners();
  }

  void toggleTodo(String id) {
    final i = _todos.indexWhere((t) => t.id == id);
    if (i == -1) return;
    final t = _todos[i];
    _todos[i] = t.copyWith(completed: !t.completed);
    notifyListeners();
  }

  // ✅ CORRECCIÓN FINAL: La función 'removeTodo' existe y es la que usamos en home_page.dart
  void removeTodo(String id) {
    _todos.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void editTodo({required String id, String? title, String? description, DateTime? dueDate, String? category}) {
    final i = _todos.indexWhere((t) => t.id == id);
    if (i == -1) return;
    _todos[i] = _todos[i].copyWith(
      title: title?.trim(),
      description: description,
      dueDate: dueDate,
      category: category,
    );
    notifyListeners();
  }

  void clearCompleted() {
    _todos.removeWhere((t) => t.completed);
    notifyListeners();
  }

  String _generateId() {
    final rnd = Random().nextInt(1000000);
    return '${DateTime.now().millisecondsSinceEpoch}-$rnd';
  }
}