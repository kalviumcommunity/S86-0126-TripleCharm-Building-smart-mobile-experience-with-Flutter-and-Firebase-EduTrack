/// App Constants for EduTrack
class AppConstants {
  // App Info
  static const String appName = 'EduTrack';
  static const String appTagline = 'Smart Coaching Management for Rural Teachers';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Rural Coaching Attendance & Progress Tracker';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String teachersCollection = 'teachers';
  static const String classesCollection = 'classes';
  static const String studentsCollection = 'students';
  static const String attendanceCollection = 'attendance';
  static const String marksCollection = 'marks';
  static const String examsCollection = 'exams';
  static const String announcementsCollection = 'announcements';

  // User Roles
  static const String roleTeacher = 'teacher';
  static const String roleStudent = 'student';

  // Attendance Status
  static const String present = 'present';
  static const String absent = 'absent';

  // Fee Status
  static const String feesPaid = 'Paid';
  static const String feesPending = 'Pending';

  // Performance Status
  static const String performanceGood = 'Good (75%+)';
  static const String performanceAverage = 'Average (50-75%)';
  static const String performanceNeedsImprovement = 'Needs Improvement (<50%)';

  // Pagination
  static const int pageSize = 20;
  static const int defaultTimeout = 30; // seconds

  // Validation
  static const int minPasswordLength = 6;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // Attendance thresholds
  static const double goodAttendanceThreshold = 0.75; // 75%
  static const double averageAttendanceThreshold = 0.50; // 50%

  // Marks thresholds
  static const double goodMarksThreshold = 75.0;
  static const double averageMarksThreshold = 50.0;

  // Error Messages
  static const String errorLoadingData = 'Error loading data. Please try again.';
  static const String errorSavingData = 'Error saving data. Please try again.';
  static const String errorDeletingData = 'Error deleting data. Please try again.';
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorInvalidEmail = 'Please enter a valid email address.';
  static const String errorWeakPassword = 'Password must be at least 6 characters.';
  static const String errorEmailExists = 'Email already exists. Please login instead.';
  static const String errorUserNotFound = 'User not found. Please sign up.';
  static const String errorWrongPassword = 'Wrong password. Please try again.';
  static const String errorTooManyAttempts = 'Too many login attempts. Try again later.';
  static const String errorUnauthorized = 'You are not authorized to perform this action.';
  static const String errorClassNotFound = 'Class not found.';
  static const String errorStudentNotFound = 'Student not found.';
  static const String errorEmptyField = 'Please fill in all required fields.';

  // Success Messages
  static const String successSignUp = 'Sign up successful! Welcome to EduTrack.';
  static const String successLogin = 'Login successful!';
  static const String successLogout = 'Logged out successfully.';
  static const String successClassCreated = 'Class created successfully.';
  static const String successClassUpdated = 'Class updated successfully.';
  static const String successClassDeleted = 'Class deleted successfully.';
  static const String successStudentAdded = 'Student added successfully.';
  static const String successStudentUpdated = 'Student updated successfully.';
  static const String successStudentDeleted = 'Student deleted successfully.';
  static const String successAttendanceSaved = 'Attendance saved successfully.';
  static const String successMarksSaved = 'Marks saved successfully.';
  static const String successExamCreated = 'Exam created successfully.';
  static const String successAnnouncementCreated = 'Announcement created successfully.';

  // Validation Messages
  static const String fieldRequired = 'This field is required.';
  static const String invalidPhone = 'Please enter a valid phone number.';
  static const String passwordMismatch = 'Passwords do not match.';
  static const String pleaseCreateClass = 'Please create a class first.';

  // Dialog Messages
  static const String confirmDelete = 'Are you sure you want to delete this?';
  static const String deleteClass = 'Delete Class';
  static const String deleteStudent = 'Delete Student';

  // Empty States
  static const String noClasses = 'No classes yet';
  static const String noStudents = 'No students yet';
  static const String noAttendance = 'No attendance records';
  static const String noExams = 'No exams yet';

  // Attendance Threshold
  static const int attendanceThreshold = 75; // 75% is the threshold
}
