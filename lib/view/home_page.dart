import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importaciones para autenticación
import '../services/auth_service.dart'; 

// Importaciones de modelos y viewmodels
import '../model/todo.dart'; 
import '../viewmodel/todo_viewmodel.dart';

// Importaciones de Vistas y Estilos
import 'add_todo_dialog.dart';
import 'edit_todo_dialog.dart';
import 'todo_item_widget.dart';
import 'styles.dart';

// Importaciones de Pestañas Funcionales
import 'calendar_tab.dart'; 
import 'pomodoro_tab.dart'; 


// ----------------------------------------------------------------------
// 1. DEFINICIÓN DE PESTAÑAS (TodoListTab, CalendarTab, PomodoroTab...)
// ----------------------------------------------------------------------

// La clase TodoListTab se mantiene igual
class TodoListTab extends StatelessWidget {
  final void Function() showAddTodoDialog;

  const TodoListTab({super.key, required this.showAddTodoDialog});

  // Función para abrir directamente el diálogo de edición
  void _showTodoDetails(BuildContext context, Todo todo) {
    print('🔍 Abriendo EditTodoDialog para: ${todo.title}');
    final viewModel = Provider.of<TodoViewModel>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        print('✅ Builder ejecutándose');
        // Pasamos el viewModel al widget para evitar problemas de contexto del Provider dentro del modal
        return EditTodoDialog(
          todo: todo,
          categories: viewModel.categories,
        );
      },
    ).then((value) {
      print('Dialog cerrado con valor: $value');
    }).catchError((error) {
      print('❌ Error en dialog: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.todos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_box_outline_blank, size: 80, color: Colors.grey),
                const SizedBox(height: 10),
                Text('¡No tienes tareas!', style: TextStyle(fontSize: 18, color: Colors.grey.shade700)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: viewModel.todos.length,
          itemBuilder: (context, index) {
            final todo = viewModel.todos[index];
            
            // ⭐️ Implementación de Dismissible solo para ELIMINAR (swipe izquierda)
            return Dismissible(
              key: Key(todo.id), 
              direction: DismissDirection.endToStart, // Solo swipe a la izquierda

              // SWIPE A LA IZQUIERDA (endToStart) -> ELIMINAR
              background: Container(
                color: AppColors.accent, 
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20.0),
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
              ),

              confirmDismiss: (direction) async {
                // Confirmación para eliminar
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Confirmar Eliminación"),
                      content: Text("¿Estás seguro de que quieres eliminar la tarea: ${todo.title}?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text("Cancelar"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text("Eliminar", style: TextStyle(color: AppColors.accent)),
                        ),
                      ],
                    );
                  },
                );
              },

              onDismissed: (direction) {
                // Eliminar la tarea
                viewModel.removeTodo(todo.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tarea "${todo.title}" eliminada')),
                );
              },
              
              // El widget principal de la lista
              child: TodoItemWidget(
                todo: todo,
                onToggle: (_) => viewModel.toggleTodo(todo.id),
                onRemove: (_) => viewModel.removeTodo(todo.id), // No se usa por el swipe, pero es requerido
                onTap: (t) => _showTodoDetails(context, t), 
              ),
            );
          },
        );
      },
    );
  }
}

