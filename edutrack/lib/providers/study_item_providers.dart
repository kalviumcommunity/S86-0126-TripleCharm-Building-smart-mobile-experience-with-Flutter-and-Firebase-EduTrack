import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/study_item.dart';
import '../models/location_data.dart';
import '../services/firestore_crud_service.dart';
import '../services/location_service.dart';

// Service providers
final firestoreCrudServiceProvider = Provider((ref) {
  return FirestoreCrudService();
});

final locationServiceProvider = Provider((ref) {
  return LocationService();
});

// Location providers
final currentLocationProvider = FutureProvider((ref) {
  final locationService = ref.watch(locationServiceProvider);
  return locationService.getCurrentLocation();
});

final locationUpdatesProvider = StreamProvider((ref) {
  final locationService = ref.watch(locationServiceProvider);
  return locationService.getLocationUpdates();
});

// Study items providers
final studyItemsProvider = StreamProvider((ref) {
  final crudService = ref.watch(firestoreCrudServiceProvider);
  return crudService.getItemsStream();
});

final itemsWithLocationProvider = StreamProvider((ref) {
  final crudService = ref.watch(firestoreCrudServiceProvider);
  return crudService.getItemsWithLocationStream();
});

// Single item provider
final studyItemProvider = FutureProvider.family<StudyItem?, String>((ref, itemId) {
  final crudService = ref.watch(firestoreCrudServiceProvider);
  return crudService.getItem(itemId);
});

// State for create/edit item
final itemFormStateProvider = StateNotifierProvider<ItemFormNotifier, ItemFormState>((ref) {
  return ItemFormNotifier(ref);
});

class ItemFormState {
  final String? id;
  final String title;
  final String description;
  final LocationData? location;
  final bool isLoading;
  final String? error;
  final bool isCompleted;

  ItemFormState({
    this.id,
    this.title = '',
    this.description = '',
    this.location,
    this.isLoading = false,
    this.error,
    this.isCompleted = false,
  });

  ItemFormState copyWith({
    String? id,
    String? title,
    String? description,
    LocationData? location,
    bool? isLoading,
    String? error,
    bool? isCompleted,
  }) {
    return ItemFormState(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class ItemFormNotifier extends StateNotifier<ItemFormState> {
  final Ref ref;

  ItemFormNotifier(this.ref) : super(ItemFormState());

  void setTitle(String title) {
    state = state.copyWith(title: title);
  }

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void setLocation(LocationData? location) {
    state = state.copyWith(location: location);
  }

  void setCompleted(bool completed) {
    state = state.copyWith(isCompleted: completed);
  }

  Future<void> createItem() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final crudService = ref.read(firestoreCrudServiceProvider);
      await crudService.createItem(
        title: state.title,
        description: state.description,
        location: state.location,
      );
      state = ItemFormState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateItem() async {
    if (state.id == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final crudService = ref.read(firestoreCrudServiceProvider);
      await crudService.updateItem(
        itemId: state.id!,
        title: state.title,
        description: state.description,
        location: state.location,
        isCompleted: state.isCompleted,
      );
      state = ItemFormState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteItem() async {
    if (state.id == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final crudService = ref.read(firestoreCrudServiceProvider);
      await crudService.deleteItem(state.id!);
      state = ItemFormState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void loadItem(StudyItem item) {
    state = ItemFormState(
      id: item.id,
      title: item.title,
      description: item.description,
      location: item.location,
      isCompleted: item.isCompleted,
    );
  }

  void resetForm() {
    state = ItemFormState();
  }
}
