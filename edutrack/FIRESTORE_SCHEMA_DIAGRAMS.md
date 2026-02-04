# EduTrack Firestore Schema - Visual Diagrams

## Interactive Entity Relationship Diagram

```mermaid
graph TB
    subgraph Collections["Top-Level Collections"]
        CC["🏢 coachingCenters"]
        U["👥 users"]
        S["📚 students"]
        C["📖 courses"]
        A["✅ attendance"]
        P["📊 progress"]
        CR["🏛️ classRooms"]
    end
    
    subgraph StudentSubs["Student Subcollections"]
        E["📝 enrollments"]
    end
    
    subgraph CourseSubs["Course Subcollections"]
        SC["📅 schedule"]
        CA["📋 assignments"]
    end
    
    subgraph ClassSubs["ClassRoom Subcollections"]
        CSS["🕐 classSchedules"]
    end
    
    subgraph CenterSubs["Center Subcollections"]
        CCS["📈 stats"]
    end
    
    S -->|contains| E
    C -->|contains| SC
    C -->|contains| CA
    CC -->|contains| CCS
    CR -->|contains| CSS
    
    U -.->|belongs to| CC
    S -.->|belongs to| CC
    C -.->|belongs to| CC
    A -.->|tracks| S
    A -.->|tracks| C
    P -.->|grades| S
    P -.->|for| C
    CR -.->|hosts| C
    E -.->|links to| C
    
    style CC fill:#FFE5CC
    style U fill:#CCE5FF
    style S fill:#E5CCFF
    style C fill:#CCFFE5
    style A fill:#FFCCCC
    style P fill:#FFFFCC
    style CR fill:#FFCCFF
    style E fill:#E5F2FF
    style SC fill:#E5F2FF
    style CA fill:#E5F2FF
    style CCS fill:#E5F2FF
    style CCS fill:#E5F2FF
    style StudentSubs fill:#F0F8FF
    style CourseSubs fill:#F0F8FF
    style ClassSubs fill:#F0F8FF
    style CenterSubs fill:#F0F8FF
```

---

## Detailed Collection Hierarchy

### 1. CoachingCenters Collection Tree

```
coachingCenters/
├── centerId: "center_001"
│   ├── name: "Sharma Coaching Center"
│   ├── address: "123 Main St, Jaipur"
│   ├── adminUserId: "user_001"
│   ├── totalStudents: 45
│   ├── activeCourses: 8
│   ├── createdAt: timestamp
│   └── stats/ (Subcollection)
│       ├── 2024-02-03
│       │   ├── totalAttendance: 40
│       │   ├── totalAbsent: 5
│       │   └── averageAttendance: 88.9%
│       ├── 2024-02-02
│       │   └── (previous day stats)
│       └── ...
│
└── centerId: "center_002"
    ├── name: "Kumar Institute"
    └── (same structure)
```

### 2. Users Collection Tree

```
users/
├── userId: "user_teacher_001"
│   ├── email: "rajesh.kumar@gmail.com"
│   ├── displayName: "Rajesh Kumar"
│   ├── role: "teacher"
│   ├── centerId: "center_001"
│   ├── departmentAssigned: "Mathematics"
│   ├── isActive: true
│   ├── createdAt: timestamp
│   └── lastLogin: timestamp
│
├── userId: "user_admin_001"
│   ├── email: "admin@center.com"
│   ├── displayName: "Admin User"
│   ├── role: "admin"
│   ├── centerId: "center_001"
│   └── (other fields)
│
└── userId: "user_coord_001"
    ├── role: "coordinator"
    └── (other fields)
```

### 3. Students Collection Tree (Complex)

