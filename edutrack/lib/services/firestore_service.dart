import 'package:cloud_firestore/cloud_firestore.dart';

/// Service class for handling Cloud Firestore operations
/// Provides CRUD operations for user data, students, attendance, and progress tracking
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names
  static const String usersCollection = 'users';
  static const String studentsCollection = 'students';
  static const String attendanceCollection = 'attendance';
  static const String progressCollection = 'progress';

  // ==================== USER DATA OPERATIONS ====================

  /// Add or update user data in Firestore
  Future<void> addUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(usersCollection).doc(uid).set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to add user data: $e');
    }
  }

  /// Get user data by UID
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection(usersCollection).doc(uid).get();
      return doc.exists ? doc.data() as Map<String, dynamic>? : null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  /// Stream user data for real-time updates
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUserData(String uid) {
    return _firestore.collection(usersCollection).doc(uid).snapshots();
  }

  // ==================== STUDENT OPERATIONS ====================

  /// Add a new student
  Future<String> addStudent(Map<String, dynamic> studentData) async {
    try {
      // Add createdAt timestamp
      studentData['createdAt'] = FieldValue.serverTimestamp();
      studentData['updatedAt'] = FieldValue.serverTimestamp();
      
      final DocumentReference docRef = await _firestore.collection(studentsCollection).add(studentData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add student: $e');
    }
  }

  /// Get all students
  Future<List<Map<String, dynamic>>> getStudents() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(studentsCollection)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      throw Exception('Failed to get students: $e');
    }
  }

  /// Stream all students for real-time updates
  Stream<QuerySnapshot<Map<String, dynamic>>> streamStudents() {
    return _firestore
        .collection(studentsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get a single student by ID
  Future<Map<String, dynamic>?> getStudent(String studentId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection(studentsCollection).doc(studentId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get student: $e');
    }
  }

  /// Update student data
  Future<void> updateStudent(String studentId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection(studentsCollection).doc(studentId).update(data);
    } catch (e) {
      throw Exception('Failed to update student: $e');
    }
  }

  /// Delete a student
  Future<void> deleteStudent(String studentId) async {
    try {
      await _firestore.collection(studentsCollection).doc(studentId).delete();
    } catch (e) {
      throw Exception('Failed to delete student: $e');
    }
  }

  // ==================== ATTENDANCE OPERATIONS ====================

  /// Mark attendance for a student
  Future<void> markAttendance(String studentId, bool isPresent, DateTime date) async {
    try {
      final String dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      final Map<String, dynamic> attendanceData = {
        'studentId': studentId,
        'date': dateKey,
        'isPresent': isPresent,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Use date and studentId as compound key
      await _firestore
          .collection(attendanceCollection)
          .doc('${studentId}_$dateKey')
          .set(attendanceData);
    } catch (e) {
      throw Exception('Failed to mark attendance: $e');
    }
  }

  /// Get attendance records for a student
  Future<List<Map<String, dynamic>>> getStudentAttendance(String studentId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(attendanceCollection)
          .where('studentId', isEqualTo: studentId)
          .orderBy('timestamp', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Failed to get attendance: $e');
    }
  }

  /// Stream attendance records
  Stream<QuerySnapshot<Map<String, dynamic>>> streamAttendance() {
    return _firestore
        .collection(attendanceCollection)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }

  // ==================== PROGRESS TRACKING OPERATIONS ====================

  /// Add test score or progress entry
  Future<String> addProgress(Map<String, dynamic> progressData) async {
    try {
      progressData['createdAt'] = FieldValue.serverTimestamp();
      
      final DocumentReference docRef = await _firestore.collection(progressCollection).add(progressData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add progress: $e');
    }
  }

  /// Get progress records for a student
  Future<List<Map<String, dynamic>>> getStudentProgress(String studentId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(progressCollection)
          .where('studentId', isEqualTo: studentId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      throw Exception('Failed to get progress: $e');
    }
  }

  /// Stream progress records
  Stream<QuerySnapshot<Map<String, dynamic>>> streamProgress(String studentId) {
    return _firestore
        .collection(progressCollection)
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Update progress entry
  Future<void> updateProgress(String progressId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(progressCollection).doc(progressId).update(data);
    } catch (e) {
      throw Exception('Failed to update progress: $e');
    }
  }

  /// Delete progress entry
  Future<void> deleteProgress(String progressId) async {
    try {
      await _firestore.collection(progressCollection).doc(progressId).delete();
    } catch (e) {
      throw Exception('Failed to delete progress: $e');
    }
  }

  // ==================== UTILITY OPERATIONS ====================

  /// Batch write operation for multiple records
  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    try {
      final WriteBatch batch = _firestore.batch();
      
      for (var operation in operations) {
        final String collection = operation['collection'];
        final String? docId = operation['docId'];
        final Map<String, dynamic> data = operation['data'];
        final String operationType = operation['type']; // 'set', 'update', 'delete'
        
        if (operationType == 'set') {
          if (docId != null) {
            batch.set(_firestore.collection(collection).doc(docId), data);
          } else {
            batch.set(_firestore.collection(collection).doc(), data);
          }
        } else if (operationType == 'update') {
          batch.update(_firestore.collection(collection).doc(docId!), data);
        } else if (operationType == 'delete') {
          batch.delete(_firestore.collection(collection).doc(docId!));
        }
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Batch write failed: $e');
    }
  }

  /// Query documents with custom filters
  Future<List<Map<String, dynamic>>> queryDocuments({
    required String collection,
    String? fieldPath,
    dynamic isEqualTo,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection);
      
      if (fieldPath != null && isEqualTo != null) {
        query = query.where(fieldPath, isEqualTo: isEqualTo);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final QuerySnapshot snapshot = await query.get();
      
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      throw Exception('Query failed: $e');
    }
  }
}
