import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importar para formateo de fecha
import 'styles.dart';

class AddTodoResult {
  final String title;
  final String description;
  final String? category;
  final DateTime? dueDate;

  AddTodoResult({required this.title, this.description = '', this.category, this.dueDate});
}

class AddTodoDialog extends StatefulWidget {
  final List<String> categories;
  final void Function(String) onAddCategory;

  const AddTodoDialog({super.key, required this.categories, required this.onAddCategory});

  @override
  State<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  
  late List<String> _localCategories;
  int _selectedCategoryIndex = 0;
  DateTime? _pickedDate;
  TimeOfDay? _pickedTime;

  @override
  void initState() {
    super.initState();
    _localCategories = List<String>.from(widget.categories);
    if (_localCategories.isEmpty) {
      _localCategories.add('General');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  DateTime? get _combinedDateTime {
    if (_pickedDate == null) return null;
    final t = _pickedTime ?? const TimeOfDay(hour: 0, minute: 0);
    return DateTime(_pickedDate!.year, _pickedDate!.month, _pickedDate!.day, t.hour, t.minute);
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _pickedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary, // Color de acento en el picker
              onPrimary: Colors.white,
              surface: AppColors.cardColor,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.cardColor,
          ),
          child: child!,
        );
      }
    );
    if (d != null) {
      setState(() => _pickedDate = d);
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _pickedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary, // Color de acento en el picker
              onPrimary: Colors.white,
              surface: AppColors.cardColor,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.cardColor,
          ),
          child: child!,
        );
      }
    );
    if (t != null) {
      setState(() => _pickedTime = t);
    }
  }

  Future<void> _addNewCategory() async {
    final controller = TextEditingController();
    final newCat = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Nueva categoría'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Nombre de la categoría',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onSubmitted: (value) => Navigator.pop(ctx, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textPrimary)),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              Navigator.pop(ctx, text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );

    if (newCat != null && newCat.trim().isNotEmpty) {
      final trimmed = newCat.trim();
      if (!_localCategories.contains(trimmed)) {
        setState(() {
          _localCategories.add(trimmed);
          _selectedCategoryIndex = _localCategories.length - 1;
        });
        widget.onAddCategory(trimmed);
      }
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    Navigator.pop(
      context,
      AddTodoResult(
        title: title,
        description: _descController.text.trim(),
        category: _localCategories[_selectedCategoryIndex],
        dueDate: _combinedDateTime,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    required IconData icon,
    int maxLines = 1,
    TextInputAction action = TextInputAction.done,
    bool autofocus = false,
  }) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      maxLines: maxLines,
      textInputAction: action,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.grey.shade100,
        prefixIcon: Icon(icon, color: AppColors.primary.withOpacity(0.7)),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Nueva Tarea', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _titleController,
                labelText: 'Título',
                hintText: 'Ingresa el título de la tarea',
                icon: Icons.title,
                action: TextInputAction.next,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descController,
                labelText: 'Descripción (opcional)',
                hintText: 'Detalles adicionales',
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Sección de Categoría
              const Text('Categoría', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ..._localCategories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final cat = entry.value;
                    final isSelected = index == _selectedCategoryIndex;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.primary.withOpacity(0.9),
                      backgroundColor: Colors.grey.shade200,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: isSelected 
                            ? BorderSide.none 
                            : BorderSide(color: Colors.grey.shade300),
                      ),
                      onSelected: (_) {
                        setState(() => _selectedCategoryIndex = index);
                      },
                    );
                  }),
                  ActionChip(
                    label: const Text('Nueva', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    avatar: const Icon(Icons.add, size: 18, color: AppColors.primary),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onPressed: _addNewCategory,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sección de Fecha y Hora
              const Text('Fecha y hora', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildDateTimeRow(
                      icon: Icons.calendar_today_outlined,
                      label: _pickedDate == null
                          ? 'Fecha de vencimiento (opcional)'
                          : DateFormat.yMMMd().format(_pickedDate!),
                      onPressed: _pickDate,
                    ),
                    const Divider(height: 20),
                    _buildDateTimeRow(
                      icon: Icons.access_time,
                      label: _pickedTime == null 
                          ? 'Hora (opcional)' 
                          : _pickedTime!.format(context),
                      onPressed: _pickTime,
                    ),
                    if (_pickedDate != null || _pickedTime != null)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _pickedDate = null;
                            _pickedTime = null;
                          });
                        },
                        icon: const Icon(Icons.clear, size: 18),
                        label: const Text('Limpiar fecha/hora'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.accent),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.all(16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: AppColors.textPrimary)),
        ),
        ElevatedButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.check, size: 20),
          label: const Text('Agregar Tarea'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDateTimeRow({required IconData icon, required String label, required VoidCallback onPressed}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
        ),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(foregroundColor: AppColors.accent),
          child: const Text('Elegir'),
        ),
      ],
    );
  }
}

Future<AddTodoResult?> showAddTodoDialog(
    BuildContext context, {
  required List<String> categories,
  required void Function(String) onAddCategory,
}) {
  return showDialog<AddTodoResult>(
    context: context,
    builder: (ctx) => AddTodoDialog(
      categories: categories,
      onAddCategory: onAddCategory,
    ),
  );
}