import 'package:flutter/material.dart';

// === Color Scheme Constants ===
const Color kPrimaryColor = Color(0xFF6C63FF);
const Color kSecondaryColor = Color(0xFF00D4FF);
const Color kSuccessColor = Color(0xFF00C853);
const Color kErrorColor = Color(0xFFD32F2F);
const Color kTextPrimaryColor = Color(0xFF2C2C2C);
const Color kTextSecondaryColor = Color(0xFF7A7A7A);
const Color kBackgroundColor = Colors.white;
const Color kInputBorderColor = Color(0xFFE0E0E0);

class UserInputForm extends StatefulWidget {
  const UserInputForm({super.key});

  @override
  State<UserInputForm> createState() => _UserInputFormState();
}

class _UserInputFormState extends State<UserInputForm> {
  // Form key for managing form state
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers for capturing user input
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  // State variables for UI feedback
  bool _isSubmitting = false;
  String? _submittedName;
  String? _submittedEmail;
  bool _formSubmitted = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[UserInputForm] initState() - Form initialized');
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
    debugPrint('[UserInputForm] dispose() - Controllers cleaned up');
  }

  /// Validates email using regex pattern
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validates phone number (10 digits)
  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\d{10}$');
    return phoneRegex.hasMatch(phone);
  }

  /// Handle form submission
  Future<void> _submitForm() async {
    debugPrint('[UserInputForm] _submitForm() - Form submission initiated');

    if (_formKey.currentState!.validate()) {
      debugPrint('[UserInputForm] Form validation successful');

      setState(() {
        _isSubmitting = true;
      });

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 1500));

      setState(() {
        _submittedName = _nameController.text;
        _submittedEmail = _emailController.text;
        _isSubmitting = false;
        _formSubmitted = true;
      });

      debugPrint('[UserInputForm] Form submitted: $_submittedName ($_submittedEmail)');

      // Show success SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: kSuccessColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Form submitted successfully! Thanks, $_submittedName!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: kSuccessColor,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } else {
      debugPrint('[UserInputForm] Form validation failed - showing errors');
    }
  }

  /// Reset form to initial state
  void _resetForm() {
    debugPrint('[UserInputForm] _resetForm() - Clearing all fields');
    _formKey.currentState!.reset();
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _messageController.clear();
    setState(() {
      _formSubmitted = false;
      _submittedName = null;
      _submittedEmail = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Input Form'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
      ),
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(),
              const SizedBox(height: 32),

              // Success Message (shown after submission)
              if (_formSubmitted)
                _buildSuccessCard()
              else
                // Form Section
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name Field
                      _buildFormField(
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        controller: _nameController,
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          if (value.length < 3) {
                            return 'Name must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Email Field
                      _buildFormField(
                        label: 'Email Address',
                        hint: 'example@edutrack.in',
                        controller: _emailController,
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!_isValidEmail(value)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Phone Field (optional)
                      _buildFormField(
                        label: 'Phone Number',
                        hint: '10-digit mobile number',
                        controller: _phoneController,
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        isOptional: true,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!_isValidPhone(value)) {
                              return 'Enter a valid 10-digit phone number';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Message Field
                      _buildFormField(
                        label: 'Message',
                        hint: 'Share your feedback or questions...',
                        controller: _messageController,
                        icon: Icons.message,
                        maxLines: 4,
                        isOptional: true,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (value.length < 10) {
                              return 'Message should be at least 10 characters';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Submit and Reset Buttons
                      _buildButtonRow(),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build header section with title and description
  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User Information Form',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: kPrimaryColor,
            fontWeight: FontWeight.w800,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Please fill in your details below. Fields marked with * are required.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: kTextSecondaryColor,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  /// Build form input field with validation
  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isOptional = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with required indicator
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: const TextStyle(
                  color: kTextPrimaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!isOptional)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: kErrorColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (isOptional)
                TextSpan(
                  text: ' (Optional)',
                  style: TextStyle(
                    color: kTextSecondaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // TextFormField
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          minLines: maxLines == 1 ? 1 : 3,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: kTextSecondaryColor.withOpacity(0.6),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: kPrimaryColor,
              size: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: kInputBorderColor,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: kInputBorderColor,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: kPrimaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: kErrorColor,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: kErrorColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: validator,
          onChanged: (value) {
            // Trigger validation on change
            _formKey.currentState?.validate();
          },
        ),
      ],
    );
  }

  /// Build success card displayed after form submission
  Widget _buildSuccessCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kSuccessColor.withOpacity(0.1),
        border: Border.all(
          color: kSuccessColor.withOpacity(0.3),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kSuccessColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: kSuccessColor,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Form Submitted Successfully!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: kSuccessColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Thank you for your submission, $_submittedName!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: kTextSecondaryColor,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'We will contact you at $_submittedEmail shortly.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: kTextSecondaryColor,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Submitted data summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: kSuccessColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Submitted Information:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: kTextPrimaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDataRow('Name:', _submittedName ?? ''),
                const SizedBox(height: 8),
                _buildDataRow('Email:', _submittedEmail ?? ''),
                if (_phoneController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildDataRow('Phone:', _phoneController.text),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Reset Button
          ElevatedButton(
            onPressed: _resetForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Submit Another Form',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build data row for displaying submitted information
  Widget _buildDataRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: kTextPrimaryColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: kTextSecondaryColor,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Build submit and reset button row
  Widget _buildButtonRow() {
    return Row(
      children: [
        // Submit Button
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: kPrimaryColor.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: _isSubmitting
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Submitting...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 16),

        // Reset Button
        Expanded(
          child: OutlinedButton(
            onPressed: _resetForm,
            style: OutlinedButton.styleFrom(
              foregroundColor: kPrimaryColor,
              side: const BorderSide(
                color: kPrimaryColor,
                width: 1.5,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Reset',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
