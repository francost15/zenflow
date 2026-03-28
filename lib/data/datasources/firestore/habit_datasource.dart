import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/habit_model.dart';

class HabitDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated. Please sign in again.');
    }
    return user.uid;
  }

  CollectionReference get _habitsRef =>
      _firestore.collection('users').doc(_userId).collection('habits');

  Future<List<HabitModel>> getHabits() async {
    final snapshot = await _habitsRef.where('isActive', isEqualTo: true).get();
    return snapshot.docs.map((doc) => HabitModel.fromFirestore(doc)).toList();
  }

  Future<HabitModel> createHabit(HabitModel habit) async {
    final docRef = _habitsRef.doc();
    final newHabit = HabitModel(
      id: docRef.id,
      name: habit.name,
      icon: habit.icon,
      currentStreak: 0,
      longestStreak: 0,
      lastCheckIn: null,
      checkInHistory: [],
      isActive: true,
    );
    await docRef.set(newHabit.toFirestore());
    return newHabit;
  }

  Future<HabitModel> checkIn(String habitId) async {
    final docRef = _habitsRef.doc(habitId);
    final doc = await docRef.get();
    final habit = HabitModel.fromFirestore(doc);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (habit.lastCheckIn != null) {
      final lastCheckIn = DateTime(
        habit.lastCheckIn!.year,
        habit.lastCheckIn!.month,
        habit.lastCheckIn!.day,
      );
      if (lastCheckIn == today) {
        return habit;
      }
    }

    int newStreak = 1;
    if (habit.lastCheckIn != null) {
      final lastDate = DateTime(
        habit.lastCheckIn!.year,
        habit.lastCheckIn!.month,
        habit.lastCheckIn!.day,
      );
      final yesterday = today.subtract(const Duration(days: 1));
      if (lastDate == yesterday) {
        newStreak = habit.currentStreak + 1;
      }
    }

    final newLongest = newStreak > habit.longestStreak
        ? newStreak
        : habit.longestStreak;

    await docRef.update({
      'currentStreak': newStreak,
      'longestStreak': newLongest,
      'lastCheckIn': Timestamp.fromDate(now),
      'checkInHistory': [
        ...habit.checkInHistory.map((e) => Timestamp.fromDate(e)),
        Timestamp.fromDate(now),
      ],
    });

    return HabitModel(
      id: habit.id,
      name: habit.name,
      icon: habit.icon,
      currentStreak: newStreak,
      longestStreak: newLongest,
      lastCheckIn: now,
      checkInHistory: [...habit.checkInHistory, now],
      isActive: habit.isActive,
    );
  }

  Future<void> deleteHabit(String habitId) async {
    await _habitsRef.doc(habitId).update({'isActive': false});
  }
}
