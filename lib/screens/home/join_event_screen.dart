import 'package:eventpix/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/event_service.dart';
import 'event_gallery_screen.dart';

class JoinEventScreen extends StatefulWidget {
  const JoinEventScreen({super.key});

  @override
  State<JoinEventScreen> createState() => _JoinEventScreenState();
}

class _JoinEventScreenState extends State<JoinEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _eventService = EventService();
  bool loading = false;

  Future<void> _join() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    final code = _code.text.trim().toUpperCase();
    final user = Provider.of<UserProvider>(context, listen: false).user!;
    final uid = user.uid;

    final eventId = await _eventService.joinEventByCode(code, uid);

    setState(() => loading = false);

    if (eventId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully joined the event!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => EventGalleryScreen(eventId: eventId)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid event code. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Event')),
      body: Padding(
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
                    controller: _code,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Event Code',
                      hintText: 'Enter Event Code',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an event code';
                      }
                      if (value.trim().length != 6) {
                        return 'Event code must be 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  loading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _join,
                            child: const Text('Join Event'),
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
