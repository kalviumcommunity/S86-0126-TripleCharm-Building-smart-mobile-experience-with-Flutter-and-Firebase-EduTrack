# Firestore Queries, Filters, and Ordering Guide

## Overview

This guide demonstrates how to efficiently retrieve data from Firestore using queries, filters, ordering, and pagination. These techniques help you build fast, responsive mobile applications by fetching only the data you need.

## 📦 Dependencies

Ensure your `pubspec.yaml` includes:

```yaml
dependencies:
  cloud_firestore: ^5.4.4
  firebase_core: ^3.6.0
```

Install dependencies:
```bash
flutter pub get
```

## 🎯 What You'll Learn

- ✅ Run Firestore queries with conditions
- ✅ Filter records using `where` clauses
- ✅ Sort data using `orderBy`
- ✅ Limit results for performance
- ✅ Display results with StreamBuilder and FutureBuilder
- ✅ Implement pagination
- ✅ Handle composite indexes

---

## 📚 Query Types Implemented

### 1. Basic Queries

#### Get All Documents
```dart
FirebaseFirestore.instance
  .collection('tasks')
  .snapshots();
```

#### Get Ordered Documents
```dart
FirebaseFirestore.instance
  .collection('tasks')
  .orderBy('createdAt', descending: true)
  .snapshots();
```

### 2. Equality Filters (`where`)

#### Simple Equality
```dart
// Get completed tasks
FirebaseFirestore.instance
  .collection('tasks')
  .where('isCompleted', isEqualTo: true)
  .snapshots();
```

#### Not Equal
```dart
// Get non-archived tasks
FirebaseFirestore.instance
  .collection('tasks')
  .where('status', isNotEqualTo: 'archived')
  .snapshots();
```

### 3. Comparison Filters

#### Greater Than
```dart
// Get high-priority tasks (priority > 7)
FirebaseFirestore.instance
  .collection('tasks')
  .where('priority', isGreaterThan: 7)
  .orderBy('priority', descending: true)
  .snapshots();
```

#### Greater Than or Equal To
```dart
// Get medium to high priority (>= 5)
FirebaseFirestore.instance
  .collection('tasks')
  .where('priority', isGreaterThanOrEqualTo: 5)
  .orderBy('priority')
  .snapshots();
```

#### Less Than / Less Than or Equal To
```dart
// Get tasks before a date
FirebaseFirestore.instance
  .collection('tasks')
  .where('createdAt', isLessThan: Timestamp.fromDate(date))
  .orderBy('createdAt')
  .snapshots();
```

#### Range Query (Between)
```dart
// Get tasks with priority between 5 and 8
FirebaseFirestore.instance
  .collection('tasks')
  .where('priority', isGreaterThanOrEqualTo: 5)
  .where('priority', isLessThanOrEqualTo: 8)
  .orderBy('priority')
  .snapshots();
```

### 4. Array Filters

#### Array Contains
```dart
// Get tasks tagged with "urgent"
FirebaseFirestore.instance
  .collection('tasks')
  .where('tags', arrayContains: 'urgent')
  .snapshots();
```

#### Array Contains Any
```dart
// Get tasks with any of these tags
FirebaseFirestore.instance
  .collection('tasks')
  .where('tags', arrayContainsAny: ['urgent', 'important', 'critical'])
  .snapshots();
```

### 5. IN / NOT IN Filters

#### IN Filter
```dart
// Get tasks with specific statuses
FirebaseFirestore.instance
  .collection('tasks')
  .where('status', whereIn: ['pending', 'in-progress', 'review'])
  .snapshots();
```

#### NOT IN Filter
```dart
// Exclude specific categories
FirebaseFirestore.instance
  .collection('tasks')
  .where('category', whereNotIn: ['archived', 'deleted'])
  .snapshots();
```

### 6. Ordering Data

#### Single Field Ordering
```dart
// Ascending (default)
.orderBy('createdAt')

// Descending
.orderBy('priority', descending: true)
```

#### Multiple Field Ordering
```dart
// Sort by completion status first, then by priority
FirebaseFirestore.instance
  .collection('tasks')
  .orderBy('isCompleted')
  .orderBy('priority', descending: true)
  .snapshots();
```

### 7. Limiting Results

```dart
// Get top 10 results
FirebaseFirestore.instance
  .collection('tasks')
  .orderBy('priority', descending: true)
  .limit(10)
  .snapshots();
```

### 8. Pagination

#### Using `startAfter` with Document
```dart
Query query = FirebaseFirestore.instance
  .collection('tasks')
  .orderBy('createdAt', descending: true)
  .limit(10);

if (lastDocument != null) {
  query = query.startAfterDocument(lastDocument);
}

final snapshot = await query.get();
```

