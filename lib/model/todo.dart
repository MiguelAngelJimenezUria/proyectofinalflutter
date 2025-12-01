class Todo {
  final String id;
  final String title;
  final String description;
  final String? category;
  final DateTime? dueDate;
  final bool completed;
  final DateTime createdAt;
  final String? ownerId; // ID del usuario dueño (viene del backend)

  Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.category,
    this.dueDate,
    this.completed = false,
    DateTime? createdAt,
    this.ownerId,
  }) : createdAt = createdAt ?? DateTime.now();

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    DateTime? dueDate,
    bool? completed,
    DateTime? createdAt,
    String? ownerId,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'dueDate': dueDate?.toIso8601String(),
        'completed': completed,
        'createdAt': createdAt.toIso8601String(),
        if (ownerId != null) 'ownerId': ownerId,
      };

  factory Todo.fromJson(Map<String, dynamic> json) {
    // Helper para parsear DateTime de manera segura
    DateTime? parseDateTimeSafe(dynamic value) {
      if (value == null) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    return Todo(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String?,
      dueDate: parseDateTimeSafe(json['dueDate']),
      completed: json['completed'] as bool? ?? false,
      createdAt: parseDateTimeSafe(json['createdAt']) ?? DateTime.now(),
      ownerId: json['ownerId']?.toString(),
    );
  }

  @override
  String toString() => 'Todo(id: $id, title: $title, category: $category, due: $dueDate, completed: $completed, ownerId: $ownerId)';
}