import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _geminiApiKey = 'gemini_api_key';
  final FlutterSecureStorage _storage;

  Future<String?> readGeminiApiKey() => _storage.read(key: _geminiApiKey);

  Future<void> saveGeminiApiKey(String value) =>
      _storage.write(key: _geminiApiKey, value: value.trim());

  Future<void> deleteGeminiApiKey() => _storage.delete(key: _geminiApiKey);
}
