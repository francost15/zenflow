import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Schedule extends Equatable {
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const Schedule({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [dayOfWeek, startTime, endTime];
}

class Course extends Equatable {
  final String id;
  final String name;
  final Color color;
  final String? professor;
  final List<Schedule> schedule;
  final String? notes;
  final double progress; // 0.0 - 1.0
  final DateTime createdAt;

  const Course({
    required this.id,
    required this.name,
    required this.color,
    this.professor,
    this.schedule = const [],
    this.notes,
    this.progress = 0.0,
    required this.createdAt,
  });

  Course copyWith({
    String? id,
    String? name,
    Color? color,
    String? professor,
    List<Schedule>? schedule,
    String? notes,
    double? progress,
    DateTime? createdAt,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      professor: professor ?? this.professor,
      schedule: schedule ?? this.schedule,
      notes: notes ?? this.notes,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    color,
    professor,
    schedule,
    notes,
    progress,
    createdAt,
  ];
}
