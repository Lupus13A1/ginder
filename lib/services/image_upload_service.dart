import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../theme/bauhaus_colors.dart';
import '../theme/bauhaus_text_styles.dart';

class ImageUploadResult {
  final bool isSuccess;
  final String? url;
  final String? deleteUrl;
  final String? errorMessage;

  const ImageUploadResult({
    required this.isSuccess,
    this.url,
    this.deleteUrl,
    this.errorMessage,
  });

  factory ImageUploadResult.success(String url, {String? deleteUrl}) {
    return ImageUploadResult(isSuccess: true, url: url, deleteUrl: deleteUrl);
  }

  factory ImageUploadResult.failure(String message) {
    return ImageUploadResult(isSuccess: false, errorMessage: message);
  }
}

class ImageUploadService {
  static final ImagePicker _picker = ImagePicker();

  /// ImgBB API Key from .env
  static String? get imgbbApiKey => dotenv.env['IMGBB_API_KEY'];

  /// Google Apps Script Web App URL from .env (fallback if configured)
  static String? get driveScriptUrl => dotenv.env['GOOGLE_DRIVE_SCRIPT_URL'];

  /// Pick an image from camera or gallery
  static Future<XFile?> pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      return file;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Upload image using ImgBB API (or Google Drive if configured)
  static Future<ImageUploadResult> uploadImage(XFile file) async {
    final imgbbKey = imgbbApiKey;

    // 1. Prefer ImgBB API if key is present
    if (imgbbKey != null &&
        imgbbKey.isNotEmpty &&
        !imgbbKey.contains('YOUR_IMGBB_API_KEY')) {
      return _uploadToImgBB(file, imgbbKey);
    }

    // 2. Fallback to Google Drive Apps Script if configured
    final driveUrl = driveScriptUrl;
    if (driveUrl != null &&
        driveUrl.isNotEmpty &&
        !driveUrl.contains('YOUR_DEPLOYED_SCRIPT_ID')) {
      return _uploadToGoogleDrive(file, driveUrl);
    }

    return ImageUploadResult.failure(
      'No image upload service configured in .env. Please set IMGBB_API_KEY.',
    );
  }

  /// Upload to ImgBB via Multipart POST
  static Future<ImageUploadResult> _uploadToImgBB(
    XFile file,
    String apiKey,
  ) async {
    try {
      final Uint8List bytes = await file.readAsBytes();
      final uri = Uri.parse('https://api.imgbb.com/1/upload');

      final request = http.MultipartRequest('POST', uri);
      request.fields['key'] = apiKey;
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: 'ginder_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final imageUrl =
              (data['data']['display_url'] ?? data['data']['url']) as String;
          final deleteUrl = data['data']['delete_url'] as String?;
          return ImageUploadResult.success(imageUrl, deleteUrl: deleteUrl);
        } else {
          final errorMsg = data['error']?['message'] ?? 'ImgBB upload failed';
          return ImageUploadResult.failure(errorMsg);
        }
      } else {
        return ImageUploadResult.failure(
          'ImgBB Server Error (${response.statusCode}): ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      debugPrint('ImgBB upload error: $e');
      return ImageUploadResult.failure('Upload error: $e');
    }
  }

  /// Upload to Google Drive via Google Apps Script Web App
  static Future<ImageUploadResult> _uploadToGoogleDrive(
    XFile file,
    String scriptUrl,
  ) async {
    try {
      final Uint8List bytes = await file.readAsBytes();
      final String base64Data = base64Encode(bytes);
      final String fileName =
          'ginder_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final requestBody = jsonEncode({
        'base64': base64Data,
        'fileName': fileName,
        'mimeType': 'image/jpeg',
      });

      http.Response response = await http.post(
        Uri.parse(scriptUrl),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 302) {
        final redirectLocation = response.headers['location'];
        if (redirectLocation != null) {
          response = await http.get(Uri.parse(redirectLocation));
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          final directUrl = responseData['url'] as String;
          return ImageUploadResult.success(directUrl);
        } else {
          return ImageUploadResult.failure(
            responseData['message'] ?? 'Failed to upload to Google Drive',
          );
        }
      } else {
        return ImageUploadResult.failure(
          'Drive HTTP Error (${response.statusCode}): ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      return ImageUploadResult.failure('Drive upload error: $e');
    }
  }

  /// Show a Bauhaus-styled modal sheet for picking Camera or Gallery
  static Future<ImageSource?> showImageSourceDialog(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: BauhausColors.background,
          border: const Border(
            top: BorderSide(color: BauhausColors.border, width: 3.0),
          ),
          boxShadow: const [
            BoxShadow(
              color: BauhausColors.border,
              offset: Offset(0, -4),
              blurRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    color: BauhausColors.primaryRed,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CHOOSE PHOTO SOURCE',
                    style: BauhausTextStyles.title().copyWith(
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSourceTile(
                context: ctx,
                title: 'TAKE PHOTO WITH CAMERA',
                icon: Icons.camera_alt,
                color: BauhausColors.cardYellow,
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              const SizedBox(height: 10),
              _buildSourceTile(
                context: ctx,
                title: 'CHOOSE FROM GALLERY',
                icon: Icons.photo_library,
                color: BauhausColors.surface,
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: BauhausColors.border,
                    border: Border.all(color: BauhausColors.border, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      'CANCEL',
                      style: BauhausTextStyles.button(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildSourceTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: BauhausColors.border, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: BauhausColors.border,
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BauhausColors.surface,
                border: Border.all(color: BauhausColors.border, width: 1.5),
              ),
              child: Icon(icon, color: BauhausColors.foreground, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: BauhausTextStyles.bodyMedium().copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward, size: 18),
          ],
        ),
      ),
    );
  }
}

// Backward compatibility alias so existing calls work seamlessly
typedef GoogleDriveService = ImageUploadService;
typedef GoogleDriveUploadResult = ImageUploadResult;
