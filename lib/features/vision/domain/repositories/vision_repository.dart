import 'dart:typed_data';

import '../models/vision_result.dart';

abstract class VisionRepository {
  Future<VisionResult> analyzeImage({
    required Uint8List imageBytes,
    required String mimeType,
    required String question,
  });
}