```
students/
├── studentId: "stu_001"
│   ├── rollNumber: "STU-2024-001"
│   ├── firstName: "Asha"
│   ├── lastName: "Sharma"
│   ├── email: "asha@example.com"
│   ├── gender: "F"
│   ├── centerId: "center_001"
│   ├── enrollmentStatus: "active"
│   ├── joiningDate: timestamp
│   ├── totalAttendancePercentage: 92.5
│   ├── averageScore: 87.3
│   ├── createdAt: timestamp
│   └── enrollments/ (Subcollection)
│       ├── enrollmentId: "enroll_001"
│       │   ├── courseId: "course_math_001"
│       │   ├── courseName: "Mathematics - Class 10"
│       │   ├── status: "active"
│       │   ├── currentGrade: "A"
│       │   ├── scorePercentage: 87.3
│       │   └── attendancePercentage: 92.5
│       │
│       ├── enrollmentId: "enroll_002"
│       │   ├── courseId: "course_physics_001"
│       │   ├── courseName: "Physics - Class 10"
│       │   ├── status: "active"
│       │   ├── currentGrade: "B"
│       │   └── scorePercentage: 82.1
│       │
│       └── enrollmentId: "enroll_003"
│           └── (more courses)
│
├── studentId: "stu_002"
│   ├── firstName: "Rajesh"
│   └── enrollments/
│       └── (multiple courses)
│
└── (more students with their enrollments)
```

### 4. Courses Collection Tree

```
courses/
├── courseId: "course_math_001"
│   ├── name: "Mathematics - Class 10"
│   ├── subject: "Mathematics"
│   ├── instructorId: "user_teacher_001"
│   ├── level: "Class 10"
│   ├── capacity: 30
│   ├── enrolledCount: 24
│   ├── startDate: timestamp
│   ├── endDate: timestamp
│   ├── createdAt: timestamp
│   ├── schedule/ (Subcollection - Class Sessions)
│   │   ├── class_001
│   │   │   ├── classDate: 2024-02-03
│   │   │   ├── startTime: 09:00 AM
│   │   │   ├── endTime: 10:30 AM
│   │   │   ├── room: "Room A-101"
│   │   │   ├── topic: "Linear Equations"
│   │   │   └── isCompleted: true
│   │   │
│   │   ├── class_002
│   │   │   ├── classDate: 2024-02-04
│   │   │   ├── startTime: 09:00 AM
│   │   │   └── (other fields)
│   │   │
│   │   └── (more classes)
│   │
│   └── assignments/ (Subcollection)
│       ├── assign_001
│       │   ├── title: "Algebra Problem Set 1"
│       │   ├── dueDate: 2024-02-10
│       │   ├── type: "homework"
│       │   ├── totalMarks: 50
│       │   └── submissionCount: 18
│       │
│       ├── assign_002
│       │   ├── title: "Geometry Project"
│       │   ├── type: "project"
│       │   └── (other fields)
│       │
│       └── (more assignments)
│
├── courseId: "course_physics_001"
│   ├── name: "Physics - Class 10"
│   └── (similar structure)
│
└── (more courses)
```

### 5. Attendance Collection Tree (Time-Series)

```
attendance/
├── attendanceId: "att_001"
│   ├── studentId: "stu_001"
│   ├── studentName: "Asha Sharma"
│   ├── courseId: "course_math_001"
│   ├── courseName: "Mathematics - Class 10"
│   ├── centerId: "center_001"
│   ├── classDate: 2024-02-03 (DATE)
│   ├── status: "present"
│   ├── markedBy: "user_teacher_001"
│   ├── markedAt: 2024-02-03 09:05 AM
│   └── remarks: null
│
├── attendanceId: "att_002"
│   ├── studentId: "stu_002"
│   ├── studentName: "Rajesh Kumar"
│   ├── courseId: "course_math_001"
│   ├── classDate: 2024-02-03
│   ├── status: "absent"
│   └── remarks: "Medical appointment"
│
├── attendanceId: "att_003"
│   ├── studentId: "stu_001"
│   ├── courseId: "course_physics_001"
│   ├── classDate: 2024-02-03
│   ├── status: "late"
│   └── (other fields)
│
├── attendanceId: "att_004"
│   ├── studentId: "stu_001"
│   ├── courseId: "course_math_001"
│   ├── classDate: 2024-02-02
│   ├── status: "present"
│   └── (previous day)
│
└── (100,000s+ more records organized by date)
```

### 6. Progress Collection Tree (Grades & Scores)

