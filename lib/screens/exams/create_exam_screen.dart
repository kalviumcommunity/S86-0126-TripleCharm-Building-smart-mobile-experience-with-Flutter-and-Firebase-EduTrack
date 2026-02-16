import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/exam_provider.dart';
import '../../config/constants.dart';

class CreateExamScreen extends StatefulWidget {
  final String classId;

  const CreateExamScreen({super.key, required this.classId});

  @override
  State<CreateExamScreen> createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<CreateExamScreen> {
  late TextEditingController _examNameController;
  late TextEditingController _totalMarksController;
  late TextEditingController _dateController;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _showMarksEntry = false;
  final Map<String, TextEditingController> _marksControllers = {};
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _examNameController = TextEditingController();
    _totalMarksController = TextEditingController(text: '100');
    _dateController = TextEditingController(
      text: DateTime.now().toString().split(' ')[0],
    );
  }

  @override
  void dispose() {
    _examNameController.dispose();
    _totalMarksController.dispose();
    _dateController.dispose();
    for (var controller in _marksControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Exam'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Exam',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter exam details',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              // Exam Name
              TextFormField(
                controller: _examNameController,
                decoration: InputDecoration(
                  labelText: 'Exam Name',
                  hintText: 'e.g., Midterm, Final, Quiz 1',
                  prefixIcon: const Icon(Icons.assignment),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter exam name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Total Marks
              TextFormField(
                controller: _totalMarksController,
                decoration: InputDecoration(
                  labelText: 'Total Marks',
                  prefixIcon: const Icon(Icons.numbers),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter total marks';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Exam Date
              TextFormField(
                readOnly: true,
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Exam Date',
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectDate,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Add Marks Checkbox
              CheckboxListTile(
                title: const Text('Add Marks Now'),
                value: _showMarksEntry,
                onChanged: (value) {
                  setState(() => _showMarksEntry = value ?? false);
                  if (_showMarksEntry) {
                    _initializeMarkControllers();
                  }
                },
              ),
              const SizedBox(height: 16),
              // Student Marks Entry
              if (_showMarksEntry)
                _buildMarksEntry(),
              const SizedBox(height: 32),
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createExam,
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Create Exam'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarksEntry() {
    return Consumer<StudentProvider>(
      builder: (context, studentProvider, _) {
        if (studentProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (studentProvider.students.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.person, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('No students in this class'),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student Marks',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...studentProvider.students.map((student) {
              final controller = _marksControllers[student.studentId] ??
                  TextEditingController();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: '${student.name} - Marks',
                    hintText: 'Enter marks',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              );
            }),
          ],
        );
      },
    );
  }

  void _initializeMarkControllers() {
    final studentProvider = context.read<StudentProvider>();
    for (var student in studentProvider.students) {
      if (!_marksControllers.containsKey(student.studentId)) {
        _marksControllers[student.studentId] = TextEditingController();
      }
    }
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = picked.toString().split(' ')[0];
      });
    }
  }

  void _createExam() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final examProvider = context.read<ExamProvider>();

      final success = await examProvider.createExam(
        teacherId: authProvider.user!.uid,
        classId: widget.classId,
        examName: _examNameController.text.trim(),
        totalMarks: int.parse(_totalMarksController.text),
        date: _selectedDate,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.successExamCreated),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);

        // Note: To add marks, create the exam first, then add marks in a separate step
        // This requires the exam ID which is obtained after creation
        if (_showMarksEntry && _marksControllers.isNotEmpty) {
          // Marks can be added after exam creation via the mark entry screen
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }
}
