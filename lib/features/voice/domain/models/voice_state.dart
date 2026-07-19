enum VoiceMode { idle, listening, thinking, speaking, error }

class VoiceState {
  const VoiceState({
    this.mode = VoiceMode.idle,
    this.language = 'en-US',
    this.speechRate = 0.48,
    this.pitch = 1,
    this.autoListen = true,
    this.transcript = '',
    this.errorMessage,
    this.permissionDenied = false,
  });

  final VoiceMode mode;
  final String language;
  final double speechRate;
  final double pitch;
  final bool autoListen;
  final String transcript;
  final String? errorMessage;
  final bool permissionDenied;

  VoiceState copyWith({
    VoiceMode? mode,
    String? language,
    double? speechRate,
    double? pitch,
    bool? autoListen,
    String? transcript,
    String? errorMessage,
    bool? permissionDenied,
    bool clearError = false,
  }) {
    return VoiceState(
      mode: mode ?? this.mode,
      language: language ?? this.language,
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      autoListen: autoListen ?? this.autoListen,
      transcript: transcript ?? this.transcript,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      permissionDenied: permissionDenied ?? this.permissionDenied,
    );
  }
}
