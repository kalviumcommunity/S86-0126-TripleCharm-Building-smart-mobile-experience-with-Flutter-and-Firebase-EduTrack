import 'package:intl/intl.dart';

/// Form Validation Utilities
class ValidationHelper {
  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  /// Validate name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.length > 50) {
      return 'Name must not exceed 50 characters';
    }
    return null;
  }

  /// Validate roll number
  static String? validateRollNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Roll number is required';
    }
    return null;
  }

  /// Validate class/grade
  static String? validateClass(String? value) {
    if (value == null || value.isEmpty) {
      return 'Class is required';
    }
    return null;
  }

  /// Validate subject
  static String? validateSubject(String? value) {
    if (value == null || value.isEmpty) {
      return 'Subject is required';
    }
    return null;
  }

  /// Validate marks
  static String? validateMarks(String? value) {
    if (value == null || value.isEmpty) {
      return 'Marks are required';
    }
    try {
      double.parse(value);
    } catch (e) {
      return 'Please enter a valid number';
    }
    return null;
  }

  /// Check if passwords match
  static bool passwordsMatch(String password1, String password2) {
    return password1 == password2;
  }
}

/// Date and Time Utilities
class DateTimeHelper {
  /// Format date to dd/MM/yyyy
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format date with time to dd/MM/yyyy HH:mm
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  /// Format time to HH:mm
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Get date without time
  static DateTime getDateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  /// Get readable date string (e.g., "Today", "Yesterday", "3 days ago")
  static String getRelativeDateString(DateTime date) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final dateToCheck = DateTime(date.year, date.month, date.day);
    final difference = todayDate.difference(dateToCheck).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference > 1 && difference < 7) {
      return '$difference days ago';
    } else {
      return formatDate(date);
    }
  }

  /// Get current date only
  static DateTime getCurrentDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}

/// Number Formatting Utilities
class NumberHelper {
  /// Format marks with 2 decimal places
  static String formatMarks(double marks) {
    return marks.toStringAsFixed(2);
  }

  /// Format percentage
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(2)}%';
  }

  /// Get grade color code
  static String getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return '#4CAF50'; // Green (Excellent)
      case 'B':
        return '#8BC34A'; // Light Green (Very Good)
      case 'C':
        return '#FFC107'; // Orange (Good)
      case 'D':
        return '#FF9800'; // Dark Orange (Fair)
      case 'F':
        return '#F44336'; // Red (Fail)
      default:
        return '#9E9E9E'; // Gray
    }
  }
}

/// String Utilities
class StringHelper {
  /// Check if string is email
  static bool isEmail(String string) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(string);
  }

  /// Capitalize first letter
  static String capitalize(String string) {
    if (string.isEmpty) return string;
    return string[0].toUpperCase() + string.substring(1).toLowerCase();
  }

  /// Get initials from name
  static String getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  /// Truncate string with ellipsis
  static String truncate(String string, int length) {
    if (string.length <= length) return string;
    return '${string.substring(0, length)}...';
  }
}
