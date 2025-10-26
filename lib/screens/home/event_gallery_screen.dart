import 'dart:io';
import 'package:eventpix/providers/user_provider.dart';
import 'package:eventpix/screens/home/event_members_screen.dart';
import 'package:eventpix/services/helpers.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/cloudinary_service.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/event_service.dart';
import '../photos/photo_detail_screen.dart';
import 'package:provider/provider.dart';

class EventGalleryScreen extends StatefulWidget {
  final String eventId;
  const EventGalleryScreen({super.key, required this.eventId});

  @override
  State<EventGalleryScreen> createState() => _EventGalleryScreenState();
}

class _EventGalleryScreenState extends State<EventGalleryScreen> {
  final CloudinaryService _cloud = CloudinaryService();
  final EventService _eventService = EventService();
  final picker = ImagePicker();

  bool uploading = false;
  bool selectionMode = false;
  Set<String> selectedPhotos = {};
  List<String> photos = [];

  Future<void> _pickAndUpload() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => uploading = true);

    final file = File(picked.path);
    final url = await _cloud.uploadImage(file);

    if (url != null) {
      await _eventService.addPhotoToEvent(widget.eventId, url);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Uploaded successfully!')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Upload failed')));
    }
    setState(() => uploading = false);
  }

  void _toggleSelection(String url) {
    setState(() {
      if (selectedPhotos.contains(url)) {
        selectedPhotos.remove(url);
        if (selectedPhotos.isEmpty) selectionMode = false;
      } else {
        selectedPhotos.add(url);
        selectionMode = true;
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (selectedPhotos.length == photos.length) {
        selectedPhotos.clear();
        selectionMode = false;
      } else {
        selectedPhotos = photos.toSet();
        selectionMode = true;
      }
    });
  }

  void _cancelSelection() {
    setState(() {
      selectionMode = false;
      selectedPhotos.clear();
    });
  }

  Future<void> _deleteSelectedPhotos() async {
    if (selectedPhotos.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete ${selectedPhotos.length} photos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _eventService.deleteMultiplePhotos(
        widget.eventId,
        selectedPhotos.toList(),
      );
      setState(() {
        selectedPhotos.clear();
        selectionMode = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photos deleted successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;
    final stream = FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .snapshots();

    return StreamBuilder<DocumentSnapshot>(
      stream: stream,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snap.data!.data() as Map<String, dynamic>;
        photos = List<String>.from(data['photos'] ?? []);
        final isOwner = data['createdBy'] == currentUser?.uid;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              selectionMode
                  ? 'Selected (${selectedPhotos.length})'
                  : 'Event Gallery',
            ),
            leading: selectionMode
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _cancelSelection,
                  )
                : null,
            actions: [
              if (selectionMode)
                IconButton(
                  icon: Icon(
                    selectedPhotos.length == photos.length
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                  ),
                  onPressed: _selectAll,
                  tooltip: selectedPhotos.length == photos.length
                      ? 'Deselect All'
                      : 'Select All',
                ),

              IconButton(
                icon: Row(
                  children: [
                    const Icon(Icons.download),
                    if (selectionMode && selectedPhotos.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Text(
                        '${selectedPhotos.length}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                ),
                onPressed: () {
                  if (selectionMode && selectedPhotos.isNotEmpty) {
                    downloadImages(context, selectedPhotos.toList());
                  } else {
                    downloadImages(context, photos);
                  }
                },
                tooltip: selectionMode
                    ? 'Download selected photos'
                    : 'Download all photos',
              ),

              if (isOwner && selectionMode && selectedPhotos.isNotEmpty)
                IconButton(
                  icon: Row(
                    children: const [
                      Icon(Icons.delete),
                    ],
                  ),
                  onPressed: _deleteSelectedPhotos,
                ),

              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () async {
                  final members = await _eventService.getEventMembers(
                    widget.eventId,
                  );

                  if (members.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No members found')),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventMembersScreen(members: members),
                    ),
                  );
                },
              ),
            ],
          ),
          body: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 5 : 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final url = photos[index];
              final isSelected = selectedPhotos.contains(url);

              return GestureDetector(
                onLongPress: () => _toggleSelection(url),
                onTap: () {
                  if (selectionMode) {
                    _toggleSelection(url);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PhotoDetailScreen(imageUrl: url),
                      ),
                    );
                  }
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                    if (isSelected)
                      Container(
                        color: Colors.black45,
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: uploading ? null : _pickAndUpload,
            child: uploading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.camera_alt),
          ),
        );
      },
    );
  }
}
