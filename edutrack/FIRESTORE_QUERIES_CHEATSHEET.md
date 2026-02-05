# Firestore Queries Quick Reference Cheat Sheet

## 🔍 Basic Query Structure

```dart
FirebaseFirestore.instance
  .collection('collectionName')
  .where('field', operator, value)
  .orderBy('field', descending: true)
  .limit(count)
  .snapshots();  // Real-time OR .get() for one-time
```

---

## 📋 Filter Operators

### Equality
| Operator | Dart | Example |
|----------|------|---------|
| Equal | `isEqualTo` | `.where('status', isEqualTo: 'active')` |
| Not Equal | `isNotEqualTo` | `.where('status', isNotEqualTo: 'deleted')` |

### Comparison
| Operator | Dart | Example |
|----------|------|---------|
| Greater Than | `isGreaterThan` | `.where('age', isGreaterThan: 18)` |
| Greater or Equal | `isGreaterThanOrEqualTo` | `.where('score', isGreaterThanOrEqualTo: 70)` |
| Less Than | `isLessThan` | `.where('price', isLessThan: 100)` |
| Less or Equal | `isLessThanOrEqualTo` | `.where('quantity', isLessThanOrEqualTo: 10)` |

### Arrays
| Operator | Dart | Example |
|----------|------|---------|
| Contains | `arrayContains` | `.where('tags', arrayContains: 'featured')` |
| Contains Any | `arrayContainsAny` | `.where('tags', arrayContainsAny: ['new', 'sale'])` |

### IN Queries
| Operator | Dart | Example |
|----------|------|---------|
| In | `whereIn` | `.where('status', whereIn: ['pending', 'approved'])` |
| Not In | `whereNotIn` | `.where('category', whereNotIn: ['spam', 'deleted'])` |

---

## 📊 Ordering

```dart
// Ascending (default)
.orderBy('createdAt')

// Descending
.orderBy('priority', descending: true)

// Multiple fields
.orderBy('status')
.orderBy('createdAt', descending: true)
```

---

## 🔢 Limiting

```dart
// First N results
.limit(10)

// Start after document (pagination)
.startAfterDocument(lastDoc)

// Start at specific value
.startAt([value])

// End before value
.endBefore([value])
```

---

## 🎯 Common Query Patterns

### Pattern 1: Get Active Items
```dart
.where('isActive', isEqualTo: true)
.orderBy('createdAt', descending: true)
.limit(20)
```

### Pattern 2: Get Range
```dart
.where('price', isGreaterThanOrEqualTo: 10)
.where('price', isLessThanOrEqualTo: 100)
.orderBy('price')
```

### Pattern 3: Get Tagged Items
```dart
.where('tags', arrayContains: 'urgent')
.orderBy('priority', descending: true)
```

### Pattern 4: Get Recent Items
```dart
.orderBy('timestamp', descending: true)
.limit(10)
```

### Pattern 5: Pagination
```dart
// First page
.orderBy('createdAt')
.limit(10)

// Next page
.orderBy('createdAt')
.startAfterDocument(lastDocument)
.limit(10)
```

---

## 🏗️ StreamBuilder Template

```dart
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
    .collection('items')
    .where('isActive', isEqualTo: true)
    .orderBy('createdAt', descending: true)
    .snapshots(),
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
    final docs = snapshot.data!.docs;
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final data = docs[index].data() as Map<String, dynamic>;
        return ListTile(
          title: Text(data['title']),
        );
      },
    );
  },
)
```

---

## 📦 FutureBuilder Template

```dart
FutureBuilder<QuerySnapshot>(
  future: FirebaseFirestore.instance
    .collection('items')
    .orderBy('createdAt', descending: true)
    .limit(20)
    .get(),  // One-time fetch
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Text('No data');
    }
    
    final docs = snapshot.data!.docs;
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final data = docs[index].data() as Map<String, dynamic>;
        return ListTile(title: Text(data['title']));
      },
    );
  },
)
```

---

## ⚠️ Query Limitations

