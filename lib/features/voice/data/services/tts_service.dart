import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService({FlutterTts? flutterTts}) : _flutterTts = flutterTts ?? FlutterTts();

  final FlutterTts _flutterTts;
  Completer<void>? _speakCompleter;

  Future<void> speak({
    required String text,
    required String language,
    required double speechRate,
    required double pitch,
  }) async {
    if (text.trim().isEmpty) return;

    await _configureAudioSession();
    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setLanguage(language);
    await _flutterTts.setSpeechRate(speechRate);
    await _flutterTts.setPitch(pitch);

    _speakCompleter = Completer<void>();
    _flutterTts.setCompletionHandler(() => _completeSpeaking());
    _flutterTts.setCancelHandler(() => _completeSpeaking());
    _flutterTts.setErrorHandler((message) => _completeSpeaking(error: message));

    await _flutterTts.speak(text);
    return _speakCompleter!.future;
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _completeSpeaking();
  }

  Future<void> dispose() => stop();

  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    await session.setActive(true);
  }

  void _completeSpeaking({String? error}) {
    final completer = _speakCompleter;
    if (completer == null || completer.isCompleted) return;
    if (error == null || error.isEmpty) {
      completer.complete();
    } else {
      completer.completeError(Exception(error));
    }
  }
}
