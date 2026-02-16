import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/class_model.dart';
import '../../providers/class_provider.dart';
import '../../providers/auth_provider.dart';

/// Add/Edit Class Screen
class AddClassScreen extends StatefulWidget {
  final ClassModel? classData;

  const AddClassScreen({super.key, this.classData});

  @override
  State<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.classData?.name ?? '');
    _descriptionController = TextEditingController(text: widget.classData?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final classProvider = context.read<ClassProvider>();
    final authProvider = context.read<AuthProvider>();
    final teacherId = authProvider.user?.id ?? '';
    bool success;

    if (kDebugMode) print('\ud83d\udccb [CLASS] ${widget.classData == null ? 'Creating' : 'Updating'} class: ${_nameController.text.trim()}');
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Saving class...'),
              ],
            ),
          ),
        ),
      ),
    );
    if (widget.classData == null) {
      // Create new class
      success = await classProvider.createClass(
        name: _nameController.text.trim(),
        teacherId: teacherId,
        description: _descriptionController.text.trim(),
      );
      if (kDebugMode) print('\ud83d\udccb [CLASS] Class creation ${success ? 'successful' : 'failed'}');
    } else {
      // Update existing class
      success = await classProvider.updateClass(
        classId: widget.classData!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
      );
      if (kDebugMode) print('\ud83d\udccb [CLASS] Class update ${success ? 'successful' : 'failed'}');
    }

    if (!mounted) return;
    Navigator.pop(context);

    if (success) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.classData == null
                ? '✅ Class created successfully!'
                : '✅ Class updated successfully!',
          ),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 2),
        ),
      );
      // Navigate back automatically - stream will update the previous screen
      if (kDebugMode) print('\ud83d\udccb [CLASS] Navigating back to class list');
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      // Show error message
      if (kDebugMode) print('\ud83d\udccb [CLASS] Error: ${classProvider.error}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ ${classProvider.error ?? 'Failed to save class'}',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classData == null ? 'Create Class' : 'Edit Class'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Class Name',
                  hintText: 'e.g., Class 10-A',
                  prefixIcon: const Icon(Icons.class_),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter class name';
                  }
                  if (value.length < 2) {
                    return 'Class name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add class details...',
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  child: Text(
                    widget.classData == null ? 'Create Class' : 'Update Class',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