#### Using `startAt` with Field Value
```dart
FirebaseFirestore.instance
  .collection('tasks')
  .orderBy('createdAt', descending: true)
  .startAt([specificTimestamp])
  .limit(10)
  .snapshots();
```

---

## 🎨 Displaying Results in UI

### Using StreamBuilder (Real-time Updates)

```dart
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
    .collection('tasks')
    .where('isCompleted', isEqualTo: false)
    .orderBy('priority', descending: true)
    .limit(10)
    .snapshots(),
  builder: (context, snapshot) {
    // Handle loading
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }

    // Handle error
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }

    // Handle empty
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Text('No tasks found');
    }

    // Display data
    final tasks = snapshot.data!.docs;

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index].data() as Map<String, dynamic>;
        return ListTile(
          title: Text(task['title']),
          subtitle: Text('Priority: ${task['priority']}'),
          trailing: Icon(
            task['isCompleted'] ? Icons.check_circle : Icons.radio_button_unchecked,
          ),
        );
      },
    );
  },
);
```

### Using FutureBuilder (One-time Load)

```dart
FutureBuilder<QuerySnapshot>(
  future: FirebaseFirestore.instance
    .collection('tasks')
    .orderBy('createdAt', descending: true)
    .limit(20)
    .get(),  // .get() returns a Future
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }

    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Text('No tasks found');
    }

    final tasks = snapshot.data!.docs;

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index].data() as Map<String, dynamic>;
        return ListTile(
          title: Text(task['title']),
        );
      },
    );
  },
);
```

---

## ⚠️ Common Mistakes to Avoid

### 1. Using `orderBy` Without Index

**Problem:**
```dart
// May require index
.where('status', isEqualTo: 'active')
.orderBy('createdAt')
```

**Solution:**
- Firestore will prompt you to create an index
- Click the link in the error message to auto-generate the index
- Or create manually in Firebase Console

### 2. Ordering by Different Field Than Filter

**Problem:**
```dart
// Requires composite index
.where('isCompleted', isEqualTo: false)
.orderBy('priority')  // Different field!
```

**Solution:**
- Create a composite index in Firestore
- Firebase Console → Firestore → Indexes → Create Index

### 3. Multiple Inequality Filters on Different Fields

**Problem:**
```dart
// NOT ALLOWED
.where('priority', isGreaterThan: 5)
.where('createdAt', isGreaterThan: timestamp)
```

**Solution:**
- Only one inequality filter allowed
- Use range queries on the same field instead

### 4. Querying Unindexed Fields

**Problem:**
- Slow query performance
- Potential timeout errors

**Solution:**
- Always index fields used in queries
- Monitor query performance in Firebase Console

### 5. Using Too Many Filters

**Problem:**
- Firestore is not SQL
- Complex queries may require restructuring

**Solution:**
- Keep queries simple
- Use composite indexes
- Consider denormalizing data

---

## 📊 Query Performance Best Practices

### ✅ DO

1. **Always index queried fields**
   ```dart
   // Create index for this combination
   .where('userId', isEqualTo: currentUserId)
   .orderBy('createdAt', descending: true)
   ```

2. **Use timestamps for sorting**
   ```dart
   .orderBy('createdAt', descending: true)
   ```

3. **Limit results**
   ```dart
   .limit(20)  // Don't fetch more than needed
   ```

4. **Use StreamBuilder for real-time data**
   ```dart
   stream: collection.snapshots()  // Live updates
   ```

5. **Use FutureBuilder for one-time loads**
   ```dart
   future: collection.get()  // One-time fetch
   ```

6. **Keep field names consistent**
   ```dart
   // All documents should have same field structure
   {
     'title': 'Task',
     'priority': 5,
     'createdAt': Timestamp.now()
   }
   ```

### ❌ DON'T

1. **Don't fetch entire collections**
   ```dart
   // Bad: Fetches everything
   .collection('tasks').snapshots()
   
   // Good: Limited and filtered
   .collection('tasks').where(...).limit(10).snapshots()
   ```

2. **Don't use deeply nested queries**
   ```dart
   // Difficult to query
   'user.profile.settings.theme'
   ```

3. **Don't ignore index warnings**
   - Always create required indexes

4. **Don't use client-side filtering**
   ```dart
   // Bad: Fetching all then filtering
   snapshot.data!.docs.where((doc) => doc['priority'] > 5)
   
   // Good: Server-side filtering
   .where('priority', isGreaterThan: 5)
   ```

---

## 🔥 Interactive Demo Screen

The project includes a fully functional demo screen at:
📄 `lib/screens/firestore_queries_demo.dart`

