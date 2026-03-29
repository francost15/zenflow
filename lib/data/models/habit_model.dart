import 'package:app/domain/entities/habit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HabitModel {
  final String id;
  final String name;
  final String? icon;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCheckIn;
  final List<DateTime> checkInHistory;
  final bool isActive;

  HabitModel({
    required this.id,
    required this.name,
    this.icon,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCheckIn,
    this.checkInHistory = const [],
    this.isActive = true,
  });

  factory HabitModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HabitModel(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'],
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      lastCheckIn: data['lastCheckIn'] != null
          ? (data['lastCheckIn'] as Timestamp).toDate()
          : null,
      checkInHistory:
          (data['checkInHistory'] as List<dynamic>?)
              ?.map((e) => (e as Timestamp).toDate())
              .toList() ??
          [],
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon': icon,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastCheckIn': lastCheckIn != null
          ? Timestamp.fromDate(lastCheckIn!)
          : null,
      'checkInHistory': checkInHistory
          .map((e) => Timestamp.fromDate(e))
          .toList(),
      'isActive': isActive,
    };
  }

  Habit toEntity() => Habit(
    id: id,
    name: name,
    icon: icon,
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    lastCheckIn: lastCheckIn,
    checkInHistory: checkInHistory,
    isActive: isActive,
  );

  factory HabitModel.fromEntity(Habit entity) => HabitModel(
    id: entity.id,
    name: entity.name,
    icon: entity.icon,
    currentStreak: entity.currentStreak,
    longestStreak: entity.longestStreak,
    lastCheckIn: entity.lastCheckIn,
    checkInHistory: entity.checkInHistory,
    isActive: entity.isActive,
  );
}
