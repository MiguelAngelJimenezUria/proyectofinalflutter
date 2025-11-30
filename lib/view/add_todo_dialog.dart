import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/todo_viewmodel.dart';
import 'styles.dart';

// Definición de tipos de callback
typedef OnAddCategory = void Function(String category);

// Definición del Widget de diálogo
class AddTodoDialog extends StatefulWidget {
  final List<String> categories;
  final OnAddCategory onAddCategory;

  const AddTodoDialog({
    super.key,
    required this.categories,
    required this.onAddCategory, // ✅ CORRECCIÓN DE ERROR 1 (image_574cb8.png)
  });

  @override
  State<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  String? _selectedCategory;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

@override
void initState() {
  super.initState();
  
  // 1. Intentar establecer 'General' como la categoría inicial.
  String? initialCategory;

  if (widget.categories.contains('General')) {
    initialCategory = 'General';
  } else if (widget.categories.isNotEmpty) {
    // 2. Si no existe 'General', usar la primera categoría disponible.
    initialCategory = widget.categories.first;
  }
  
  // 3. Establecer el estado. Si no hay categorías, _selectedCategory queda como null (String?).
  _selectedCategory = initialCategory;
}

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- Funciones Auxiliares de UI ---

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
  
  void _showAddCategoryDialog(BuildContext context) {
    String newCategoryName = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Categoría'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nombre de la Categoría'),
          onChanged: (value) => newCategoryName = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (newCategoryName.trim().isNotEmpty) {
                widget.onAddCategory(newCategoryName.trim());
                setState(() {
                  _selectedCategory = newCategoryName.trim();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  // --- Implementación Principal ---

  @override
  Widget build(BuildContext context) {
    // Escucha el ViewModel solo para la función de guardar.
    final viewModel = Provider.of<TodoViewModel>(context, listen: false);

    // Combina fecha y hora si ambas están seleccionadas
    DateTime? finalDueDate;
    if (_selectedDate != null) {
      finalDueDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime?.hour ?? 23, // 23:59:00 si no se selecciona hora
        _selectedTime?.minute ?? 59,
      );
    }
    
    return AlertDialog(
      title: const Text(
        'Nueva Tarea', 
        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)
      ),
      contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0),
      backgroundColor: AppColors.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Título
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Título',
                hintText: 'Ingresa el título de la tarea',
                prefixIcon: const Icon(Icons.title, color: AppColors.primary),
                labelStyle: TextStyle(color: AppColors.textPrimary.withOpacity(0.7)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 15),

            // 2. Descripción
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción (opcional)',
                prefixIcon: const Icon(Icons.description, color: AppColors.primary),
                labelStyle: TextStyle(color: AppColors.textPrimary.withOpacity(0.7)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            // 3. Selector de Categoría
            Text('Categoría', style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary)),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                ...widget.categories.map((category) => ChoiceChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  selectedColor: AppColors.primary,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category : null;
                    });
                  },
                  backgroundColor: AppColors.background,
                  labelStyle: TextStyle(
                    color: _selectedCategory == category ? AppColors.cardColor : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                )),
                // Botón para nueva categoría
                ActionChip(
                  avatar: const Icon(Icons.add, color: AppColors.primary, size: 18),
                  label: const Text('Nueva', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  onPressed: () => _showAddCategoryDialog(context),
                  backgroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 4. Fecha y Hora de Vencimiento
            Text('Fecha y Hora', style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today, color: AppColors.accent),
              title: Text(_selectedDate == null 
                  ? 'Fecha de vencimiento (opcional)'
                  : 'Fecha: ${finalDueDate != null ? '${finalDueDate.day}/${finalDueDate.month}/${finalDueDate.year}' : ''}'),
              trailing: TextButton(
                onPressed: () => _selectDate(context),
                child: const Text('Elegir', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule, color: AppColors.accent),
              title: Text(_selectedTime == null 
                  ? 'Hora (opcional)'
                  : 'Hora: ${_selectedTime!.format(context)}'),
              trailing: TextButton(
                onPressed: () => _selectTime(context),
                child: const Text('Elegir', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ),
        
        ElevatedButton.icon(
          // ✅ CORRECCIÓN DE FUNCIONALIDAD: Guardar la tarea
          onPressed: () {
            if (_titleController.text.trim().isNotEmpty) {
              viewModel.addTodo(
                title: _titleController.text,
                description: _descriptionController.text,
                dueDate: finalDueDate,
                category: _selectedCategory,
              );
              Navigator.pop(context); // Cerrar el diálogo después de agregar
            } else {
              // Opcional: Mostrar un mensaje si el título está vacío
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('El título de la tarea es obligatorio.')),
              );
            }
          },
          icon: const Icon(Icons.check, color: AppColors.cardColor),
          label: const Text('Agregar Tarea', style: TextStyle(color: AppColors.cardColor, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            elevation: 5,
          ),
        ),
      ],
    );
  }
}