import 'dart:async';
import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/models/ai_exception.dart';

// ignore: camel_case_types
abstract class AIService {
  Future<String> sendMessage(String message);
}

class GeminiService implements AIService {
  GeminiService(this._secureStorageService);

  static const _modelName = 'gemini-1.5-flash';
  static const _timeout = Duration(seconds: 30);

  final SecureStorageService _secureStorageService;

  @override
  Future<String> sendMessage(String message) async {
    final apiKey = await _secureStorageService.readGeminiApiKey();
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw const AiException(
        AiErrorType.invalidApiKey,
        'Gemini API key is missing. Add a valid key in Settings.',
      );
    }

    try {
      final model = GenerativeModel(model: _modelName, apiKey: apiKey.trim());
      final response = await model
          .generateContent([Content.text(message)])
          .timeout(_timeout);
      final text = response.text?.trim();
      if (text == null || text.isEmpty) {
        throw const AiException(
          AiErrorType.unknown,
          'Gemini returned an empty response.',
        );
      }
      return text;
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
      final lowerMessage = error.message.toLowerCase();
      if (lowerMessage.contains('api key') ||
          lowerMessage.contains('permission') ||
          lowerMessage.contains('unauthenticated')) {
        throw const AiException(
          AiErrorType.invalidApiKey,
          'The Gemini API key is invalid or unauthorized.',
        );
      }
      throw AiException(AiErrorType.unknown, error.message);
    } catch (_) {
      throw const AiException(
        AiErrorType.unknown,
        'Something went wrong while contacting Gemini.',
      );
    }
  }
}
