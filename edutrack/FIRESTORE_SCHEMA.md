# 🗄️ Cloud Firestore Database Schema Design for EduTrack

## 📋 Table of Contents
1. [Overview](#overview)
2. [Data Requirements](#data-requirements)
3. [Firestore Schema Structure](#firestore-schema-structure)
4. [Collections & Documents](#collections--documents)
5. [Sample JSON Documents](#sample-json-documents)
6. [Schema Diagram](#schema-diagram)
7. [Design Decisions & Rationale](#design-decisions--rationale)
8. [Scalability Considerations](#scalability-considerations)
9. [Future Extensions](#future-extensions)

---

## Overview

**EduTrack** uses Cloud Firestore (NoSQL) to store and manage student attendance, academic progress, and coaching center data. The schema is designed for:

- ✅ **Real-time updates** across multiple clients
- ✅ **Scalability** to thousands of students and records
- ✅ **Easy querying** (filter by student, course, date, etc.)
- ✅ **Minimal data duplication** while maintaining performance
- ✅ **Clear hierarchical relationships** (users → students → attendance)

---

## Data Requirements

### Core Data Entities

| Entity | Purpose | Growth Rate | Notes |
|--------|---------|-------------|-------|
| **Users** | Teachers, admins, coordinators | Medium (10s per center) | Authentication & authorization |
| **Students** | Student profiles and metadata | High (100s per center) | Core business entity |
| **Courses** | Course offerings and categories | Low (10s per center) | Define what students are enrolled in |
| **Enrollments** | Student-Course relationships | Medium (100s) | Links students to courses |
| **Attendance** | Daily attendance records | Very High (1000s+) | Time-series data, should use subcollections |
| **Progress** | Academic performance & scores | High (100s) | Grades, test scores, assessments |
| **Assignments** | Course assignments and tasks | Medium (100s) | Track what's assigned to students |
| **Coaching Centers** | Organization metadata | Low (1-10) | Top-level org info |

### Key Functional Requirements

- Track daily attendance for students by course
- Store grades, test scores, and performance metrics
- Manage student-to-course enrollments
- Generate reports by student, course, or date
- Real-time notifications for attendance changes
- Search/filter students by name, enrollment, performance

---

## Firestore Schema Structure

```
firestore/
├── coachingCenters/              (Collection)
│   └── centerId/                 (Document)
│       ├── Basic Info
│       └── stats/                (Subcollection)
│
├── users/                        (Collection)
│   └── userId/                   (Document)
│       ├── Profile Info
│       └── preferences/          (Optional Subcollection)
│
├── students/                     (Collection)
│   └── studentId/                (Document)
│       ├── Student Info
│       └── enrollments/          (Subcollection - Courses)
│           └── enrollmentId/     (Document)
│
├── courses/                      (Collection)
│   └── courseId/                 (Document)
│       ├── Course Details
│       ├── schedule/             (Subcollection - Class Sessions)
│       └── assignments/          (Subcollection - Course Assignments)
│
├── attendance/                   (Collection - Time-series data)
│   └── attendanceId/             (Document)
│       ├── Basic Attendance Record
│
├── progress/                     (Collection)
│   └── progressId/               (Document)
│       ├── Grade & Score Info
│
└── classRooms/                   (Collection)
    └── classRoomId/              (Document)
        ├── Room Details
        └── students/             (Subcollection - Enrolled Students)
```

---

## Collections & Documents

### 1. **coachingCenters** Collection
Top-level organization information.

#### Document: centerId

```
Field Name          | Type        | Description                    | Example
--------------------|-------------|--------------------------------|------------------
name                | string      | Center name                    | "Sharma Coaching Center"
address             | string      | Physical address               | "123 Main St, City"
city                | string      | City name                      | "Jaipur"
state               | string      | State/Province                 | "Rajasthan"
phoneNumber         | string      | Contact number                 | "+91-9876543210"
email               | string      | Contact email                  | "contact@sharma.edu"
adminUserId         | string      | Primary admin reference        | (reference to users/{userId})
createdAt           | timestamp   | Account creation date          | 2024-01-15T10:30:00Z
updatedAt           | timestamp   | Last update timestamp          | 2024-02-04T15:45:00Z
totalStudents       | number      | Cached student count           | 45
activeCourses       | number      | Total active courses           | 8
logo                | string      | Logo URL (Cloud Storage)       | "gs://bucket/logos/center1.png"
isActive            | boolean     | Center operational status      | true
```

#### Subcollection: stats
Real-time analytics about the center.

```
Field Name          | Type        | Description
--------------------|-------------|---------------------------
date                | date        | Date of statistics
totalAttendance     | number      | Students present that day
totalAbsent         | number      | Students absent
averageAttendance   | number      | Percentage attendance
coursesScheduled    | number      | Classes scheduled that day
```

---

### 2. **users** Collection
Teachers, admins, and staff members.

#### Document: userId

```
Field Name          | Type        | Description                    | Example
--------------------|-------------|--------------------------------|------------------
email               | string      | Login email (unique)           | "teacher1@gmail.com"
displayName         | string      | Full name                      | "Rajesh Kumar"
role                | string      | User role (enum)               | "teacher" | "admin" | "coordinator"
centerId            | string      | Reference to coaching center   | "center_001"
phoneNumber         | string      | Contact phone                  | "+91-9988776655"
profileImageUrl     | string      | Profile photo (Cloud Storage)  | "gs://bucket/profiles/user1.jpg"
isActive            | boolean     | Account status                 | true
lastLogin           | timestamp   | Last login time                | 2024-02-04T09:15:00Z
createdAt           | timestamp   | Account creation date          | 2024-01-10T11:00:00Z
updatedAt           | timestamp   | Last profile update            | 2024-02-01T14:30:00Z
permissions         | array       | List of permissions            | ["view_attendance", "edit_grades"]
departmentAssigned  | string      | Assigned department/subject    | "Mathematics"
```

---

### 3. **students** Collection
Student profiles and personal information.

#### Document: studentId

```
Field Name          | Type        | Description                    | Example
--------------------|-------------|--------------------------------|------------------
rollNumber          | string      | Unique roll number (can be ID) | "STU-2024-001"
firstName           | string      | First name                     | "Asha"
lastName            | string      | Last name                      | "Sharma"
email               | string      | Email (optional)               | "asha.sharma@email.com"
phoneNumber         | string      | Contact number                 | "+91-9123456789"
parentPhoneNumber   | string      | Parent/guardian contact        | "+91-9876543210"
dateOfBirth         | timestamp   | Date of birth                  | 2008-05-15T00:00:00Z
gender              | string      | Gender (M/F/Other)             | "F"
address             | string      | Residential address            | "Apt 5B, Rajeev Nagar"
city                | string      | City                           | "Jaipur"
state               | string      | State                          | "Rajasthan"
centerId            | string      | Reference to coaching center   | "center_001"
enrollmentStatus    | string      | Status (active/inactive/left)  | "active"
joiningDate         | timestamp   | Enrollment date                | 2024-01-10T10:00:00Z
profileImageUrl     | string      | Student photo (Cloud Storage)  | "gs://bucket/students/stu001.jpg"
guardianName        | string      | Parent/guardian name           | "Vikram Sharma"
guardianRelation    | string      | Relationship to student        | "Father"
emergencyContact    | string      | Emergency contact number       | "+91-9988112233"
notes                | string      | Additional notes               | "Excellent in Math"
isActive            | boolean     | Currently enrolled             | true
createdAt           | timestamp   | Record creation date           | 2024-01-10T10:00:00Z
updatedAt           | timestamp   | Last update                    | 2024-02-04T12:00:00Z
totalAttendancePercentage | number | Cached attendance %            | 92.5
averageScore        | number      | Cached average score           | 87.3
```

#### Subcollection: enrollments
Tracks which courses the student is enrolled in.

```
Field Name          | Type        | Description
--------------------|-------------|---------------------------
courseId            | string      | Reference to courses/{courseId}
courseName          | string      | Cached course name (denormalization)
enrollmentDate      | timestamp   | When student enrolled
status              | string      | "active" | "completed" | "dropped"
currentGrade        | string      | Letter grade (A, B, C, etc)
scorePercentage     | number      | Score percentage
attendancePercentage| number      | Attendance in this course
isMandatory         | boolean     | Is it a required course
```

---

### 4. **courses** Collection
Course/subject information.

#### Document: courseId

```
Field Name          | Type        | Description                    | Example
--------------------|-------------|--------------------------------|------------------
name                | string      | Course name                    | "Mathematics - Class 10"
subject             | string      | Subject name                   | "Mathematics"
description         | string      | Course description             | "Comprehensive Math curriculum"
centerId            | string      | Reference to coaching center   | "center_001"
instructorId        | string      | Primary instructor             | "user_teacher1"
instructorName      | string      | Instructor name (cached)       | "Rajesh Kumar"
capacity            | number      | Max students in course         | 30
enrolledCount       | number      | Current enrollment count       | 24
level               | string      | Course level                   | "Class 10" | "JEE" | "NEET"
category            | string      | Course category                | "Science" | "Commerce" | "Humanities"
scheduleType        | string      | How often it meets             | "daily" | "thrice-weekly" | "twice-weekly"
startDate           | timestamp   | Course start date              | 2024-01-15T08:00:00Z
endDate             | timestamp   | Course end date                | 2024-06-30T18:00:00Z
syllabus            | string      | URL to syllabus document       | "gs://bucket/syllabus/math10.pdf"
price               | number      | Course fee (optional)          | 5000
currency            | string      | Currency code                  | "INR"
isActive            | boolean     | Course currently running       | true
createdAt           | timestamp   | Created date                   | 2024-01-10T10:00:00Z
updatedAt           | timestamp   | Last update                    | 2024-02-04T12:00:00Z
tags                | array       | Search tags                    | ["math", "class10", "exam-prep"]
```

#### Subcollection: schedule
Class sessions and schedules.

```
Field Name          | Type        | Description
--------------------|-------------|---------------------------
classDate           | timestamp   | Class session date/time
dayOfWeek           | string      | Day name
startTime           | timestamp   | Start time
endTime             | timestamp   | End time
room                | string      | Classroom location/number
instructor          | string      | Instructor for this session
topic               | string      | Topic covered in this class
notes               | string      | Class notes/materials
isCompleted         | boolean     | Has this class occurred
```

#### Subcollection: assignments
Assignments and homework for the course.

```
Field Name          | Type        | Description
--------------------|-------------|---------------------------
title               | string      | Assignment name
description         | string      | Details
dueDate             | timestamp   | Due date
type                | string      | "homework" | "project" | "test"
totalMarks          | number      | Maximum marks
submissionCount     | number      | How many submitted
filePath            | string      | Path to assignment PDF/file
createdBy           | string      | Instructor who created it
createdAt           | timestamp   | Assignment creation date
```

---

### 5. **attendance** Collection
Daily attendance records (time-series data).

#### Document: attendanceId

```
Field Name          | Type        | Description                    | Example
--------------------|-------------|--------------------------------|------------------
studentId           | string      | Reference to students/{id}     | "stu_001"
studentName         | string      | Student name (cached)          | "Asha Sharma"
courseId            | string      | Reference to courses/{id}      | "course_001"
courseName          | string      | Course name (cached)           | "Mathematics"
centerId            | string      | Center ID                      | "center_001"
classDate           | date        | Date of attendance             | 2024-02-03
sessionStartTime    | timestamp   | Class session start            | 2024-02-03T09:00:00Z
sessionEndTime      | timestamp   | Class session end              | 2024-02-03T10:30:00Z
status              | string      | "present" | "absent" | "late" | "excused" | "leave" | "online"
markedBy            | string      | Staff who marked it            | "user_teacher1"
markedAt            | timestamp   | When it was marked             | 2024-02-03T09:05:00Z
remarks             | string      | Reason for absence, if any     | "Medical leave"
isEdited            | boolean     | Was this record edited         | false
editedBy            | string      | Who edited it (if applicable)  | null
editedAt            | timestamp   | When it was edited             | null
createdAt           | timestamp   | Record creation               | 2024-02-03T09:05:00Z
```

**Indexing Strategy for Attendance:**
- Composite index: (studentId, classDate DESC)
- Composite index: (courseId, classDate DESC)
- Single field: centerId (for center-level reports)

---

### 6. **progress** Collection
Academic progress, grades, and scores.

#### Document: progressId

```
Field Name          | Type        | Description                    | Example
--------------------|-------------|--------------------------------|------------------
studentId           | string      | Reference to students/{id}     | "stu_001"
studentName         | string      | Student name (cached)          | "Asha Sharma"
courseId            | string      | Reference to courses/{id}      | "course_001"
courseName          | string      | Course name (cached)           | "Mathematics"
centerId            | string      | Center ID                      | "center_001"
assessmentType      | string      | Type of assessment             | "unit_test" | "monthly_exam" | "final_exam" | "assignment"
assessmentTitle     | string      | Name of the assessment         | "Unit Test 1 - Algebra"
totalMarks          | number      | Total marks for this test      | 100
obtainedMarks       | number      | Marks obtained                 | 87
scorePercentage     | number      | Calculated percentage          | 87.0
grade               | string      | Letter grade                   | "A"
gradePoints         | number      | Grade point (if applicable)    | 4.0
comments            | string      | Teacher feedback               | "Excellent work on algebra"
evaluatedBy         | string      | Teacher who evaluated          | "user_teacher1"
evaluatedAt         | timestamp   | When it was evaluated          | 2024-01-25T14:30:00Z
improvementAreas    | array       | Areas needing improvement      | ["Geometry", "Word Problems"]
strengths           | array       | Student strengths              | ["Calculation", "Concept Understanding"]
createdAt           | timestamp   | Record creation                | 2024-01-25T14:30:00Z
updatedAt           | timestamp   | Last update                    | 2024-01-25T14:30:00Z
isPublished         | boolean     | Visible to students/parents    | true
```

---

### 7. **classRooms** Collection
Physical/virtual classroom management.

#### Document: classRoomId

```
Field Name          | Type        | Description                    | Example
--------------------|-------------|--------------------------------|------------------
name                | string      | Room name/number               | "Room A-101"
capacity            | number      | Max capacity                   | 40
location            | string      | Building/location              | "Building A, Floor 1"
centerId            | string      | Reference to coaching center   | "center_001"
resources           | array       | Available resources            | ["projector", "whiteboard", "AC"]
isActive            | boolean     | Currently in use               | true
createdAt           | timestamp   | Creation date                  | 2024-01-10T10:00:00Z
```

#### Subcollection: classSchedules
Fixed schedule for this classroom.

```
Field Name          | Type        | Description
--------------------|-------------|---------------------------
courseId            | string      | Scheduled course
dayOfWeek           | string      | Day (Monday, Tuesday, etc)
startTime           | timestamp   | Time slot start
endTime             | timestamp   | Time slot end
isActive            | boolean     | Schedule currently active
```

---

## Sample JSON Documents

### Example 1: Student Document with Enrollment

```json
// students/stu_001
{
  "rollNumber": "STU-2024-001",
  "firstName": "Asha",
  "lastName": "Sharma",
  "email": "asha.sharma@example.com",
  "phoneNumber": "+91-9123456789",
  "parentPhoneNumber": "+91-9876543210",
  "dateOfBirth": "2008-05-15T00:00:00Z",
  "gender": "F",
  "address": "Apt 5B, Rajeev Nagar",
  "city": "Jaipur",
  "state": "Rajasthan",
  "centerId": "center_001",
  "enrollmentStatus": "active",
  "joiningDate": "2024-01-10T10:00:00Z",
  "profileImageUrl": "gs://edutrack-bucket/students/stu_001.jpg",
  "guardianName": "Vikram Sharma",
  "guardianRelation": "Father",
  "emergencyContact": "+91-9988112233",
  "notes": "Excellent in Mathematics, needs support in English",
  "isActive": true,
  "createdAt": "2024-01-10T10:00:00Z",
  "updatedAt": "2024-02-04T12:00:00Z",
  "totalAttendancePercentage": 92.5,
  "averageScore": 87.3,
  
  // Subcollection: enrollments (accessible via reference)
  // - enrollments/enroll_001 (Mathematics - Class 10)
  // - enrollments/enroll_002 (Physics - Class 10)
}
```

### Example 2: Enrollment Document (Subcollection)

```json
// students/stu_001/enrollments/enroll_001
{
  "courseId": "course_math_001",
  "courseName": "Mathematics - Class 10",
  "enrollmentDate": "2024-01-10T10:00:00Z",
  "status": "active",
  "currentGrade": "A",
  "scorePercentage": 87.3,
  "attendancePercentage": 92.5,
  "isMandatory": true
}
```

### Example 3: Attendance Record

```json
// attendance/att_001
{
  "studentId": "stu_001",
  "studentName": "Asha Sharma",
  "courseId": "course_math_001",
  "courseName": "Mathematics - Class 10",
  "centerId": "center_001",
  "classDate": "2024-02-03",
  "sessionStartTime": "2024-02-03T09:00:00Z",
  "sessionEndTime": "2024-02-03T10:30:00Z",
  "status": "present",
  "markedBy": "user_teacher1",
  "markedAt": "2024-02-03T09:05:00Z",
  "remarks": null,
  "isEdited": false,
  "editedBy": null,
  "editedAt": null,
  "createdAt": "2024-02-03T09:05:00Z"
}
```

### Example 4: Progress/Grade Record

```json
// progress/prog_001
{
  "studentId": "stu_001",
  "studentName": "Asha Sharma",
  "courseId": "course_math_001",
  "courseName": "Mathematics - Class 10",
  "centerId": "center_001",
  "assessmentType": "unit_test",
  "assessmentTitle": "Unit Test 1 - Algebra",
  "totalMarks": 100,
  "obtainedMarks": 87,
  "scorePercentage": 87.0,
  "grade": "A",
  "gradePoints": 4.0,
  "comments": "Excellent work on algebraic equations. Keep it up!",
  "evaluatedBy": "user_teacher1",
  "evaluatedAt": "2024-01-25T14:30:00Z",
  "improvementAreas": ["Geometry", "Word Problems"],
  "strengths": ["Calculation Speed", "Concept Understanding"],
  "createdAt": "2024-01-25T14:30:00Z",
  "updatedAt": "2024-01-25T14:30:00Z",
  "isPublished": true
}
```

### Example 5: Course with Assignments (Subcollection)

```json
// courses/course_math_001
{
  "name": "Mathematics - Class 10",
  "subject": "Mathematics",
  "description": "Comprehensive curriculum for Class 10 mathematics covering algebra, geometry, trigonometry, and statistics",
  "centerId": "center_001",
  "instructorId": "user_teacher1",
  "instructorName": "Rajesh Kumar",
  "capacity": 30,
  "enrolledCount": 24,
  "level": "Class 10",
  "category": "Science",
  "scheduleType": "daily",
  "startDate": "2024-01-15T08:00:00Z",
  "endDate": "2024-06-30T18:00:00Z",
  "syllabus": "gs://edutrack-bucket/syllabi/math10.pdf",
  "price": 5000,
  "currency": "INR",
  "isActive": true,
  "createdAt": "2024-01-10T10:00:00Z",
  "updatedAt": "2024-02-04T12:00:00Z",
  "tags": ["mathematics", "class10", "exam-prep", "algebra", "geometry"],
  
  // Subcollection: schedule
  // - schedule/class_001 (2024-02-03 09:00 AM)
  // - schedule/class_002 (2024-02-04 09:00 AM)
  
  // Subcollection: assignments
  // - assignments/assign_001 (Algebra Homework)
  // - assignments/assign_002 (Geometry Project)
}
```

### Example 6: Assignment Document (Subcollection)

```json
// courses/course_math_001/assignments/assign_001
{
  "title": "Algebra Problem Set 1",
  "description": "Solve problems 1-20 from Chapter 4: Linear Equations and Quadratic Equations",
  "dueDate": "2024-02-10T23:59:59Z",
  "type": "homework",
  "totalMarks": 50,
  "submissionCount": 18,
  "filePath": "gs://edutrack-bucket/assignments/algebra_set1.pdf",
  "createdBy": "user_teacher1",
  "createdAt": "2024-02-03T10:00:00Z"
}
```

---

## Schema Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                       FIRESTORE DATABASE                            │
└─────────────────────────────────────────────────────────────────────┘

                          ┌──────────────────┐
                          │ coachingCenters  │
                          │   (Collection)   │
                          └────────┬─────────┘
                                   │
                        ┌──────────┼──────────┐
                        │          │          │
                        ▼          ▼          ▼
                    [centerId]   [stats]   (Subcollection)
                    (Document)  (Sub)
                        │
        ┌───────────────┼───────────────┐
        │               │               │
        ▼               ▼               ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│    users     │ │   students   │ │   courses    │
│(Collection)  │ │(Collection)  │ │(Collection)  │
└──────┬───────┘ └──────┬───────┘ └──────┬───────┘
       │                │                │
    [userId]        [studentId]      [courseId]
    (Document)      (Document)       (Document)
       │                │                │
       │         ┌──────┴──────┐     ┌───┴────┐
       │         │             │     │        │
       ▼         ▼             ▼     ▼        ▼
             [enrollments]         [schedule] [assignments]
             (Sub-collection)      (Sub)      (Sub)
                  │
              [enrollmentId]
              (Document)

        ┌──────────────────┐  ┌──────────────────┐
        │   attendance     │  │    progress      │
        │  (Collection)    │  │  (Collection)    │
        └────────┬─────────┘  └────────┬─────────┘
                 │                     │
          [attendanceId]         [progressId]
          (Document)             (Document)
                 │                     │
          Time-series data     Grade & Score Data
          (indexed by student,  (indexed by student
           course, date)         course, date)
```

---

## Design Decisions & Rationale

### 1. **Why Use Separate Collections for Attendance & Progress?**

- **Scalability:** Attendance records grow daily (1000s of records). Keeping them separate prevents document size explosions
- **Performance:** Queries on attendance don't load progress data and vice versa
- **Time-series:** Attendance is inherently time-series data, best served by separate collection
- **Archival:** Old attendance records can be archived separately from student profiles

### 2. **Why Use Subcollections for Enrollments?**

- **Growth:** A student might enroll in 5-10 courses. Subcollections avoid array-size limits
- **Real-time:** Can listen to real-time updates on specific enrollments
- **Querying:** Easy to query all courses for a student without loading student profile
- **Flexibility:** Each enrollment can have nested data (assignments submitted, etc.) without cluttering the main student document

### 3. **Why Cache Fields Like courseName and studentName?**

- **Performance:** Avoids N+1 queries when displaying attendance reports
- **Offline:** Mobile app can display data without needing to fetch related documents
- **Consistency:** Critical info is duplicated minimally (only denormalized where needed)
- **Trade-off:** Slight update complexity in exchange for fast reads

### 4. **Why Separate classRooms Collection?**

- **Resource Management:** Rooms can be managed independently
- **Schedule Conflicts:** Easy to check room availability
- **Maintenance:** Separate from courses (courses can move between rooms)
- **Scalability:** Centers might have 5-20 rooms, manageable at top level

### 5. **Why Use Composite Indexes for Attendance?**

Firestore requires composite indexes for these query patterns:
```dart
// Query 1: Get all attendance for a student, ordered by date
students/{studentId}/attendance where classDate > X ORDER BY classDate DESC

// Query 2: Get all attendance for a course on a date
courses/{courseId}/attendance where classDate == X

// Query 3: Get center-level report
attendance where centerId == X AND classDate >= startDate AND classDate <= endDate
```

---

## Scalability Considerations

### Growth Projections

| Entity | Small Center | Medium Center | Large Center |
|--------|--------------|---------------|--------------|
| Students | 50 | 300 | 1000+ |
| Courses | 5 | 15 | 40 |
| Attendance Records/Month | 7,500 | 45,000 | 150,000 |
| Progress Records/Semester | 500 | 3,000 | 10,000 |

### How This Schema Scales

✅ **Attendance Isolation:** Time-series data in separate collection prevents document bloat
✅ **Subcollections:** Enrollments scale linearly with courses per student
✅ **Denormalization:** Strategic caching avoids complex joins
✅ **Indexing:** Composite indexes make queries efficient even with 100k+ records
✅ **Partitioning:** By centerId, date ranges naturally partition data

### Potential Bottlenecks & Solutions

| Issue | Mitigation |
|-------|-----------|
| Too many attendance reads | Archive old records to backup collection |
| Enrollment subcollection growth | Likely acceptable (max 10-20 per student) |
| Cached name updates | Use batch writes; eventually consistent |
| Complex reports | Use Cloud Functions for async computation |

---

## Future Extensions

### 1. **Payments & Invoicing**
```
payments/
  └── paymentId/
      ├── studentId
      ├── amount
      ├── dateOfPayment
      └── invoiceUrl
```

### 2. **Chat & Notifications**
```
messages/
  └── messageId/
      ├── senderId
      ├── courseId
      ├── content
      └── timestamp

notifications/
  └── userId/
      └── notificationId/
          ├── type (attendance, grade, assignment)
          └── isRead
```

### 3. **Assignments & Submissions**
```
assignments/{assignmentId}/submissions/
  └── submissionId/
      ├── studentId
      ├── submissionDate
      ├── fileUrl
      └── status (submitted, graded)
```

### 4. **Analytics & Reports**
```
reports/
  └── reportId/
      ├── type (monthly, semester, annual)
      ├── data
      └── generatedAt
```

### 5. **Inventory & Resources**
```
resources/
  └── resourceId/
      ├── type (book, equipment, etc)
      ├── quantity
      └── assignedTo
```

---

## Security Rules Preview

```
// Example Firestore Security Rules (to be implemented)

match /databases/{database}/documents {
  // Students can only read their own documents
  match /students/{studentId} {
    allow read: if request.auth.uid == studentId;
    allow write: if request.auth.uid == get(/databases/$(database)/documents/users/$(request.auth.uid)).data.centerId == resource.data.centerId && request.auth.token.role == 'admin';
  }
  
  // Teachers can read attendance for their courses
  match /attendance/{attendanceId} {
    allow read: if request.auth.token.role == 'teacher' || request.auth.token.role == 'admin';
  }
  
  // Admin can write all data for their center
  match /{document=**} {
    allow write: if request.auth.token.role == 'admin' && request.auth.token.centerId == resource.data.centerId;
  }
}
```

---

## Summary

The EduTrack Firestore schema is designed with the following principles:

1. **Clarity:** Simple, hierarchical structure easy for developers to understand
2. **Performance:** Strategic denormalization and indexing for fast queries
3. **Scalability:** Subcollections and time-series partitioning for growth
4. **Flexibility:** Easy to add features without major restructuring
5. **Real-time:** Supports live updates for attendance and grades
6. **Offline-first:** Cached data helps mobile app work offline

This schema can support 1000+ students, 100k+ monthly attendance records, and complex reporting requirements while maintaining optimal query performance.

