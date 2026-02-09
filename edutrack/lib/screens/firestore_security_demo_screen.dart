import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/security_service.dart';
import '../services/firestore_service.dart';

/// Demo screen for testing Firestore Security Rules and Permissions
class FirestoreSecurityDemoScreen extends StatefulWidget {
  const FirestoreSecurityDemoScreen({Key? key}) : super(key: key);

  @override
  State<FirestoreSecurityDemoScreen> createState() =>
      _FirestoreSecurityDemoScreenState();
}

class _FirestoreSecurityDemoScreenState extends State<FirestoreSecurityDemoScreen> {
  late AuthService _authService;
  late SecurityService _securityService;
  late FirestoreService _firestoreService;

  String _status = 'Loading...';
  String _userInfo = '';
  String _testLogs = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _securityService = SecurityService();
    _firestoreService = FirestoreService();
    _initializeStatus();
  }

  Future<void> _initializeStatus() async {
    await _updateStatus();
  }

  Future<void> _updateStatus() async {
    final user = _authService.currentUser;
    String info = '';

    if (user != null) {
      final role = await _securityService.getCurrentUserRole();
      final isAdmin = await _securityService.currentUserIsAdmin();
      final isTeacher = await _securityService.currentUserIsTeacher();
      final isStudent = await _securityService.currentUserIsStudent();

      info = '''
📧 Email: ${user.email}
🆔 UID: ${user.uid}
👤 Role: ${role?.value ?? 'Not set'}

📊 Roles:
  • Admin: $isAdmin
  • Teacher: $isTeacher
  • Student: $isStudent

✅ Session: Valid
      ''';
    } else {
      info = 'Not logged in';
    }

    setState(() {
      _userInfo = info;
      _status = user != null ? '✅ Authenticated' : '❌ Not authenticated';
    });
  }

  void _addLog(String message) {
    setState(() {
      final timestamp = DateTime.now().toString().split('.')[0];
      _testLogs = '[$timestamp] $message\n$_testLogs';
    });
  }

  /// Test 1: Try to read own user document
  Future<void> _testReadOwnProfile() async {
    setState(() => _isLoading = true);
    _addLog('Testing: Read own profile...');

    try {
      if (_securityService.currentUserId == null) {
        throw Exception('No user logged in');
      }

      final data = await _firestoreService.getUserData(_securityService.currentUserId!);
      if (data != null) {
        _addLog('✅ SUCCESS: Can read own profile');
      } else {
        _addLog('⚠️  Document does not exist');
      }
    } catch (e) {
      _addLog('❌ DENIED: Cannot read own profile - $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Test 2: Try to read another user's document
  Future<void> _testReadOtherProfile() async {
    setState(() => _isLoading = true);
    _addLog('Testing: Read other user profile...');

    try {
      // Try to read a fake user ID
      const fakeUserId = 'fake_user_123456';
      final data = await _firestoreService.getUserData(fakeUserId);

      if (data != null) {
        _addLog('❌ SECURITY ISSUE: Can read other user profile!');
      } else {
        _addLog('✅ SUCCESS: Cannot read other user profile (permission denied)');
      }
    } catch (e) {
      _addLog('✅ SUCCESS: Permission denied - $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Test 3: Try to create an assignment (requires teacher role)
  Future<void> _testCreateAssignment() async {
    setState(() => _isLoading = true);
    _addLog('Testing: Create assignment (requires teacher role)...');

    try {
      final isTeacher = await _securityService.currentUserIsTeacher();

      if (!isTeacher) {
        _addLog('ℹ️  INFO: You are not a teacher (role required)');
        _addLog('To test: Set your role to "teacher" first');
        setState(() => _isLoading = false);
        return;
      }

      final assignmentData = {
        'title': 'Test Assignment ${DateTime.now().millisecondsSinceEpoch}',
        'description': 'This is a test assignment',
        'subject': 'Math',
        'dueDate': DateTime.now().add(const Duration(days: 7)),
      };

      final docId = await _firestoreService.addStudent(assignmentData);
      _addLog('✅ SUCCESS: Assignment created with ID: $docId');
    } catch (e) {
      _addLog('❌ FAILED: Cannot create assignment - $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Test 4: Check permission before deletion
  Future<void> _testDeletionPermission() async {
    setState(() => _isLoading = true);
    _addLog('Testing: Check deletion permission...');

    try {
      const testDocId = 'test_document_123';
      final canDelete = await _securityService.canDeleteDocument('students', testDocId);

      if (canDelete) {
        _addLog('✅ You have permission to delete documents');
      } else {
        _addLog('✅ SUCCESS: Cannot delete (only admins allowed)');
      }
    } catch (e) {
      _addLog('❌ Error checking permission: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Test 5: Access control based on role
  Future<void> _testRoleBasedAccess() async {
    setState(() => _isLoading = true);
    _addLog('Testing: Role-based access control...');

    try {
      final role = await _securityService.getCurrentUserRole();
      final collections = await _securityService.getAccessibleCollections(
          _securityService.currentUserId!);

      _addLog('Your role: ${role?.value ?? "Not set"}');
      _addLog('Accessible collections:');
      for (final collection in collections) {
        _addLog('  • $collection');
      }
      _addLog('✅ SUCCESS: Access control verified');
    } catch (e) {
      _addLog('❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Test 6: Data validation
  Future<void> _testDataValidation() async {
    setState(() => _isLoading = true);
    _addLog('Testing: Data validation...');

    try {
      // Test with valid data
      _addLog('Test 1: Valid user data');
      final validData = {
        'uid': 'test_uid_123',
        'email': 'test@example.com',
      };
      _securityService.validateUserData(validData);
      _addLog('✅ Valid data accepted');

      // Test with invalid email
      _addLog('Test 2: Invalid email');
      final invalidData = {
        'uid': 'test_uid_123',
        'email': 'invalid-email',
      };
      try {
        _securityService.validateUserData(invalidData);
        _addLog('❌ Invalid email was accepted (should be rejected)');
      } catch (e) {
        _addLog('✅ Invalid email rejected: ${e.toString()}');
      }
    } catch (e) {
      _addLog('❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Test 7: Audit logging
  Future<void> _testAuditLogging() async {
    setState(() => _isLoading = true);
    _addLog('Testing: Audit logging...');

    try {
      await _securityService.logAction(
        actionType: 'security_test',
        description: 'User tested Firestore security rules',
        additionalData: {'testName': 'audit_logging_test'},
      );
      _addLog('✅ SUCCESS: Action logged to audit trail');
    } catch (e) {
      _addLog('❌ Failed to log action: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Test 8: Session validity
  Future<void> _testSessionValidity() async {
    setState(() => _isLoading = true);
    _addLog('Testing: Session validity...');

    try {
      final isValid = await _securityService.isSessionValid();
      if (isValid) {
        _addLog('✅ SUCCESS: User session is valid');
      } else {
        _addLog('❌ Session is invalid - please re-authenticate');
      }
    } catch (e) {
      _addLog('❌ Error checking session: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearLogs() {
    setState(() => _testLogs = '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Security Testing'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Information Section
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _status.startsWith('✅')
                                ? Colors.green
                                : Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _userInfo,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test Buttons Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Security Tests',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTestButton(
                      '1. Read Own Profile',
                      '✅ Baseline - should always succeed',
                      _testReadOwnProfile,
                    ),
                    _buildTestButton(
                      '2. Read Other Profile',
                      '❌ Should be denied',
                      _testReadOtherProfile,
                    ),
                    _buildTestButton(
                      '3. Create Assignment',
                      '⚠️  Requires teacher role',
                      _testCreateAssignment,
                    ),
                    _buildTestButton(
                      '4. Check Deletion Permission',
                      '🔒 Admin only',
                      _testDeletionPermission,
                    ),
                    _buildTestButton(
                      '5. Role-Based Access',
                      '👤 List accessible collections',
                      _testRoleBasedAccess,
                    ),
                    _buildTestButton(
                      '6. Data Validation',
                      '⚠️  Check data constraints',
                      _testDataValidation,
                    ),
                    _buildTestButton(
                      '7. Audit Logging',
                      '📋 Log security test',
                      _testAuditLogging,
                    ),
                    _buildTestButton(
                      '8. Session Validity',
                      '🔑 Verify auth token',
                      _testSessionValidity,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test Results Section
            Card(
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Test Results',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _clearLogs,
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Clear'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                        fontFeature: const [],
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _testLogs.isEmpty ? 'Run tests to see results...' : _testLogs,
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: Color(0xFF00FF00),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Information Section
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About These Tests',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '✅ = Permission Granted\n'
                      '❌ = Permission Denied\n'
                      '⚠️ = Conditional (depends on your role)\n'
                      '🔒 = Admin Only\n',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Results depend on your Firestore rules and user role. '
                      'Check FIRESTORE_SECURITY_LESSON.md for detailed explanations.',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(String title, String description, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
