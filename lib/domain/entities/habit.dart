import 'package:equatable/equatable.dart';

class Habit extends Equatable {
  final String id;
  final String name;
  final String? icon;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCheckIn;
  final List<DateTime> checkInHistory;
  final bool isActive;

  const Habit({
    required this.id,
    required this.name,
    this.icon,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCheckIn,
    this.checkInHistory = const [],
    this.isActive = true,
  });

  Habit copyWith({
    String? id,
    String? name,
    String? icon,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCheckIn,
    List<DateTime>? checkInHistory,
    bool? isActive,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      checkInHistory: checkInHistory ?? this.checkInHistory,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    icon,
    currentStreak,
    longestStreak,
    lastCheckIn,
    checkInHistory,
    isActive,
  ];
}
