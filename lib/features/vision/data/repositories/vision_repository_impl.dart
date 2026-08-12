import 'dart:typed_data';

import '../../domain/models/vision_result.dart';
import '../../domain/repositories/vision_repository.dart';
import '../services/vision_service.dart';

class VisionRepositoryImpl implements VisionRepository {
  const VisionRepositoryImpl(this._service);

  final VisionService _service;

  @override
  Future<VisionResult> analyzeImage({
    required Uint8List imageBytes,
    required String mimeType,
    required String question,
  }) {
    return _service.analyzeImage(
      imageBytes: imageBytes,
      mimeType: mimeType,
      question: question,
    );
  }
}
