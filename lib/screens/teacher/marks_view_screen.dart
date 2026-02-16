import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/marks_provider.dart';
import '../../models/marks_model.dart';

/// Screen to view all marks for a class
class MarksViewScreen extends StatefulWidget {
  final String classId;
  final String className;

  const MarksViewScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<MarksViewScreen> createState() => _MarksViewScreenState();
}

class _MarksViewScreenState extends State<MarksViewScreen> {
  String? _selectedSubject;
  final List<String> _subjects = ['All', 'Hindi', 'English', 'Maths', 'Biology', 'Science', 'Social'];

  @override
  void initState() {
    super.initState();
    _selectedSubject = 'All';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarksProvider>().loadClassMarks(widget.classId);
    });
  }

  List<MarksModel> _getFilteredMarks(List<MarksModel> marks) {
    if (_selectedSubject == null || _selectedSubject == 'All') {
      return marks;
    }
    return marks.where((m) => m.subject == _selectedSubject).toList();
  }

  Map<String, List<MarksModel>> _groupMarksByTest(List<MarksModel> marks) {
    final Map<String, List<MarksModel>> grouped = {};
    for (var mark in marks) {
      final key = '${mark.testName} - ${mark.subject}';
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(mark);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Marks - ${widget.className}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon')),
              );
            },
            tooltip: 'Export',
          ),
        ],
      ),
      body: Column(
        children: [
          // Subject Filter
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.neutralGray,
            child: Row(
              children: [
                const Text('Subject: ', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _subjects.map((subject) {
                        final isSelected = _selectedSubject == subject;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(subject),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedSubject = subject;
                              });
                            },
                            selectedColor: AppTheme.primaryColor.withAlpha(50),
                            checkmarkColor: AppTheme.primaryColor,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Marks List
          Expanded(
            child: Consumer<MarksProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.marks.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.marks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assessment_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No marks recorded yet',
                          style: TextStyle(color: Colors.grey[600], fontSize: 18),
                        ),
                      ],
                    ),
                  );
                }

                final filteredMarks = _getFilteredMarks(provider.marks);
                
                if (filteredMarks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.filter_alt_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No marks for $_selectedSubject',
                          style: TextStyle(color: Colors.grey[600], fontSize: 18),
                        ),
                      ],
                    ),
                  );
                }

                final groupedMarks = _groupMarksByTest(filteredMarks);
                final sortedKeys = groupedMarks.keys.toList()
                  ..sort((a, b) {
                    final aMarks = groupedMarks[a]!;
                    final bMarks = groupedMarks[b]!;
                    return bMarks.first.recordedAt.compareTo(aMarks.first.recordedAt);
                  });

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedKeys.length,
                  itemBuilder: (context, index) {
                    final key = sortedKeys[index];
                    final marks = groupedMarks[key]!;
                    final firstMark = marks.first;
                    
                    return _buildTestCard(
                      context,
                      testName: firstMark.testName,
                      subject: firstMark.subject,
                      totalMarks: firstMark.totalMarks,
                      marks: marks,
                      recordedAt: firstMark.recordedAt,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard(
    BuildContext context, {
    required String testName,
    required String subject,
    required double totalMarks,
    required List<MarksModel> marks,
    required DateTime recordedAt,
  }) {
    // Calculate statistics
    final obtainedMarks = marks.map((m) => m.marksObtained ?? 0.0).toList();
    final avg = obtainedMarks.isNotEmpty ? obtainedMarks.reduce((a, b) => a + b) / obtainedMarks.length : 0.0;
    final highest = obtainedMarks.isNotEmpty ? obtainedMarks.reduce((a, b) => a > b ? a : b) : 0.0;
    final lowest = obtainedMarks.isNotEmpty ? obtainedMarks.reduce((a, b) => a < b ? a : b) : 0.0;
    final avgPercent = (avg / totalMarks) * 100;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: _getSubjectColor(subject),
            child: const Icon(Icons.assessment, color: Colors.white, size: 20),
          ),
          title: Text(
            testName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getSubjectColor(subject).withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      subject,
                      style: TextStyle(
                        fontSize: 11,
                        color: _getSubjectColor(subject),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Total: $totalMarks',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('MMM dd, yyyy').format(recordedAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Class Avg: ${avg.toStringAsFixed(1)}/${totalMarks.toStringAsFixed(0)} (${avgPercent.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 12,
                  color: _getPercentageColor(avgPercent),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          children: [
            // Statistics Row
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.neutralGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Students', marks.length.toString(), Icons.people),
                  _buildStatItem('Highest', highest.toStringAsFixed(1), Icons.arrow_upward, Colors.green),
                  _buildStatItem('Lowest', lowest.toStringAsFixed(1), Icons.arrow_downward, Colors.red),
                  _buildStatItem('Average', avg.toStringAsFixed(1), Icons.analytics, AppTheme.accentColor),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Student Marks Table
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withAlpha(20),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text('Student', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Marks', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Percentage', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                        ),
                      ],
                    ),
                  ),
                  
                  // Student Rows
                  ...marks.asMap().entries.map((entry) {
                    final index = entry.key;
                    final mark = entry.value;
                    final percentage = ((mark.marksObtained ?? 0.0) / totalMarks) * 100;
                    
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: index.isEven ? Colors.white : Colors.grey[50],
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[200]!,
                            width: index == marks.length - 1 ? 0 : 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: FutureBuilder<String?>(
                              future: _getStudentName(mark.studentId),
                              builder: (context, snapshot) {
                                return Text(
                                  snapshot.data ?? 'Student ${mark.studentId.substring(0, 8)}...',
                                  style: const TextStyle(fontSize: 14),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${(mark.marksObtained ?? 0.0).toStringAsFixed(1)}/${totalMarks.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getPercentageColor(percentage).withAlpha(20),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _getPercentageColor(percentage),
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, [Color? color]) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color ?? AppTheme.textSecondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'hindi':
        return Colors.orange;
      case 'english':
        return Colors.blue;
      case 'maths':
        return Colors.purple;
      case 'biology':
        return Colors.green;
      case 'science':
        return Colors.teal;
      case 'social':
        return Colors.brown;
      default:
        return AppTheme.primaryColor;
    }
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 70) return AppTheme.successColor;
    if (percentage >= 50) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  Future<String?> _getStudentName(String studentId) async {
    try {
      final marksProvider = context.read<MarksProvider>();
      // Try to find student name from loaded marks
      final marks = marksProvider.marks;
      for (var mark in marks) {
        if (mark.studentId == studentId) {
          // Try to get student name from database if needed
          return 'Student ${mark.studentId.substring(0, 8)}...';
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