| Limitation | Details |
|------------|---------|
| **Multiple inequalities** | Only ONE inequality filter allowed per query |
| **orderBy + where** | Requires composite index if on different fields |
| **IN/NOT IN limit** | Max 10 values in array |
| **arrayContainsAny limit** | Max 10 values in array |
| **Document size** | Max 1 MB per document |
| **Query result size** | No hard limit, but affects performance |

---

## 🔑 Index Requirements

### Single Field Index (Automatic)
```dart
.where('status', isEqualTo: 'active')
```

### Composite Index (Manual)
```dart
// Requires index creation
.where('status', isEqualTo: 'active')
.orderBy('createdAt', descending: true)
```

**How to Create:**
1. Firebase Console → Firestore → Indexes
2. Click "Create Index"
3. Add fields and directions
4. Or click the link in error message

---

## 💾 Data Access Methods

### Real-time (Stream)
```dart
.snapshots()  // Live updates
```

### One-time (Future)
```dart
.get()  // Single fetch
```

### Single Document
```dart
// Real-time
.doc('docId').snapshots()

// One-time
.doc('docId').get()
```

---

## 🚀 Performance Tips

1. ✅ **Always use indexes** for queried fields
2. ✅ **Limit results** - don't fetch more than needed
3. ✅ **Use `.get()`** for static data
4. ✅ **Use `.snapshots()`** for live data
5. ✅ **Paginate** large datasets
6. ✅ **Cache** on client when possible
7. ✅ **Denormalize** for complex queries
8. ❌ **Avoid** client-side filtering
9. ❌ **Avoid** deeply nested data
10. ❌ **Avoid** fetching entire collections

---

## 🔧 Common Errors

### Error: Requires Index
```
The query requires an index. You can create it here: [link]
```
**Fix:** Click link or create index manually

### Error: Multiple Inequalities
```
Cannot have multiple inequality filters on different fields
```
**Fix:** Use single inequality OR restructure query

### Error: orderBy Mismatch
```
To use orderBy on field X, you must also use where on X
```
**Fix:** Ensure where and orderBy use same field OR create index

---

## 📝 Quick Examples

### Example 1: User's Tasks
```dart
FirebaseFirestore.instance
  .collection('tasks')
  .where('userId', isEqualTo: currentUserId)
  .where('isCompleted', isEqualTo: false)
  .orderBy('dueDate')
  .snapshots()
```

### Example 2: Top Products
```dart
FirebaseFirestore.instance
  .collection('products')
  .where('inStock', isEqualTo: true)
  .where('rating', isGreaterThanOrEqualTo: 4.0)
  .orderBy('rating', descending: true)
  .limit(10)
  .snapshots()
```

### Example 3: Recent Posts
```dart
FirebaseFirestore.instance
  .collection('posts')
  .where('isPublished', isEqualTo: true)
  .orderBy('publishedAt', descending: true)
  .limit(20)
  .snapshots()
```

### Example 4: Search by Tags
```dart
FirebaseFirestore.instance
  .collection('articles')
  .where('tags', arrayContainsAny: ['flutter', 'firebase', 'mobile'])
  .orderBy('views', descending: true)
  .limit(15)
  .snapshots()
```

---

## 🎯 Decision Tree

**Need real-time updates?**
- Yes → Use `.snapshots()` with `StreamBuilder`
- No → Use `.get()` with `FutureBuilder`

**Need to filter data?**
- Yes → Use `.where()`
- No → Just use `.orderBy()`

**Need to sort?**
- Yes → Use `.orderBy()`
- No → Data in document order

**Large dataset?**
- Yes → Use `.limit()` and pagination
- No → Fetch all

**Multiple conditions?**
- Same field → Can combine
- Different fields → May need composite index

---

## 📚 Learn More

- [Official Firestore Docs](https://firebase.google.com/docs/firestore)
- [Query Data](https://firebase.google.com/docs/firestore/query-data/queries)
- [Indexing](https://firebase.google.com/docs/firestore/query-data/indexing)

---

*Print this for quick reference during development!*
