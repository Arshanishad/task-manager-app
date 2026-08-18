import 'package:cloud_firestore/cloud_firestore.dart';


class TaskModel {
  final String id;
  final String title;
  final String description;
  final String priority;
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime createdDate;
  final bool syncPending;
  final bool isDeleted;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    required this.isCompleted,
    required this.createdDate,
    this.syncPending = false,
    this.isDeleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
      'createdDate': Timestamp.fromDate(createdDate),
    };
  }

  factory TaskModel.fromFirestore(
    Map<String, dynamic> json,
  ) {
    return TaskModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'Medium',
      dueDate: _parseDate(json['dueDate']),
      isCompleted: json['isCompleted'] ?? false,
      createdDate: _parseDate(json['createdDate']),
      syncPending: false,
      isDeleted: false,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.parse(value);
    }

    return DateTime.now();
  }

  TaskModel copyWith({
    String? title,
    String? description,
    String? priority,
    DateTime? dueDate,
    bool? isCompleted,
    bool? syncPending,
    bool? isDeleted,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdDate: createdDate,
      syncPending: syncPending ?? this.syncPending,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toHiveMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'createdDate': createdDate.toIso8601String(),
      'syncPending': syncPending,
      'isDeleted': isDeleted,
    };
  }
  
  factory TaskModel.fromHiveMap(
    Map<dynamic, dynamic> map,
  ) {
    return TaskModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      priority: map['priority'] ?? 'Medium',
      dueDate: DateTime.parse(map['dueDate']),
      isCompleted: map['isCompleted'] ?? false,
      createdDate: DateTime.parse(map['createdDate']),
      syncPending: map['syncPending'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
    );
  }
}