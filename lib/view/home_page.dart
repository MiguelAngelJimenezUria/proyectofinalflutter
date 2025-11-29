import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/todo_viewmodel.dart';
import 'add_todo_dialog.dart';
import 'todo_item_widget.dart';
import 'styles.dart';

// --- NUEVAS PESTAÑAS (PLACEHOLDERS) ---

class TodoListTab extends StatelessWidget {
  final Function showAddTodoDialog;

  const TodoListTab({super.key, required this.showAddTodoDialog});

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
            
            return TodoItemWidget(
              todo: todo,
              // ✅ CORRECCIÓN DE TIPO: Acepta un parámetro (_) y llama a la función de toggle
              onToggle: (_) => viewModel.toggleTodo(todo.id),
              // ✅ CORRECCIÓN DE TIPO: Acepta un parámetro (_) y llama a la función de remove
              onRemove: (_) => viewModel.removeTodo(todo.id),
            );
          },
        );
      },
    );
  }
}

class CalendarTab extends StatelessWidget {
  const CalendarTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Calendario', style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary)),
    );
  }
}

class PomodoroTab extends StatelessWidget {
  const PomodoroTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Temporizador Pomodoro', style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary)),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Perfil de Usuario', style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary)),
    );
  }
}


// --- CLASE PRINCIPAL HOME PAGE ---

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
      TodoListTab(showAddTodoDialog: _showAddTodoDialog),
      const CalendarTab(),
      const PomodoroTab(),
      const ProfileTab(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // ✅ CORRECCIÓN FINAL: Implementación correcta con parámetros requeridos por AddTodoDialog
  void _showAddTodoDialog(BuildContext context) {
    final viewModel = Provider.of<TodoViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddTodoDialog(
          categories: viewModel.categories, 
          onAddCategory: (newCategory) {
            viewModel.addCategory(newCategory); 
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBar = _selectedIndex == 0
        ? AppBar(
            // ✅ CORRECCIÓN DE COLOR: Usamos AppColors.textPrimary
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
      
      // ✅ IMPLEMENTACIÓN DE BARRA DE NAVEGACIÓN INFERIOR
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
        unselectedItemColor: Colors.grey.shade600,
        backgroundColor: AppColors.cardColor,
        elevation: 10,
        onTap: _onItemTapped,
      ),
    );
  }
}