import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/todo.dart';
import '../viewmodel/todo_viewmodel.dart';
import 'styles.dart';

class EditTodoDialog extends StatefulWidget {
  final Todo todo;
  final List<String> categories;

  const EditTodoDialog({
    super.key,
    required this.todo,
    required this.categories,
  });

  @override
  State<EditTodoDialog> createState() => _EditTodoDialogState();
}

class _EditTodoDialogState extends State<EditTodoDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  
  bool _debugInitLogged = false;
  String? _selectedCategory;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    
    // Debug: log that initState ran
    try {
      debugPrint('🛠️ EditTodoDialog.initState for todo id=${widget.todo.id}');
      _debugInitLogged = true;
    } catch (e) {
      // ignore
    }
    // Inicializar con los datos actuales de la tarea
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController = TextEditingController(text: widget.todo.description);
    _selectedCategory = widget.todo.category;
    
    // Inicializar fecha y hora si existen
    if (widget.todo.dueDate != null) {
      _selectedDate = widget.todo.dueDate;
      _selectedTime = TimeOfDay(
        hour: widget.todo.dueDate!.hour,
        minute: widget.todo.dueDate!.minute,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

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
  
  // adding categories removed

  @override
  Widget build(BuildContext context) {
    // Match AddTodoDialog: read the ViewModel to obtain current categories
    final vm = Provider.of<TodoViewModel>(context, listen: true);
    final currentCategories = vm.categories;

    // Combina fecha y hora si ambas están seleccionadas
    DateTime? finalDueDate;
    if (_selectedDate != null) {
      finalDueDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime?.hour ?? 23,
        _selectedTime?.minute ?? 59,
      );
    }
    
    return AlertDialog(
      title: const Text(
        'Editar Tarea', 
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
                ...currentCategories.map((category) => ChoiceChip(
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
                // (Adding categories removed)
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () => setState(() {
                        _selectedDate = null;
                        _selectedTime = null;
                      }),
                    ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Elegir', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule, color: AppColors.accent),
              title: Text(_selectedTime == null 
                  ? 'Hora (opcional)'
                  : 'Hora: ${_selectedTime!.format(context)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedTime != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () => setState(() => _selectedTime = null),
                    ),
                  TextButton(
                    onPressed: () => _selectTime(context),
                    child: const Text('Elegir', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                  ),
                ],
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
          onPressed: () async {
            if (_titleController.text.trim().isNotEmpty) {
              try {
                await vm.editTodo(
                  id: widget.todo.id,
                  title: _titleController.text.trim(),
                  description: _descriptionController.text.trim(),
                  dueDate: finalDueDate,
                  category: _selectedCategory,
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tarea actualizada exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al actualizar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('El título de la tarea es obligatorio.')),
              );
            }
          },
          icon: const Icon(Icons.save, color: AppColors.cardColor),
          label: const Text('Guardar Cambios', style: TextStyle(color: AppColors.cardColor, fontWeight: FontWeight.bold)),
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
