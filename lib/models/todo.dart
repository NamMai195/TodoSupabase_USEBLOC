import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final String id;
  final String userId;
  final String task; // Hoặc dùng `name` nếu cột DB là `name`
  final String? description;
  final int? priority;
  final String status; // Đã thay thế isCompleted
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Todo({
    required this.id,
    required this.userId,
    required this.task, // Hoặc dùng `name`
    this.description,
    this.priority,
    required this.status, // Đã thay thế isCompleted
    required this.createdAt,
    this.updatedAt,
  });

  // Getter để kiểm tra hoàn thành nếu cần (tiện lợi)
  bool get isCompleted => status == 'completed';

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'].toString(),
      userId: json['user_id'] as String,
      task: json['task'] ?? json['name'] ?? '', // Hoặc dùng `name`
      description: json['description'] as String?,
      priority: json['priority'] as int?,
      status: json['status'] as String? ?? 'pending', // Đọc status, mặc định là 'pending'
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null ? null : DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'task': task, // Hoặc dùng 'name': task
      'description': description,
      'priority': priority,
      'status': status, // Dùng status
    };
  }

  @override
  List<Object?> get props => [id, userId, task, description, priority, status, createdAt, updatedAt]; // Dùng status
}