import 'dart:typed_data';

import '../../domain/repositories/ai_repository.dart';
import '../services/gemini_service.dart';

class AiRepositoryImpl implements AiRepository {
  const AiRepositoryImpl(this._aiService);

  final AIService _aiService;

  @override
  Future<String> sendMessage(String message) => _aiService.sendMessage(message);

  @override
  Stream<String> streamMessage(String message) => _aiService.streamMessage(message);

  @override
  Future<String> analyzeImage({
    required Uint8List imageBytes,
    required String mimeType,
    required String question,
  }) {
    return _aiService.analyzeImage(
      imageBytes: imageBytes,
      mimeType: mimeType,
      question: question,
    );
  }
}
