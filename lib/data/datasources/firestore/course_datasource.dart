import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/course_model.dart';

class CourseDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;
  CollectionReference get _coursesRef =>
      _firestore.collection('users').doc(_userId).collection('courses');

  Future<List<CourseModel>> getCourses() async {
    final snapshot = await _coursesRef
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => CourseModel.fromFirestore(doc)).toList();
  }

  Future<CourseModel> createCourse(CourseModel course) async {
    final docRef = _coursesRef.doc();
    final newCourse = CourseModel(
      id: docRef.id,
      name: course.name,
      colorValue: course.colorValue,
      professor: course.professor,
      schedule: course.schedule,
      notes: course.notes,
      progress: 0.0,
      createdAt: DateTime.now(),
    );
    await docRef.set(newCourse.toFirestore());
    return newCourse;
  }

  Future<CourseModel> updateCourse(CourseModel course) async {
    await _coursesRef.doc(course.id).update(course.toFirestore());
    return course;
  }

  Future<void> deleteCourse(String courseId) async {
    await _coursesRef.doc(courseId).delete();
  }

  Future<void> updateProgress(String courseId, double progress) async {
    await _coursesRef.doc(courseId).update({'progress': progress});
  }
}
