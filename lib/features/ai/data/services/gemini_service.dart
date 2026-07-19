import 'dart:async';
import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/models/ai_exception.dart';

// ignore: camel_case_types
abstract class AIService {
  Future<String> sendMessage(String message);

  Stream<String> streamMessage(String message);
}

class GeminiService implements AIService {
  GeminiService(this._secureStorageService);

  static const _modelName = 'gemini-1.5-flash';
  static const _timeout = Duration(seconds: 30);

  final SecureStorageService _secureStorageService;

  @override
  Future<String> sendMessage(String message) async {
    final chunks = <String>[];
    await for (final chunk in streamMessage(message)) {
      chunks.add(chunk);
    }
    final response = chunks.join().trim();
    if (response.isEmpty) {
      throw const AiException(
        AiErrorType.gemini,
        'Gemini returned an empty response.',
      );
    }
    return response;
  }

  @override
  Stream<String> streamMessage(String message) async* {
    final apiKey = await _readAndValidateApiKey();

    try {
      final model = GenerativeModel(model: _modelName, apiKey: apiKey);
      final stream = model
          .generateContentStream([Content.text(message.trim())])
          .timeout(_timeout);

      await for (final response in stream) {
        final text = response.text;
        if (text != null && text.isNotEmpty) {
          yield text;
        }
      }
    } on AiException {
      rethrow;
    } on TimeoutException {
      throw const AiException(
        AiErrorType.timeout,
        'The Gemini request timed out. Please try again.',
      );
    } on SocketException {
      throw const AiException(
        AiErrorType.noInternet,
        'No internet connection. Check your network and try again.',
      );
    } on InvalidApiKey {
      throw const AiException(
        AiErrorType.invalidApiKey,
        'The Gemini API key is invalid or unauthorized.',
      );
    } on GenerativeAIException catch (error) {
      throw _mapGeminiException(error);
    } catch (_) {
      throw const AiException(
        AiErrorType.gemini,
        'Gemini could not complete the request.',
      );
    }
  }

  Future<String> _readAndValidateApiKey() async {
    final apiKey = await _secureStorageService.readGeminiApiKey();
    final trimmed = apiKey?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      throw const AiException(
        AiErrorType.invalidApiKey,
        'Gemini API key is missing. Add a valid key in Settings.',
      );
    }
    if (!_looksLikeGeminiApiKey(trimmed)) {
      throw const AiException(
        AiErrorType.invalidApiKey,
        'The Gemini API key format is invalid.',
      );
    }
    return trimmed;
  }

  bool _looksLikeGeminiApiKey(String apiKey) {
    return apiKey.length >= 20 && !apiKey.contains(RegExp(r'\s'));
  }

  AiException _mapGeminiException(GenerativeAIException error) {
    final lowerMessage = error.message.toLowerCase();
    if (lowerMessage.contains('api key') ||
        lowerMessage.contains('permission') ||
        lowerMessage.contains('unauthenticated')) {
      return const AiException(
        AiErrorType.invalidApiKey,
        'The Gemini API key is invalid or unauthorized.',
      );
    }
    return AiException(
      AiErrorType.gemini,
      error.message.isEmpty ? 'Gemini returned an error.' : error.message,
    );
  }
}
