import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/course.dart';

class CourseModel {
  final String id;
  final String name;
  final int colorValue;
  final String? professor;
  final List<Map<String, dynamic>> schedule;
  final String? notes;
  final double progress;
  final DateTime createdAt;

  CourseModel({
    required this.id,
    required this.name,
    required this.colorValue,
    this.professor,
    this.schedule = const [],
    this.notes,
    this.progress = 0.0,
    required this.createdAt,
  });

  factory CourseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CourseModel(
      id: doc.id,
      name: data['name'] ?? '',
      colorValue: data['colorValue'] ?? 0xFF6366F1,
      professor: data['professor'],
      schedule:
          (data['schedule'] as List<dynamic>?)?.map((e) {
            final map = e as Map<String, dynamic>;
            return {
              'dayOfWeek': map['dayOfWeek'] ?? 1,
              'startHour': map['startHour'] ?? 0,
              'startMinute': map['startMinute'] ?? 0,
              'endHour': map['endHour'] ?? 0,
              'endMinute': map['endMinute'] ?? 0,
            };
          }).toList() ??
          [],
      notes: data['notes'],
      progress: (data['progress'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'colorValue': colorValue,
      'professor': professor,
      'schedule': schedule,
      'notes': notes,
      'progress': progress,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Course toEntity() => Course(
    id: id,
    name: name,
    color: Color(colorValue),
    professor: professor,
    schedule: schedule.map((s) {
      return Schedule(
        dayOfWeek: s['dayOfWeek'] ?? 1,
        startTime: TimeOfDay(
          hour: s['startHour'] ?? 0,
          minute: s['startMinute'] ?? 0,
        ),
        endTime: TimeOfDay(
          hour: s['endHour'] ?? 0,
          minute: s['endMinute'] ?? 0,
        ),
      );
    }).toList(),
    notes: notes,
    progress: progress,
    createdAt: createdAt,
  );

  factory CourseModel.fromEntity(Course entity) => CourseModel(
    id: entity.id,
    name: entity.name,
    colorValue: entity.color.value,
    professor: entity.professor,
    schedule: entity.schedule.map((s) {
      return {
        'dayOfWeek': s.dayOfWeek,
        'startHour': s.startTime.hour,
        'startMinute': s.startTime.minute,
        'endHour': s.endTime.hour,
        'endMinute': s.endTime.minute,
      };
    }).toList(),
    notes: entity.notes,
    progress: entity.progress,
    createdAt: entity.createdAt,
  );
}
