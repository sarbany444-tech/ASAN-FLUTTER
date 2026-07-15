import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/learning_models.dart';

class CourseService {
  CourseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _courses =>
      _firestore.collection(AppConstants.coursesCollection);

  CollectionReference<Map<String, dynamic>> get _lessons =>
      _firestore.collection(AppConstants.lessonsCollection);

  CollectionReference<Map<String, dynamic>> get _enrollments =>
      _firestore.collection(AppConstants.enrollmentsCollection);

  CollectionReference<Map<String, dynamic>> get _liveClasses =>
      _firestore.collection(AppConstants.liveClassesCollection);

  Future<List<CourseModel>> getCourses({String? subjectId}) async {
    Query<Map<String, dynamic>> query = _courses
        .where('status', isEqualTo: 'published')
        .where('isApproved', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(AppConstants.pageSize);

    if (subjectId != null) {
      query = _courses
          .where('subjectId', isEqualTo: subjectId)
          .where('status', isEqualTo: 'published')
          .where('isApproved', isEqualTo: true)
          .limit(AppConstants.pageSize);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => CourseModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<CourseModel?> getCourse(String courseId) async {
    final doc = await _courses.doc(courseId).get();
    if (!doc.exists) return null;
    return CourseModel.fromMap(doc.data()!, doc.id);
  }

  Future<List<LessonModel>> getLessons(String courseId) async {
    final snapshot = await _lessons
        .where('courseId', isEqualTo: courseId)
        .orderBy('order')
        .get();
    return snapshot.docs
        .map((doc) => LessonModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<EnrollmentModel>> getStudentEnrollments(String studentId) async {
    final snapshot = await _enrollments
        .where('studentId', isEqualTo: studentId)
        .orderBy('enrolledAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => EnrollmentModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> enrollStudent({
    required String studentId,
    required String courseId,
  }) async {
    final existing = await _enrollments
        .where('studentId', isEqualTo: studentId)
        .where('courseId', isEqualTo: courseId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return;

    await _enrollments.add({
      'studentId': studentId,
      'courseId': courseId,
      'progress': 0,
      'completedLessonIds': [],
      'enrolledAt': FieldValue.serverTimestamp(),
    });

    await _courses.doc(courseId).update({
      'studentCount': FieldValue.increment(1),
    });
  }

  Future<void> updateLessonProgress({
    required String enrollmentId,
    required String lessonId,
    required int totalLessons,
  }) async {
    final doc = await _enrollments.doc(enrollmentId).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final completed =
        List<String>.from(data['completedLessonIds'] as List? ?? []);
    if (!completed.contains(lessonId)) {
      completed.add(lessonId);
    }
    final progress =
        totalLessons > 0 ? (completed.length / totalLessons) * 100 : 0.0;

    await _enrollments.doc(enrollmentId).update({
      'completedLessonIds': completed,
      'lastLessonId': lessonId,
      'progress': progress,
    });
  }

  Future<List<LiveClassModel>> getLiveClasses({bool liveOnly = false}) async {
    Query<Map<String, dynamic>> query = _liveClasses.orderBy(
      'scheduledAt',
      descending: true,
    );
    if (liveOnly) {
      query = _liveClasses.where('status', isEqualTo: 'live');
    }
    final snapshot = await query.limit(10).get();
    return snapshot.docs
        .map((doc) => LiveClassModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<CourseModel>> getTeacherCourses(String teacherId) async {
    final snapshot = await _courses
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => CourseModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<String> createCourse(CourseModel course) async {
    final doc = await _courses.add({
      ...course.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  List<CourseModel> getSampleCourses() {
    return SubjectCatalogFallback.sampleCourses;
  }

  List<LessonModel> getSampleLessons(String courseId) {
    return SubjectCatalogFallback.sampleLessons(courseId);
  }
}

/// Offline sample data when Firebase is not configured.
class SubjectCatalogFallback {
  static final sampleCourses = [
    CourseModel(
      id: 'sample_math',
      title: 'Grade 12 Mathematics',
      description: 'Complete mathematics curriculum with video lessons, PDFs, and quizzes.',
      subjectId: 'mathematics',
      teacherId: 'teacher_1',
      teacherName: 'Dr. Ahmed Hassan',
      lessonCount: 24,
      studentCount: 1250,
      rating: 4.8,
      grade: 'Grade 12',
    ),
    CourseModel(
      id: 'sample_physics',
      title: 'Grade 12 Physics',
      description: 'Master mechanics, electricity, and modern physics concepts.',
      subjectId: 'physics',
      teacherId: 'teacher_2',
      teacherName: 'Prof. Sara Ali',
      lessonCount: 20,
      studentCount: 980,
      rating: 4.7,
      grade: 'Grade 12',
    ),
    CourseModel(
      id: 'sample_english',
      title: 'Grade 12 English',
      description: 'Grammar, literature, and writing skills for final exams.',
      subjectId: 'english',
      teacherId: 'teacher_3',
      teacherName: 'Ms. Layla Omar',
      lessonCount: 18,
      studentCount: 1100,
      rating: 4.9,
      grade: 'Grade 12',
    ),
  ];

  static List<LessonModel> sampleLessons(String courseId) => [
        LessonModel(
          id: '${courseId}_l1',
          courseId: courseId,
          title: 'Introduction & Overview',
          type: 'video',
          durationMinutes: 15,
          order: 1,
          isFree: true,
        ),
        LessonModel(
          id: '${courseId}_l2',
          courseId: courseId,
          title: 'Chapter 1 - Core Concepts',
          type: 'video',
          durationMinutes: 25,
          order: 2,
        ),
        LessonModel(
          id: '${courseId}_l3',
          courseId: courseId,
          title: 'Study Notes (PDF)',
          type: 'pdf',
          order: 3,
        ),
        LessonModel(
          id: '${courseId}_l4',
          courseId: courseId,
          title: 'Chapter 1 Quiz',
          type: 'quiz',
          order: 4,
        ),
      ];
}