```
progress/
├── progressId: "prog_001"
│   ├── studentId: "stu_001"
│   ├── studentName: "Asha Sharma"
│   ├── courseId: "course_math_001"
│   ├── courseName: "Mathematics - Class 10"
│   ├── assessmentType: "unit_test"
│   ├── assessmentTitle: "Unit Test 1 - Algebra"
│   ├── totalMarks: 100
│   ├── obtainedMarks: 87
│   ├── scorePercentage: 87.0
│   ├── grade: "A"
│   ├── comments: "Excellent work"
│   ├── evaluatedBy: "user_teacher_001"
│   ├── evaluatedAt: 2024-01-25
│   └── isPublished: true
│
├── progressId: "prog_002"
│   ├── studentId: "stu_001"
│   ├── courseId: "course_math_001"
│   ├── assessmentType: "monthly_exam"
│   ├── assessmentTitle: "January Monthly Exam"
│   ├── totalMarks: 100
│   ├── obtainedMarks: 85
│   └── (other fields)
│
├── progressId: "prog_003"
│   ├── studentId: "stu_002"
│   ├── courseId: "course_math_001"
│   ├── assessmentType: "unit_test"
│   └── (other fields)
│
└── (1000s+ records per semester)
```

### 7. ClassRooms Collection Tree

```
classRooms/
├── classRoomId: "room_001"
│   ├── name: "Room A-101"
│   ├── capacity: 40
│   ├── location: "Building A, Floor 1"
│   ├── centerId: "center_001"
│   ├── resources: ["projector", "whiteboard", "AC"]
│   ├── isActive: true
│   └── classSchedules/ (Subcollection)
│       ├── schedule_001
│       │   ├── courseId: "course_math_001"
│       │   ├── dayOfWeek: "Monday"
│       │   ├── startTime: 09:00 AM
│       │   ├── endTime: 10:30 AM
│       │   └── isActive: true
│       │
│       ├── schedule_002
│       │   ├── courseId: "course_math_001"
│       │   ├── dayOfWeek: "Wednesday"
│       │   └── (other times)
│       │
│       └── (more schedules)
│
├── classRoomId: "room_002"
│   ├── name: "Room B-201"
│   └── (similar structure)
│
└── (more rooms)
```

---

## Data Flow Diagram

```mermaid
graph LR
    App["📱 Flutter App"]
    Auth["🔐 Firebase Auth"]
    Firestore["🗄️ Cloud Firestore"]
    
    App -->|Login| Auth
    Auth -->|User Verified| App
    App -->|Create/Update Data| Firestore
    Firestore -->|Real-time Updates| App
    
    subgraph "Firestore Collections"
        Users["users/"]
        Students["students/"]
        Courses["courses/"]
        Attendance["attendance/"]
        Progress["progress/"]
    end
    
    Firestore --> Users
    Firestore --> Students
    Firestore --> Courses
    Firestore --> Attendance
    Firestore --> Progress
    
    Users -->|Belongs to| CenterDB["CoachingCenter"]
    Students -->|Enrolled in| Courses
    Students -->|Has| Attendance
    Students -->|Has| Progress
    Courses -->|Contains| Attendance
    Courses -->|Contains| Progress
```

---

## Collection Query Patterns

```mermaid
graph TB
    Q1["Query: Get All Students"] --> S1["students/"]
    Q2["Query: Get Student's Courses"] --> S2["students/{id}/enrollments/"]
    Q3["Query: Get Today's Attendance"] --> S3["attendance/ WHERE classDate = today"]
    Q4["Query: Get Course Schedule"] --> S4["courses/{id}/schedule/"]
    Q5["Query: Get Student Grades"] --> S5["progress/ WHERE studentId = X"]
    Q6["Query: Get Class Assignments"] --> S6["courses/{id}/assignments/"]
    
    style Q1 fill:#CCE5FF
    style Q2 fill:#CCE5FF
    style Q3 fill:#FFCCCC
    style Q4 fill:#CCFFE5
    style Q5 fill:#FFFFCC
    style Q6 fill:#E5CCFF
```

---

## Write Operations Diagram

