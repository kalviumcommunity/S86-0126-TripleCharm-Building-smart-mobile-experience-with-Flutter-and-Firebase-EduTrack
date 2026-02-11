/// Form Validators Utility
/// 
/// A collection of reusable form validation functions
/// that can be used across the app for consistent validation logic.
/// 
/// Usage:
/// ```dart
/// TextFormField(
///   validator: FormValidators.email,
/// )
/// ```

class FormValidators {
  // Private constructor to prevent instantiation
  FormValidators._();

  // ============================================================
  // BASIC VALIDATORS
  // ============================================================

  /// Validates that a field is not empty
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates minimum length
  static String? Function(String?) minLength(int min, [String? fieldName]) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return null; // Let required validator handle empty case
      }
      if (value.length < min) {
        return '${fieldName ?? 'This field'} must be at least $min characters';
      }
      return null;
    };
  }

  /// Validates maximum length
  static String? Function(String?) maxLength(int max, [String? fieldName]) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return null;
      }
      if (value.length > max) {
        return '${fieldName ?? 'This field'} must be at most $max characters';
      }
      return null;
    };
  }

  /// Validates exact length
  static String? Function(String?) exactLength(int length, [String? fieldName]) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return null;
      }
      if (value.length != length) {
        return '${fieldName ?? 'This field'} must be exactly $length characters';
      }
      return null;
    };
  }

  // ============================================================
  // EMAIL VALIDATORS
  // ============================================================

  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Comprehensive email regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  /// Optional email validator (only validates if not empty)
  static String? optionalEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    return email(value);
  }

  /// Validates email with custom domain
  static String? Function(String?) emailWithDomain(String domain) {
    return (String? value) {
      final emailError = email(value);
      if (emailError != null) {
        return emailError;
      }

      if (!value!.toLowerCase().endsWith('@$domain')) {
        return 'Email must be from $domain domain';
      }

      return null;
    };
  }

  // ============================================================
  // PASSWORD VALIDATORS
  // ============================================================

  /// Validates basic password (min 8 characters)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  /// Validates strong password with multiple requirements
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  /// Validates password confirmation
  static String? Function(String?) confirmPassword(String password) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Please confirm your password';
      }

      if (value != password) {
        return 'Passwords do not match';
      }

      return null;
    };
  }

  // ============================================================
  // PHONE NUMBER VALIDATORS
  // ============================================================

  /// Validates 10-digit phone number
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length != 10) {
      return 'Phone number must be 10 digits';
    }

    return null;
  }

  /// Optional phone validator
  static String? optionalPhone(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return phone(value);
  }

  /// Validates phone with country code (e.g., +1234567890)
  static String? phoneWithCountryCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return 'Enter a valid phone number with country code';
    }

    return null;
  }

  // ============================================================
  // NUMBER VALIDATORS
  // ============================================================

  /// Validates that input is a number
  static String? number(String? value, [String fieldName = 'This field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (double.tryParse(value) == null) {
      return 'Enter a valid number';
    }

    return null;
  }

  /// Validates integer
  static String? integer(String? value, [String fieldName = 'This field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (int.tryParse(value) == null) {
      return 'Enter a valid integer';
    }

    return null;
  }

  /// Validates number within range
  static String? Function(String?) numberInRange(
    double min,
    double max, [
    String? fieldName,
  ]) {
    return (String? value) {
      final numError = number(value, fieldName ?? 'This field');
      if (numError != null) {
        return numError;
      }

      final numValue = double.parse(value!);

      if (numValue < min || numValue > max) {
        return '${fieldName ?? 'Value'} must be between $min and $max';
      }

      return null;
    };
  }

  /// Validates positive number
  static String? positiveNumber(String? value, [String? fieldName]) {
    final numError = number(value, fieldName ?? 'This field');
    if (numError != null) {
      return numError;
    }

    if (double.parse(value!) <= 0) {
      return '${fieldName ?? 'This field'} must be positive';
    }

    return null;
  }

  // ============================================================
  // AGE VALIDATORS
  // ============================================================

  /// Validates age (13-120)
  static String? age(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }

    final ageValue = int.tryParse(value);

    if (ageValue == null) {
      return 'Enter a valid age';
    }

    if (ageValue < 13) {
      return 'You must be at least 13 years old';
    }

    if (ageValue > 120) {
      return 'Please enter a valid age';
    }

    return null;
  }

  /// Validates age with custom min/max
  static String? Function(String?) ageRange(int min, int max) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Age is required';
      }

      final ageValue = int.tryParse(value);

      if (ageValue == null) {
        return 'Enter a valid age';
      }

      if (ageValue < min || ageValue > max) {
        return 'Age must be between $min and $max';
      }

      return null;
    };
  }

  // ============================================================
  // URL VALIDATORS
  // ============================================================

  /// Validates URL format
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }

    final urlRegex = RegExp(
      r'^(https?:\/\/)?(www\.)?[a-zA-Z0-9-]+\.[a-zA-Z]{2,}(\/.*)?$',
    );

    if (!urlRegex.hasMatch(value.trim())) {
      return 'Enter a valid URL';
    }

    return null;
  }

  /// Optional URL validator
  static String? optionalUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return url(value);
  }

  // ============================================================
  // ADDRESS VALIDATORS
  // ============================================================

  /// Validates ZIP code (5 digits)
  static String? zipCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'ZIP code is required';
    }

    if (!RegExp(r'^\d{5}$').hasMatch(value)) {
      return 'ZIP code must be 5 digits';
    }

    return null;
  }

  /// Validates ZIP+4 code (e.g., 12345-6789)
  static String? zipCodeExtended(String? value) {
    if (value == null || value.isEmpty) {
      return 'ZIP code is required';
    }

    if (!RegExp(r'^\d{5}(-\d{4})?$').hasMatch(value)) {
      return 'Enter a valid ZIP code (12345 or 12345-6789)';
    }

    return null;
  }

  // ============================================================
  // CREDIT CARD VALIDATORS
  // ============================================================

  /// Validates credit card number using Luhn algorithm
  static String? creditCard(String? value) {
    if (value == null || value.isEmpty) {
      return 'Card number is required';
    }

    final digitsOnly = value.replaceAll(' ', '');

    if (digitsOnly.length < 13 || digitsOnly.length > 19) {
      return 'Enter a valid card number';
    }

    // Luhn algorithm
    int sum = 0;
    bool alternate = false;

    for (int i = digitsOnly.length - 1; i >= 0; i--) {
      int digit = int.parse(digitsOnly[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    if (sum % 10 != 0) {
      return 'Invalid card number';
    }

    return null;
  }

  /// Optional credit card validator
  static String? optionalCreditCard(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return creditCard(value);
  }

  /// Validates CVV (3-4 digits)
  static String? cvv(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV is required';
    }

    if (!RegExp(r'^\d{3,4}$').hasMatch(value)) {
      return 'CVV must be 3 or 4 digits';
    }

    return null;
  }

  /// Optional CVV validator
  static String? optionalCvv(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return cvv(value);
  }

  // ============================================================
  // USERNAME VALIDATORS
  // ============================================================

  /// Validates username (alphanumeric and underscore, 3-20 chars)
  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (value.length > 20) {
      return 'Username must be at most 20 characters';
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null;
  }

  // ============================================================
  // DATE VALIDATORS
  // ============================================================

  /// Validates date format (YYYY-MM-DD)
  static String? date(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }

    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Enter a valid date (YYYY-MM-DD)';
    }
  }

  /// Validates date is in the past
  static String? pastDate(String? value) {
    final dateError = date(value);
    if (dateError != null) {
      return dateError;
    }

    final parsedDate = DateTime.parse(value!);
    if (parsedDate.isAfter(DateTime.now())) {
      return 'Date must be in the past';
    }

    return null;
  }

  /// Validates date is in the future
  static String? futureDate(String? value) {
    final dateError = date(value);
    if (dateError != null) {
      return dateError;
    }

    final parsedDate = DateTime.parse(value!);
    if (parsedDate.isBefore(DateTime.now())) {
      return 'Date must be in the future';
    }

    return null;
  }

  // ============================================================
  // COMPOSITE VALIDATORS
  // ============================================================

  /// Combines multiple validators
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) {
          return error;
        }
      }
      return null;
    };
  }

  /// Creates a conditional validator
  static String? Function(String?) when(
    bool condition,
    String? Function(String?) validator,
  ) {
    return (String? value) {
      if (condition) {
        return validator(value);
      }
      return null;
    };
  }
}
