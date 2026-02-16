import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/student_provider.dart';
import '../../providers/marks_provider.dart';

/// Available subjects for marks entry
const List<String> kSubjects = [
  'Hindi',
  'English',
  'Maths',
  'Biology',
  'Science',
  'Social',
];

/// Marks Entry Screen
class MarksEntryScreen extends StatefulWidget {
  final String classId;
  final String className;

  const MarksEntryScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<MarksEntryScreen> createState() => _MarksEntryScreenState();
}

class _MarksEntryScreenState extends State<MarksEntryScreen> {
  late TextEditingController _testNameController;
  final Map<String, Map<String, dynamic>> _marks = {};
  double _totalMarks = 100;
  String _selectedSubject = kSubjects[0]; // Default to Hindi
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _testNameController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<StudentProvider>().loadClassStudents(widget.classId);
    });
  }

  @override
  void dispose() {
    _testNameController.dispose();
    super.dispose();
  }

  Future<void> _saveMarks() async {
    if (_testNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter test/exam name')),
      );
      return;
    }

    final marksProvider = context.read<MarksProvider>();
    final students = context.read<StudentProvider>().classStudents;

    // Check if any marks entered
    final hasMarks = _marks.values.any((m) => (m['obtained'] ?? 0.0) > 0);
    if (!hasMarks) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter marks for at least one student')),
      );
      return;
    }

    setState(() => _isSaving = true);

    int successCount = 0;
    int totalCount = 0;

    for (var student in students) {
      final obtained = _marks[student.id]?['obtained'] ?? 0.0;
      if (obtained > 0) {
        totalCount++;
        final success = await marksProvider.addMarks(
          classId: widget.classId,
          testName: _testNameController.text.trim(),
          subject: _selectedSubject,
          studentId: student.id,
          obtainedMarks: obtained,
          totalMarks: _totalMarks,
        );
        if (success) successCount++;
      }
    }

    setState(() => _isSaving = false);

    if (!mounted) return;

    if (successCount == totalCount && totalCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Marks saved successfully for $successCount student(s)'),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 2),
        ),
      );
      // Wait before navigating
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.pop(context, true);
    } else if (successCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Saved $successCount of $totalCount marks. Some failed.'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${marksProvider.error ?? 'Failed to save marks'}'),
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
        title: Text('Enter Marks - ${widget.className}'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Test Details
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppTheme.primaryLight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Exam/Test Details',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Subject Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSubject,
                        decoration: const InputDecoration(
                          labelText: 'Subject',
                          prefixIcon: Icon(Icons.subject),
                          border: OutlineInputBorder(),
                        ),
                        items: kSubjects.map((subject) {
                          return DropdownMenuItem(
                            value: subject,
                            child: Text(subject),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSubject = value ?? kSubjects[0];
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Test Name
                      TextField(
                        controller: _testNameController,
                        decoration: const InputDecoration(
                          labelText: 'Test/Exam Name',
                          hintText: 'e.g., Mid Term Exam, Unit Test 1',
                          prefixIcon: Icon(Icons.assignment),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Total Marks
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Total Marks',
                          hintText: 'e.g., 100',
                          prefixIcon: Icon(Icons.grade),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _totalMarks = double.tryParse(value) ?? 100;
                          });
                        },
                        controller: TextEditingController(text: _totalMarks.toString()),
                      ),
                    ],
                  ),
                ),
                // Students Marks
            Consumer<StudentProvider>(
              builder: (context, studentProvider, _) {
                if (studentProvider.classStudents.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No students in this class',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Enter Marks for Students',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: studentProvider.classStudents.length,
                      itemBuilder: (context, index) {
                        final student = studentProvider.classStudents[index];
                        final obtained = _marks[student.id]?['obtained'] ?? 0.0;
                        final percentage = _totalMarks > 0
                            ? ((obtained / _totalMarks) * 100).toStringAsFixed(1)
                            : '0.0';

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppTheme.primaryColor,
                                      child: Text(
                                        student.name.isNotEmpty
                                            ? student.name[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            student.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            '$percentage%',
                                            style: TextStyle(
                                              color: double.parse(percentage) >= 70
                                                  ? AppTheme.successColor
                                                  : (double.parse(percentage) >= 50
                                                      ? AppTheme.warningColor
                                                      : Colors.red),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Marks Obtained',
                                    hintText: '0',
                                    suffixText: '/ $_totalMarks',
                                    border: const OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _marks[student.id] = {
                                        'obtained': double.tryParse(value) ?? 0.0,
                                      };
                                    });
                                  },
                                  controller: TextEditingController(
                                    text: obtained > 0 ? obtained.toString() : '',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            // Save Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveMarks,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Save All Marks',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
              ],
            ),
          ),
          // Loading Overlay
          if (_isSaving)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Card(
                  margin: EdgeInsets.all(32),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Saving marks...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Please wait',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
