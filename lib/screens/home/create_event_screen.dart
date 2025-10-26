import 'dart:math';
import 'package:eventpix/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/event_service.dart';
import 'event_gallery_screen.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _location = TextEditingController();
  DateTime? _selectedDate;
  final _eventService = EventService();
  bool loading = false;

  String generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

Future<void> _create() async {
  if (!_formKey.currentState!.validate()) return;

  if (_selectedDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a date')),
    );
    return;
  }

  setState(() => loading = true);

  final user = Provider.of<UserProvider>(context, listen: false).user!;
  final uid = user.uid;
  final code = generateCode();
  print("user name: ${user.name}" );

  final data = {
    'title': _title.text.trim(),
    'description': _desc.text.trim(),
    'location': _location.text.trim(),
    'date': _selectedDate!.toIso8601String(),
    'ownerName': user.name,
    'createdBy': uid,
    'participants': [uid],
    'photos': [],
    'code': code,
  };

  final id = await _eventService.createEvent(data);
  setState(() => loading = false);

  if (id != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Event created successfully! Code: $code')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => EventGalleryScreen(eventId: id)),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('An error occurred while creating the event')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final dateText = _selectedDate == null
        ? 'Pick a date'
        : DateFormat("dd-MM-yyyy").format(_selectedDate!);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20.0),
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  TextFormField(
                    controller: _title,
                    decoration: const InputDecoration(
                      labelText: "Event Title",
                      hintText: 'Event title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an event title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _desc,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      hintText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the event description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _location,
                    decoration: const InputDecoration(
                      labelText: "Location",
                      hintText: 'Location',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the event location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: Text(dateText),
                    leading: const Icon(Icons.calendar_today),
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 20),
                  loading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _create,
                            child: const Text('Create Event'),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
