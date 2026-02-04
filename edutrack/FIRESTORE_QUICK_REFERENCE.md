# 🚀 Firestore Reading Quick Reference

## One-Minute Setup

```dart
// 1. Import
import 'services/firestore_service.dart';

// 2. Create service instance
final _firestore = FirestoreService();

// 3. Read data and display
StreamBuilder<QuerySnapshot>(
  stream: _firestore.getStudentsStream('center_001'),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    return ListView(
      children: snapshot.data!.docs.map((doc) => 
        ListTile(title: Text(doc['firstName']))
      ).toList(),
    );
  },
)
```

---

## Read Methods Cheat Sheet

### Students

```dart
// Get one student
await _firestore.getStudent(studentId);

// Get all students
await _firestore.getStudents();

// Get active students only
await _firestore.getActiveStudents(centerId);

// Real-time stream
_firestore.getStudentsStream(centerId)

// Search students
await _firestore.searchStudents(centerId, query);

// Get student enrollments (courses)
await _firestore.getStudentEnrollments(studentId);
```

### Courses

```dart
// Get one course
await _firestore.getCourseById(courseId);

// Get all courses
await _firestore.getCoursesByCenter(centerId);

// Get course schedule
await _firestore.getCourseSchedule(courseId);

// Get assignments
await _firestore.getCourseAssignments(courseId);

// Real-time course updates
_firestore.getCoursesStream(centerId)
```

### Attendance

```dart
// Get student's attendance history
await _firestore.getStudentAttendance(studentId);

// Get course attendance
await _firestore.getCourseAttendance(courseId);

// Get today's attendance
await _firestore.getTodaysAttendance(centerId);

// Real-time attendance
_firestore.getAttendanceStream(courseId)

// Attendance stats
await _firestore.getAttendanceStats(studentId);

// Attendance percentage
await _firestore.getAttendancePercentage(studentId);
```

### Progress/Grades

```dart
// Get student grades
await _firestore.getStudentProgress(studentId);

// Get course grades
await _firestore.getCourseProgress(courseId);

// Get grades for student in course
await _firestore.getStudentCourseProgress(studentId, courseId);

// Average score
await _firestore.getStudentAverageScore(studentId);

// Real-time grades
_firestore.getProgressStream(studentId)
```

---

## UI Pattern: StreamBuilder vs FutureBuilder

### Use StreamBuilder for Real-Time Data

```dart
// ✅ Attendance (changes often)
// ✅ Messages (arrive frequently)
// ✅ Live notifications

StreamBuilder<QuerySnapshot>(
  stream: _firestore.getAttendanceStream(courseId),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    final records = snapshot.data!.docs;
    return ListView(...);
  },
)
```

### Use FutureBuilder for Static Data

```dart
// ✅ User profile (rarely changes)
// ✅ Course info (stable)
// ✅ Historical reports

FutureBuilder<Map<String, dynamic>?>(
  future: _firestore.getStudent(studentId),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    final student = snapshot.data!;
    return Text(student['firstName']);
  },
)
```

---

## Error Handling Patterns

### Safe Field Access

```dart
// ❌ Unsafe
final name = doc['firstName'];  // Could be null!

// ✅ Safe
final name = doc['firstName'] as String? ?? 'Unknown';

// ✅ Also safe
final name = (doc['firstName'] ?? 'Unknown') as String;
```

### Check Data Availability

```dart
// ✅ All states handled
StreamBuilder<QuerySnapshot>(
  stream: firestore.collection('students').snapshots(),
  builder: (context, snapshot) {
    // Loading
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    
    // Error
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    
    // Empty
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Text('No data');
    }
    
    // Success
    return ListView(...);
  },
)
```

---

## Common Queries

### Get Active Students in a Center

```dart
final students = await FirebaseFirestore.instance
    .collection('students')
    .where('centerId', isEqualTo: centerId)
    .where('isActive', isEqualTo: true)
    .orderBy('firstName')
    .get();
```

### Filter Attendance by Date Range

```dart
final records = await FirebaseFirestore.instance
    .collection('attendance')
    .where('centerId', isEqualTo: centerId)
    .where('classDate', 
      isGreaterThanOrEqualTo: startDate,
      isLessThanOrEqualTo: endDate)
    .orderBy('classDate', descending: true)
    .get();
```

### Get Best Performing Students

