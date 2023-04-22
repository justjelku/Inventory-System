class Todo {
  final String id;
  final String title;
  final String description;
  final bool completed;
  final String userId;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
    required this.userId,
  });

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? completed,
    String? userId,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      userId: userId ?? this.userId,
    );
  }
}
