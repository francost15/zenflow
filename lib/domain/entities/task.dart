import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum TaskPriority { low, medium, high }

enum TaskStatus { pending, inProgress, completed }

enum CalendarSyncAction { create, update, delete }

enum CalendarSyncStatus { synced, pending, failed }

const Object _taskUnset = Object();

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
  final bool isDeleted;
  final CalendarSyncAction? pendingCalendarSyncAction;
  final CalendarSyncStatus calendarSyncStatus;
  final String? lastCalendarSyncError;
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
    this.isDeleted = false,
    this.pendingCalendarSyncAction,
    this.calendarSyncStatus = CalendarSyncStatus.synced,
    this.lastCalendarSyncError,
    required this.createdAt,
    required this.updatedAt,
  });

  Task copyWith({
    String? id,
    String? title,
    Object? description = _taskUnset,
    DateTime? dueDate,
    Object? dueTime = _taskUnset,
    TaskPriority? priority,
    TaskStatus? status,
    Object? courseId = _taskUnset,
    List<String>? subtasks,
    Object? calendarEventId = _taskUnset,
    bool? isDeleted,
    Object? pendingCalendarSyncAction = _taskUnset,
    CalendarSyncStatus? calendarSyncStatus,
    Object? lastCalendarSyncError = _taskUnset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: identical(description, _taskUnset)
          ? this.description
          : description as String?,
      dueDate: dueDate ?? this.dueDate,
      dueTime: identical(dueTime, _taskUnset)
          ? this.dueTime
          : dueTime as TimeOfDay?,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      courseId: identical(courseId, _taskUnset)
          ? this.courseId
          : courseId as String?,
      subtasks: subtasks ?? this.subtasks,
      calendarEventId: identical(calendarEventId, _taskUnset)
          ? this.calendarEventId
          : calendarEventId as String?,
      isDeleted: isDeleted ?? this.isDeleted,
      pendingCalendarSyncAction:
          identical(pendingCalendarSyncAction, _taskUnset)
          ? this.pendingCalendarSyncAction
          : pendingCalendarSyncAction as CalendarSyncAction?,
      calendarSyncStatus: calendarSyncStatus ?? this.calendarSyncStatus,
      lastCalendarSyncError: identical(lastCalendarSyncError, _taskUnset)
          ? this.lastCalendarSyncError
          : lastCalendarSyncError as String?,
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
    isDeleted,
    pendingCalendarSyncAction,
    calendarSyncStatus,
    lastCalendarSyncError,
    createdAt,
    updatedAt,
  ];
}
