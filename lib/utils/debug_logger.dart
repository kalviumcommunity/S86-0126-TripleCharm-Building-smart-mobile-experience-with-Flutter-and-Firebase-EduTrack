import 'package:flutter/foundation.dart';

/// Debug logger utility - only prints in debug mode
class DebugLogger {
  static void log(String message) {
    if (kDebugMode) {
      print(message);
    }
  }
}
