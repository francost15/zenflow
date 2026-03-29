import 'package:app/core/error/exceptions.dart';
import 'package:app/data/models/task_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException(
        'No authenticated user found. Please sign in again.',
        'AUTH_REQUIRED',
      );
    }
    return user.uid;
  }

  CollectionReference get _tasksRef =>
      _firestore.collection('users').doc(_userId).collection('tasks');

  Future<List<TaskModel>> getTasks({bool includeDeleted = false}) async {
    final snapshot = await _tasksRef.orderBy('dueDate').get();
    final tasks = snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    if (includeDeleted) {
      return tasks;
    }
    return tasks.where((task) => !task.isDeleted).toList();
  }

  Future<List<TaskModel>> getTasksByDate(
    DateTime date, {
    bool includeDeleted = false,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _tasksRef
        .where(
          'dueDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('dueDate', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    final tasks = snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    if (includeDeleted) {
      return tasks;
    }
    return tasks.where((task) => !task.isDeleted).toList();
  }

  Future<List<TaskModel>> getTasksByCourse(
    String courseId, {
    bool includeDeleted = false,
  }) async {
    final snapshot = await _tasksRef.where('courseId', isEqualTo: courseId).get();
    final tasks = snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    if (includeDeleted) {
      return tasks;
    }
    return tasks.where((task) => !task.isDeleted).toList();
  }

  Future<List<TaskModel>> getPendingSyncTasks() async {
    final snapshot = await _tasksRef.get();
    final tasks = snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList()
      ..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    return tasks
        .where(
          (task) =>
              task.pendingCalendarSyncAction != null ||
              task.calendarSyncStatus != 'synced' ||
              task.isDeleted,
        )
        .toList();
  }

  Future<TaskModel> createTask(TaskModel task) async {
    final docRef = _tasksRef.doc();
    final newTask = TaskModel(
      id: docRef.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      dueTime: task.dueTime,
      priority: task.priority,
      status: task.status,
      courseId: task.courseId,
      subtasks: task.subtasks,
      calendarEventId: task.calendarEventId,
      isDeleted: task.isDeleted,
      pendingCalendarSyncAction: task.pendingCalendarSyncAction,
      calendarSyncStatus: task.calendarSyncStatus,
      lastCalendarSyncError: task.lastCalendarSyncError,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    );
    await docRef.set(newTask.toFirestore());
    return newTask;
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    await _tasksRef.doc(task.id).update(task.toFirestore());
    return task;
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksRef.doc(taskId).delete();
  }

  Future<void> toggleTaskStatus(String taskId, bool completed) async {
    await _tasksRef.doc(taskId).update({
      'status': completed ? 'completed' : 'pending',
      'updatedAt': Timestamp.now(),
    });
  }
}
