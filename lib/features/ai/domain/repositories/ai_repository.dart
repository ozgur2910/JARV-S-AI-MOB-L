import 'dart:typed_data';

abstract class AiRepository {
  Future<String> sendMessage(String message);

  Stream<String> streamMessage(String message);

  Future<String> analyzeImage({
    required Uint8List imageBytes,
    required String mimeType,
    required String question,
  });
}