```dart
final topStudents = await FirebaseFirestore.instance
    .collection('students')
    .where('centerId', isEqualTo: centerId)
    .where('averageScore', isGreaterThanOrEqualTo: 80)
    .orderBy('averageScore', descending: true)
    .limit(10)
    .get();
```

### Get Students Enrolled in a Course

```dart
final courseStudents = await FirebaseFirestore.instance
    .collection('students')
    .doc(studentId)
    .collection('enrollments')
    .where('courseId', isEqualTo: courseId)
    .get();
```

---

## Data Type Conversions

```dart
// String
final name = doc['firstName'] as String? ?? '';

// Number (int)
final count = (doc['count'] as num?)?.toInt() ?? 0;

// Number (double)
final percentage = (doc['percentage'] as num?)?.toDouble() ?? 0.0;

// Boolean
final isActive = doc['isActive'] as bool? ?? false;

// Date (Timestamp)
final date = (doc['date'] as Timestamp?)?.toDate() ?? DateTime.now();

// List
final tags = (doc['tags'] as List?)?.cast<String>() ?? [];

// Map/Object
final data = doc['data'] as Map<String, dynamic>? ?? {};
```

---

## Performance Tips

### ✅ DO

```dart
// Filter at database level
.where('centerId', isEqualTo: centerId)
.where('isActive', isEqualTo: true)

// Limit results
.limit(50)

// Order and paginate
.orderBy('createdAt', descending: true)

// Only listen to needed fields
.snapshots()  // Efficient
```

### ❌ DON'T

```dart
// Load entire collection
getStudents()  // 1000+ docs

// Load all attendance
getAttendanceStream()  // Could be 100,000+

// Filter in code
students.where((s) => s['isActive'])  // Do this in query

// Multiple separate reads
for student in students {
  await getStudent(student.id)  // N+1 problem!
}
```

---

## Testing Data Locally

```dart
// 1. Add sample data
await FirestoreSampleDataHelper.initializeSampleData();

// 2. Test reading
final students = await FirestoreService().getStudents();
print('Found ${students.length} students');

// 3. Test filtering
final active = students.where((s) => s['isActive']).toList();
print('Active: ${active.length}');

// 4. Test calculations
final avgScore = students
    .map((s) => s['averageScore'] as num? ?? 0)
    .reduce((a, b) => a + b) / students.length;
print('Average score: $avgScore');
```

---

## Debugging Tips

### Enable Firestore Logging

```dart
// In main.dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
);

// See all queries in console
FirebaseFirestore.instance.snapshotMetadataChanges().listen((event) {
  print('Firestore update: ${event.docs.length} docs');
});
```

### Print Query Data

```dart
StreamBuilder<QuerySnapshot>(
  stream: firestore.collection('students').snapshots(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      // Debug: Print all documents
      for (var doc in snapshot.data!.docs) {
        print('Student: ${doc['firstName']} - ${doc['averageScore']}');
      }
    }
    return SizedBox();
  },
)
```

### Monitor Network Requests

```dart
// Use Flutter DevTools (F12 in browser)
// Network tab shows all Firestore requests
// Check response times and data size
```

---

## Screen Snippets

### Complete Student List Screen

```dart
class StudentListScreen extends StatelessWidget {
  final FirestoreService _firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Students')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.getStudentsStream('center_001'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              return ListTile(
                title: Text(doc['firstName']),
                subtitle: Text(doc['rollNumber']),
                trailing: Text('${doc['averageScore']}%'),
              );
            },
          );
        },
      ),
    );
  }
}
```

### Complete Stats Screen

```dart
class StatsScreen extends StatelessWidget {
  final String studentId;
  final FirestoreService _firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _firestore.getAttendanceStats(studentId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        
        final stats = snapshot.data!;
        return Column(
          children: [
            Text('Total: ${stats['total']}'),
            Text('Present: ${stats['present']}'),
            Text('Absent: ${stats['absent']}'),
            Text('Percentage: ${stats['percentage']}%'),
          ],
        );
      },
    );
  }
}
```

---

## Links & Resources

- 📖 [Full Reading Guide](FIRESTORE_READING_GUIDE.md)
- 🧪 [Testing Guide](FIRESTORE_READING_TESTING.md)
- 🗄️ [Schema Design](FIRESTORE_SCHEMA.md)
- 📚 [Firestore Docs](https://firebase.google.com/docs/firestore)

