# Form Validation Quick Reference Card

## Essential Setup

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Process form
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _controller,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: _submit,
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
```

---

## Common Regex Patterns

| Type | Regex | Use Case |
|------|-------|----------|
| **Email** | `r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'` | Standard email |
| **Phone (US)** | `r'^\d{10}$'` | 10-digit phone |
| **Phone (Intl)** | `r'^\+?[1-9]\d{1,14}$'` | International format |
| **URL** | `r'^(https?:\/\/)?(www\.)?[a-zA-Z0-9-]+\.[a-zA-Z]{2,}(\/.*)?$'` | Web address |
| **ZIP** | `r'^\d{5}$'` | 5-digit ZIP |
| **ZIP+4** | `r'^\d{5}(-\d{4})?$'` | Extended ZIP |
| **Username** | `r'^[a-zA-Z0-9_]{3,20}$'` | Alphanumeric + underscore |
| **HEX Color** | `r'^#?[0-9A-Fa-f]{6}$'` | Hex color code |
| **Date (ISO)** | `r'^\d{4}-\d{2}-\d{2}$'` | YYYY-MM-DD |
| **Time** | `r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$'` | 24-hour time |

---

## Validator Templates

### Email
```dart
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  if (!regex.hasMatch(value)) {
    return 'Enter a valid email';
  }
  return null;
}
```

### Password
```dart
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 8) {
    return 'Must be at least 8 characters';
  }
  if (!value.contains(RegExp(r'[A-Z]'))) {
    return 'Must contain uppercase letter';
  }
  if (!value.contains(RegExp(r'[a-z]'))) {
    return 'Must contain lowercase letter';
  }
  if (!value.contains(RegExp(r'[0-9]'))) {
    return 'Must contain number';
  }
  if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
    return 'Must contain special character';
  }
  return null;
}
```

### Phone
```dart
String? validatePhone(String? value) {
  if (value == null || value.isEmpty) {
    return 'Phone is required';
  }
  final digits = value.replaceAll(RegExp(r'[^\d]'), '');
  if (digits.length != 10) {
    return 'Must be 10 digits';
  }
  return null;
}
```

### Age
```dart
String? validateAge(String? value) {
  if (value == null || value.isEmpty) {
    return 'Age is required';
  }
  final age = int.tryParse(value);
  if (age == null) {
    return 'Enter a valid number';
  }
  if (age < 13) {
    return 'Must be at least 13';
  }
  if (age > 120) {
    return 'Enter a valid age';
  }
  return null;
}
```

### Number Range
```dart
String? validateRange(String? value, double min, double max) {
  if (value == null || value.isEmpty) {
    return 'Required';
  }
  final num = double.tryParse(value);
  if (num == null) {
    return 'Enter a valid number';
  }
  if (num < min || num > max) {
    return 'Must be between $min and $max';
  }
  return null;
}
```

### Credit Card (Luhn)
```dart
String? validateCreditCard(String? value) {
  if (value == null || value.isEmpty) {
    return 'Card number required';
  }
  final digits = value.replaceAll(' ', '');
  if (digits.length != 16) {
    return 'Must be 16 digits';
  }
  
  int sum = 0;
  bool alt = false;
  for (int i = digits.length - 1; i >= 0; i--) {
    int digit = int.parse(digits[i]);
    if (alt) {
      digit *= 2;
      if (digit > 9) digit -= 9;
    }
    sum += digit;
    alt = !alt;
  }
  
  if (sum % 10 != 0) {
    return 'Invalid card number';
  }
  return null;
}
```

---

## Input Formatters

### Digits Only
```dart
TextFormField(
  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
)
```

### Max Length
```dart
TextFormField(
  inputFormatters: [LengthLimitingTextInputFormatter(10)],
)
```

### Phone Formatting
```dart
TextFormField(
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10),
  ],
)
```

### Credit Card Formatting (xxxx xxxx xxxx xxxx)
```dart
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i + 1 != text.length) {
        buffer.write(' ');
      }
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

TextFormField(
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(16),
    CardNumberFormatter(),
  ],
)
```

---

## AutovalidateMode Pattern

