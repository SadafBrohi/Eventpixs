import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:convert';

class CloudinaryService {
  final String cloudName = 'cloudtalha';
  final String unsignedUploadPreset = 'flutter_unsigned_eventpix';

  Future<String?> uploadImage(File file) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
    final parts = mimeType.split('/');
    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = unsignedUploadPreset;
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType(parts[0], parts[1]),
      ),
    );

    print('Uploading ${file.path} to Cloudinary...');

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode == 200 || res.statusCode == 201) {
      final Map data = json.decode(res.body);
      print('Uploaded image URL: ${data['secure_url']}');
      return data['secure_url'] as String?;
    } else {
      print('Cloudinary upload failed: ${res.statusCode} ${res.body}');
      return null;
    }
  }
}
