import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/study_item_providers.dart';
import '../models/location_data.dart';

class CreateEditItemScreen extends ConsumerStatefulWidget {
  final bool isEdit;

  const CreateEditItemScreen({
    Key? key,
    required this.isEdit,
  }) : super(key: key);

  @override
  ConsumerState<CreateEditItemScreen> createState() =>
      _CreateEditItemScreenState();
}

class _CreateEditItemScreenState extends ConsumerState<CreateEditItemScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final formState = ref.read(itemFormStateProvider);
    _titleController = TextEditingController(text: formState.title);
    _descriptionController = TextEditingController(text: formState.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(itemFormStateProvider);
    final locationAsyncValue = ref.watch(currentLocationProvider);

    return WillPopScope(
      onWillPop: () async {
        ref.read(itemFormStateProvider.notifier).resetForm();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEdit ? 'Edit Item' : 'Create Item'),
        ),
        body: formState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title field
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        hintText: 'Enter item title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.title),
                      ),
                      onChanged: (value) {
                        ref.read(itemFormStateProvider.notifier).setTitle(value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description field
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter item description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      maxLines: 4,
                      onChanged: (value) {
                        ref
                            .read(itemFormStateProvider.notifier)
                            .setDescription(value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Location section
                    _buildLocationSection(formState, locationAsyncValue),

                    const SizedBox(height: 16),

                    // Completion checkbox (for edit mode)
                    if (widget.isEdit)
                      CheckboxListTile(
                        title: const Text('Mark as Completed'),
                        value: formState.isCompleted,
                        onChanged: (value) {
                          if (value != null) {
                            ref
                                .read(itemFormStateProvider.notifier)
                                .setCompleted(value);
                          }
                        },
                      ),

                    const SizedBox(height: 24),

                    // Error message
                    if (formState.error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Text(
                          formState.error!,
                          style: TextStyle(color: Colors.red[900]),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              ref
                                  .read(itemFormStateProvider.notifier)
                                  .resetForm();
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: _submitForm,
                            child: Text(widget.isEdit ? 'Update' : 'Create'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildLocationSection(
    ItemFormState formState,
    AsyncValue<LocationData?> locationAsyncValue,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Location',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (formState.location != null) ...[
            Text(
              'Latitude: ${formState.location!.latitude.toStringAsFixed(4)}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Longitude: ${formState.location!.longitude.toStringAsFixed(4)}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                ref.read(itemFormStateProvider.notifier).setLocation(null);
              },
              child: const Text('Clear Location'),
            ),
          ] else ...[
            locationAsyncValue.when(
              data: (location) {
                if (location == null) {
                  return Text(
                    'No location data available',
                    style: TextStyle(color: Colors.grey[600]),
                  );
                }
                return FilledButton.icon(
                  onPressed: () {
                    ref
                        .read(itemFormStateProvider.notifier)
                        .setLocation(location);
                  },
                  icon: const Icon(Icons.add_location),
                  label: const Text('Add Current Location'),
                );
              },
              loading: () => const Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (error, stackTrace) => Text(
                'Error getting location: $error',
                style: TextStyle(color: Colors.red[600]),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    final formState = ref.read(itemFormStateProvider);

    // Validation
    if (formState.title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    if (formState.description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description')),
      );
      return;
    }

    // Submit
    if (widget.isEdit) {
      await ref.read(itemFormStateProvider.notifier).updateItem();
    } else {
      await ref.read(itemFormStateProvider.notifier).createItem();
    }

    // Check for errors
    final updatedState = ref.read(itemFormStateProvider);
    if (updatedState.error == null && !updatedState.isLoading) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEdit ? 'Item updated successfully' : 'Item created successfully',
            ),
          ),
        );
      }
    }
  }
}
