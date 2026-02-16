import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/announcement_model.dart';
import '../services/database_service.dart';

/// Announcement Provider - Manages announcements state
class AnnouncementProvider extends ChangeNotifier {
  List<AnnouncementModel> _announcements = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<AnnouncementModel>>? _announcementSubscription;
  String? _currentClassId;

  // Getters
  List<AnnouncementModel> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load announcements for a class with real-time updates
  void loadClassAnnouncements(String classId) {
    // Avoid redundant subscriptions for the same class
    if (_currentClassId == classId && _announcementSubscription != null) {
      if (kDebugMode) print('📢 [ANNOUNCEMENT] Already subscribed to announcements for class: $classId');
      return;
    }

    if (kDebugMode) print('📢 [ANNOUNCEMENT] Setting up real-time announcements stream for class: $classId');
    _currentClassId = classId;
    _announcementSubscription?.cancel();
    
    _isLoading = true;
    notifyListeners();

    _announcementSubscription = DatabaseService.getClassAnnouncementsStream(classId).listen(
      (announcementList) {
        if (kDebugMode) print('📢 [ANNOUNCEMENT] Received ${announcementList.length} announcements');
        _announcements = announcementList;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        if (kDebugMode) print('❌ [ANNOUNCEMENT] Error loading announcements: $e');
        _isLoading = false;
        _error = 'Failed to load announcements';
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _announcementSubscription?.cancel();
    super.dispose();
  }

  /// Create announcement
  Future<bool> createAnnouncement({
    required String classId,
    required String teacherId,
    required String title,
    required String content,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await DatabaseService.createAnnouncement(
        classId: classId,
        teacherId: teacherId,
        title: title,
        content: content,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to create announcement';
      notifyListeners();
      return false;
    }
  }

  /// Update announcement
  Future<bool> updateAnnouncement(
    String announcementId,
    String title,
    String content,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await DatabaseService.updateAnnouncement(announcementId, title, content);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to update announcement';
      notifyListeners();
      return false;
    }
  }

  /// Delete announcement
  Future<bool> deleteAnnouncement(String announcementId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await DatabaseService.deleteAnnouncement(announcementId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to delete announcement';
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
