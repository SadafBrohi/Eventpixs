import 'package:flutter/material.dart';

class EventMembersScreen extends StatelessWidget {
  final List<String> members;

  const EventMembersScreen({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event Members')),
        body: const Center(
          child: Text('No members found.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Members'),
      ),
      body: ListView.separated(
        itemCount: members.length,
        separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, color: Colors.grey),
        itemBuilder: (context, index) {
          final name = members[index];
          final isOwner = index == 0;

          return ListTile(
            leading: isOwner ? const Icon(Icons.star, color: Colors.orange) : null,
            title: Text(name),
            subtitle: isOwner ? const Text('Owner') : null,
          );
        },
      ),
    );
  }
}
