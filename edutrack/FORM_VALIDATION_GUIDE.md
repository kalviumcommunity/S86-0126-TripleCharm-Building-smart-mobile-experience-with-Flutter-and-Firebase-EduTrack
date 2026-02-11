# Flutter Form Validation Guide

## Table of Contents
- [Overview](#overview)
- [Basic Form Structure](#basic-form-structure)
- [Validation Types](#validation-types)
- [Best Practices](#best-practices)
- [Common Patterns](#common-patterns)
- [Troubleshooting](#troubleshooting)

---

## Overview

Form validation in Flutter ensures data quality, security, and a great user experience. This guide covers everything from basic validation to advanced patterns.

### Why Form Validation Is Important
- ✅ Prevents invalid or incomplete data submission
- ✅ Provides immediate user feedback
- ✅ Protects backend systems from malformed input
- ✅ Enforces required fields and format constraints
- ✅ Critical for authentication, profiles, and payments

---

## Basic Form Structure

### Required Components

1. **Form Widget**: Wraps all form fields
2. **GlobalKey<FormState>**: Manages form state
3. **TextFormField**: Input fields with validation
4. **Validators**: Functions that check input validity
5. **Submit Handler**: Processes validated data

### Minimal Example

```dart
class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Name is required';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Form is valid, proceed
                print('Name: ${_nameController.text}');
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
```

---

## Validation Types

### 1. Required Field Validation

```dart
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'This field is required';
  }
  return null;
}
```

### 2. Email Validation

```dart
validator: (value) {
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  if (value == null || !emailRegex.hasMatch(value)) {
    return 'Enter a valid email address';
  }
  return null;
}
```

**Better regex for production:**
```dart
final emailRegex = RegExp(
  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
);
```

### 3. Password Validation

#### Basic (minimum length):
```dart
validator: (value) {
  if (value == null || value.length < 8) {
    return 'Password must be at least 8 characters';
  }
  return null;
}
```

#### Strong Password (with requirements):
```dart
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 8) {
    return 'Password must be at least 8 characters';
  }
  if (!value.contains(RegExp(r'[A-Z]'))) {
    return 'Must contain at least one uppercase letter';
  }
  if (!value.contains(RegExp(r'[a-z]'))) {
    return 'Must contain at least one lowercase letter';
  }
  if (!value.contains(RegExp(r'[0-9]'))) {
    return 'Must contain at least one number';
  }
  if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
    return 'Must contain at least one special character';
  }
  return null;
}
```

### 4. Phone Number Validation

```dart
validator: (value) {
  final phoneRegex = RegExp(r'^[0-9]{10}$');
  if (value == null || !phoneRegex.hasMatch(value)) {
    return 'Enter a valid 10-digit phone number';
  }
  return null;
}
```

**With input formatter:**
```dart
TextFormField(
  keyboardType: TextInputType.phone,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10),
  ],
  validator: validatePhone,
)
```

### 5. Cross-Field Validation (Password Confirmation)

```dart
class _MyFormState extends State<MyForm> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ...

  TextFormField(
    controller: _passwordController,
    decoration: InputDecoration(labelText: 'Password'),
    obscureText: true,
    validator: (value) {
      if (value == null || value.length < 8) {
        return 'Password must be at least 8 characters';
      }
      return null;
    },
    onChanged: (value) {
      // Re-validate confirm password when password changes
      if (_formKey.currentState != null) {
        _formKey.currentState!.validate();
      }
    },
  ),
  
  TextFormField(
    controller: _confirmPasswordController,
    decoration: InputDecoration(labelText: 'Confirm Password'),
    obscureText: true,
    validator: (value) {
      if (value != _passwordController.text) {
        return 'Passwords do not match';
      }
      return null;
    },
  ),
}
```

### 6. Age Validation

```dart
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Age is required';
  }
  
  final age = int.tryParse(value);
  
  if (age == null) {
    return 'Enter a valid number';
  }
  
  if (age < 13) {
    return 'You must be at least 13 years old';
  }
  
  if (age > 120) {
    return 'Please enter a valid age';
  }
  
  return null;
}
```

### 7. URL Validation

```dart
validator: (value) {
  if (value == null || value.isEmpty) {
    return null; // Optional field
  }
  
  final urlRegex = RegExp(
    r'^(https?:\/\/)?(www\.)?[a-zA-Z0-9-]+\.[a-zA-Z]{2,}(\/.*)?$',
  );
  
  if (!urlRegex.hasMatch(value)) {
    return 'Enter a valid website URL';
  }
  
  return null;
}
```

### 8. Credit Card Validation (Luhn Algorithm)

```dart
validator: (value) {
  if (value == null || value.isEmpty) {
    return null; // Optional
  }
  
  final digitsOnly = value.replaceAll(' ', '');
  
  if (digitsOnly.length != 16) {
    return 'Card number must be 16 digits';
  }
  
  // Luhn algorithm
  int sum = 0;
  bool alternate = false;
  
  for (int i = digitsOnly.length - 1; i >= 0; i--) {
    int digit = int.parse(digitsOnly[i]);
    
    if (alternate) {
      digit *= 2;
      if (digit > 9) digit -= 9;
    }
    
    sum += digit;
    alternate = !alternate;
  }
  
  if (sum % 10 != 0) {
    return 'Invalid card number';
  }
  
  return null;
}
```

---

## Best Practices

### 1. Use AutovalidateMode

```dart
Form(
  key: _formKey,
  autovalidateMode: _autovalidateMode,
  // ...
)
```

**Pattern:**
```dart
AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

void _submitForm() {
  setState(() {
    _autovalidateMode = AutovalidateMode.onUserInteraction;
  });
  
  if (_formKey.currentState!.validate()) {
    // Submit
  }
}
```

This ensures validation only shows after the first submit attempt, improving UX.

### 2. Always Dispose Controllers

```dart
@override
void dispose() {
  _nameController.dispose();
  _emailController.dispose();
  _passwordController.dispose();
  super.dispose();
}
```

### 3. Use Input Formatters

```dart
import 'package:flutter/services.dart';

TextFormField(
  keyboardType: TextInputType.phone,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10),
  ],
)
```

### 4. Provide Visual Feedback

```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Email',
    prefixIcon: Icon(Icons.email_outlined),
    filled: true,
    fillColor: Colors.grey.shade50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
)
```

### 5. Show Loading State During Submission

```dart
bool _isSubmitting = false;

ElevatedButton(
  onPressed: _isSubmitting ? null : _submitForm,
  child: _isSubmitting
      ? CircularProgressIndicator()
      : Text('Submit'),
)
```

### 6. Use Reusable Validator Functions

```dart
class FormValidators {
  static String? email(String? value) {
    // validation logic
  }
  
  static String? password(String? value) {
    // validation logic
  }
}

// Usage:
TextFormField(
  validator: FormValidators.email,
)
```

### 7. Handle Error Messages Gracefully

```dart
void _showErrorSnackBar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.white),
          SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
```

---

## Common Patterns

### Multi-Step Forms

```dart
class MultiStepForm extends StatefulWidget {
  @override
  _MultiStepFormState createState() => _MultiStepFormState();
}

class _MultiStepFormState extends State<MultiStepForm> {
  int _currentStep = 0;
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  void _nextStep() {
    if (_formKeys[_currentStep].currentState!.validate()) {
      setState(() {
        if (_currentStep < 2) {
          _currentStep++;
        } else {
          _submitForm();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stepper(
      currentStep: _currentStep,
      onStepContinue: _nextStep,
      onStepCancel: () {
        if (_currentStep > 0) {
          setState(() => _currentStep--);
        }
      },
      steps: [
        Step(
          title: Text('Personal Info'),
          content: Form(
            key: _formKeys[0],
            child: Column(/* fields */),
          ),
          isActive: _currentStep >= 0,
        ),
        Step(
          title: Text('Account Details'),
          content: Form(
            key: _formKeys[1],
            child: Column(/* fields */),
          ),
          isActive: _currentStep >= 1,
        ),
        Step(
          title: Text('Confirmation'),
          content: Form(
            key: _formKeys[2],
            child: Column(/* fields */),
          ),
          isActive: _currentStep >= 2,
        ),
      ],
    );
  }
}
```

### Conditional Field Validation

```dart
bool _showOptionalFields = false;

// ...

if (_showOptionalFields)
  TextFormField(
    validator: (value) {
      // Only validate when visible
      if (_showOptionalFields && value == null) {
        return 'This field is required';
      }
      return null;
    },
  ),
```

### Composite Validators

```dart
String? Function(String?) compose(
  List<String? Function(String?)> validators,
) {
  return (String? value) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  };
}

// Usage:
TextFormField(
  validator: compose([
    FormValidators.required,
    FormValidators.email,
    (value) => value!.contains('banned') ? 'Email not allowed' : null,
  ]),
)
```

---

## Troubleshooting

### Common Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| Validators not triggered | Missing `Form` widget or `GlobalKey` | Wrap fields in `Form` with proper key |
| Error messages not showing | Using `TextField` instead of `TextFormField` | Switch to `TextFormField` |
| Submit works with invalid fields | Not calling `validate()` | Ensure `_formKey.currentState!.validate()` runs |
| Regex not matching correctly | Wrong pattern | Test regex separately with online tools |
| Multi-field validation failing | Using local variable | Use state variables or controllers |
| Auto-validation too aggressive | `autovalidateMode` set to `always` | Use `disabled` initially, switch to `onUserInteraction` after first submit |
| Memory leaks | Controllers not disposed | Always dispose controllers in `dispose()` |
| Form revalidates incorrectly | Not managing state properly | Use `setState()` when changing validation state |

### Debugging Tips

1. **Print validation errors:**
```dart
validator: (value) {
  final error = myValidation(value);
  if (error != null) {
    print('Validation error: $error');
  }
  return error;
}
```

2. **Check form state:**
```dart
print('Form valid: ${_formKey.currentState?.validate()}');
```

3. **Verify controller values:**
```dart
print('Email value: ${_emailController.text}');
```

---

## Testing Forms

### Unit Testing Validators

```dart
void main() {
  test('Email validator accepts valid email', () {
    expect(FormValidators.email('test@example.com'), null);
  });

  test('Email validator rejects invalid email', () {
    expect(
      FormValidators.email('invalid-email'),
      'Enter a valid email address',
    );
  });
}
```

### Widget Testing

```dart
testWidgets('Form shows error on invalid submission', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Tap submit without entering data
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();
  
  // Verify error message appears
  expect(find.text('Name is required'), findsOneWidget);
});
```

---

## Additional Resources

- **Flutter Documentation**: [Form validation](https://docs.flutter.dev/cookbook/forms/validation)
- **RegEx Testing**: [regex101.com](https://regex101.com/)
- **Input Formatters**: [Flutter API](https://api.flutter.dev/flutter/services/TextInputFormatter-class.html)

---

## Quick Reference

### Common Regex Patterns

```dart
// Email
r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'

// Phone (US 10-digit)
r'^[0-9]{10}$'

// URL
r'^(https?:\/\/)?(www\.)?[a-zA-Z0-9-]+\.[a-zA-Z]{2,}(\/.*)?$'

// ZIP Code
r'^\d{5}$'

// Username (alphanumeric + underscore)
r'^[a-zA-Z0-9_]+$'

// Credit Card (16 digits)
r'^\d{16}$'

// CVV (3-4 digits)
r'^\d{3,4}$'
```

### Essential Imports

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
```

---

**Need Help?** Check out the `ComplexFormValidationDemo` screen in this app for a comprehensive working example!
