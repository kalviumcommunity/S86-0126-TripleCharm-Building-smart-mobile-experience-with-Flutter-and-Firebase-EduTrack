import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/study_item_providers.dart';
import '../models/study_item.dart';
import 'create_edit_item_screen.dart';
import 'items_map_view.dart';

class StudyItemsCrudScreen extends ConsumerStatefulWidget {
  const StudyItemsCrudScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StudyItemsCrudScreen> createState() =>
      _StudyItemsCrudScreenState();
}

class _StudyItemsCrudScreenState extends ConsumerState<StudyItemsCrudScreen> {
  @override
  Widget build(BuildContext context) {
    final itemsAsyncValue = ref.watch(studyItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Items'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: 'View on Map',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ItemsMapView(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openCreateItemDialog(context);
        },
        child: const Icon(Icons.add),
      ),
      body: itemsAsyncValue.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No items yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create your first study item',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final item = items[index];
              return StudyItemCard(
                item: item,
                onTap: () => _openEditItemDialog(context, item),
                onDelete: () => _deleteItem(context, item.id),
                onToggleComplete: () =>
                    _toggleComplete(context, item.id, item.isCompleted),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading items',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCreateItemDialog(BuildContext context) {
    ref.read(itemFormStateProvider.notifier).resetForm();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateEditItemScreen(isEdit: false),
      ),
    );
  }

  void _openEditItemDialog(BuildContext context, StudyItem item) {
    ref.read(itemFormStateProvider.notifier).loadItem(item);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateEditItemScreen(isEdit: true),
      ),
    );
  }

  void _deleteItem(BuildContext context, String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(itemFormStateProvider.notifier).state =
                  ref.read(itemFormStateProvider.notifier).state.copyWith(
                    id: itemId,
                  );
              ref.read(itemFormStateProvider.notifier).deleteItem();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Item deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _toggleComplete(BuildContext context, String itemId, bool currentStatus) {
    final crudService = ref.read(firestoreCrudServiceProvider);
    crudService.toggleItemCompletion(itemId, currentStatus).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(currentStatus ? 'Marked as incomplete' : 'Marked as complete'),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    });
  }
}

class StudyItemCard extends StatelessWidget {
  final StudyItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onToggleComplete;

  const StudyItemCard({
    Key? key,
    required this.item,
    required this.onTap,
    required this.onDelete,
    required this.onToggleComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: ListTile(
        leading: Checkbox(
          value: item.isCompleted,
          onChanged: (_) => onToggleComplete(),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            decoration: item.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              item.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (item.location != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      '${item.location?.latitude.toStringAsFixed(2)}, ${item.location?.longitude.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Edit'),
              onTap: onTap,
            ),
            PopupMenuItem(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
