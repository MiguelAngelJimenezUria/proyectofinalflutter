import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/user.dart';
import '../model/todo.dart';

/// Servicio centralizado para realizar llamadas HTTP al backend Spring Boot
class ApiService {
  // ⚠️ CAMBIAR ESTA URL A LA DE TU BACKEND (localhost, IP o dominio)
  static const String baseUrl = 'http://10.0.2.2:8080/api';
  
  // Headers comunes para todas las peticiones
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  // ============================================================
  // HELPER: Formatear fecha para backend
  // ============================================================
  
  /// Formatea DateTime a "2025-12-05T18:00:00" (sin milisegundos, sin Z)
  static String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return date.toIso8601String().split('.')[0];
  }

  // ============================================================
  // AUTENTICACIÓN (/api/auth)
  // ============================================================

  /// Login con email y contraseña
  /// Devuelve el usuario si es exitoso, null si falla
  static Future<User?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          return User.fromJson(data['user']);
        }
      }
      return null;
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }

  // ============================================================
  // USUARIOS (/api/users)
  // ============================================================

  /// Crear nuevo usuario (registro)
  static Future<User?> createUser({
    required String email,
    required String password,
    String? username,
    String? gender,
    String? avatarUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'username': username ?? '',
          'gender': gender,
          'avatarUrl': avatarUrl,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return User.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error al crear usuario: $e');
      return null;
    }
  }

  /// Obtener todos los usuarios
  static Future<List<User>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error al obtener usuarios: $e');
      return [];
    }
  }

  /// Obtener usuario por ID
  static Future<User?> getUserById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error al obtener usuario por ID: $e');
      return null;
    }
  }

  /// Obtener usuario por email
  static Future<User?> getUserByEmail(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/email/$email'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error al obtener usuario por email: $e');
      return null;
    }
  }

  // ============================================================
  // TODOS (/api/todos)
  // ============================================================

  /// Crear nueva tarea
  static Future<Todo?> createTodo({
    required String userId,
    required String title,
    String? description,
    String? category,
    DateTime? dueDate,
    bool completed = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/todos/user/$userId'),
        headers: _headers,
        body: jsonEncode({
          'title': title,
          'description': description ?? '',
          'category': category,
          'dueDate': _formatDate(dueDate),
          'completed': completed,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Todo.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error al crear todo: $e');
      return null;
    }
  }

  /// Obtener todas las tareas
  static Future<List<Todo>> getAllTodos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/todos'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Todo.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error al obtener todos: $e');
      return [];
    }
  }

  /// Obtener tarea por ID
  static Future<Todo?> getTodoById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/todos/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return Todo.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error al obtener todo por ID: $e');
      return null;
    }
  }

  /// Obtener todas las tareas de un usuario
  static Future<List<Todo>> getTodosByUserId(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/todos/user/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Todo.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error al obtener todos del usuario: $e');
      return [];
    }
  }

  /// Filtrar tareas por estado (completadas/pendientes)
  static Future<List<Todo>> getTodosByCompletion(String userId, bool completed) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/todos/user/$userId/completed?completed=$completed'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Todo.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error al filtrar todos por estado: $e');
      return [];
    }
  }

  /// Filtrar tareas por categoría
  static Future<List<Todo>> getTodosByCategory(String userId, String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/todos/user/$userId/category/$category'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Todo.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error al filtrar todos por categoría: $e');
      return [];
    }
  }

  /// Actualizar tarea
  static Future<Todo?> updateTodo(String id, {
    String? title,
    String? description,
    String? category,
    DateTime? dueDate,
    bool? completed,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/todos/$id'),
        headers: _headers,
        body: jsonEncode({
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (category != null) 'category': category,
          if (dueDate != null) 'dueDate': _formatDate(dueDate),
          if (completed != null) 'completed': completed,
        }),
      );

      if (response.statusCode == 200) {
        return Todo.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error al actualizar todo: $e');
      return null;
    }
  }

  /// Cambiar estado completado (toggle)
  static Future<bool> toggleTodo(String id) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/todos/$id/toggle'),
        headers: _headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error al hacer toggle de todo: $e');
      return false;
    }
  }

  /// Eliminar tarea
  static Future<bool> deleteTodo(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/todos/$id'),
        headers: _headers,
      );

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Error al eliminar todo: $e');
      return false;
    }
  }
}
