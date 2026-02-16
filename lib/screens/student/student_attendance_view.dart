import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../models/attendance_model.dart';
import '../../config/theme.dart';

class StudentAttendanceView extends StatefulWidget {
  const StudentAttendanceView({super.key});

  @override
  State<StudentAttendanceView> createState() => _StudentAttendanceViewState();
}

class _StudentAttendanceViewState extends State<StudentAttendanceView> {
  String _selectedFilter = 'All';
  bool _isLoading = true;
  String? _studentId;
  
  final List<String> _filters = ['All', 'Present', 'Absent'];

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
        
        // Load attendance with real-time updates
        context.read<AttendanceProvider>().loadStudentAttendance(student.id);
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = context.watch<AttendanceProvider>();
    final records = attendanceProvider.studentAttendance;
    
    // Filter records based on selected filter
    final filteredRecords = _selectedFilter == 'All' 
        ? records
        : _selectedFilter == 'Present'
            ? records.where((r) => r.isPresent).toList()
            : records.where((r) => !r.isPresent).toList();
    
    // Calculate statistics
    final totalDays = records.length;
    final presentDays = records.where((r) => r.isPresent).length;
    final absentDays = totalDays - presentDays;
    final attendancePercentage = totalDays > 0 ? (presentDays / totalDays) * 100 : 0.0;
    
    // Sort records by date (most recent first)
    filteredRecords.sort((a, b) => b.date.compareTo(a.date));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          if (_studentId != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                // Refresh attendance data
                context.read<AttendanceProvider>().loadStudentAttendance(_studentId!);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Refreshing attendance...')),
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
                    Text('Loading your attendance...', 
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
            : records.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_outlined, 
                         size: 80, color: AppTheme.primaryColor.withAlpha(76)),
                    const SizedBox(height: 16),
                    Text('No attendance records yet', 
                         style: Theme.of(context).textTheme.titleLarge?.copyWith(
                           color: AppTheme.primaryColor.withAlpha(178))),
                    const SizedBox(height: 8),
                    Text('Your attendance will appear here once teachers mark it',
                         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                           color: AppTheme.textSecondary)),
                  ],
                ))
            : Column(
                children: [
                  // Attendance Statistics Card
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          attendancePercentage >= 80 ? const Color(0xFF4CAF50) : 
                          attendancePercentage >= 60 ? const Color(0xFFFF9800) : const Color(0xFFf44336),
                          (attendancePercentage >= 80 ? const Color(0xFF4CAF50) : 
                          attendancePercentage >= 60 ? const Color(0xFFFF9800) : const Color(0xFFf44336)).withAlpha(204),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (attendancePercentage >= 80 ? const Color(0xFF4CAF50) : 
                          attendancePercentage >= 60 ? const Color(0xFFFF9800) : const Color(0xFFf44336)).withAlpha(76),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text('Attendance Overview', 
                                   style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Present', '$presentDays', Icons.check_circle),
                            _buildStatItem('Absent', '$absentDays', Icons.cancel),
                            _buildStatItem('Percentage', '${attendancePercentage.toStringAsFixed(1)}%', Icons.pie_chart),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Progress bar
                        Container(
                          width: double.infinity,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(76),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: attendancePercentage / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Filter Chips
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: _filters.map((filter) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: _selectedFilter == filter,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          selectedColor: AppTheme.primaryColor.withAlpha(51),
                          checkmarkColor: AppTheme.primaryColor,
                        ),
                      )).toList(),
                    ),
                  ),
                  
                  // Attendance Records List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredRecords.length,
                      itemBuilder: (context, index) {
                        final record = filteredRecords[index];
                        return _buildAttendanceCard(record, index == 0);
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
  
  Widget _buildAttendanceCard(AttendanceModel record, bool isLatest) {
    final isToday = DateTime.now().difference(record.date).inDays == 0;
    final dayName = _getDayName(record.date.weekday);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isLatest ? 6 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: isLatest ? BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryColor, width: 2),
        ) : null,
        child: Row(
          children: [
            // Date Circle
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: record.isPresent ? AppTheme.successColor : AppTheme.errorColor,
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${record.date.day}',
                       style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(_getMonthName(record.date.month).substring(0, 3),
                       style: const TextStyle(color: Colors.white, fontSize: 10)),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Date and Status Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('$dayName, ${record.date.day} ${_getMonthName(record.date.month)} ${record.date.year}',
                           style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      if (isToday) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withAlpha(51),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('TODAY', style: TextStyle(color: AppTheme.primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        record.isPresent ? Icons.check_circle : Icons.cancel,
                        color: record.isPresent ? AppTheme.successColor : AppTheme.errorColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        record.isPresent ? 'Present' : 'Absent',
                        style: TextStyle(
                          color: record.isPresent ? AppTheme.successColor : AppTheme.errorColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Latest indicator
            if (isLatest)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Latest', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
  
  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
  
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
