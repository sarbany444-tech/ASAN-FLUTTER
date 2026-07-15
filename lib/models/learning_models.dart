class CourseModel {
  const CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectId,
    required this.teacherId,
    required this.teacherName,
    this.thumbnailUrl,
    this.grade = 'Grade 12',
    this.lessonCount = 0,
    this.studentCount = 0,
    this.rating = 0.0,
    this.status = 'published',
    this.isApproved = true,
    this.tags = const [],
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String subjectId;
  final String teacherId;
  final String teacherName;
  final String? thumbnailUrl;
  final String grade;
  final int lessonCount;
  final int studentCount;
  final double rating;
  final String status;
  final bool isApproved;
  final List<String> tags;
  final DateTime? createdAt;

  factory CourseModel.fromMap(Map<String, dynamic> map, String id) {
    return CourseModel(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      subjectId: map['subjectId'] as String? ?? '',
      teacherId: map['teacherId'] as String? ?? '',
      teacherName: map['teacherName'] as String? ?? 'Teacher',
      thumbnailUrl: map['thumbnailUrl'] as String?,
      grade: map['grade'] as String? ?? 'Grade 12',
      lessonCount: map['lessonCount'] as int? ?? 0,
      studentCount: map['studentCount'] as int? ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      status: map['status'] as String? ?? 'draft',
      isApproved: map['isApproved'] as bool? ?? false,
      tags: List<String>.from(map['tags'] as List? ?? []),
      createdAt: map['createdAt']?.toDate() as DateTime?,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'subjectId': subjectId,
        'teacherId': teacherId,
        'teacherName': teacherName,
        'thumbnailUrl': thumbnailUrl,
        'grade': grade,
        'lessonCount': lessonCount,
        'studentCount': studentCount,
        'rating': rating,
        'status': status,
        'isApproved': isApproved,
        'tags': tags,
      };
}

class LessonModel {
  const LessonModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.type,
    this.description,
    this.videoUrl,
    this.pdfUrl,
    this.durationMinutes = 0,
    this.order = 0,
    this.isFree = false,
    this.createdAt,
  });

  final String id;
  final String courseId;
  final String title;
  final String type; // video, pdf, quiz, assignment
  final String? description;
  final String? videoUrl;
  final String? pdfUrl;
  final int durationMinutes;
  final int order;
  final bool isFree;
  final DateTime? createdAt;

  bool get isVideo => type == 'video';
  bool get isPdf => type == 'pdf';

  factory LessonModel.fromMap(Map<String, dynamic> map, String id) {
    return LessonModel(
      id: id,
      courseId: map['courseId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      type: map['type'] as String? ?? 'video',
      description: map['description'] as String?,
      videoUrl: map['videoUrl'] as String?,
      pdfUrl: map['pdfUrl'] as String?,
      durationMinutes: map['durationMinutes'] as int? ?? 0,
      order: map['order'] as int? ?? 0,
      isFree: map['isFree'] as bool? ?? false,
      createdAt: map['createdAt']?.toDate() as DateTime?,
    );
  }

  Map<String, dynamic> toMap() => {
        'courseId': courseId,
        'title': title,
        'type': type,
        'description': description,
        'videoUrl': videoUrl,
        'pdfUrl': pdfUrl,
        'durationMinutes': durationMinutes,
        'order': order,
        'isFree': isFree,
      };
}

class EnrollmentModel {
  const EnrollmentModel({
    required this.id,
    required this.studentId,
    required this.courseId,
    this.progress = 0.0,
    this.completedLessonIds = const [],
    this.lastLessonId,
    this.enrolledAt,
  });

  final String id;
  final String studentId;
  final String courseId;
  final double progress;
  final List<String> completedLessonIds;
  final String? lastLessonId;
  final DateTime? enrolledAt;

  factory EnrollmentModel.fromMap(Map<String, dynamic> map, String id) {
    return EnrollmentModel(
      id: id,
      studentId: map['studentId'] as String? ?? '',
      courseId: map['courseId'] as String? ?? '',
      progress: (map['progress'] as num?)?.toDouble() ?? 0,
      completedLessonIds:
          List<String>.from(map['completedLessonIds'] as List? ?? []),
      lastLessonId: map['lastLessonId'] as String?,
      enrolledAt: map['enrolledAt']?.toDate() as DateTime?,
    );
  }
}

class QuizModel {
  const QuizModel({
    required this.id,
    required this.courseId,
    required this.title,
    this.questions = const [],
    this.timeLimitMinutes = 30,
    this.passingScore = 60,
  });

  final String id;
  final String courseId;
  final String title;
  final List<QuizQuestion> questions;
  final int timeLimitMinutes;
  final int passingScore;

  factory QuizModel.fromMap(Map<String, dynamic> map, String id) {
    return QuizModel(
      id: id,
      courseId: map['courseId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      timeLimitMinutes: map['timeLimitMinutes'] as int? ?? 30,
      passingScore: map['passingScore'] as int? ?? 60,
      questions: (map['questions'] as List? ?? [])
          .map((q) => QuizQuestion.fromMap(Map<String, dynamic>.from(q as Map)))
          .toList(),
    );
  }
}

class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  final String question;
  final List<String> options;
  final int correctIndex;

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      question: map['question'] as String? ?? '',
      options: List<String>.from(map['options'] as List? ?? []),
      correctIndex: map['correctIndex'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
      };
}

class LiveClassModel {
  const LiveClassModel({
    required this.id,
    required this.title,
    required this.teacherId,
    required this.teacherName,
    required this.courseId,
    this.status = 'scheduled',
    this.scheduledAt,
    this.viewerCount = 0,
    this.recordingUrl,
  });

  final String id;
  final String title;
  final String teacherId;
  final String teacherName;
  final String courseId;
  final String status;
  final DateTime? scheduledAt;
  final int viewerCount;
  final String? recordingUrl;

  bool get isLive => status == 'live';

  factory LiveClassModel.fromMap(Map<String, dynamic> map, String id) {
    return LiveClassModel(
      id: id,
      title: map['title'] as String? ?? '',
      teacherId: map['teacherId'] as String? ?? '',
      teacherName: map['teacherName'] as String? ?? '',
      courseId: map['courseId'] as String? ?? '',
      status: map['status'] as String? ?? 'scheduled',
      scheduledAt: map['scheduledAt']?.toDate() as DateTime?,
      viewerCount: map['viewerCount'] as int? ?? 0,
      recordingUrl: map['recordingUrl'] as String?,
    );
  }
}

class CertificateModel {
  const CertificateModel({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.courseTitle,
    this.issuedAt,
    this.certificateUrl,
  });

  final String id;
  final String studentId;
  final String courseId;
  final String courseTitle;
  final DateTime? issuedAt;
  final String? certificateUrl;

  factory CertificateModel.fromMap(Map<String, dynamic> map, String id) {
    return CertificateModel(
      id: id,
      studentId: map['studentId'] as String? ?? '',
      courseId: map['courseId'] as String? ?? '',
      courseTitle: map['courseTitle'] as String? ?? '',
      issuedAt: map['issuedAt']?.toDate() as DateTime?,
      certificateUrl: map['certificateUrl'] as String?,
    );
  }
}

class CommunityPostModel {
  const CommunityPostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.title,
    required this.content,
    this.answerCount = 0,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String userName;
  final String title;
  final String content;
  final int answerCount;
  final DateTime? createdAt;

  factory CommunityPostModel.fromMap(Map<String, dynamic> map, String id) {
    return CommunityPostModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      answerCount: map['answerCount'] as int? ?? 0,
      createdAt: map['createdAt']?.toDate() as DateTime?,
    );
  }
}
