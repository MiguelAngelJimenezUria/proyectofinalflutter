import 'package:flutter/material.dart';

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
    );
    if (d != null) {
      setState(() => _pickedDate = d);
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _pickedTime ?? TimeOfDay.now(),
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
        title: const Text('Nueva categoría'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nombre de la categoría',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) => Navigator.pop(ctx, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              Navigator.pop(ctx, text);
            },
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
        // Call after setState to avoid rebuild issues
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva tarea', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  hintText: 'Ingresa el título de la tarea',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  hintText: 'Detalles adicionales',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const Text('Categoría', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ..._localCategories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final cat = entry.value;
                    final isSelected = index == _selectedCategoryIndex;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedCategoryIndex = index);
                      },
                    );
                  }),
                  ActionChip(
                    label: const Text('+ Agregar'),
                    avatar: const Icon(Icons.add, size: 16),
                    onPressed: _addNewCategory,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Fecha y hora', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _pickedDate == null
                                  ? 'Sin fecha'
                                  : '${_pickedDate!.day}/${_pickedDate!.month}/${_pickedDate!.year}',
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _pickDate,
                            icon: const Icon(Icons.edit),
                            label: const Text('Fecha'),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _pickedTime == null ? 'Sin hora' : _pickedTime!.format(context),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _pickTime,
                            icon: const Icon(Icons.edit),
                            label: const Text('Hora'),
                          ),
                        ],
                      ),
                      if (_pickedDate != null || _pickedTime != null)
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _pickedDate = null;
                              _pickedTime = null;
                            });
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text('Limpiar'),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.check),
          label: const Text('Agregar'),
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