```mermaid
graph LR
    TEA["👨‍🏫 Teacher"]
    APP["📱 App"]
    DB["🗄️ Firestore"]
    
    TEA -->|Mark Attendance| APP
    APP -->|Write attendance doc| DB
    
    TEA -->|Enter Grade| APP
    APP -->|Write progress doc| DB
    
    TEA -->|Update Course| APP
    APP -->|Update courses/{id}| DB
    
    ADM["👨‍💼 Admin"]
    ADM -->|Create Student| APP
    APP -->|Create students/{id}| DB
    
    style TEA fill:#FFE5CC
    style ADM fill:#E5CCFF
    style APP fill:#CCE5FF
    style DB fill:#FFFFCC
```

---

## Indexing Strategy

```mermaid
graph TB
    subgraph "Composite Indexes (Required for Queries)"
        I1["(studentId, classDate DESC)"]
        I2["(courseId, classDate DESC)"]
        I3["(centerId, classDate DESC)"]
        I4["(studentId, courseId, classDate DESC)"]
    end
    
    subgraph "Single Field Indexes"
        S1["centerId"]
        S2["studentId"]
        S3["courseId"]
        S4["enrollmentStatus"]
    end
    
    A["Attendance Collection"]
    P["Progress Collection"]
    S["Students Collection"]
    C["Courses Collection"]
    
    I1 -->|For attendance queries| A
    I2 -->|For course attendance| A
    I3 -->|For center reports| A
    I4 -->|For detailed attendance| A
    
    S1 -->|Filter by center| S
    S2 -->|Find student data| S
    S3 -->|Filter by course| C
    S4 -->|Active students| S
```

---

## Scaling Growth Model

```mermaid
graph LR
    T0["Start:<br/>1 Center<br/>50 Students<br/>5 Courses"]
    T1["3 Months:<br/>2 Centers<br/>200 Students<br/>15 Courses"]
    T2["1 Year:<br/>5 Centers<br/>500 Students<br/>40 Courses"]
    T3["2 Years:<br/>10 Centers<br/>1000+ Students<br/>100+ Courses"]
    
    T0 -->|Add center| T1
    T1 -->|Expand| T2
    T2 -->|Scale| T3
    
    style T0 fill:#CCFFCC
    style T1 fill:#FFFFCC
    style T2 fill:#FFCCCC
    style T3 fill:#FFCCCC
```

---

## Denormalization Strategy

```mermaid
graph TB
    subgraph "Normalized Location"
        Norm["students/{id}<br/>name: 'Asha'"]
    end
    
    subgraph "Denormalized Copies"
        Den1["attendance/{id}<br/>studentName: 'Asha'"]
        Den2["progress/{id}<br/>studentName: 'Asha'"]
    end
    
    subgraph "Purpose"
        P1["Avoid loading student doc<br/>when reading attendance"]
        P2["Offline support<br/>in mobile app"]
        P3["Faster report generation"]
    end
    
    Norm -.->|Cached in| Den1
    Norm -.->|Cached in| Den2
    Den1 -.-> P1
    Den2 -.-> P2
    Den1 -.-> P3
    
    style Norm fill:#E5FFCC
    style Den1 fill:#CCFFFF
    style Den2 fill:#CCFFFF
```

---

## Storage Estimation for 1 Year

| Collection | Records | Avg Doc Size | Storage |
|------------|---------|--------------|---------|
| coachingCenters | 5 | 1 KB | 5 KB |
| users | 50 | 2 KB | 100 KB |
| students | 500 | 5 KB | 2.5 MB |
| courses | 40 | 3 KB | 120 KB |
| enrollments (subcollection) | 2,500 | 1 KB | 2.5 MB |
| attendance | 270,000 | 0.8 KB | 216 MB |
| progress | 15,000 | 1.5 KB | 22.5 MB |
| classRooms | 20 | 2 KB | 40 KB |

**Total Est. Storage: ~246 MB for 1 center with 500 students over 1 year**

*(Firestore provides 1 GB free storage/month, so well within limits)*

---

## Next Steps for Implementation

1. ✅ **Schema Design** (This document)
2. 📋 **Security Rules** - Define Firebase Security Rules
3. 🔧 **CRUD Operations** - Implement Create, Read, Update, Delete functions
4. 🏗️ **Data Models** - Create Dart classes for type safety
5. 🎨 **UI Integration** - Connect widgets to Firestore
6. 📊 **Real-time Listeners** - Setup StreamBuilders for live updates
7. 🧪 **Testing** - Unit and integration tests

