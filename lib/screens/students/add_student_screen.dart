import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/student_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/student_provider.dart';
import '../../config/constants.dart';

class AddStudentScreen extends StatefulWidget {
  final dynamic argument;

  const AddStudentScreen({super.key, this.argument});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  late TextEditingController _nameController;
  late TextEditingController _rollNumberController;
  late TextEditingController _phoneController;
  String _selectedClassId = '';
  String _selectedFeesStatus = AppConstants.feesPending;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  StudentModel? _studentToEdit;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _rollNumberController = TextEditingController();
    _phoneController = TextEditingController();

    // Check if we're editing or the argument is a classId
    if (widget.argument is StudentModel) {
      _studentToEdit = widget.argument as StudentModel;
      _nameController.text = _studentToEdit!.name;
      _rollNumberController.text = _studentToEdit!.rollNumber ?? '';
      _phoneController.text = _studentToEdit!.phone ?? '';
      _selectedClassId = _studentToEdit!.classId;
      _selectedFeesStatus = _studentToEdit!.feesStatus;
    } else if (widget.argument is String) {
      _selectedClassId = widget.argument as String;
    }

    Future.microtask(() {
      if (!mounted) return;
      context.read<ClassProvider>().fetchClasses(
        context.read<AuthProvider>().user!.uid,
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollNumberController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _studentToEdit != null ? 'Edit Student' : 'Add Student',
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Consumer<ClassProvider>(
            builder: (context, classProvider, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _studentToEdit != null
                        ? 'Update Student Details'
                        : 'Add New Student',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter student information',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Student Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Student Name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter student name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Roll Number Field
                  TextFormField(
                    controller: _rollNumberController,
                    decoration: InputDecoration(
                      labelText: 'Roll Number',
                      prefixIcon: const Icon(Icons.numbers),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Phone Field
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Parent Phone (Optional)',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  // Class Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedClassId.isEmpty ? null : _selectedClassId,
                    items: classProvider.classes
                        .map((c) => DropdownMenuItem(
                      value: c.classId,
                      child: Text(c.className),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedClassId = value ?? '');
                    },
                    decoration: InputDecoration(
                      labelText: 'Select Class',
                      prefixIcon: const Icon(Icons.class_),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a class';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Admission Date
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Admission Date',
                      prefixIcon: const Icon(Icons.calendar_today),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _selectDate,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    controller: TextEditingController(
                      text: _selectedDate.toString().split(' ')[0],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Fees Status
                  DropdownButtonFormField<String>(
                    initialValue: _selectedFeesStatus,
                    items: [
                      DropdownMenuItem(
                        value: AppConstants.feesPaid,
                        child: const Text(AppConstants.feesPaid),
                      ),
                      DropdownMenuItem(
                        value: AppConstants.feesPending,
                        child: const Text(AppConstants.feesPending),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedFeesStatus = value ?? '');
                    },
                    decoration: InputDecoration(
                      labelText: 'Fees Status',
                      prefixIcon: const Icon(Icons.payments),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveStudent,
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : Text(
                        _studentToEdit != null
                            ? 'Update Student'
                            : 'Add Student',
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveStudent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedClassId.isEmpty && _studentToEdit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a class'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final studentProvider = context.read<StudentProvider>();

      bool success;
      if (_studentToEdit != null) {
        success = await studentProvider.updateStudentFields(
          studentId: _studentToEdit!.id,
          data: {
            'name': _nameController.text.trim(),
            'rollNumber': _rollNumberController.text.trim(),
            'phone': _phoneController.text.trim(),
            'feesStatus': _selectedFeesStatus,
          },
        );
      } else {
        // Generate email from name if not provided
        final name = _nameController.text.trim().toLowerCase().replaceAll(' ', '');
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final email = '$name$timestamp@edutrack.local';
        
        success = await studentProvider.addStudent(
          classId: _selectedClassId,
          name: _nameController.text.trim(),
          email: email,
          phone: _phoneController.text.trim(),
          rollNumber: _rollNumberController.text.trim(),
          admissionDate: _selectedDate,
          feesStatus: _selectedFeesStatus,
        );
      }

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _studentToEdit != null
                  ? '✅ ${AppConstants.successStudentUpdated}'
                  : '✅ ${AppConstants.successStudentAdded}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        // Small delay to ensure Firestore write completes
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Failed to save student. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