// ----------------------------------------------------------------------
// 🚨 CLASE PROFILE TAB MODIFICADA CON LÓGICA DE AUTENTICACIÓN
// ----------------------------------------------------------------------

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  // Función para mostrar la lista de tareas pendientes
  void _showPendingTodos(BuildContext context, TodoViewModel viewModel) {
    final pendingTodos = viewModel.todos.where((t) => !t.completed).toList();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '📋 Tareas Pendientes (${pendingTodos.length})', 
                    style: AppTextStyles.titleLarge.copyWith(fontSize: 22)
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: pendingTodos.isEmpty
                      ? const Center(child: Text('¡Todas tus tareas están completas!', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: pendingTodos.length,
                          itemBuilder: (context, index) {
                            final todo = pendingTodos[index];
                            return ListTile(
                              title: Text(todo.title, style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                              subtitle: Text(todo.description.isNotEmpty ? todo.description : 'Sin descripción'),
                              trailing: Checkbox(
                                value: todo.completed,
                                onChanged: (val) => viewModel.toggleTodo(todo.id),
                                activeColor: AppColors.primary,
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  // Función placeholder para la edición de perfil
  void _editProfile(BuildContext context, AuthService authService) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Función de Edición de Perfil Pendiente')),
      );
      // Aquí se implementaría la lógica para cambiar la foto, nombre de usuario, etc.
  }

  @override
  Widget build(BuildContext context) {
    // Escuchar el estado de autenticación y el ViewModel de tareas
    final authService = Provider.of<AuthService>(context);
    final todoViewModel = Provider.of<TodoViewModel>(context);

    // Mostrar el perfil del usuario autenticado
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        // Sección de Encabezado/Foto
        Center(
          child: Column(
            children: [
              // Foto de perfil con botón de cambio
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    // Si existe un avatar_url, lo usa; si no, usa el icono
                    backgroundImage: authService.avatarUrl != null
                        ? NetworkImage(authService.avatarUrl!) as ImageProvider
                        : null,
                    child: authService.avatarUrl == null
                        ? Icon(Icons.person, size: 60, color: AppColors.primary)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () => _editProfile(context, authService), // Abrir selector de imagen/edición
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              // Nombre de Usuario
              Text(
                authService.username, 
                style: AppTextStyles.titleLarge.copyWith(fontSize: 24)
              ),
              // Email
              Text(
                authService.currentUser?.email ?? 'Email no disponible', 
                style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary)
              ),
            ],
          ),
        ),
        
        const Divider(height: 40, thickness: 1),

        // Opciones de Perfil
        _buildProfileInfoTile(context, Icons.info_outline, 'Nombre de Usuario', authService.username, () => _editProfile(context, authService)),
        _buildProfileInfoTile(context, Icons.wc_outlined, 'Sexo', authService.gender, () => _editProfile(context, authService)),

        const SizedBox(height: 20),

        // Botón para ver tareas pendientes
        ListTile(
          leading: const Icon(Icons.list_alt, color: AppColors.primary),
          title: Text('Ver Tareas Pendientes', style: TextStyle(color: AppColors.textPrimary)),
          trailing: Chip(
            label: Text(
              // Cuenta las tareas NO completadas
              todoViewModel.todos.where((t) => !t.completed).length.toString(), 
              style: const TextStyle(color: Colors.white)
            ),
            backgroundColor: AppColors.accent,
          ),
          onTap: () => _showPendingTodos(context, todoViewModel),
        ),

        const SizedBox(height: 30),

        // Botón de Cerrar Sesión
        ElevatedButton.icon(
          icon: const Icon(Icons.logout, color: Colors.white),
          label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white, fontSize: 16)),
          onPressed: () async {
            await authService.signOut();
            // Limpiar las tareas al cerrar sesión
            todoViewModel.setUser(null);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sesión cerrada con éxito.')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
  
  // Widget helper para las opciones de perfil
  Widget _buildProfileInfoTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary)),
        subtitle: Text(subtitle, style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}


// ----------------------------------------------------------------------
// 2. CLASE PRINCIPAL HOME PAGE
// ----------------------------------------------------------------------

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; 

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      TodoListTab(showAddTodoDialog: () => _showAddTodoDialog(context)),
      const CalendarTab(),
      const PomodoroTab(),
      const ProfileTab(), // Ahora usa la lógica de autenticación
    ];
    
    // Cargar tareas del usuario al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserTodos();
    });
  }

  /// Cargar las tareas del usuario autenticado
  void _loadUserTodos() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final todoViewModel = Provider.of<TodoViewModel>(context, listen: false);
    
    if (authService.isAuthenticated && authService.userId != null) {
      todoViewModel.setUser(authService.userId);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddTodoDialog(BuildContext context) {
    final viewModel = Provider.of<TodoViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddTodoDialog(
          categories: viewModel.categories,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // El AppBar solo se muestra en la pestaña de Tareas (índice 0)
    final appBar = _selectedIndex == 0
        ? AppBar(
            title: const Text(
              'Mis Tareas Pendientes', 
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
          )
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: appBar,
      
      body: _widgetOptions.elementAt(_selectedIndex), 

      // Muestra el FAB solo en la pestaña de tareas (índice 0)
      floatingActionButton: _selectedIndex == 0 ? FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context),
        backgroundColor: AppColors.accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
      
      // Barra de Navegación Inferior
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box_outlined),
            label: 'Tareas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            label: 'Pomodoro',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Usuario',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary, 
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.cardColor,
        elevation: 10,
        onTap: _onItemTapped,
      ),
    );
  }
}