### Features:
- ✅ Interactive query selector
- ✅ Real-time result updates
- ✅ Sample data generator
- ✅ Visual result display
- ✅ Sorting controls
- ✅ Limit adjustment
- ✅ Error handling

### How to Run:
```dart
// Add to your navigation
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const FirestoreQueriesDemo(),
  ),
);
```

---

## 📁 Code Organization

```
lib/
├── screens/
│   └── firestore_queries_demo.dart      # Interactive demo UI
└── examples/
    └── firestore_query_examples.dart    # Query pattern library
```

---

## 🧪 Testing Your Queries

### 1. Add Sample Data
Use the demo screen's "Add Sample Data" button to populate Firestore with test data.

### 2. Test Different Query Types
- All Tasks
- Active Tasks (where filter)
- Completed Tasks
- High Priority (comparison filter)
- Tagged "urgent" (array filter)
- Recent (ordered by date)

### 3. Verify Results
- Check document count matches query criteria
- Verify sorting order
- Confirm filters work correctly

### 4. Monitor Performance
- Firebase Console → Firestore → Usage
- Check read counts
- Monitor query performance

---

## 🎓 Learning Outcomes

After completing this lesson, you should understand:

✅ **Query Structure**
- How to construct Firestore queries
- Difference between `.get()` and `.snapshots()`

✅ **Filtering**
- Equality filters (`isEqualTo`, `isNotEqualTo`)
- Comparison filters (`isGreaterThan`, `isLessThan`, etc.)
- Array filters (`arrayContains`, `arrayContainsAny`)
- IN/NOT IN filters

✅ **Ordering**
- Single field ordering
- Multiple field ordering
- Ascending vs descending

✅ **Performance**
- Why limiting is important
- When to use indexes
- StreamBuilder vs FutureBuilder

✅ **Best Practices**
- Index management
- Query optimization
- Error handling

---

## 💡 Reflection Questions

1. **Which query types did you implement?**
   - [ ] Equality filters
   - [ ] Comparison filters
   - [ ] Array filters
   - [ ] Ordering
   - [ ] Limiting
   - [ ] Pagination

2. **Why does sorting/filtering improve UX?**
   - Faster load times (less data transferred)
   - More relevant results
   - Better user experience
   - Reduced bandwidth costs

3. **Did you encounter any index errors?**
   - Document the error message
   - Explain how you created the index
   - Show before/after query performance

4. **What's the difference between StreamBuilder and FutureBuilder?**
   - StreamBuilder: Real-time updates, live connection
   - FutureBuilder: One-time load, static data

5. **When would you use pagination?**
   - Large datasets
   - Infinite scroll lists
   - Performance optimization
   - Bandwidth conservation

---

## 📸 Screenshots

### Firestore Console - Sample Data
![Firestore Console](screenshots/firestore_console.png)
*Screenshot showing tasks collection with various fields*

### Demo App - Query Interface
![Query Interface](screenshots/query_interface.png)
*Interactive query selector with options*

### Demo App - Filtered Results
![Filtered Results](screenshots/filtered_results.png)
*ListView showing filtered and sorted tasks*

### Demo App - High Priority Tasks
![High Priority](screenshots/high_priority.png)
*Results showing only tasks with priority >= 7*

---

## 🔗 Additional Resources

- [Firestore Queries Documentation](https://firebase.google.com/docs/firestore/query-data/queries)
- [Firestore Indexes](https://firebase.google.com/docs/firestore/query-data/indexing)
- [Flutter StreamBuilder](https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html)
- [Flutter FutureBuilder](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html)

---

## 🚀 Next Steps

1. ✅ Implement custom queries for your app
2. ✅ Create composite indexes as needed
3. ✅ Monitor query performance
4. ✅ Optimize data structure for queries
5. ✅ Implement pagination for large datasets

---

## 📝 Summary

This lesson covered:
- **Queries**: Basic structure and syntax
- **Filters**: where, comparison, array operations
- **Ordering**: Single and multiple field sorting
- **Limiting**: Performance optimization
- **Display**: StreamBuilder and FutureBuilder
- **Pagination**: Efficient data loading
- **Indexing**: Performance and error handling

**Key Takeaway**: Efficient queries are essential for building fast, scalable mobile applications. Always filter, sort, and limit data at the server level for optimal performance.

---

## 📧 Support

For questions or issues:
- Check Firebase Console for index errors
- Review Firestore documentation
- Test queries in Firebase Console first
- Use the demo screen to experiment

---

*Last Updated: February 5, 2026*
*Flutter Version: 3.10.7*
*Firestore Version: 5.4.4*
