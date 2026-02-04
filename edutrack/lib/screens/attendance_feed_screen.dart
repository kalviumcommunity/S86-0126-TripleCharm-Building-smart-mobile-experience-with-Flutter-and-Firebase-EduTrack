import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import 'package:intl/intl.dart';

/// AttendanceFeedScreen - Real-time attendance updates using StreamBuilder
/// Demonstrates reading time-series data with proper filtering and formatting
class AttendanceFeedScreen extends StatefulWidget {
  final String centerId;

  const AttendanceFeedScreen({
    Key? key,
    required this.centerId,
  }) : super(key: key);

  @override
  State<AttendanceFeedScreen> createState() => _AttendanceFeedScreenState();
}

class _AttendanceFeedScreenState extends State<AttendanceFeedScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedStatus = 'all'; // Filter: all, present, absent, late

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Feed'),
        elevation: 0,
        backgroundColor: const Color(0xFF6C63FF),
      ),
      body: Column(
        children: [
          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  _buildFilterChip('Present', 'present'),
                  _buildFilterChip('Absent', 'absent'),
                  _buildFilterChip('Late', 'late'),
                ],
              ),
            ),
          ),
          // Attendance List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.streamAttendance(),
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Error state
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }

                // No data state
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No attendance records',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Data retrieved successfully
                final attendanceRecords = snapshot.data!.docs;

                // Filter by status
                final filteredRecords = _selectedStatus == 'all'
                    ? attendanceRecords
                    : attendanceRecords.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return data['isPresent'] == true && _selectedStatus == 'present' ||
                            data['isPresent'] == false && _selectedStatus == 'absent' ||
                            (data['status'] as String? ?? '')
                                    .toLowerCase() ==
                                _selectedStatus;
                      }).toList();

                return ListView.builder(
                  itemCount: filteredRecords.length,
                  itemBuilder: (context, index) {
                    final attendanceDoc = filteredRecords[index];
                    final attendanceData =
                        attendanceDoc.data() as Map<String, dynamic>;

                    final studentName = attendanceData['studentName'] ??
                        attendanceData['studentId'] ??
                        'Unknown';
                    final date = attendanceData['date'] ?? 'N/A';
                    final isPresent =
                        attendanceData['isPresent'] as bool? ?? false;
                    final status =
                        attendanceData['status'] as String? ?? 'unknown';
                    final timestamp = attendanceData['timestamp'];

                    // Format timestamp
                    String formattedTime = '';
                    if (timestamp != null) {
                      final dateTime = (timestamp as Timestamp).toDate();
                      formattedTime = DateFormat('hh:mm a').format(dateTime);
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: _buildStatusIcon(
                          isPresent,
                          status,
                        ),
                        title: Text(
                          studentName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Date: $date | Time: $formattedTime',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: _buildStatusBadge(status),
                      ),
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

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedStatus == value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedStatus = value;
          });
        },
        selectedColor: const Color(0xFF6C63FF),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildStatusIcon(bool isPresent, String status) {
    if (status == 'late') {
      return Container(
        decoration: BoxDecoration(
          color: Colors.orange[100],
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.schedule,
          color: Colors.orange[700],
        ),
      );
    } else if (isPresent || status == 'present') {
      return Container(
        decoration: BoxDecoration(
          color: Colors.green[100],
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check_circle,
          color: Colors.green[700],
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: Colors.red[100],
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.cancel,
          color: Colors.red[700],
        ),
      );
    }
  }

  Widget _buildStatusBadge(String status) {
    final isPresent = status == 'present';
    final isLate = status == 'late';

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
        ),
      ),
      backgroundColor: isPresent
          ? Colors.green
          : isLate
              ? Colors.orange
              : Colors.red,
    );
  }
}

/// AttendanceStatsScreen - Shows aggregated attendance statistics
/// Demonstrates reading multiple documents and calculating statistics
class AttendanceStatsScreen extends StatefulWidget {
  final String studentId;

  const AttendanceStatsScreen({
    Key? key,
    required this.studentId,
  }) : super(key: key);

  @override
  State<AttendanceStatsScreen> createState() => _AttendanceStatsScreenState();
}

class _AttendanceStatsScreenState extends State<AttendanceStatsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Statistics'),
        elevation: 0,
        backgroundColor: const Color(0xFF6C63FF),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _firestoreService.getStudentAttendance(widget.studentId),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          // No data state
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No attendance data available'),
            );
          }

          // Calculate statistics
          final attendanceList = snapshot.data!;
          int presentCount = 0;
          int absentCount = 0;
          int lateCount = 0;

          for (var record in attendanceList) {
            final status = record['status'] as String? ?? '';
            if (record['isPresent'] == true || status == 'present') {
              presentCount++;
            } else if (status == 'late') {
              lateCount++;
            } else {
              absentCount++;
            }
          }

          final totalClasses = presentCount + absentCount + lateCount;
          final attendancePercentage = totalClasses > 0
              ? ((presentCount + lateCount) / totalClasses * 100)
                  .toStringAsFixed(1)
              : '0';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall Stats Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Overall Attendance',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$attendancePercentage%',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$totalClasses classes attended',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Breakdown Stats
                  const Text(
                    'Breakdown',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow('Present', presentCount, Colors.green),
                  _buildStatRow('Absent', absentCount, Colors.red),
                  _buildStatRow('Late', lateCount, Colors.orange),
                  const SizedBox(height: 24),
                  // Recent Records
                  const Text(
                    'Recent Records',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...attendanceList.take(10).map((record) {
                    final date = record['date'] ?? 'N/A';
                    final status = record['status'] ?? 'unknown';
                    final isPresent = record['isPresent'] as bool? ?? false;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(date),
                          Chip(
                            label: Text(
                              isPresent ? 'Present' : status,
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: isPresent
                                ? Colors.green[100]
                                : Colors.red[100],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
