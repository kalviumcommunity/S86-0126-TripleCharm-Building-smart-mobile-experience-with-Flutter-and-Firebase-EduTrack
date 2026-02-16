import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/announcement_provider.dart';
import '../../models/announcement_model.dart';
import 'package:intl/intl.dart';

class AnnouncementsScreen extends StatefulWidget {

  final String classId;
  final String className;
  final bool isTeacher;

  const AnnouncementsScreen({
    super.key,
    required this.classId,
    required this.className,
    this.isTeacher = true,
  });


  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementProvider>().loadClassAnnouncements(widget.classId);
    });
  }

  void _showAddAnnouncementDialog({AnnouncementModel? announcement}) {
    final isEditing = announcement != null;
    final titleController = TextEditingController(text: announcement?.title ?? '');
    final contentController = TextEditingController(text: announcement?.content ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Announcement' : 'New Announcement'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g., Exam Schedule',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Enter announcement details...',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final content = contentController.text.trim();

              if (title.isEmpty || content.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              final provider = context.read<AnnouncementProvider>();
              final authProvider = context.read<AuthProvider>();
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              bool success;
              if (isEditing) {
                success = await provider.updateAnnouncement(
                  announcement.id,
                  title,
                  content,
                );
              } else {
                success = await provider.createAnnouncement(
                  classId: widget.classId,
                  teacherId: authProvider.user?.id ?? '',
                  title: title,
                  content: content,
                );
              }

              if (mounted) {
                if (success) {
                  navigator.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(isEditing ? 'Updated successfully' : 'Created successfully'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                } else {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(provider.error ?? 'Something went wrong'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            child: Text(isEditing ? 'Update' : 'Post'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Announcement'),
        content: const Text('Are you sure you want to delete this announcement?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final provider = context.read<AnnouncementProvider>();
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              final success = await provider.deleteAnnouncement(id);
              if (mounted) {
                navigator.pop();
                if (success) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Deleted successfully')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Announcements - ${widget.className}'),
      ),
      body: Consumer<AnnouncementProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.announcements.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.announcements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.announcement_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No announcements yet',
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddAnnouncementDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Post First Announcement'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.announcements.length,
            itemBuilder: (context, index) {
              final announcement = provider.announcements[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              announcement.title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          if (widget.isTeacher)
                          PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'edit', child: Text('Edit')),
                              const PopupMenuItem(value: 'delete', child: Text('Delete')),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showAddAnnouncementDialog(announcement: announcement);
                              } else if (value == 'delete') {
                                _confirmDelete(announcement.id);
                              }
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, yyyy - hh:mm a').format(announcement.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        announcement.content,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: widget.isTeacher ? FloatingActionButton(
        heroTag: 'announcements_screen_fab',
        onPressed: () => _showAddAnnouncementDialog(),
        child: const Icon(Icons.add),
      ) : null,

    );
  }
}
