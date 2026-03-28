import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final String? dueTime; // Store as string "HH:mm"
  final String priority;
  final String status;
  final String? courseId;
  final List<String> subtasks;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.dueTime,
    required this.priority,
    required this.status,
    this.courseId,
    required this.subtasks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      dueTime: data['dueTime'],
      priority: data['priority'] ?? 'medium',
      status: data['status'] ?? 'pending',
      courseId: data['courseId'],
      subtasks: List<String>.from(data['subtasks'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'dueTime': dueTime,
      'priority': priority,
      'status': status,
      'courseId': courseId,
      'subtasks': subtasks,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Task toEntity() {
    TimeOfDay? time;
    if (dueTime != null) {
      final parts = dueTime!.split(':');
      time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return Task(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      dueTime: time,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == priority,
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => TaskStatus.pending,
      ),
      courseId: courseId,
      subtasks: subtasks,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory TaskModel.fromEntity(Task entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      dueDate: entity.dueDate,
      dueTime: entity.dueTime != null
          ? '${entity.dueTime!.hour}:${entity.dueTime!.minute}'
          : null,
      priority: entity.priority.name,
      status: entity.status.name,
      courseId: entity.courseId,
      subtasks: entity.subtasks,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
