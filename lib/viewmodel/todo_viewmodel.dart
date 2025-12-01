import 'package:flutter/foundation.dart';
import '../model/todo.dart';
import '../services/api_service.dart';

class TodoViewModel extends ChangeNotifier {
  final List<Todo> _todos = [];
  final List<String> _categories = ['General', 'Casa', 'Trabajo', 'Estudio'];
  bool _isLoading = false;
  String? _currentUserId;

  List<Todo> get todos => List.unmodifiable(_todos);
  List<String> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;

  /// Establecer el usuario actual y cargar sus tareas
  Future<void> setUser(String? userId) async {
    _currentUserId = userId;
    if (userId != null) {
      await loadTodos();
    } else {
      _todos.clear();
      notifyListeners();
    }
  }

  /// Cargar todas las tareas del usuario desde el backend
  Future<void> loadTodos() async {
    if (_currentUserId == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final remoteTodos = await ApiService.getTodosByUserId(_currentUserId!);
      _todos.clear();
      _todos.addAll(remoteTodos);
    } catch (e) {
      print('Error al cargar tareas: $e');
      // No crashear si no hay conexión, simplemente mantener lista vacía
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addCategory(String name) {
    final n = name.trim();
    if (n.isEmpty) return;
    if (_categories.contains(n)) return;
    try {
      debugPrint('🔧 TodoViewModel.addCategory BEFORE add: $n');
      _categories.add(n);
      // Notify listeners; wrap in try/catch to capture unexpected errors during rebuilds
      try {
        notifyListeners();
        debugPrint('🔧 TodoViewModel.addCategory AFTER notifyListeners: $n');
      } catch (e, st) {
        debugPrint('❌ Error during notifyListeners in addCategory: $e\n$st');
        rethrow;
      }
    } catch (e, st) {
      debugPrint('❌ Unexpected error in addCategory: $e\n$st');
      rethrow;
    }
  }

  /// Agregar tarea (persiste en el backend)
  Future<void> addTodo({
    required String title,
    String? description,
    DateTime? dueDate,
    String? category,
  }) async {
    if (title.trim().isEmpty || _currentUserId == null) return;

    try {
      final newTodo = await ApiService.createTodo(
        userId: _currentUserId!,
        title: title.trim(),
        description: description,
        category: category,
        dueDate: dueDate,
      );

      if (newTodo != null) {
        _todos.insert(0, newTodo);
        notifyListeners();
      }
    } catch (e) {
      print('Error al crear tarea: $e');
      rethrow;
    }
  }

  /// Cambiar estado completado de una tarea (toggle)
  Future<void> toggleTodo(String id) async {
    try {
      final success = await ApiService.toggleTodo(id);
      if (success) {
        final i = _todos.indexWhere((t) => t.id == id);
        if (i != -1) {
          final t = _todos[i];
          _todos[i] = t.copyWith(completed: !t.completed);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error al hacer toggle de tarea: $e');
      rethrow;
    }
  }

  /// Eliminar tarea (del backend y local)
  Future<void> removeTodo(String id) async {
    try {
      final success = await ApiService.deleteTodo(id);
      if (success) {
        _todos.removeWhere((t) => t.id == id);
        notifyListeners();
      }
    } catch (e) {
      print('Error al eliminar tarea: $e');
      rethrow;
    }
  }

  /// Editar tarea existente
  Future<void> editTodo({
    required String id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? category,
  }) async {
    try {
      final updatedTodo = await ApiService.updateTodo(
        id,
        title: title?.trim(),
        description: description,
        dueDate: dueDate,
        category: category,
      );

      if (updatedTodo != null) {
        final i = _todos.indexWhere((t) => t.id == id);
        if (i != -1) {
          _todos[i] = updatedTodo;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error al editar tarea: $e');
      rethrow;
    }
  }

  /// Limpiar tareas completadas
  Future<void> clearCompleted() async {
    final completedIds = _todos.where((t) => t.completed).map((t) => t.id).toList();
    
    try {
      for (final id in completedIds) {
        await ApiService.deleteTodo(id);
      }
      _todos.removeWhere((t) => t.completed);
      notifyListeners();
    } catch (e) {
      print('Error al limpiar tareas completadas: $e');
      rethrow;
    }
  }

  /// Filtrar tareas por categoría
  Future<List<Todo>> getTodosByCategory(String category) async {
    if (_currentUserId == null) return [];
    
    try {
      return await ApiService.getTodosByCategory(_currentUserId!, category);
    } catch (e) {
      print('Error al filtrar por categoría: $e');
      return [];
    }
  }

  /// Filtrar tareas por estado
  Future<List<Todo>> getTodosByCompletion(bool completed) async {
    if (_currentUserId == null) return [];
    
    try {
      return await ApiService.getTodosByCompletion(_currentUserId!, completed);
    } catch (e) {
      print('Error al filtrar por estado: $e');
      return [];
    }
  }
}