import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

class FeedbackSubmissionException implements Exception {
  FeedbackSubmissionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class FeedbackService {
  FeedbackService({SupabaseClient? client})
    : _client = client ?? _resolveClient();

  static const imageBucket = 'feedback-images';
  static const feedbackTable = 'feedback';

  final SupabaseClient? _client;

  bool get isConfigured => _client != null && SupabaseConfig.isConfigured;

  static SupabaseClient? _resolveClient() {
    if (!SupabaseConfig.isConfigured) {
      return null;
    }
    return Supabase.instance.client;
  }

  Future<void> submit({
    required String message,
    required List<XFile> images,
  }) async {
    final client = _client;
    final trimmedMessage = message.trim();

    if (trimmedMessage.isEmpty) {
      throw FeedbackSubmissionException('Feedback is required.');
    }
    if (images.length > 3) {
      throw FeedbackSubmissionException('Attach up to 3 images.');
    }
    if (client == null) {
      throw FeedbackSubmissionException(
        'Supabase is not configured for this build.',
      );
    }

    try {
      final imagePaths = await _uploadImages(client, images);

      await client.from(feedbackTable).insert({
        'message': trimmedMessage,
        'image_paths': imagePaths,
        'metadata': {'source': 'mobile_app', 'image_count': imagePaths.length},
      });
    } on FeedbackSubmissionException {
      rethrow;
    } catch (_) {
      throw FeedbackSubmissionException(
        'Could not submit feedback. Please try again.',
      );
    }
  }

  Future<List<String>> _uploadImages(
    SupabaseClient client,
    List<XFile> images,
  ) async {
    final submissionId = DateTime.now().microsecondsSinceEpoch.toString();
    final uploadedPaths = <String>[];

    for (final (index, image) in images.indexed) {
      final bytes = await image.readAsBytes();
      final extension = p.extension(image.path).toLowerCase();
      final fallbackName =
          'image_$index${extension.isEmpty ? '.jpg' : extension}';
      final pathName = p.basename(image.path).isEmpty
          ? fallbackName
          : p.basename(image.path);
      final objectPath = 'feedback/$submissionId/${index}_$pathName';

      await client.storage
          .from(imageBucket)
          .uploadBinary(
            objectPath,
            bytes,
            fileOptions: FileOptions(
              contentType: image.mimeType,
              upsert: false,
            ),
          );

      uploadedPaths.add(objectPath);
    }

    return uploadedPaths;
  }
}
