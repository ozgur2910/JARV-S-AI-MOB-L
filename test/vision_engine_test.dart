import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis_ai_mobile/features/ai/domain/repositories/ai_repository.dart';
import 'package:jarvis_ai_mobile/features/vision/data/repositories/vision_repository_impl.dart';
import 'package:jarvis_ai_mobile/features/vision/data/services/vision_service.dart';
import 'package:jarvis_ai_mobile/features/vision/domain/models/vision_result.dart';
import 'package:jarvis_ai_mobile/features/vision/presentation/providers/vision_controller.dart';

void main() {
  test('vision result serializes and restores', () {
    final processedAt = DateTime.utc(2026, 8, 12, 10);
    final result = VisionResult(
      answer: 'A blue neon assistant orb.',
      success: true,
      processedAt: processedAt,
    );

    final restored = VisionResult.fromJson(result.toJson());

    expect(restored.answer, result.answer);
    expect(restored.success, isTrue);
    expect(restored.processedAt, processedAt);
  });

  test('detects supported MIME types from bytes', () {
    expect(VisionService.detectMimeType('image.jpg', _jpegBytes()), 'image/jpeg');
    expect(VisionService.detectMimeType('image.png', _pngBytes()), 'image/png');
    expect(VisionService.detectMimeType('image.webp', _webpBytes()), 'image/webp');
  });

  test('image validation rejects invalid bytes', () {
    expect(
      () => VisionService.validateImageBytes(Uint8List.fromList([1, 2, 3]), 'image/jpeg'),
      throwsA(isA<VisionValidationException>()),
    );
  });

  test('vision repository delegates to service and returns success', () async {
    final repository = VisionRepositoryImpl(VisionService(_SuccessAiRepository()));

    final result = await repository.analyzeImage(
      imageBytes: _jpegBytes(),
      mimeType: 'image/jpeg',
      question: 'What is this?',
    );

    expect(result.success, isTrue);
    expect(result.answer, contains('test image'));
  });

  test('vision service maps AI errors to result errors', () async {
    final repository = VisionRepositoryImpl(VisionService(_ThrowingAiRepository()));

    final result = await repository.analyzeImage(
      imageBytes: _jpegBytes(),
      mimeType: 'image/jpeg',
      question: 'Analyze this',
    );

    expect(result.success, isFalse);
    expect(result.errorMessage, isNotEmpty);
  });

  test('vision state transitions for analyze without image', () async {
    final controller = VisionController(repository: VisionRepositoryImpl(VisionService(_SuccessAiRepository())));

    await controller.analyzeSelectedImage('What is this?');

    expect(controller.debugState.mode, VisionMode.error);
    expect(controller.debugState.errorMessage, contains('Select an image'));
  });
}

class _SuccessAiRepository implements AiRepository {
  @override
  Future<String> analyzeImage({
    required Uint8List imageBytes,
    required String mimeType,
    required String question,
  }) async {
    return 'This is a test image.';
  }

  @override
  Future<String> sendMessage(String message) async => 'ok';

  @override
  Stream<String> streamMessage(String message) => Stream.value('ok');
}

class _ThrowingAiRepository implements AiRepository {
  @override
  Future<String> analyzeImage({
    required Uint8List imageBytes,
    required String mimeType,
    required String question,
  }) async {
    throw Exception('network unavailable');
  }

  @override
  Future<String> sendMessage(String message) async => 'ok';

  @override
  Stream<String> streamMessage(String message) => Stream.value('ok');
}

Uint8List _jpegBytes() => Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10]);

Uint8List _pngBytes() => Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);

Uint8List _webpBytes() => Uint8List.fromList([
      0x52,
      0x49,
      0x46,
      0x46,
      0x24,
      0x00,
      0x00,
      0x00,
      0x57,
      0x45,
      0x42,
      0x50,
    ]);
