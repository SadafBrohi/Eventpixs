import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

Future<void> downloadImages(BuildContext context, List<String> urls) async {
  PermissionStatus status;
  if (Platform.isAndroid) {
    status = await Permission.manageExternalStorage.request();
  } else if (Platform.isIOS) {
    status = await Permission.photos.request();
  } else {
    status = PermissionStatus.granted;
  }

  if (!status.isGranted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Storage permission denied')));
    return;
  }

  final dir = Directory('/storage/emulated/0/DCIM/EventPix');
  if (!await dir.exists()) await dir.create(recursive: true);

  int total = urls.length;
  int completed = 0;

  for (var url in urls) {
    try {
      final response = await http.get(Uri.parse(url));
      final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);
      completed++;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),
          content: Text('Downloading $completed of $total...'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download one image!: $e')),
      );
    }
  }

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        total == 1
            ? 'Image downloaded successfully!'
            : 'All $total images downloaded successfully!',
      ),
    ),
  );
}
