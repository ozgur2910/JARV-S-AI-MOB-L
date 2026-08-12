class VisionResult {
  const VisionResult({
    required this.answer,
    required this.success,
    this.errorMessage,
    this.processedAt,
  });

  final String answer;
  final bool success;
  final String? errorMessage;
  final DateTime? processedAt;

  Map<String, dynamic> toJson() => {
        'answer': answer,
        'success': success,
        'errorMessage': errorMessage,
        'processedAt': processedAt?.toIso8601String(),
      };

  factory VisionResult.fromJson(Map<dynamic, dynamic> json) {
    final rawProcessedAt = json['processedAt'] as String?;
    return VisionResult(
      answer: json['answer'] as String? ?? '',
      success: json['success'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
      processedAt: rawProcessedAt == null ? null : DateTime.parse(rawProcessedAt),
    );
  }
}
