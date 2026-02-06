import 'package:cloud_functions/cloud_functions.dart';

/// Service class for interacting with Firebase Cloud Functions
/// Handles callable functions and provides a convenient wrapper for calling serverless logic
class CloudFunctionsService {
  static final CloudFunctionsService _instance = CloudFunctionsService._internal();

  late final FirebaseFunctions _functions;

  CloudFunctionsService._internal() {
    _functions = FirebaseFunctions.instance;
    // Uncomment to emulate functions locally during development
    // _functions.useFunctionsEmulator('localhost', 5001);
  }

  factory CloudFunctionsService() {
    return _instance;
  }

  /// Call the sayHello callable cloud function
  /// Returns a greeting message from the backend
  /// 
  /// Example:
  /// ```dart
  /// final result = await CloudFunctionsService().sayHello('Alice');
  /// print(result['message']); // "Hello, Alice! Welcome to EduTrack!"
  /// ```
  Future<Map<String, dynamic>> sayHello(String name) async {
    try {
      print('Calling sayHello cloud function with name: $name');
      
      final callable = _functions.httpsCallable('sayHello');
      final result = await callable.call({'name': name});
      
      print('sayHello response: ${result.data}');
      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      print('Cloud Functions error: ${e.code} - ${e.message}');
      throw _handleFunctionsError(e);
    } catch (e) {
      print('Unexpected error calling sayHello: $e');
      rethrow;
    }
  }

  /// Call the logUserActivity callable cloud function
  /// Logs user activity to Firestore through a cloud function
  /// 
  /// Parameters:
  /// - [activityType]: Type of activity (e.g., 'course_view', 'assignment_submit')
  /// - [description]: Optional description of the activity
  /// 
  /// Returns a map containing:
  /// - success: Boolean indicating if the activity was logged
  /// - message: Status message
  /// - activityId: ID of the created activity document
  /// - timestamp: Server timestamp of the activity
  /// 
  /// Example:
  /// ```dart
  /// final result = await CloudFunctionsService().logUserActivity(
  ///   activityType: 'course_enrolled',
  ///   description: 'Enrolled in Flutter Basics course'
  /// );
  /// ```
  Future<Map<String, dynamic>> logUserActivity({
    required String activityType,
    String? description,
  }) async {
    try {
      print('Logging user activity: $activityType');
      
      final callable = _functions.httpsCallable('logUserActivity');
      final result = await callable.call({
        'activityType': activityType,
        'description': description ?? '',
      });
      
      print('Activity logged successfully: ${result.data}');
      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (e) {
      print('Cloud Functions error: ${e.code} - ${e.message}');
      throw _handleFunctionsError(e);
    } catch (e) {
      print('Unexpected error logging activity: $e');
      rethrow;
    }
  }

  /// Handle Firebase Cloud Functions errors in a user-friendly way
  String _handleFunctionsError(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'not-found':
        return 'Cloud Function not found. Please check the function name.';
      case 'permission-denied':
        return 'You do not have permission to call this function.';
      case 'unauthenticated':
        return 'User must be authenticated to call this function.';
      case 'invalid-argument':
        return 'Invalid arguments provided: ${e.message}';
      case 'internal':
        return 'An internal server error occurred.';
      case 'resource-exhausted':
        return 'Resource limit exceeded. Please try again later.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}