```dart
AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

void _submit() {
  setState(() {
    _autovalidateMode = AutovalidateMode.onUserInteraction;
  });
  
  if (_formKey.currentState!.validate()) {
    // Process
  }
}

@override
Widget build(BuildContext context) {
  return Form(
    key: _formKey,
    autovalidateMode: _autovalidateMode,
    child: /* ... */,
  );
}
```

---

## Cross-Field Validation

```dart
final _passwordController = TextEditingController();

// Password field
TextFormField(
  controller: _passwordController,
  validator: validatePassword,
  onChanged: (value) {
    // Revalidate confirm field when password changes
    _formKey.currentState?.validate();
  },
)

// Confirm password field
TextFormField(
  validator: (value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  },
)
```

---

## Keyboard Types

```dart
TextFormField(
  keyboardType: TextInputType.text,        // Default
  keyboardType: TextInputType.emailAddress, // Email
  keyboardType: TextInputType.phone,        // Phone
  keyboardType: TextInputType.number,       // Number
  keyboardType: TextInputType.datetime,     // Date/Time
  keyboardType: TextInputType.url,          // URL
  keyboardType: TextInputType.multiline,    // Multi-line
)
```

---

## Text Capitalization

```dart
TextFormField(
  textCapitalization: TextCapitalization.none,       // Default
  textCapitalization: TextCapitalization.words,      // Title Case
  textCapitalization: TextCapitalization.sentences,  // Sentence case
  textCapitalization: TextCapitalization.characters, // UPPERCASE
)
```

---

## Common Decorations

```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'your.email@example.com',
    helperText: 'We will never share your email',
    prefixIcon: Icon(Icons.email),
    suffixIcon: Icon(Icons.check_circle, color: Colors.green),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    filled: true,
    fillColor: Colors.grey.shade50,
    errorMaxLines: 2,
  ),
)
```

---

## Submit Button States

```dart
bool _isSubmitting = false;

SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton(
    onPressed: _isSubmitting ? null : _submit,
    child: _isSubmitting
        ? CircularProgressIndicator(color: Colors.white)
        : Text('Submit'),
  ),
)
```

---

## Error Handling

```dart
void _submit() {
  if (!_formKey.currentState!.validate()) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please fix all errors'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }
  
  // Process form
}
```

---

## Conditional Validation

```dart
bool _isRequired = false;

TextFormField(
  validator: (value) {
    if (_isRequired && (value == null || value.isEmpty)) {
      return 'This field is required';
    }
    return null;
  },
)
```

---

## Dropdown Validation

```dart
String? _selectedValue;

DropdownButtonFormField<String>(
  value: _selectedValue,
  items: ['Option 1', 'Option 2'].map((option) {
    return DropdownMenuItem(
      value: option,
      child: Text(option),
    );
  }).toList(),
  onChanged: (value) {
    setState(() => _selectedValue = value);
  },
  validator: (value) {
    if (value == null) {
      return 'Please select an option';
    }
    return null;
  },
)
```

---

## Checkbox Validation

```dart
bool _agreed = false;

FormField<bool>(
  initialValue: _agreed,
  validator: (value) {
    if (!(value ?? false)) {
      return 'You must agree to continue';
    }
    return null;
  },
  builder: (state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: Text('I agree to terms'),
          value: _agreed,
          onChanged: (value) {
            setState(() => _agreed = value ?? false);
            state.didChange(value);
          },
        ),
        if (state.hasError)
          Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              state.errorText!,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  },
)
```

---

## Reset Form

```dart
void _reset() {
  _formKey.currentState?.reset();
  _controller.clear();
  setState(() {
    _autovalidateMode = AutovalidateMode.disabled;
  });
}
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Validators not working | Ensure using `TextFormField` not `TextField` |
| Validation not triggered | Call `_formKey.currentState!.validate()` |
| Form submits when invalid | Check `validate()` returns `true` |
| Memory leak | Dispose all controllers in `dispose()` |
| Regex not matching | Test pattern at regex101.com |
| Cross-validation not working | Use controllers or state variables |

---

**📚 For complete examples, see:**
- `simple_form_validation_example.dart`
- `complex_form_validation_demo.dart`
- `FORM_VALIDATION_GUIDE.md`
