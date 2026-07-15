import 'package:flutter/material.dart';
import '../models/learning_models.dart';
import '../services/course_service.dart';

class LearningProvider extends ChangeNotifier {
  LearningProvider({CourseService? courseService})
      : _courseService = courseService ?? CourseService();

  final CourseService _courseService;

  List<CourseModel> _courses = [];
  List<CourseModel> _popularCourses = [];
  List<EnrollmentModel> _enrollments = [];
  List<LiveClassModel> _liveClasses = [];
  bool _isLoading = false;
  String? _error;

  List<CourseModel> get courses => _courses;
  List<CourseModel> get popularCourses => _popularCourses;
  List<EnrollmentModel> get enrollments => _enrollments;
  List<LiveClassModel> get liveClasses => _liveClasses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadHomeData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _courseService.getCourses(),
        _courseService.getLiveClasses(liveOnly: true),
      ]);
      _courses = results[0] as List<CourseModel>;
      _popularCourses = List.from(_courses)
        ..sort((a, b) => b.studentCount.compareTo(a.studentCount));
      _liveClasses = results[1] as List<LiveClassModel>;

      if (_courses.isEmpty) {
        _courses = _courseService.getSampleCourses();
        _popularCourses = List.from(_courses);
      }
    } catch (_) {
      _courses = _courseService.getSampleCourses();
      _popularCourses = List.from(_courses);
      _liveClasses = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCoursesBySubject(String subjectId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _courses = await _courseService.getCourses(subjectId: subjectId);
      if (_courses.isEmpty) {
        _courses = _courseService
            .getSampleCourses()
            .where((c) => c.subjectId == subjectId)
            .toList();
      }
    } catch (_) {
      _courses = _courseService
          .getSampleCourses()
          .where((c) => c.subjectId == subjectId)
          .toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CourseModel?> getCourse(String courseId) async {
    try {
      final course = await _courseService.getCourse(courseId);
      if (course != null) return course;
    } catch (_) {}
    try {
      return _courseService
          .getSampleCourses()
          .firstWhere((c) => c.id == courseId);
    } catch (_) {
      return null;
    }
  }

  Future<List<LessonModel>> getLessons(String courseId) async {
    try {
      final lessons = await _courseService.getLessons(courseId);
      if (lessons.isNotEmpty) return lessons;
    } catch (_) {}
    return _courseService.getSampleLessons(courseId);
  }

  Future<void> loadEnrollments(String studentId) async {
    try {
      _enrollments = await _courseService.getStudentEnrollments(studentId);
    } catch (_) {
      _enrollments = [];
    }
    notifyListeners();
  }

  Future<void> enroll(String studentId, String courseId) async {
    await _courseService.enrollStudent(
      studentId: studentId,
      courseId: courseId,
    );
    await loadEnrollments(studentId);
  }
}
