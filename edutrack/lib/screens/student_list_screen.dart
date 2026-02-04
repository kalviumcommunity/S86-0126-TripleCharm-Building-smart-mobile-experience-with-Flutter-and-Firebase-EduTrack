import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

/// StudentListScreen - Demonstrates reading and displaying a list of students
/// Uses StreamBuilder for real-time updates from Firestore
class StudentListScreen extends StatefulWidget {
  final String centerId;

  const StudentListScreen({
    Key? key,
    required this.centerId,
  }) : super(key: key);

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student List'),
        elevation: 0,
        backgroundColor: const Color(0xFF6C63FF),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by name or roll number...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          // Student List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.streamStudents(),
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
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No students found',
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
                final students = snapshot.data!.docs;
                
                // Filter students based on search query
                final filteredStudents = _searchQuery.isEmpty
                    ? students
                    : students.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final firstName =
                            (data['firstName'] as String? ?? '').toLowerCase();
                        final lastName =
                            (data['lastName'] as String? ?? '').toLowerCase();
                        final rollNumber =
                            (data['rollNumber'] as String? ?? '').toLowerCase();
                        final query = _searchQuery.toLowerCase();

                        return firstName.contains(query) ||
                            lastName.contains(query) ||
                            rollNumber.contains(query);
                      }).toList();

                return ListView.builder(
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    final studentDoc = filteredStudents[index];
                    final studentData =
                        studentDoc.data() as Map<String, dynamic>;
                    final studentId = studentDoc.id;

                    final firstName = studentData['firstName'] ?? 'Unknown';
                    final lastName = studentData['lastName'] ?? '';
                    final rollNumber = studentData['rollNumber'] ?? 'N/A';
                    final enrollmentStatus =
                        studentData['enrollmentStatus'] ?? 'inactive';
                    final averageScore =
                        studentData['averageScore'] as num? ?? 0;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF6C63FF),
                          child: Text(
                            firstName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          '$firstName $lastName',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Roll: $rollNumber',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${averageScore.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Chip(
                              label: Text(
                                enrollmentStatus,
                                style: const TextStyle(fontSize: 10),
                              ),
                              backgroundColor:
                                  enrollmentStatus == 'active'
                                      ? Colors.green[100]
                                      : Colors.red[100],
                            ),
                          ],
                        ),
                        onTap: () {
                          // Navigate to student detail screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentDetailScreen(
                                studentId: studentId,
                              ),
                            ),
                          );
                        },
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
}

/// StudentDetailScreen - Shows detailed information about a single student
/// Uses FutureBuilder and StreamBuilder for different data types
class StudentDetailScreen extends StatefulWidget {
  final String studentId;

  const StudentDetailScreen({
    Key? key,
    required this.studentId,
  }) : super(key: key);

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details'),
        elevation: 0,
        backgroundColor: const Color(0xFF6C63FF),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _firestoreService.getStudent(widget.studentId),
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
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('Student not found'),
            );
          }

          final student = snapshot.data!;
          final firstName = student['firstName'] ?? 'Unknown';
          final lastName = student['lastName'] ?? '';
          final rollNumber = student['rollNumber'] ?? 'N/A';
          final email = student['email'] ?? 'N/A';
          final phoneNumber = student['phoneNumber'] ?? 'N/A';
          final joiningDate = student['joiningDate'] ?? '';

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: const Color(0xFF6C63FF),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Text(
                          firstName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6C63FF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$firstName $lastName',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Roll: $rollNumber',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                // Details Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal Information
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow('Email', email),
                      _buildDetailRow('Phone', phoneNumber),
                      _buildDetailRow('Joining Date', joiningDate.toString()),
                      const SizedBox(height: 20),
                      // Recent Grades
                      const Text(
                        'Recent Grades',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder<QuerySnapshot>(
                        stream: _firestoreService
                            .streamProgress(widget.studentId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Text(
                              'No grades recorded yet',
                              style: TextStyle(color: Colors.grey),
                            );
                          }

                          final grades = snapshot.data!.docs.take(5);

                          return Column(
                            children: grades.map((doc) {
                              final data = doc.data()
                                  as Map<String, dynamic>;
                              final title = data['title'] ?? 'Assessment';
                              final score = data['score'] ?? 0;
                              final maxScore = data['maxScore'] ?? 100;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(title),
                                    Text(
                                      '$score/$maxScore',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
