enum AiErrorType { invalidApiKey, noInternet, timeout, unknown }

class AiException implements Exception {
  const AiException(this.type, this.message);

  final AiErrorType type;
  final String message;

  @override
  String toString() => message;
}
