import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

const String supabaseUrl = '[TU_URL_SUPABASE]'; 
const String supabaseAnonKey = '[TU_ANON_KEY_SUPABASE]';

final SupabaseClient supabase = Supabase.instance.client;

class AuthService with ChangeNotifier {
  Session? _session;
  Map<String, dynamic>? _userMetadata;

  bool get isAuthenticated => _session != null;
  User? get currentUser => _session?.user;
  String get username => _userMetadata?['username'] ?? 'Usuario';
  String get gender => _userMetadata?['gender'] ?? 'No especificado';
  String? get avatarUrl => _userMetadata?['avatar_url'] as String?;

  AuthService() {
    _initAuthListener();
    _loadInitialSession();
  }

  void _initAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      _session = data.session;
      _userMetadata = _session?.user.userMetadata;

      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.initialSession) {
        _fetchUserMetadata(data.session?.user.id);
      } else if (event == AuthChangeEvent.signedOut) {
        _userMetadata = null; // Limpiar datos al cerrar sesión
      }
      notifyListeners();
    });
  }

  Future<void> _loadInitialSession() async {
    final session = supabase.auth.currentSession;
    if (session != null) {
      _session = session;
      await _fetchUserMetadata(session.user.id);
    }
    notifyListeners();
  }

  Future<void> _fetchUserMetadata(String? userId) async {
    if (userId == null) return;
    
    final response = await supabase
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .single()
        .limit(1);

    if (response != null) {
        _userMetadata = response;
    } else {
        _userMetadata = {'username': currentUser?.email?.split('@').first ?? 'Nuevo Usuario', 'gender': 'No especificado'};
    }
    notifyListeners();
  }

  // ----------------------------------------------------------------------
  // 2. MÉTODOS DE AUTENTICACIÓN
  // ----------------------------------------------------------------------

  // 2.1. Login Convencional (Email/Password)
  Future<void> signIn(String email, String password) async {
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Ocurrió un error inesperado al iniciar sesión: $e';
    }
  }

  // 2.2. Registro Convencional (Email/Password + Metadatos)
  Future<void> signUp(String email, String password, String username, String gender) async {
    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: email, 
        password: password,
        // Puedes añadir metadatos iniciales aquí, pero para datos sensibles es mejor una tabla aparte
        data: {'username_temp': username, 'gender_temp': gender}, 
      );
      
      final user = response.user;
      if (user != null) {
        await supabase.from('user_profiles').insert({
          'id': user.id,
          'email': user.email,
          'username': username,
          'gender': gender,
          'avatar_url': null,
          'created_at': DateTime.now().toIso8601String(),
        });
        await _fetchUserMetadata(user.id);
      }
      
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Ocurrió un error inesperado al registrarse: $e';
    }
  }
  
  Future<void> signInWithGoogle() async {
    try {
        await supabase.auth.signInWithOAuth(
            OAuthProvider.google,
            redirectTo: 'io.supabase.flutterquickstart://login-callback/',
        );
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Ocurrió un error inesperado con Google: $e';
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<void> updateProfile({String? newUsername, String? newGender, String? newAvatarUrl}) async {
    if (currentUser == null) return;
    
    final updates = <String, dynamic>{};
    if (newUsername != null) updates['username'] = newUsername;
    if (newGender != null) updates['gender'] = newGender;
    if (newAvatarUrl != null) updates['avatar_url'] = newAvatarUrl;

    if (updates.isNotEmpty) {
      await supabase
        .from('user_profiles')
        .update(updates)
        .eq('id', currentUser!.id);
        
      await _fetchUserMetadata(currentUser!.id);
    }
  }

}