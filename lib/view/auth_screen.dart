import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'styles.dart'; 

// Este widget manejará el inicio de sesión y el registro.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  String _selectedGender = 'Femenino';
  bool _isLogin = true; 
  bool _isLoading = false;

  void _submitAuthForm(AuthService authService) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // LOGIN
        await authService.signIn(_emailController.text, _passwordController.text);
      } else {
        // REGISTRO
        await authService.signUp(
          _emailController.text, 
          _passwordController.text,
          _usernameController.text,
          _selectedGender,
        );
      }
      
    } catch (e) {
      // Mostrar error al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.accent),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _signInWithGoogle(AuthService authService) async {
    setState(() => _isLoading = true);
    try {
      await authService.signInWithGoogle();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error con Google: $e'), backgroundColor: AppColors.accent),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Iniciar Sesión' : 'Registrarse', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // 1. Campos Comunes
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                  validator: (value) => (value == null || !value.contains('@')) ? 'Introduce un email válido' : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                  validator: (value) => (value == null || value.length < 6) ? 'La contraseña debe tener al menos 6 caracteres' : null,
                ),
                
                // 2. Campos de Registro (Solo para SignUp)
                if (!_isLogin) ...[
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Nombre de Usuario'),
                    validator: (value) => (value == null || value.isEmpty) ? 'Introduce un nombre de usuario' : null,
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(labelText: 'Sexo'),
                    items: ['Femenino', 'Masculino'].map((String gender) {
                      return DropdownMenuItem<String>(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) setState(() => _selectedGender = newValue);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
                
                const SizedBox(height: 20),
                
                // 3. Botón de Enviar (Login/Registro)
                if (_isLoading) 
                  const CircularProgressIndicator(color: AppColors.primary)
                else
                  ElevatedButton(
                    onPressed: () => _submitAuthForm(authService),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      _isLogin ? 'Iniciar Sesión' : 'Registrarse',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                
                const SizedBox(height: 20),

                // 4. Botón de Google
                ElevatedButton.icon(
                  icon: Image.asset('assets/google_icon.png', height: 24.0), // Reemplaza con una imagen real
                  label: Text('Google', style: TextStyle(color: AppColors.textPrimary)),
                  onPressed: _isLoading ? null : () => _signInWithGoogle(authService),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cardColor,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey.shade300)),
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // 5. Cambiar entre Login y Registro
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                      _formKey.currentState?.reset();
                    });
                  },
                  child: Text(
                    _isLogin ? '¿No tienes cuenta? Regístrate' : '¿Ya tienes cuenta? Inicia Sesión',
                    style: const TextStyle(color: AppColors.primary),
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