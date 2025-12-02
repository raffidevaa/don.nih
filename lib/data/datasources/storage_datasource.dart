import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageDatasource {
  final SupabaseClient supabase = Supabase.instance.client;
  final String bucketName = 'don.nih!';

  /// format file name: {id}_{folderName}.{fileExt}
  String _generateFileName({
    required String id,
    required String folderName,
    required File file,
  }) {
    final String extension = file.path.split('.').last;
    return '$id\_$folderName.$extension';
  }

  /// Upload file baru
  Future<String> uploadImage({
    required File file,
    required String id,
    required String folderName, // profile / menu
  }) async {
    try {
      final fileName = _generateFileName(
        id: id,
        folderName: folderName,
        file: file,
      );
      final fullPath = '$folderName/$fileName';

      await supabase.storage
          .from(bucketName)
          .upload(
            fullPath,
            file,
            fileOptions: const FileOptions(upsert: false),
          );

      return supabase.storage.from(bucketName).getPublicUrl(fullPath);
    } catch (e) {
      rethrow;
    }
  }

  /// Update file (hapus lama + upload baru)
  Future<String> updateImage({
    required File file,
    required String id,
    required String folderName,
  }) async {
    try {
      final fileName = _generateFileName(
        id: id,
        folderName: folderName,
        file: file,
      );
      final fullPath = '$folderName/$fileName';

      // delete file lama jika ada
      await supabase.storage.from(bucketName).remove([fullPath]);

      // upload baru
      await supabase.storage
          .from(bucketName)
          .upload(fullPath, file, fileOptions: const FileOptions(upsert: true));

      return supabase.storage.from(bucketName).getPublicUrl(fullPath);
    } catch (e) {
      rethrow;
    }
  }

  /// Cek apakah file ada
  Future<bool> checkImageExists({
    required String id,
    required String folderName,
    required String fileType, // png/jpg/webp dll
  }) async {
    try {
      final fileName = '$id\_$folderName.$fileType';

      final files = await supabase.storage
          .from(bucketName)
          .list(path: folderName);

      return files.any((f) => f.name == fileName);
    } catch (_) {
      return false;
    }
  }

  /// Dapatkan public URL tanpa upload
  String getImageUrl({
    required String id,
    required String folderName,
    required String fileType,
  }) {
    final fileName = '$id\_$folderName.$fileType';
    return supabase.storage
        .from(bucketName)
        .getPublicUrl('$folderName/$fileName');
  }
}
