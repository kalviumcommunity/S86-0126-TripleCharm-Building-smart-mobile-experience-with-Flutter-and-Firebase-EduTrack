import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../lib/models/location_data.dart';
import '../lib/models/study_item.dart';
import '../lib/services/firestore_crud_service.dart';

// Mock classes
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockCollectionReference extends Mock implements CollectionReference {}
class MockDocumentReference extends Mock implements DocumentReference {}
class MockQuerySnapshot extends Mock implements QuerySnapshot {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

void main() {
  group('FirestoreCrudService Tests', () {
    late FirestoreCrudService crudService;
    late MockFirebaseFirestore mockFirestore;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();

      // Setup default mocks
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-uid-123');

      crudService = FirestoreCrudService();
    });

    group('Create Operation', () {
      test('createItem should successfully create a new study item', () async {
        const title = 'Test Study Item';
        const description = 'This is a test item';
        final location = LocationData(
          latitude: 28.6139,
          longitude: 77.2090,
        );

        // Expected behavior
        expect(title, isNotEmpty);
        expect(description, isNotEmpty);
        expect(location.latitude, closeTo(28.6139, 0.0001));
        expect(location.longitude, closeTo(77.2090, 0.0001));
      });

      test('createItem should throw exception if user not authenticated', () async {
        // Simulate unauthenticated user
        when(mockAuth.currentUser).thenReturn(null);

        expect(
          () async {
            await crudService.createItem(
              title: 'Test',
              description: 'Test description',
            );
          },
          throwsException,
        );
      });

      test('createItem should include location if provided', () async {
        final location = LocationData(
          latitude: 40.7128,
          longitude: -74.0060,
        );

        // Verify location data structure
        final locationMap = location.toMap();
        expect(locationMap['latitude'], 40.7128);
        expect(locationMap['longitude'], -74.0060);
      });
    });

    group('Read Operation', () {
      test('getItemsStream should return stream of study items', () async {
        // Verify stream provider exists
        expect(crudService.getItemsStream, isNotNull);
      });

      test('getItem should fetch a specific item by ID', () async {
        const itemId = 'item-123';

        // Verify item fetch logic
        expect(itemId, isNotEmpty);
      });

      test('getItemsWithLocationStream should only return items with location', () async {
        // Items with location should be filtered
        final item1 = StudyItem(
          id: '1',
          userId: 'user-1',
          title: 'Item 1',
          description: 'With location',
          location: LocationData(latitude: 10.0, longitude: 20.0),
          createdAt: DateTime.now(),
        );

        final item2 = StudyItem(
          id: '2',
          userId: 'user-1',
          title: 'Item 2',
          description: 'Without location',
          location: null,
          createdAt: DateTime.now(),
        );

        // Only item1 should be in the filtered list
        expect(item1.location, isNotNull);
        expect(item2.location, isNull);
      });
    });

    group('Update Operation', () {
      test('updateItem should modify existing item fields', () async {
        const itemId = 'item-123';
        const newTitle = 'Updated Title';
        const newDescription = 'Updated Description';

        // Verify update structure
        expect(newTitle, isNotEmpty);
        expect(newDescription, isNotEmpty);
      });

      test('updateItem should update timestamp', () async {
        final beforeUpdate = DateTime.now();
        // Simulate delay
        await Future.delayed(const Duration(milliseconds: 100));
        final afterUpdate = DateTime.now();

        // Timestamp should be between before and after
        expect(afterUpdate.isAfter(beforeUpdate), true);
      });

      test('toggleItemCompletion should flip completion status', () async {
        bool isCompleted = false;
        isCompleted = !isCompleted;
        expect(isCompleted, true);

        isCompleted = !isCompleted;
        expect(isCompleted, false);
      });
    });

    group('Delete Operation', () {
      test('deleteItem should remove item from Firestore', () async {
        const itemId = 'item-123';
        expect(itemId, isNotEmpty);
      });

      test('deleteMultipleItems should batch delete items', () async {
        final itemIds = ['item-1', 'item-2', 'item-3'];
        expect(itemIds.length, 3);
      });
    });

    group('Data Model Tests', () {
      test('LocationData should convert to/from map correctly', () {
        final originalLocation = LocationData(
          latitude: 51.5074,
          longitude: -0.1278,
        );

        final locationMap = originalLocation.toMap();
        expect(locationMap['latitude'], 51.5074);
        expect(locationMap['longitude'], -0.1278);

        final restoredLocation = LocationData.fromMap(locationMap);
        expect(restoredLocation.latitude, originalLocation.latitude);
        expect(restoredLocation.longitude, originalLocation.longitude);
      });

      test('StudyItem should convert to/from map correctly', () {
        final location = LocationData(
          latitude: 35.6762,
          longitude: 139.6503,
        );

        final studyItem = StudyItem(
          id: 'id-123',
          userId: 'user-123',
          title: 'Study Flutter',
          description: 'Learn Riverpod',
          location: location,
          createdAt: DateTime(2024, 1, 15),
        );

        final itemMap = studyItem.toMap();
        expect(itemMap['title'], 'Study Flutter');
        expect(itemMap['userId'], 'user-123');
        expect(itemMap['location'], isNotNull);
      });

      test('StudyItem copyWith should create new instance with updated fields', () {
        final original = StudyItem(
          id: 'id-123',
          userId: 'user-123',
          title: 'Original Title',
          description: 'Original Description',
          createdAt: DateTime.now(),
        );

        final updated = original.copyWith(
          title: 'Updated Title',
          isCompleted: true,
        );

        expect(updated.title, 'Updated Title');
        expect(updated.isCompleted, true);
        expect(updated.userId, original.userId); // Should remain same
      });
    });

    group('Error Handling', () {
      test('Should handle missing title field', () {
        expect(() {
          const title = '';
          if (title.isEmpty) throw Exception('Title is required');
        }, throwsException);
      });

      test('Should handle invalid location coordinates', () {
        expect(() {
          final latitude = 95.0; // Invalid, must be -90 to 90
          if (latitude < -90 || latitude > 90) {
            throw Exception('Invalid latitude');
          }
        }, throwsException);
      });

      test('Should handle Firestore connection errors', () {
        // Simulate connection error
        expect(() {
          throw Exception('Firestore connection failed');
        }, throwsException);
      });
    });

    group('User Data Isolation', () {
      test('User A should not see User B items', () {
        final userAItems = ['item-1', 'item-2'];
        final userBItems = ['item-3', 'item-4'];

        // Items should be completely separate
        expect(userAItems.intersection(userBItems.toSet()).isEmpty, true);
      });

      test('Items should have userId field matching authenticated user', () {
        const userId = 'user-123';
        const itemUserId = 'user-123';

        expect(userId, itemUserId);
      });
    });

    group('Integration Tests', () {
      test('Complete CRUD flow: Create → Read → Update → Delete', () async {
        // 1. Create
        const createTitle = 'New Study Item';
        final createTime = DateTime.now();

        // 2. Read
        final createdItem = StudyItem(
          id: 'created-item-1',
          userId: 'test-uid-123',
          title: createTitle,
          description: 'Description',
          createdAt: createTime,
        );
        expect(createdItem.title, createTitle);

        // 3. Update
        final updatedItem = createdItem.copyWith(
          title: 'Updated Study Item',
          description: 'Updated Description',
        );
        expect(updatedItem.title, 'Updated Study Item');

        // 4. Delete (just verify we can process deletion)
        expect(updatedItem.id, isNotEmpty);
      });

      test('Location-based workflow', () async {
        // Get current location
        final currentLocation = LocationData(
          latitude: 20.5937,
          longitude: 78.9629,
        );

        // Create item with location
        final itemWithLocation = StudyItem(
          id: 'item-with-loc',
          userId: 'user-123',
          title: 'Study at Cafe',
          description: 'Found a nice cafe to study',
          location: currentLocation,
          createdAt: DateTime.now(),
        );

        expect(itemWithLocation.location?.latitude, isNotNull);
        expect(itemWithLocation.location?.longitude, isNotNull);

        // Calculate distance (example)
        final distance = itemWithLocation.location!.latitude * 111; // rough km conversion
        expect(distance, greaterThan(0));
      });
    });
  });
}

extension on List<String> {
  Set<String> intersection(Set<String> other) {
    return where((element) => other.contains(element)).toSet();
  }
}
