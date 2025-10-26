import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 

class EventCard extends StatelessWidget {
  final String title;
  final String code;
  final String location;
  final String ownerName;
  final String date;
  final int members;
  final int photoCount;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.title,
    required this.code,
    required this.location,
    required this.ownerName,
    required this.members,
    required this.date,
    required this.photoCount,
    required this.onTap,
  });


  @override
  Widget build(BuildContext context) {
    String formattedDate;
    try {
      final parsedDate = DateTime.parse(date);
      formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
      
    } catch (e) {
      formattedDate = date; 
    }

    return Card(
      color: const Color.fromARGB(255, 244, 252, 255),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Code: $code • $photoCount photos',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Owner: $ownerName',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'members: $members',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Location: $location',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Date: $formattedDate',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
