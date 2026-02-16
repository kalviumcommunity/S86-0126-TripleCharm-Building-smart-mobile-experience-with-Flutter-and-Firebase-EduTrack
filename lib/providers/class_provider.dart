import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/class_model.dart';
import '../services/database_service.dart';

/// Class Provider - Manages classes state
class ClassProvider extends ChangeNotifier {
  List<ClassModel> _classes = [];
  ClassModel? _selectedClass;
  bool _isLoading = false;
  String? _error;
  String? _lastTeacherId;
  StreamSubscription? _classSubscription;

  // Getters
  List<ClassModel> get classes => _classes;
  ClassModel? get selectedClass => _selectedClass;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get classCount => _classes.length;

  /// Create a new class
  Future<bool> createClass({
    required String name,
    required String teacherId,
    String? description,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await DatabaseService.createClass(
        name: name,
        teacherId: teacherId,
        description: description,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to create class: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load teacher's classes as stream
  void loadTeacherClasses(String teacherId) {
    if (teacherId.isEmpty) {
      _classes = [];
      notifyListeners();
      return;
    }

    // Avoid redundant re-subscriptions for the same teacher
    if (_lastTeacherId == teacherId && _classSubscription != null) {
      if (kDebugMode) print('📋 [CLASS] Already subscribed to classes for teacher: $teacherId');
      return;
    }

    if (kDebugMode) print('📋 [CLASS] Loading classes for teacher: $teacherId');
    _lastTeacherId = teacherId;
    _classSubscription?.cancel();
    
    _isLoading = true;
    notifyListeners();

    _classSubscription = DatabaseService.getTeacherClassesStream(teacherId).listen(
      (classList) {
        if (kDebugMode) {
          print('📋 [CLASS] Received ${classList.length} classes from stream');
          for (var c in classList) {
            print('   - ${c.name} (ID: ${c.id})');
          }
        }
        _classes = classList;
        _isLoading = false;
        _error = null;
        notifyListeners();
      }, 
      onError: (e) {
        if (kDebugMode) print('❌ [CLASS] Error loading classes: $e');
        _error = 'Failed to load classes: ${e.toString()}';
        _isLoading = false;
        notifyListeners();
      }
    );
  }

  @override
  void dispose() {
    _classSubscription?.cancel();
    super.dispose();
  }

  /// Get class by ID
  Future<ClassModel?> getClassById(String classId) async {
    try {
      return await DatabaseService.getClassById(classId);
    } catch (e) {
      _error = 'Failed to load class';
      notifyListeners();
      return null;
    }
  }

  /// Select a class
  void selectClass(ClassModel classModel) {
    _selectedClass = classModel;
    notifyListeners();
  }

  /// Update class
  Future<bool> updateClass({
    required String classId,
    required String name,
    String? description,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await DatabaseService.updateClass(classId, {
        'name': name,
        'description': description,
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update class: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete class
  Future<bool> deleteClass(String classId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await DatabaseService.deleteClass(classId);

      if (_selectedClass?.id == classId) {
        _selectedClass = null;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete class: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Fetch classes for a teacher (alias for loadTeacherClasses)
  Future<void> fetchClasses(String teacherId) async {
    loadTeacherClasses(teacherId);
  }
}
