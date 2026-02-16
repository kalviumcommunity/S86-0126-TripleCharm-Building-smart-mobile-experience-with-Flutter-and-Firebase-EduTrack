import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/marks_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../models/marks_model.dart';
import '../../config/theme.dart';

class StudentMarksView extends StatefulWidget {
  const StudentMarksView({super.key});

  @override
  State<StudentMarksView> createState() => _StudentMarksViewState();
}

class _StudentMarksViewState extends State<StudentMarksView> {
  String _selectedSubject = 'All';
  bool _isLoading = true;
  String? _studentId;
  
  final List<String> _subjects = [
    'All',
    'Hindi', 
    'English', 
    'Maths', 
    'Biology', 
    'Science', 
    'Social'
  ];

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }
  
  void _loadStudentData() async {
    final auth = context.read<AuthProvider>();
    if (auth.user != null) {
      final studentProvider = context.read<StudentProvider>();
      
      // First try to get student by userId (linked account)
      var student = await studentProvider.loadStudentByUserId(auth.user!.id);
      
      // Fallback to email if userId link doesn't exist
      student ??= await studentProvider.loadStudentByEmail(auth.user!.email);
      
      if (student != null && mounted) {
        setState(() {
          _studentId = student!.id;
          _isLoading = false;
        });
        
        // Load marks with real-time updates
        context.read<MarksProvider>().loadStudentMarks(student.id);
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final marksProvider = context.watch<MarksProvider>();
    final marks = marksProvider.studentMarks;
    
    // Filter marks by selected subject
    final filteredMarks = _selectedSubject == 'All' 
        ? marks
        : marks.where((m) => m.subject == _selectedSubject).toList();
    
    // Calculate overall statistics
    final totalMarks = marks.isNotEmpty ? marks.map((m) => m.totalMarks).reduce((a, b) => a + b) : 0;
    final obtainedMarks = marks.isNotEmpty ? marks.map((m) => m.obtainedMarks).reduce((a, b) => a + b) : 0;
    final overallPercentage = totalMarks > 0 ? (obtainedMarks / totalMarks) * 100 : 0.0;
    
    // Group marks by subject for subject-wise statistics
    final Map<String, List<MarksModel>> subjectMarks = {};
    for (var mark in marks) {
      if (!subjectMarks.containsKey(mark.subject)) {
        subjectMarks[mark.subject] = [];
      }
      subjectMarks[mark.subject]!.add(mark);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Marks'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          if (_studentId != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                // Refresh marks data
                context.read<MarksProvider>().loadStudentMarks(_studentId!);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Refreshing marks...')),
                );
              },
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
              colors: [AppTheme.primaryColor.withAlpha(12), Colors.white],
          ),
        ),
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryColor),
                    const SizedBox(height: 16),
                    Text('Loading your marks...', 
                         style: Theme.of(context).textTheme.titleMedium?.copyWith(
                           color: AppTheme.primaryColor)),
                  ],
                ))
            : _studentId == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, 
                         size: 80, color: AppTheme.errorColor.withAlpha(76)),
                    const SizedBox(height: 16),
                    Text('Student not found', 
                         style: Theme.of(context).textTheme.titleLarge?.copyWith(
                           color: AppTheme.errorColor.withAlpha(178))),
                    const SizedBox(height: 8),
                    Text('Please contact your teacher to link your account',
                         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                           color: AppTheme.textSecondary)),
                  ],
                ))
            : marks.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_outlined, 
                         size: 80, color: AppTheme.primaryColor.withAlpha(76)),
                    const SizedBox(height: 16),
                    Text('No marks available yet', 
                         style: Theme.of(context).textTheme.titleLarge?.copyWith(
                           color: AppTheme.primaryColor.withAlpha(178))),
                    const SizedBox(height: 8),
                    Text('Your test scores will appear here once teachers add them',
                         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                           color: AppTheme.textSecondary)),
                  ],
                ))
            : Column(
                children: [
                  // Overall Statistics Card
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.primaryColor.withAlpha(204)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withAlpha(76),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text('Overall Performance', 
                                   style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Tests Taken', '${marks.length}', Icons.assignment_turned_in),
                            _buildStatItem('Total Score', '$obtainedMarks/$totalMarks', Icons.star),
                            _buildStatItem('Average', '${overallPercentage.toStringAsFixed(1)}%', Icons.trending_up),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Subject Filter
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _subjects.map((subject) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(subject),
                            selected: _selectedSubject == subject,
                            onSelected: (selected) {
                              setState(() {
                                _selectedSubject = subject;
                              });
                            },
                            selectedColor: AppTheme.primaryColor.withAlpha(51),
                            checkmarkColor: AppTheme.primaryColor,
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                  
                  // Marks List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredMarks.length,
                      itemBuilder: (context, index) {
                        final mark = filteredMarks[index];
                        return _buildMarkCard(mark);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
  
  Widget _buildMarkCard(MarksModel mark) {
    final percentage = mark.percentage;
    Color gradeColor = AppTheme.errorColor;
    String grade = 'F';
    
    if (percentage >= 90) {
      gradeColor = const Color(0xFF4CAF50); // Green
      grade = 'A+';
    } else if (percentage >= 80) {
      gradeColor = const Color(0xFF66BB6A);
      grade = 'A';
    } else if (percentage >= 70) {
      gradeColor = const Color(0xFF42A5F5); // Blue
      grade = 'B';
    } else if (percentage >= 60) {
      gradeColor = const Color(0xFFFF9800); // Orange
      grade = 'C';
    } else if (percentage >= 50) {
      gradeColor = const Color(0xFFFF5722); // Deep Orange
      grade = 'D';
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mark.testName, 
                           style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(mark.subject, 
                           style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.primaryColor)),
                      const SizedBox(height: 4),
                      Text('${mark.recordedAt.day}/${mark.recordedAt.month}/${mark.recordedAt.year}',
                           style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: gradeColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(grade, 
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    Text('${mark.obtainedMarks}/${mark.totalMarks}',
                         style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text('${percentage.toStringAsFixed(1)}%',
                         style: TextStyle(color: gradeColor, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
