import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RealTimeSyncScreen extends StatefulWidget {
  const RealTimeSyncScreen({Key? key}) : super(key: key);

  @override
  State<RealTimeSyncScreen> createState() => _RealTimeSyncScreenState();
}

class _RealTimeSyncScreenState extends State<RealTimeSyncScreen> {
  StreamSubscription<QuerySnapshot>? _tasksSub;

  @override
  void initState() {
    super.initState();

    // Example of manual listening (advanced): react to individual changes
    _tasksSub = FirebaseFirestore.instance
        .collection('tasks')
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final title = change.doc.data()?['title'] ?? 'New item';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Task added: $title')),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _tasksSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'demoUser';

    return Scaffold(
      appBar: AppBar(title: const Text('Real-Time Firestore')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Document listener (user profile):', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
                if (!snapshot.hasData || snapshot.data!.data() == null) {
                  return const Text('No user data available');
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(data['displayName'] ?? 'Unnamed'),
                    subtitle: Text(data['email'] ?? 'No email'),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),
            const Text('Collection listener (messages):', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Collection StreamBuilder showing real-time updates
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No messages yet'));
                  }

                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final d = docs[index].data() as Map<String, dynamic>;
                      final text = d['text'] ?? '';
                      final author = d['author'] ?? 'anon';
                      return ListTile(
                        leading: const Icon(Icons.message),
                        title: Text(text),
                        subtitle: Text('by $author'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTestMessage,
        child: const Icon(Icons.add),
        tooltip: 'Add test message',
      ),
    );
  }

  Future<void> _addTestMessage() async {
    await FirebaseFirestore.instance.collection('messages').add({
      'text': 'Hello from device @ ${DateTime.now()}',
      'author': FirebaseAuth.instance.currentUser?.email ?? 'local',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
