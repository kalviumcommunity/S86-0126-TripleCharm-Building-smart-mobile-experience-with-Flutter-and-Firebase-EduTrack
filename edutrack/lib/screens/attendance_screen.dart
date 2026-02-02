import 'package:flutter/material.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String _selectedClass = 'Class 10A';
  DateTime _selectedDate = DateTime.now();
  
  // Sample attendance data
  final Map<String, Map<String, String>> attendanceData = {
    '001': {'name': 'Rajesh Kumar', 'status': 'present'},
    '002': {'name': 'Priya Sharma', 'status': 'present'},
    '003': {'name': 'Amit Patel', 'status': 'absent'},
    '004': {'name': 'Sneha Reddy', 'status': 'present'},
    '005': {'name': 'Arjun Singh', 'status': 'late'},
    '006': {'name': 'Meera Nair', 'status': 'present'},
  };

  void _toggleAttendance(String id, String currentStatus) {
    setState(() {
      if (currentStatus == 'present') {
        attendanceData[id]!['status'] = 'absent';
      } else if (currentStatus == 'absent') {
        attendanceData[id]!['status'] = 'late';
      } else {
        attendanceData[id]!['status'] = 'present';
      }
    });
  }

  void _saveAttendance() {
    final presentCount = attendanceData.values.where((s) => s['status'] == 'present').length;
    final absentCount = attendanceData.values.where((s) => s['status'] == 'absent').length;
    final lateCount = attendanceData.values.where((s) => s['status'] == 'late').length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Attendance?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Present: $presentCount'),
            Text('Absent: $absentCount'),
            Text('Late: $lateCount'),
            const SizedBox(height: 16),
            const Text('This will save attendance for the selected class and date.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✓ Attendance saved successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final presentCount = attendanceData.values.where((s) => s['status'] == 'present').length;
    final totalCount = attendanceData.length;
    final attendancePercentage = (presentCount / totalCount * 100).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Attendance history coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Date and Class Selection
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Date Selector
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2026),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF6C63FF)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Color(0xFF6C63FF)),
                        const SizedBox(width: 12),
                        Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Class Selector
                DropdownButtonFormField<String>(
                  value: _selectedClass,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.class_, color: Color(0xFF6C63FF)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF6C63FF)),
                    ),
                  ),
                  items: ['Class 10A', 'Class 10B', 'Class 9A']
                      .map((cls) => DropdownMenuItem(value: cls, child: Text(cls)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClass = value!;
                    });
                  },
                ),
              ],
            ),
          ),

          // Attendance Summary
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryChip('Present', '$presentCount', Colors.green),
                _buildSummaryChip('Absent', '${attendanceData.values.where((s) => s['status'] == 'absent').length}', Colors.red),
                _buildSummaryChip('Late', '${attendanceData.values.where((s) => s['status'] == 'late').length}', Colors.orange),
                _buildSummaryChip('Rate', '$attendancePercentage%', Colors.blue),
              ],
            ),
          ),

          // Quick Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        for (var key in attendanceData.keys) {
                          attendanceData[key]!['status'] = 'present';
                        }
                      });
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Mark All Present'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        for (var key in attendanceData.keys) {
                          attendanceData[key]!['status'] = 'absent';
                        }
                      });
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text('Mark All Absent'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Student List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: attendanceData.length,
              itemBuilder: (context, index) {
                final id = attendanceData.keys.elementAt(index);
                final student = attendanceData[id]!;
                final status = student['status']!;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(status).withOpacity(0.2),
                      child: Text(
                        student['name']![0],
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(student['name']!),
                    subtitle: Text('ID: $id'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildStatusButton(
                          'P',
                          status == 'present',
                          Colors.green,
                          () => _toggleAttendance(id, status),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusButton(
                          'A',
                          status == 'absent',
                          Colors.red,
                          () => _toggleAttendance(id, status),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusButton(
                          'L',
                          status == 'late',
                          Colors.orange,
                          () => _toggleAttendance(id, status),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _saveAttendance,
          icon: const Icon(Icons.save),
          label: const Text('Save Attendance'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusButton(String label, bool isSelected, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
