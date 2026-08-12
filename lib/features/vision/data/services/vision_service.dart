import 'dart:typed_data';

import '../../../ai/domain/models/ai_exception.dart';
import '../../../ai/domain/repositories/ai_repository.dart';
import '../../domain/models/vision_result.dart';

class VisionValidationException implements Exception {
  const VisionValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class VisionService {
  const VisionService(this._aiRepository);

  static const maxImageBytes = 4 * 1024 * 1024;
  static const supportedMimeTypes = {'image/jpeg', 'image/png', 'image/webp'};

  final AiRepository _aiRepository;

  Future<VisionResult> analyzeImage({
    required Uint8List imageBytes,
    required String mimeType,
    required String question,
  }) async {
    try {
      validateImageBytes(imageBytes, mimeType);
      final answer = await _aiRepository.analyzeImage(
        imageBytes: imageBytes,
        mimeType: mimeType,
        question: _normalizeQuestion(question),
      );
      if (answer.trim().isEmpty) {
        return VisionResult(
          answer: '',
          success: false,
          errorMessage: 'JARVIS could not find a vision response.',
          processedAt: DateTime.now(),
        );
      }
      return VisionResult(
        answer: answer.trim(),
        success: true,
        processedAt: DateTime.now(),
      );
    } on VisionValidationException catch (error) {
      return VisionResult(
        answer: '',
        success: false,
        errorMessage: error.message,
        processedAt: DateTime.now(),
      );
    } on AiException catch (error) {
      return VisionResult(
        answer: '',
        success: false,
        errorMessage: error.message,
        processedAt: DateTime.now(),
      );
    } catch (_) {
      return VisionResult(
        answer: '',
        success: false,
        errorMessage: 'JARVIS could not analyze this image.',
        processedAt: DateTime.now(),
      );
    }
  }

  static String detectMimeType(String fileName, Uint8List bytes) {
    if (_hasJpegSignature(bytes) || _extension(fileName) == 'jpg' || _extension(fileName) == 'jpeg') {
      return 'image/jpeg';
    }
    if (_hasPngSignature(bytes) || _extension(fileName) == 'png') {
      return 'image/png';
    }
    if (_hasWebpSignature(bytes) || _extension(fileName) == 'webp') {
      return 'image/webp';
    }
    throw const VisionValidationException('Unsupported image format. Use JPEG, PNG, or WebP.');
  }

  static void validateImageBytes(Uint8List bytes, String mimeType) {
    if (bytes.isEmpty) {
      throw const VisionValidationException('Selected image is empty or corrupt.');
    }
    if (!supportedMimeTypes.contains(mimeType)) {
      throw const VisionValidationException('Unsupported image format. Use JPEG, PNG, or WebP.');
    }
    if (bytes.length > maxImageBytes) {
      throw const VisionValidationException(
        'Image is too large. Select a smaller image so JARVIS can analyze it safely.',
      );
    }
    final signatureMatches = switch (mimeType) {
      'image/jpeg' => _hasJpegSignature(bytes),
      'image/png' => _hasPngSignature(bytes),
      'image/webp' => _hasWebpSignature(bytes),
      _ => false,
    };
    if (!signatureMatches) {
      throw const VisionValidationException('Selected image appears invalid or corrupt.');
    }
  }

  static String _normalizeQuestion(String question) {
    final trimmed = question.trim();
    return trimmed.isEmpty ? 'What do you see? Describe this image.' : trimmed;
  }

  static String _extension(String fileName) {
    final parts = fileName.toLowerCase().split('.');
    return parts.length < 2 ? '' : parts.last;
  }

  static bool _hasJpegSignature(Uint8List bytes) {
    return bytes.length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF;
  }

  static bool _hasPngSignature(Uint8List bytes) {
    const png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
    return bytes.length >= png.length && Iterable<int>.generate(png.length).every((index) => bytes[index] == png[index]);
  }

  static bool _hasWebpSignature(Uint8List bytes) {
    return bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP';
  }
}
