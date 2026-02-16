import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/class_model.dart';
import '../models/student_model.dart';
import '../models/attendance_model.dart';
import '../models/marks_model.dart';
import '../models/announcement_model.dart';
import '../models/exam_model.dart';
import '../config/constants.dart';

/// Firebase Database Service - Handles all Firestore operations
class DatabaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const uuid = Uuid();
  
  // Timeout and retry configuration
  static const Duration _writeTimeout = Duration(seconds: 30);
  static const Duration _readTimeout = Duration(seconds: 10);
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(milliseconds: 1000);
  
  /// Check if error is a Firestore internal error
  static bool _isFirestoreInternalError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('internal assertion failed') ||
           errorStr.contains('unexpected state') ||
           errorStr.contains('cache') ||
           errorStr.contains('timeout') ||
           errorStr.contains('network') ||
           errorStr.contains('unavailable');
  }
  
  /// Check if error is retryable
  static bool _isRetryableError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('timeout') ||
           errorStr.contains('unavailable') ||
           errorStr.contains('deadline-exceeded') ||
           errorStr.contains('network') ||
           errorStr.contains('internal');
  }
  
  /// Execute operation with retry logic
  static Future<T> _withRetry<T>(
    Future<T> Function() operation, {
    String operationName = 'Database operation',
    int maxRetries = _maxRetries,
  }) async {
    Exception? lastError;
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        if (kDebugMode && attempt > 1) {
          print('🔄 [DATABASE] Retry attempt $attempt/$maxRetries for $operationName');
        }
        
        return await operation();
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        
        if (kDebugMode) {
          print('❌ [DATABASE] Error in $operationName (attempt $attempt/$maxRetries): $e');
        }
        
        // Don't retry if it's the last attempt or error is not retryable
        if (attempt >= maxRetries || !_isRetryableError(e)) {
          break;
        }
        
        // Exponential backoff delay
        final delay = Duration(
          milliseconds: _retryDelay.inMilliseconds * (1 << (attempt - 1)),
        );
        
        if (kDebugMode) {
          print('⏳ [DATABASE] Waiting ${delay.inMilliseconds}ms before retry...');
        }
        
        await Future.delayed(delay);
      }
    }
    
    throw lastError ?? Exception('Operation failed after $maxRetries attempts');
  }
  
  /// Handle Firestore errors with retry logic
  static Future<T> _withErrorHandling<T>(
    Future<T> Function() operation, {
    String operationName = 'Database operation',
  }) async {
    try {
      return await _withRetry(operation, operationName: operationName);
    } catch (e) {
      if (kDebugMode) print('❌ [DATABASE] Final error in $operationName: $e');
      
      // Check if it's a Firestore internal error
      if (_isFirestoreInternalError(e)) {
        if (kDebugMode) print('⚠️ [DATABASE] Detected Firestore internal error - this may be temporary');
        
        // For web, suggest clearing cache
        if (kIsWeb) {
          throw Exception('Firestore connection error. Please check your internet connection and try again.');
        }
      }
      
      rethrow;
    }
  }
  
  /// Test Firestore connectivity
  static Future<bool> testFirestoreConnection() async {
    try {
      if (kDebugMode) print('🔌 [DATABASE] Testing Firestore connection...');
      
      // Try a simple read operation with timeout
      await _firestore
          .collection('_connection_test')
          .limit(1)
          .get()
          .timeout(_readTimeout);
      
      if (kDebugMode) print('✅ [DATABASE] Firestore connection successful!');
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [DATABASE] Firestore connection failed!');
        print('❌ [DATABASE] Error: $e');
        print('❌ [DATABASE] Error type: ${e.runtimeType}');
      }
      return false;
    }
  }
  
  /// Enhanced Firestore write operation with retry logic
  static Future<void> _safeWrite(
    String collectionPath,
    String documentId,
    Map<String, dynamic> data, {
    bool merge = false,
    String operationName = 'write',
  }) async {
    return await _withErrorHandling(() async {
      if (kDebugMode) {
        print('💾 [DATABASE] Starting $operationName to $collectionPath/$documentId');
        print('📝 [DATABASE] Data size: ${data.length} fields');
      }
      
      // Test connection before write
      final isConnected = await testFirestoreConnection();
      if (!isConnected) {
        throw Exception('No connection to Firestore. Please check your internet connection.');
      }
      
      await _firestore
          .collection(collectionPath)
          .doc(documentId)
          .set(data, SetOptions(merge: merge))
          .timeout(_writeTimeout);
      
      if (kDebugMode) print('✅ [DATABASE] $operationName completed successfully');
    }, operationName: operationName);
  }
  
  /// Enhanced Firestore read operation with retry logic
  static Future<DocumentSnapshot<Map<String, dynamic>>> _safeRead(
    String collectionPath,
    String documentId, {
    String operationName = 'read',
  }) async {
    return await _withErrorHandling(() async {
      if (kDebugMode) print('🔍 [DATABASE] Reading $collectionPath/$documentId');
      
      final doc = await _firestore
          .collection(collectionPath)
          .doc(documentId)
          .get()
          .timeout(_readTimeout);
      
      if (kDebugMode) {
        print('✅ [DATABASE] Read completed - exists: ${doc.exists}');
      }
      
      return doc;
    }, operationName: operationName);
  }

  // ===== USER OPERATIONS =====

  /// Create or update user document
  static Future<void> createUser({
    required String userId,
    required String name,
    required String email,
    required String role, // 'teacher' or 'student'
    String? phone,
  }) async {
    try {
      if (kDebugMode) {
        print('💾 [DATABASE] Creating user document...');
        print('   User ID: $userId');
        print('   Name: $name');
        print('   Email: $email');
        print('   Role: $role');
        print('   Phone: ${phone ?? "null"}');
      }
      
      // Normalize role to lowercase for consistency
      final normalizedRole = role.toLowerCase().trim();
      
      final user = UserModel(
        id: userId,
        name: name,
        email: email,
        phone: phone,
        role: normalizedRole,
        createdAt: DateTime.now(),
        isActive: true,
      );

      final userJson = user.toJson();
      if (kDebugMode) print('💾 [DATABASE] User JSON to save: $userJson');

      // Write to Firestore with enhanced error handling and retry logic
      await _safeWrite(
        AppConstants.usersCollection,
        userId,
        userJson,
        operationName: 'createUser',
      );
      
      if (kDebugMode) print('✅ [DATABASE] User document created successfully!');
    } catch (e) {
      if (kDebugMode) {
        print('❌ [DATABASE] Error creating user: $e');
        print('❌ [DATABASE] Error type: ${e.runtimeType}');
      }
      
      // Provide user-friendly error messages
      if (e.toString().contains('timeout')) {
        throw Exception('Network timeout. Please check your internet connection and try again.');
      } else if (e.toString().contains('permission-denied')) {
        throw Exception('Permission denied. Please contact support.');
      } else if (e.toString().contains('unavailable')) {
        throw Exception('Service temporarily unavailable. Please try again in a moment.');
      }
      
      rethrow;
    }
  }

  /// Get user by ID
  static Future<UserModel?> getUserById(String userId) async {
    try {
      if (kDebugMode) print('🔍 [DATABASE] Getting user document for ID: $userId');
      
      // Get from server with retry logic
      final doc = await _safeRead(
        AppConstants.usersCollection,
        userId,
        operationName: 'getUserById',
      );

      if (kDebugMode) {
        print('🔍 [DATABASE] Document exists: ${doc.exists}');
        print('🔍 [DATABASE] Document source: ${doc.metadata.isFromCache ? "cache" : "server"}');
      }

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (kDebugMode) {
          print('✅ [DATABASE] Found user data: Name=${data['name']}, Email=${data['email']}, Role=${data['role']}');
        }
        return UserModel.fromJson({...data, 'id': doc.id});
      }
      
      if (kDebugMode) print('⚠️ [DATABASE] User document not found for ID: $userId');
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [DATABASE] Failed to get user: $e');
        print('❌ [DATABASE] Error type: ${e.runtimeType}');
        if (e.toString().contains('PERMISSION_DENIED')) {
          print('❌ [DATABASE] Security rules are blocking the read! Check Firestore rules.');
        }
      }
      
      // Provide user-friendly error messages
      if (e.toString().contains('permission-denied')) {
        throw Exception('Access denied. Please contact support.');
      } else if (e.toString().contains('timeout')) {
        throw Exception('Network timeout. Please check your connection.');
      }
      
      rethrow;
    }
  }

  /// Update user
  static Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    return await _withErrorHandling(() async {
      if (kDebugMode) print('🔄 [DATABASE] Updating user $userId with: $data');
      
      // Use update() instead of set() to ensure partial update
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update(data)
          .timeout(_writeTimeout);
          
      if (kDebugMode) print('✅ [DATABASE] User updated successfully');
    }, operationName: 'updateUser');
  }

  // ===== CLASS OPERATIONS =====

  /// Create a class
  static Future<String> createClass({
    required String name,
    required String teacherId,
    String? description,
  }) async {
    return await _withErrorHandling(() async {
      final classId = uuid.v4();
      final classModel = ClassModel(
        id: classId,
        name: name,
        teacherId: teacherId,
        description: description,
        studentCount: 0,
        createdAt: DateTime.now(),
      );

      await _safeWrite(
        AppConstants.classesCollection,
        classId,
        classModel.toJson(),
        operationName: 'createClass',
      );

      return classId;
    }, operationName: 'createClass');
  }

  /// Get class by ID
  static Future<ClassModel?> getClassById(String classId) async {
    return await _withErrorHandling(() async {
      final doc = await _safeRead(
        AppConstants.classesCollection,
        classId,
        operationName: 'getClassById',
      );
      
      if (doc.exists) {
        return ClassModel.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    }, operationName: 'getClassById');
  }

  /// Get all classes for a teacher (stream)
  static Stream<List<ClassModel>> getTeacherClassesStream(String teacherId) {
    if (kDebugMode) print('📋 [DATABASE] Setting up class stream for teacher: $teacherId');
    return _firestore
        .collection(AppConstants.classesCollection)
        .where('teacherId', isEqualTo: teacherId)
        // Temporarily removed orderBy to avoid indexing issues
        // .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ClassModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  /// Update class
  static Future<void> updateClass(String classId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(AppConstants.classesCollection)
          .doc(classId)
          .update({...data, 'updatedAt': DateTime.now().toIso8601String()});
    } catch (e) {
      rethrow;
    }
  }

  /// Delete class
  static Future<void> deleteClass(String classId) async {
    try {
      await _firestore
          .collection(AppConstants.classesCollection)
          .doc(classId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Sync student count for a class by counting actual active students
  static Future<void> syncClassStudentCount(String classId) async {
    try {
      // Count active students for this class
      final studentsSnapshot = await _firestore
          .collection(AppConstants.studentsCollection)
          .where('classId', isEqualTo: classId)
          .where('isActive', isEqualTo: true)
          .get();
      
      final actualCount = studentsSnapshot.docs.length;
      
      // Update the class document with the correct count
      await _firestore
          .collection(AppConstants.classesCollection)
          .doc(classId)
          .update({
            'studentCount': actualCount,
            'updatedAt': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      rethrow;
    }
  }

  /// Sync all student counts for a teacher's classes
  static Future<void> syncAllClassStudentCounts(String teacherId) async {
    try {
      final classesSnapshot = await _firestore
          .collection(AppConstants.classesCollection)
          .where('teacherId', isEqualTo: teacherId)
          .get();
      
      for (var classDoc in classesSnapshot.docs) {
        await syncClassStudentCount(classDoc.id);
      }
    } catch (e) {
      rethrow;
    }
  }

  // ===== STUDENT OPERATIONS =====

  /// Get student by email
  static Future<StudentModel?> getStudentByEmail(String email) async {
    try {
      if (kDebugMode) print('🔍 [DATABASE] Searching for student with email: $email');
      
      final snapshot = await _firestore
          .collection(AppConstants.studentsCollection)
          .where('email', isEqualTo: email.toLowerCase().trim())
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final student = StudentModel.fromJson(
            {...snapshot.docs.first.data(), 'id': snapshot.docs.first.id});
        if (kDebugMode) print('✅ [DATABASE] Found student: ${student.name} with email: ${student.email}');
        return student;
      }
      
      if (kDebugMode) print('❌ [DATABASE] No student found for email: $email');
      return null;
    } catch (e) {
      if (kDebugMode) print('❌ [DATABASE] Error searching for student: $e');
      rethrow;
    }
  }

  /// Get student by Firebase Auth userId
  static Future<StudentModel?> getStudentByUserId(String userId) async {
    try {
      if (kDebugMode) print('🔍 [DATABASE] Getting student by userId: $userId');
      
      final snapshot = await _firestore
          .collection(AppConstants.studentsCollection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final student = StudentModel.fromJson(
            {...snapshot.docs.first.data(), 'id': snapshot.docs.first.id});
        if (kDebugMode) print('✅ [DATABASE] Found student: ${student.name} (${student.id})');
        return student;
      }
      
      if (kDebugMode) print('⚠️ [DATABASE] No student found for userId: $userId');
      return null;
    } catch (e) {
      if (kDebugMode) print('❌ [DATABASE] Error getting student by userId: $e');
      rethrow;
    }
  }

  /// Check if student email exists in database
  static Future<bool> checkStudentEmailExists(String email) async {
    try {
      if (kDebugMode) print('🔍 [DATABASE] Checking if student exists for email: $email');
      final student = await getStudentByEmail(email);
      final exists = student != null;
      if (kDebugMode) print('✅ [DATABASE] Student exists: $exists');
      
      // Debug: If student not found, list all students to see what's in the database
      if (!exists && kDebugMode) {
        print('🔍 [DEBUG] Student not found, listing all students for debugging:');
        await debugListAllStudents();
      }
      
      return exists;
    } catch (e) {
      if (kDebugMode) print('❌ [DATABASE] Error checking student email: $e');
      return false;
    }
  }

  /// Debug method to list all students (temporary)
  static Future<void> debugListAllStudents() async {
    try {
      if (kDebugMode) print('🔍 [DEBUG] Listing all students in database...');
      final snapshot = await _firestore
          .collection(AppConstants.studentsCollection)
          .get();
      
      if (kDebugMode) print('📊 [DEBUG] Found ${snapshot.docs.length} students:');
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (kDebugMode) {
          print('📝 [DEBUG] Student: ${data['name']} | Email: "${data['email']}" | ID: ${doc.id}');
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ [DEBUG] Error listing students: $e');
    }
  }

  /// Link student account with Firebase Auth user when student signs up
  static Future<String?> linkStudentAccount({
    required String email,
    required String userId,
  }) async {
    try {
      if (kDebugMode) {
        print('🔗 [DATABASE] Linking student account with user...');
        print('   Email: $email');
        print('   User ID: $userId');
      }

      // Find student by email
      final student = await getStudentByEmail(email);
      if (student == null) {
        if (kDebugMode) print('❌ [DATABASE] Student not found for email: $email');
        return null;
      }

      // Update student with userId
      await _firestore
          .collection(AppConstants.studentsCollection)
          .doc(student.id)
          .update({
        'userId': userId,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Update user with studentId
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'studentId': student.id,
      });

      if (kDebugMode) {
        print('✅ [DATABASE] Successfully linked accounts!');
        print('   Student ID: ${student.id}');
        print('   User ID: $userId');
      }

      return student.id;
    } catch (e) {
      if (kDebugMode) print('❌ [DATABASE] Error linking accounts: $e');
      rethrow;
    }
  }


  /// Add student to class
  static Future<String> addStudent({
    required String name,
    required String email,
    required String classId,
    String? phone,
    String? rollNumber,
    DateTime? admissionDate,
    String? feesStatus,
  }) async {
    return await _withErrorHandling(
      () async {
        // Check for duplicate roll number if provided
        if (rollNumber != null && rollNumber.isNotEmpty) {
          final isDuplicate = await checkDuplicateStudent(
            classId: classId,
            rollNumber: rollNumber,
          );
          if (isDuplicate) {
            throw Exception('A student with roll number "$rollNumber" already exists in this class');
          }
        }

        final studentId = uuid.v4();
        final student = StudentModel(
          id: studentId,
          name: name,
          email: email.toLowerCase().trim(),
          phone: phone,
          rollNumber: rollNumber,
          classId: classId,
          attendancePercentage: 100.0,
          averageMarks: 0.0,
          enrolledAt: admissionDate ?? DateTime.now(),
          isActive: true,
          feesStatus: feesStatus ?? 'Pending',
        );

        // Use batch operation for atomicity
        final batch = _firestore.batch();
        
        // Add the student
        final studentRef = _firestore.collection(AppConstants.studentsCollection).doc(studentId);
        batch.set(studentRef, student.toJson());

        // Update class student count
        final classRef = _firestore.collection(AppConstants.classesCollection).doc(classId);
        batch.update(classRef, {
          'studentCount': FieldValue.increment(1),
          'updatedAt': DateTime.now().toIso8601String(),
        });

        // Commit batch with timeout
        await batch.commit().timeout(_writeTimeout);

        if (kDebugMode) print('✅ [DATABASE] Student added successfully: $studentId');
        return studentId;
      },
      operationName: 'addStudent',
    );
  }

  /// Bulk add students to class
  static Future<void> bulkAddStudents({
    required String classId,
    required List<Map<String, String>> studentData,
  }) async {
    try {
      final batch = _firestore.batch();
      final now = DateTime.now();

      for (var data in studentData) {
        final id = uuid.v4();
        final student = StudentModel(
          id: id,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          classId: classId,
          enrolledAt: now,
          attendancePercentage: 100.0,
          averageMarks: 0.0,
        );
        
        final docRef = _firestore.collection(AppConstants.studentsCollection).doc(id);
        batch.set(docRef, student.toJson());
      }

      // Update class count
      final classRef = _firestore.collection(AppConstants.classesCollection).doc(classId);
      batch.update(classRef, {
        'studentCount': FieldValue.increment(studentData.length),
        'updatedAt': now.toIso8601String(),
      });

      await batch.commit().timeout(_writeTimeout);
    } catch (e) {
      rethrow;
    }
  }

  /// Get student by ID

  static Future<StudentModel?> getStudentById(String studentId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.studentsCollection)
          .doc(studentId)
          .get();

      if (doc.exists) {
        return StudentModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Get all students for a class (stream)
  static Stream<List<StudentModel>> getClassStudentsStream(String classId) {
    return _firestore
        .collection(AppConstants.studentsCollection)
        .where('classId', isEqualTo: classId)
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => StudentModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  /// Check if student with same roll number exists in class
  static Future<bool> checkDuplicateStudent({
    required String classId,
    String? rollNumber,
    String? name,
  }) async {
    try {
      // Check by roll number if provided
      if (rollNumber != null && rollNumber.isNotEmpty) {
        final rollQuery = await _firestore
            .collection(AppConstants.studentsCollection)
            .where('classId', isEqualTo: classId)
            .where('rollNumber', isEqualTo: rollNumber)
            .where('isActive', isEqualTo: true)
            .limit(1)
            .get();
        
        if (rollQuery.docs.isNotEmpty) {
          return true; // Duplicate found
        }
      }
      
      return false; // No duplicate
    } catch (e) {
      if (kDebugMode) print('Error checking duplicate: $e');
      return false; // On error, allow the addition
    }
  }

  /// Get all students for a teacher across all classes
  static Stream<List<StudentModel>> getTeacherStudentsStream(String teacherId) async* {
    // First, get all class IDs for this teacher
    await for (final classSnapshot in _firestore
        .collection(AppConstants.classesCollection)
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()) {
      
      final classIds = classSnapshot.docs.map((doc) => doc.id).toList();
      
      if (classIds.isEmpty) {
        yield [];
        continue;
      }
      
      // Firestore whereIn supports max 10 items, so we batch the queries
      List<StudentModel> allStudents = [];
      
      for (int i = 0; i < classIds.length; i += 10) {
        final batch = classIds.skip(i).take(10).toList();
        
        final studentSnapshot = await _firestore
            .collection(AppConstants.studentsCollection)
            .where('classId', whereIn: batch)
            .where('isActive', isEqualTo: true)
            .get();
        
        allStudents.addAll(
          studentSnapshot.docs
              .map((doc) => StudentModel.fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        );
      }
      
      yield allStudents;
    }
  }

  /// Update student
  static Future<void> updateStudent(String studentId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(AppConstants.studentsCollection)
          .doc(studentId)
          .update({...data, 'updatedAt': DateTime.now().toIso8601String()});
    } catch (e) {
      rethrow;
    }
  }

  /// Delete student (soft delete)
  static Future<void> deleteStudent(String studentId, String classId) async {
    try {
      final batch = _firestore.batch();
      
      final studentRef = _firestore.collection(AppConstants.studentsCollection).doc(studentId);
      batch.update(studentRef, {
        'isActive': false, 
        'updatedAt': DateTime.now().toIso8601String()
      });

      // Update class student count
      final classRef = _firestore.collection(AppConstants.classesCollection).doc(classId);
      batch.update(classRef, {'studentCount': FieldValue.increment(-1)});

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  // ===== ATTENDANCE OPERATIONS =====

  /// Record attendance
  static Future<String> recordAttendance({
    required String classId,
    required String studentId,
    required DateTime date,
    required bool isPresent,
    String? remarks,
  }) async {
    try {
      // Normalize date to start of day
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final dateString = '${normalizedDate.year}-${normalizedDate.month.toString().padLeft(2, '0')}-${normalizedDate.day.toString().padLeft(2, '0')}';

      // Create a composite key for uniqueness
      final compositeKey = '${classId}_${studentId}_$dateString';

      // Check if attendance record already exists
      final existingQuery = await _firestore
          .collection(AppConstants.attendanceCollection)
          .where('classId', isEqualTo: classId)
          .where('studentId', isEqualTo: studentId)
          .where('dateString', isEqualTo: dateString)
          .limit(1)
          .get();

      String attendanceId;
      
      if (existingQuery.docs.isNotEmpty) {
        // Update existing record
        attendanceId = existingQuery.docs.first.id;
        await _firestore
            .collection(AppConstants.attendanceCollection)
            .doc(attendanceId)
            .update({
          'isPresent': isPresent,
          'remarks': remarks,
          'recordedAt': DateTime.now().toIso8601String(),
        }).timeout(_writeTimeout);
        if (kDebugMode) print('Updated attendance: $attendanceId');
      } else {
        // Create new record with predictable ID to avoid duplicates
        attendanceId = compositeKey;
        final attendance = AttendanceModel(
          id: attendanceId,
          classId: classId,
          studentId: studentId,
          date: normalizedDate,
          dateString: dateString,
          isPresent: isPresent,
          remarks: remarks,
          recordedAt: DateTime.now(),
        );

        await _firestore
            .collection(AppConstants.attendanceCollection)
            .doc(attendanceId)
            .set(attendance.toJson())
            .timeout(_writeTimeout);
        if (kDebugMode) print('Created attendance: $attendanceId');
      }

      // Update student attendance percentage
      await _updateStudentAttendancePercentage(studentId, classId);

      return attendanceId;
    } catch (e) {
      if (kDebugMode) print('Error recording attendance: $e');
      rethrow;
    }
  }

  /// Get attendance for a date
  static Future<List<AttendanceModel>> getAttendanceByDate({
    required String classId,
    required DateTime date,
  }) async {
    try {
      final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final snapshot = await _firestore
          .collection(AppConstants.attendanceCollection)
          .where('classId', isEqualTo: classId)
          .where('dateString', isEqualTo: dateString)
          .get();

      return snapshot.docs
          .map((doc) => AttendanceModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      if (kDebugMode) print('Error getting attendance by date: $e');
      rethrow;
    }
  }

  /// Get student's attendance records
  static Stream<List<AttendanceModel>> getStudentAttendanceStream(String studentId) {
    return _firestore
        .collection(AppConstants.attendanceCollection)
        .where('studentId', isEqualTo: studentId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AttendanceModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  /// Get attendance for a date (stream for real-time updates)
  static Stream<List<AttendanceModel>> getAttendanceByDateStream({
    required String classId,
    required DateTime date,
  }) {
    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    return _firestore
        .collection(AppConstants.attendanceCollection)
        .where('classId', isEqualTo: classId)
        .where('dateString', isEqualTo: dateString)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AttendanceModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  /// Get all attendance records for a class
  static Future<List<AttendanceModel>> getClassAttendanceRecords(String classId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.attendanceCollection)
          .where('classId', isEqualTo: classId)
          .get();

      return snapshot.docs
          .map((doc) => AttendanceModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Update attendance
  static Future<void> updateAttendance(String attendanceId, bool isPresent) async {
    try {
      await _firestore
          .collection(AppConstants.attendanceCollection)
          .doc(attendanceId)
          .update({'isPresent': isPresent, 'recordedAt': DateTime.now().toIso8601String()});
    } catch (e) {
      rethrow;
    }
  }

  /// Calculate and update student attendance percentage
  static Future<void> _updateStudentAttendancePercentage(
      String studentId, String classId) async {
    try {
      if (kDebugMode) print('📊 [DB] Calculating attendance percentage for student: $studentId');
      
      final snapshot = await _firestore
          .collection(AppConstants.attendanceCollection)
          .where('studentId', isEqualTo: studentId)
          .where('classId', isEqualTo: classId)
          .get();

      if (snapshot.docs.isEmpty) {
        if (kDebugMode) print('📊 [DB] No attendance records found for student');
        return;
      }

      int presentDays = 0;
      int totalDays = snapshot.docs.length;
      for (var doc in snapshot.docs) {
        if (doc['isPresent'] == true) {
          presentDays++;
        }
      }

      final percentage = (presentDays / totalDays) * 100;
      if (kDebugMode) print('📊 [DB] Attendance: $presentDays/$totalDays days = ${percentage.toStringAsFixed(2)}%');

      await _firestore
          .collection(AppConstants.studentsCollection)
          .doc(studentId)
          .update({'attendancePercentage': percentage});
      
      if (kDebugMode) print('✅ [DB] Updated student attendance percentage to ${percentage.toStringAsFixed(2)}%');
    } catch (e) {
      if (kDebugMode) print('❌ [DB] Error updating attendance percentage: $e');
      rethrow;
    }
  }

  // ===== MARKS OPERATIONS =====

  /// Add marks for student
  static Future<String> addMarks({
    required String classId,
    required String testName,
    required String subject,
    required String studentId,
    required double obtainedMarks,
    required double totalMarks,
  }) async {
    try {
      final marksId = uuid.v4();
      final marks = MarksModel(
        id: marksId,
        classId: classId,
        testName: testName,
        subject: subject,
        studentId: studentId,
        obtainedMarks: obtainedMarks,
        totalMarks: totalMarks,
        recordedAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.marksCollection)
          .doc(marksId)
          .set(marks.toJson());

      // Update student average marks
      await _updateStudentAverageMarks(studentId, classId);

      return marksId;
    } catch (e) {
      rethrow;
    }
  }

  /// Get marks for a student
  static Stream<List<MarksModel>> getStudentMarksStream(String studentId) {
    return _firestore
        .collection(AppConstants.marksCollection)
        .where('studentId', isEqualTo: studentId)
        .orderBy('recordedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MarksModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  /// Get marks for a class
  static Stream<List<MarksModel>> getClassMarksStream(String classId) {
    return _firestore
        .collection(AppConstants.marksCollection)
        .where('classId', isEqualTo: classId)
        .orderBy('recordedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MarksModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  /// Update marks
  static Future<void> updateMarks(
    String marksId,
    double obtainedMarks,
    String studentId,
    String classId,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.marksCollection)
          .doc(marksId)
          .update({
        'obtainedMarks': obtainedMarks,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Update student average marks
      await _updateStudentAverageMarks(studentId, classId);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete marks
  static Future<void> deleteMarks(String marksId, String studentId, String classId) async {
    try {
      await _firestore
          .collection(AppConstants.marksCollection)
          .doc(marksId)
          .delete();

      // Update student average marks
      await _updateStudentAverageMarks(studentId, classId);
    } catch (e) {
      rethrow;
    }
  }

  /// Calculate and update student average marks
  static Future<void> _updateStudentAverageMarks(String studentId, String classId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.marksCollection)
          .where('studentId', isEqualTo: studentId)
          .where('classId', isEqualTo: classId)
          .get();

      if (snapshot.docs.isEmpty) {
        await _firestore
            .collection(AppConstants.studentsCollection)
            .doc(studentId)
            .update({'averageMarks': 0.0});
        return;
      }

      double totalPercentage = 0.0;
      for (var doc in snapshot.docs) {
        final percentage = ((doc['obtainedMarks'] ?? 0) / (doc['totalMarks'] ?? 100)) * 100;
        totalPercentage += percentage;
      }

      final averagePercentage = totalPercentage / snapshot.docs.length;

      await _firestore
          .collection(AppConstants.studentsCollection)
          .doc(studentId)
          .update({'averageMarks': averagePercentage});
    } catch (e) {
      rethrow;
    }
  }

  // ===== ANNOUNCEMENT OPERATIONS =====

  /// Create announcement
  static Future<String> createAnnouncement({
    required String classId,
    required String teacherId,
    required String title,
    required String content,
  }) async {
    try {
      final announcementId = uuid.v4();
      final announcement = AnnouncementModel(
        id: announcementId,
        classId: classId,
        teacherId: teacherId,
        title: title,
        content: content,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.announcementsCollection)
          .doc(announcementId)
          .set(announcement.toJson());

      return announcementId;
    } catch (e) {
      rethrow;
    }
  }

  /// Get announcements for a class
  static Stream<List<AnnouncementModel>> getClassAnnouncementsStream(String classId) {
    return _firestore
        .collection(AppConstants.announcementsCollection)
        .where('classId', isEqualTo: classId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AnnouncementModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  /// Update announcement
  static Future<void> updateAnnouncement(
    String announcementId,
    String title,
    String content,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.announcementsCollection)
          .doc(announcementId)
          .update({
        'title': title,
        'content': content,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Delete announcement
  static Future<void> deleteAnnouncement(String announcementId) async {
    try {
      await _firestore
          .collection(AppConstants.announcementsCollection)
          .doc(announcementId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  // ===== EXAM OPERATIONS ===== (Added missing methods)
  static Stream<List<Exam>> getClassExamsStream(String classId) {
    return _firestore
        .collection(AppConstants.examsCollection)
        .where('classId', isEqualTo: classId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Exam.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // ===== UTILITY OPERATIONS =====

  /// Get class name by ID
  static Future<String?> getClassName(String classId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.classesCollection)
          .doc(classId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        return data?['name'] as String?;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Get student name by ID
  static Future<String?> getStudentName(String studentId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.studentsCollection)
          .doc(studentId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        return data?['name'] as String?;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
