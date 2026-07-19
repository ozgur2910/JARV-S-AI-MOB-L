import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/storage/hive_boxes.dart';
import '../../../ai/presentation/providers/chat_controller.dart';
import '../../data/services/speech_service.dart';
import '../../data/services/tts_service.dart';
import '../../data/services/voice_service.dart';
import '../../domain/models/voice_state.dart';

final speechServiceProvider = Provider<SpeechService>((ref) {
  final service = SpeechService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

final voiceServiceProvider = Provider<VoiceService>((ref) {
  final service = VoiceService(
    speechService: ref.watch(speechServiceProvider),
    ttsService: ref.watch(ttsServiceProvider),
  );
  return service;
});

final voiceControllerProvider = StateNotifierProvider<VoiceController, VoiceState>((ref) {
  return VoiceController(
    voiceService: ref.watch(voiceServiceProvider),
    chatController: ref.watch(chatControllerProvider.notifier),
    settingsBox: Hive.box<dynamic>(HiveBoxes.settings),
  );
});

class VoiceController extends StateNotifier<VoiceState> {
  VoiceController({
    required VoiceService voiceService,
    required ChatController chatController,
    required Box<dynamic> settingsBox,
  })  : _voiceService = voiceService,
        _chatController = chatController,
        _settingsBox = settingsBox,
        super(_readSettings(settingsBox)) {
    _speechSubscription = _voiceService.speechResults.listen(
      _handleSpeechResult,
      onError: _handleSpeechError,
    );
  }

  static const _languageKey = 'voice_language';
  static const _speechRateKey = 'voice_speech_rate';
  static const _pitchKey = 'voice_pitch';
  static const _autoListenKey = 'voice_auto_listen';

  final VoiceService _voiceService;
  final ChatController _chatController;
  final Box<dynamic> _settingsBox;
  StreamSubscription<SpeechListenResult>? _speechSubscription;
  bool _processingFinalResult = false;

  Future<void> startAutoListening() async {
    if (!state.autoListen || state.mode == VoiceMode.listening) return;
    await startListening();
  }

  Future<void> startListening() async {
    if (state.mode == VoiceMode.speaking || state.mode == VoiceMode.thinking) {
      return;
    }
    state = state.copyWith(
      mode: VoiceMode.listening,
      transcript: '',
      permissionDenied: false,
      clearError: true,
    );
    try {
      await _voiceService.startListening(language: state.language);
    } on MicrophonePermissionDeniedException {
      state = state.copyWith(
        mode: VoiceMode.error,
        permissionDenied: true,
        errorMessage: 'Microphone permission is required for JARVIS voice mode.',
      );
    } catch (error) {
      state = state.copyWith(
        mode: VoiceMode.error,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> retryPermission() => startListening();

  Future<bool> openAppSettings() => _voiceService.openSettings();

  Future<void> stopListening() async {
    await _voiceService.stopListening();
    if (state.mode == VoiceMode.listening) {
      state = state.copyWith(mode: VoiceMode.idle);
    }
  }

  Future<void> stopSpeaking() async {
    await _voiceService.stopSpeaking();
    if (state.autoListen) {
      await startListening();
    } else {
      state = state.copyWith(mode: VoiceMode.idle);
    }
  }

  Future<void> updateLanguage(String language) async {
    state = state.copyWith(language: language);
    await _settingsBox.put(_languageKey, language);
  }

  Future<void> updateSpeechRate(double speechRate) async {
    state = state.copyWith(speechRate: speechRate);
    await _settingsBox.put(_speechRateKey, speechRate);
  }

  Future<void> updatePitch(double pitch) async {
    state = state.copyWith(pitch: pitch);
    await _settingsBox.put(_pitchKey, pitch);
  }

  Future<void> updateAutoListen(bool autoListen) async {
    state = state.copyWith(autoListen: autoListen);
    await _settingsBox.put(_autoListenKey, autoListen);
    if (autoListen && state.mode == VoiceMode.idle) {
      await startListening();
    }
  }

  Future<void> _handleSpeechResult(SpeechListenResult result) async {
    state = state.copyWith(transcript: result.text);
    if (!result.isFinal || _processingFinalResult) return;
    _processingFinalResult = true;
    await _voiceService.stopListening();
    state = state.copyWith(mode: VoiceMode.thinking, transcript: result.text);

    try {
      final response = await _chatController.sendMessage(result.text);
      if (response == null || response.trim().isEmpty) {
        state = state.copyWith(
          mode: VoiceMode.error,
          errorMessage: 'JARVIS could not generate a spoken response.',
        );
        return;
      }

      state = state.copyWith(mode: VoiceMode.speaking);
      await _voiceService.speak(
        text: response,
        language: state.language,
        speechRate: state.speechRate,
        pitch: state.pitch,
      );

      if (state.autoListen) {
        await startListening();
      } else {
        state = state.copyWith(mode: VoiceMode.idle);
      }
    } catch (error) {
      state = state.copyWith(mode: VoiceMode.error, errorMessage: error.toString());
    } finally {
      _processingFinalResult = false;
    }
  }

  void _handleSpeechError(Object error, StackTrace stackTrace) {
    state = state.copyWith(mode: VoiceMode.error, errorMessage: error.toString());
  }

  static VoiceState _readSettings(Box<dynamic> box) {
    return VoiceState(
      language: box.get(_languageKey, defaultValue: 'en-US') as String,
      speechRate: (box.get(_speechRateKey, defaultValue: 0.48) as num).toDouble(),
      pitch: (box.get(_pitchKey, defaultValue: 1) as num).toDouble(),
      autoListen: box.get(_autoListenKey, defaultValue: true) as bool,
    );
  }

  @override
  void dispose() {
    _speechSubscription?.cancel();
    super.dispose();
  }
}
