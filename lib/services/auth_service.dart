import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user.dart';
import 'api_service.dart';

/// Servicio de autenticación que usa el backend Spring Boot
class AuthService with ChangeNotifier {
  User? _currentUser;
  
  // Keys para almacenamiento
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';

  bool get isAuthenticated => _currentUser != null;
  User? get currentUser => _currentUser;
  String get username => _currentUser?.username ?? 'Usuario';
  String get gender => _currentUser?.gender ?? 'No especificado';
  String? get avatarUrl => _currentUser?.avatarUrl;
  String? get userId => _currentUser?.id;

  AuthService() {
    // Cargar usuario en background sin bloquear la UI
    Future.microtask(() => _loadStoredUser());
  }

  /// Cargar usuario almacenado al iniciar la app
  Future<void> _loadStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getString(_userIdKey);
      final storedEmail = prefs.getString(_userEmailKey);
      
      if (storedUserId != null && storedEmail != null) {
        // Por ahora solo crear el usuario con los datos guardados localmente
        // No intentar conectar al servidor al iniciar
        _currentUser = User(
          id: storedUserId,
          email: storedEmail,
          username: storedEmail.split('@').first,
        );
        notifyListeners();
        
        // Intentar actualizar datos del servidor en segundo plano
        _refreshUserDataInBackground(storedUserId);
      }
    } catch (e) {
      print('Error al cargar usuario almacenado: $e');
      // No hacer nada si falla, simplemente no hay usuario guardado
    }
  }

  /// Refrescar datos del usuario en segundo plano
  Future<void> _refreshUserDataInBackground(String userId) async {
    try {
      final user = await ApiService.getUserById(userId);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    } catch (e) {
      print('Error al refrescar datos del usuario: $e');
      // No hacer nada, usamos los datos locales
    }
  }

  /// Guardar datos del usuario en almacenamiento
  Future<void> _saveUserToStorage(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, user.id);
      await prefs.setString(_userEmailKey, user.email ?? '');
    } catch (e) {
      print('Error al guardar usuario: $e');
    }
  }

  /// Limpiar almacenamiento
  Future<void> _clearStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);
      await prefs.remove(_userEmailKey);
    } catch (e) {
      print('Error al limpiar almacenamiento: $e');
    }
  }

  // ----------------------------------------------------------------------
  // MÉTODOS DE AUTENTICACIÓN
  // ----------------------------------------------------------------------

  /// Login con email y contraseña
  Future<void> signIn(String email, String password) async {
    try {
      final user = await ApiService.login(email, password);
      if (user != null) {
        _currentUser = user;
        await _saveUserToStorage(user);
        notifyListeners();
      } else {
        throw 'Email o contraseña incorrectos';
      }
    } catch (e) {
      throw 'Error al iniciar sesión: $e';
    }
  }

  /// Registro de nuevo usuario
  Future<void> signUp(String email, String password, String username, String gender) async {
    try {
      final user = await ApiService.createUser(
        email: email,
        password: password,
        username: username,
        gender: gender,
      );
      
      if (user != null) {
        _currentUser = user;
        await _saveUserToStorage(user);
        notifyListeners();
      } else {
        throw 'No se pudo crear el usuario';
      }
    } catch (e) {
      throw 'Error al registrarse: $e';
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    _currentUser = null;
    await _clearStorage();
    notifyListeners();
  }

  /// Actualizar perfil del usuario (placeholder - necesitarás implementar endpoint en backend)
  Future<void> updateProfile({String? newUsername, String? newGender, String? newAvatarUrl}) async {
    if (_currentUser == null) return;
    
    // TODO: Implementar endpoint PUT /api/users/{id} en el backend Spring Boot
    // Por ahora, solo actualizamos localmente
    _currentUser = _currentUser!.copyWith(
      username: newUsername,
      gender: newGender,
      avatarUrl: newAvatarUrl,
    );
    
    await _saveUserToStorage(_currentUser!);
    notifyListeners();
  }

  /// Refrescar datos del usuario actual
  Future<void> refreshUser() async {
    if (_currentUser == null) return;
    
    try {
      final updatedUser = await ApiService.getUserById(_currentUser!.id);
      if (updatedUser != null) {
        _currentUser = updatedUser;
        await _saveUserToStorage(updatedUser);
        notifyListeners();
      }
    } catch (e) {
      print('Error al refrescar usuario: $e');
    }
  }
}