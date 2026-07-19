import 'dart:async';

import 'speech_service.dart';
import 'tts_service.dart';

class VoiceService {
  VoiceService({
    required SpeechService speechService,
    required TtsService ttsService,
  })  : _speechService = speechService,
        _ttsService = ttsService;

  final SpeechService _speechService;
  final TtsService _ttsService;

  Stream<SpeechListenResult> get speechResults => _speechService.results;

  Future<void> startListening({required String language}) {
    return _speechService.startListening(language: language);
  }

  Future<void> stopListening() => _speechService.stopListening();

  Future<void> cancelListening() => _speechService.cancelListening();

  Future<void> speak({
    required String text,
    required String language,
    required double speechRate,
    required double pitch,
  }) {
    return _ttsService.speak(
      text: text,
      language: language,
      speechRate: speechRate,
      pitch: pitch,
    );
  }

  Future<void> stopSpeaking() => _ttsService.stop();

  Future<bool> openSettings() => _speechService.openSettings();

  Future<void> dispose() async {
    await _speechService.dispose();
    await _ttsService.dispose();
  }
}
