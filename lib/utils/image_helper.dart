import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'dart:math';

class ImageHelper {
  static Future<String?> pickAndSaveImage({
    ImageSource source = ImageSource.gallery,
    int quality = 80,
    double? maxWidth,
    double? maxHeight,
  }) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: quality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (pickedFile == null) return null;

      // Get application documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/images');

      // Create images directory if it doesn't exist
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Generate unique filename
      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final targetPath = path.join(imagesDir.path, fileName);

      // Compress and save the image
      final File? compressedFile = await compressImage(
        pickedFile.path,
        targetPath: targetPath,
        quality: quality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (compressedFile != null) {
        return compressedFile.path;
      }

      // If compression fails, copy the original file
      final savedImage = await File(pickedFile.path).copy(targetPath);
      return savedImage.path;
    } catch (e) {
      print('Error picking/saving image: $e');
      return null;
    }
  }

  static Future<File?> compressImage(
      String sourcePath, {
        required String targetPath,
        int quality = 80,
        double? maxWidth,
        double? maxHeight,
      }) async {
    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        sourcePath,
        targetPath,
        quality: quality,
        minWidth: maxWidth?.toInt() ?? 1024,
        minHeight: maxHeight?.toInt() ?? 1024,
        format: CompressFormat.jpeg,
      );

      if (result != null) {
        // Get file sizes for logging
        final originalSize = await File(sourcePath).length();
        final compressedSize = await File(result.path).length();
        print('Original size: ${originalSize / 1024}KB');
        print('Compressed size: ${compressedSize / 1024}KB');

        return File(result.path);
      }
      return null;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  static Future<void> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  static Future<void> cleanupUnusedImages(List<String> usedImagePaths) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/images');

      if (!await imagesDir.exists()) return;

      await for (final file in imagesDir.list()) {
        if (file is File && !usedImagePaths.contains(file.path)) {
          await file.delete();
        }
      }
    } catch (e) {
      print('Error cleaning up images: $e');
    }
  }

  static Future<bool> isValidImage(String? imagePath) async {
    if (imagePath == null) return false;
    try {
      final file = File(imagePath);
      return await file.exists();
    } catch (e) {
      print('Error checking image: $e');
      return false;
    }
  }

  // Utility method to format file size
  static String getReadableFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }
}