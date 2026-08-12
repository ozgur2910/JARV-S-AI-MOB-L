enum AiErrorType { invalidApiKey, noInternet, timeout, gemini, unknown }

class AiException implements Exception {
  const AiException(this.type, this.message);

  final AiErrorType type;
  final String message;

  @override
  String toString() => message;
}
