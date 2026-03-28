import 'package:equatable/equatable.dart';

abstract class StreaksEvent extends Equatable {
  const StreaksEvent();

  @override
  List<Object?> get props => [];
}

class StreaksLoadRequested extends StreaksEvent {}

class HabitCheckInRequested extends StreaksEvent {
  final String habitId;

  const HabitCheckInRequested(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

class HabitCreated extends StreaksEvent {
  final String name;
  final String? icon;

  const HabitCreated({required this.name, this.icon});

  @override
  List<Object?> get props => [name, icon];
}

class HabitDeleted extends StreaksEvent {
  final String habitId;

  const HabitDeleted(this.habitId);

  @override
  List<Object?> get props => [habitId];
}
