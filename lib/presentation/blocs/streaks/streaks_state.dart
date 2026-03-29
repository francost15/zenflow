import 'package:app/domain/entities/habit.dart';
import 'package:equatable/equatable.dart';

abstract class StreaksState extends Equatable {
  const StreaksState();

  @override
  List<Object?> get props => [];
}

class StreaksInitial extends StreaksState {}

class StreaksLoading extends StreaksState {}

class StreaksLoaded extends StreaksState {
  final List<Habit> habits;
  final Map<DateTime, int> heatmapData;
  final int totalCurrentStreak;
  final int longestStreak;

  const StreaksLoaded({
    required this.habits,
    required this.heatmapData,
    required this.totalCurrentStreak,
    required this.longestStreak,
  });

  @override
  List<Object?> get props => [
    habits,
    heatmapData,
    totalCurrentStreak,
    longestStreak,
  ];
}

class StreaksError extends StreaksState {
  final String message;

  const StreaksError(this.message);

  @override
  List<Object?> get props => [message];
}
