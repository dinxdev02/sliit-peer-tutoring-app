import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'backend_config.dart';

class UploadService {
  static const maxBytes = 5 * 1024 * 1024;
  static Future<PlatformFile?> pick() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf'],
        withData: true);
    if (result == null) return null;
    final file = result.files.single;
    if (file.size <= 0 || file.size > maxBytes || file.bytes == null) {
      throw StateError('Choose a PNG, JPG or PDF file up to 5 MB.');
    }
    return file;
  }

  static Future<Map<String, dynamic>> upload(
      PlatformFile file, String folder) async {
    if (!BackendConfig.uploadsEnabled) {
      throw StateError('File uploads are unavailable in this version.');
    }
    if (file.bytes == null || file.size > maxBytes) {
      throw StateError('Invalid file or file exceeds 5 MB.');
    }
    final ext = file.extension?.toLowerCase();
    final contentType = ext == 'pdf'
        ? 'application/pdf'
        : ext == 'png'
            ? 'image/png'
            : 'image/jpeg';
    final safeName = file.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final path = '$folder/${DateTime.now().microsecondsSinceEpoch}_$safeName';
    await FirebaseStorage.instance
        .ref(path)
        .putData(file.bytes!, SettableMetadata(contentType: contentType));
    return {
      'name': file.name,
      'path': path,
      'size': file.size,
      'contentType': contentType
    };
  }

  static Future<void> open(Map<String, dynamic> attachment) async {
    final url = await FirebaseStorage.instance
        .ref(attachment['path'] as String)
        .getDownloadURL();
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      throw StateError('No app is available to open this file.');
    }
  }

  static Future<void> openTeams(String? url) async {
    final uri = Uri.tryParse(url ?? '');
    if (uri == null ||
        uri.scheme != 'https' ||
        !(uri.host == 'teams.microsoft.com' ||
            uri.host == 'teams.live.com' ||
            uri.host == 'teams.cloud.microsoft')) {
      throw StateError(
          'Your tutor has not added a valid Teams meeting link yet.');
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw StateError('Could not open the meeting link.');
    }
  }
}
