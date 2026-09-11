import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechListenResult {
  const SpeechListenResult({required this.text, required this.isFinal});

  final String text;
  final bool isFinal;
}

class MicrophonePermissionDeniedException implements Exception {
  const MicrophonePermissionDeniedException();
}

class SpeechUnavailableException implements Exception {
  const SpeechUnavailableException(this.message);

  final String message;
}

class SpeechService {
  SpeechService({SpeechToText? speechToText})
      : _speechToText = speechToText ?? SpeechToText();

  final SpeechToText _speechToText;
  final StreamController<SpeechListenResult> _resultsController =
      StreamController<SpeechListenResult>.broadcast();
  Timer? _silenceTimer;
  bool _initialized = false;
  bool _disposed = false;

  Stream<SpeechListenResult> get results => _resultsController.stream;

  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> openSettings() => openAppSettings();

  Future<void> startListening({required String language}) async {
    final hasPermission = await requestMicrophonePermission();
    if (!hasPermission) throw const MicrophonePermissionDeniedException();

    await _configureAudioSession();
    await _initialize();
    _silenceTimer?.cancel();

    await _speechToText.listen(
      onResult: _handleResult,
      listenOptions: SpeechListenOptions(
        localeId: language,
        partialResults: true,
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(milliseconds: 850),
        cancelOnError: true,
      ),
    );
  }

  Future<void> stopListening() async {
    _silenceTimer?.cancel();
    await _speechToText.stop();
  }

  Future<void> cancelListening() async {
    _silenceTimer?.cancel();
    await _speechToText.cancel();
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _silenceTimer?.cancel();
    await _resultsController.close();
  }

  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    await session.setActive(true);
  }

  Future<void> _initialize() async {
    if (_initialized) return;
    final available = await _speechToText.initialize(
      onError: _handleError,
      onStatus: _handleStatus,
    );
    if (!available) {
      throw const SpeechUnavailableException('Speech recognition is unavailable.');
    }
    _initialized = true;
  }

  void _handleResult(SpeechRecognitionResult result) {
    final text = result.recognizedWords.trim();
    if (text.isEmpty) return;
    _resultsController.add(SpeechListenResult(text: text, isFinal: result.finalResult));
    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(milliseconds: 850), () async {
      _resultsController.add(SpeechListenResult(text: text, isFinal: true));
      await stopListening();
    });
  }

  void _handleStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      _silenceTimer?.cancel();
    }
  }

  void _handleError(SpeechRecognitionError error) {
    _resultsController.addError(SpeechUnavailableException(error.errorMsg));
  }
}
