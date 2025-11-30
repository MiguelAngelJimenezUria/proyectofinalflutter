import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Rutas de importación: ajusta si tus archivos están en otra carpeta
import '../viewmodel/todo_viewmodel.dart';
import 'add_todo_dialog.dart';
import 'todo_item_widget.dart';
import 'styles.dart';

// Importaciones de Pestañas Funcionales (Deben estar en la misma carpeta 'view/')
import 'calendar_tab.dart'; // Tu archivo funcional de calendario
import 'pomodoro_tab.dart'; // Tu archivo funcional de pomodoro (corregido sin la doble 'b' si es posible)

// Definición de las pestañas que permanecen en home_page.dart (si es que no tienen archivos separados)
class TodoListTab extends StatelessWidget {
  final void Function() showAddTodoDialog;

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
              onToggle: (_) => viewModel.toggleTodo(todo.id),
              onRemove: (_) => viewModel.removeTodo(todo.id),
            );
          },
        );
      },
    );
  }
}

// **IMPORTANTE:** Las clases CalendarTab y PomodoroTab fueron ELIMINADAS de aquí
// y se usan las clases importadas de sus propios archivos.

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
    // ✅ Aquí se usan las clases importadas de los archivos separados
    _widgetOptions = <Widget>[
      TodoListTab(showAddTodoDialog: () => _showAddTodoDialog(context)),
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

      floatingActionButton: _selectedIndex == 0 ? FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context),
        backgroundColor: AppColors.accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
      
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