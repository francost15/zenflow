import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum TaskPriority { low, medium, high }

enum TaskStatus { pending, inProgress, completed }

class Task extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final TimeOfDay? dueTime;
  final TaskPriority priority;
  final TaskStatus status;
  final String? courseId;
  final List<String> subtasks;
  final String? calendarEventId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.dueTime,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.courseId,
    this.subtasks = const [],
    this.calendarEventId,
    required this.createdAt,
    required this.updatedAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    TaskPriority? priority,
    TaskStatus? status,
    String? courseId,
    List<String>? subtasks,
    String? calendarEventId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      courseId: courseId ?? this.courseId,
      subtasks: subtasks ?? this.subtasks,
      calendarEventId: calendarEventId ?? this.calendarEventId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    dueDate,
    dueTime,
    priority,
    status,
    courseId,
    subtasks,
    calendarEventId,
    createdAt,
    updatedAt,
  ];
}
