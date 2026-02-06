import 'package:flutter/material.dart';
import '../services/cloud_functions_service.dart';

/// Demo screen for Cloud Functions
/// Demonstrates how to call:
/// 1. Callable Cloud Functions (sayHello, logUserActivity)
/// 2. How to handle responses and errors
class CloudFunctionsDemo extends StatefulWidget {
  const CloudFunctionsDemo({Key? key}) : super(key: key);

  @override
  State<CloudFunctionsDemo> createState() => _CloudFunctionsDemoState();
}

class _CloudFunctionsDemoState extends State<CloudFunctionsDemo> {
  final CloudFunctionsService _functionsService = CloudFunctionsService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _activityTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _responseMessage = '';
  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = 'Flutter Developer';
    _activityTypeController.text = 'course_view';
    _descriptionController.text = 'Viewed Flutter Basics lesson';
  }

  /// Call the sayHello cloud function
  Future<void> _callSayHello() async {
    setState(() {
      _isLoading = true;
      _responseMessage = '';
      _isSuccess = false;
    });

    try {
      final result = await _functionsService.sayHello(_nameController.text);

      setState(() {
        _responseMessage = result['message'] ?? 'No response';
        _isSuccess = result['success'] ?? false;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Function called successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _responseMessage = 'Error: ${e.toString()}';
        _isSuccess = false;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Call the logUserActivity cloud function
  Future<void> _callLogActivity() async {
    setState(() {
      _isLoading = true;
      _responseMessage = '';
      _isSuccess = false;
    });

    try {
      final result = await _functionsService.logUserActivity(
        activityType: _activityTypeController.text,
        description: _descriptionController.text,
      );

      setState(() {
        _responseMessage =
            '${result['message']}\nActivity ID: ${result['activityId'] ?? 'N/A'}';
        _isSuccess = result['success'] ?? false;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Activity logged successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _responseMessage = 'Error: ${e.toString()}';
        _isSuccess = false;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Functions Demo'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== Function 1: Say Hello ==========
            _buildSectionHeader('1. Callable Function: Say Hello'),
            const SizedBox(height: 12),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter your name and click to receive a greeting from the cloud:',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Your Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _callSayHello,
                      icon: const Icon(Icons.cloud),
                      label: const Text('Call sayHello Function'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ========== Function 2: Log User Activity ==========
            _buildSectionHeader('2. Callable Function: Log Activity'),
            const SizedBox(height: 12),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Log user activity to Firestore via Cloud Function:',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _activityTypeController,
                    decoration: InputDecoration(
                      labelText: 'Activity Type',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., course_view, assignment_submit',
                      prefixIcon: Icon(Icons.category),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _callLogActivity,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('Log Activity'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ========== Response Display ==========
            if (_responseMessage.isNotEmpty) ...[
              _buildSectionHeader('Response from Cloud Function'),
              const SizedBox(height: 12),
              _buildCard(
                color: _isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isSuccess ? Icons.check_circle : Icons.error,
                          color: _isSuccess ? Colors.green : Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _isSuccess ? 'Success' : 'Error',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _isSuccess ? Colors.green : Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      _responseMessage,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ========== Loading Indicator ==========
            if (_isLoading) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ========== Info Section ==========
            _buildSectionHeader('How It Works'),
            const SizedBox(height: 12),
            _buildCard(
              color: Colors.blue.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '📱 Callable Functions:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• sayHello: Returns a personalized greeting message\n'
                    '• logUserActivity: Logs activity to Firestore and returns activity ID\n\n'
                    '🔥 Event-Based Functions (running in background):\n'
                    '• onNewUserCreated: Initializes user profile when user document is created\n'
                    '• onCourseUpdated: Logs course changes when course data is updated\n'
                    '• onUserDeleted: Cleans up user data when user is deleted',
                    style: TextStyle(fontSize: 13, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ========== Deployment Instructions ==========
            _buildSectionHeader('Deployment Instructions'),
            const SizedBox(height: 12),
            _buildCard(
              color: Colors.amber.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '1. Open terminal in project root\n'
                    '2. Run: npm install -g firebase-tools\n'
                    '3. Run: firebase login\n'
                    '4. Navigate to functions directory: cd functions\n'
                    '5. Install dependencies: npm install\n'
                    '6. Deploy: firebase deploy --only functions\n'
                    '7. Check logs: firebase functions:log',
                    style: TextStyle(fontSize: 13, fontFamily: 'monospace', height: 1.8),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a section header widget
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  /// Build a card widget with content
  Widget _buildCard({
    required Widget child,
    Color? color,
  }) {
    return Card(
      color: color ?? Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _activityTypeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
