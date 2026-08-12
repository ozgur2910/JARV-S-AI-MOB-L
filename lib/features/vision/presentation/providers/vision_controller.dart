import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../ai/presentation/providers/chat_controller.dart';
import '../../../memory/domain/models/memory_type.dart';
import '../../../memory/domain/repositories/memory_repository.dart';
import '../../data/services/vision_service.dart';
import '../../domain/models/vision_result.dart';
import '../../domain/repositories/vision_repository.dart';

enum VisionMode { idle, selectingImage, camera, preview, analyzing, result, error }

class SelectedVisionImage {
  const SelectedVisionImage({
    required this.path,
    required this.bytes,
    required this.mimeType,
  });

  final String path;
  final Uint8List bytes;
  final String mimeType;
}

class VisionState {
  const VisionState({
    this.mode = VisionMode.idle,
    this.selectedImage,
    this.result,
    this.errorMessage,
  });

  final VisionMode mode;
  final SelectedVisionImage? selectedImage;
  final VisionResult? result;
  final String? errorMessage;

  VisionState copyWith({
    VisionMode? mode,
    SelectedVisionImage? selectedImage,
    VisionResult? result,
    String? errorMessage,
    bool clearImage = false,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return VisionState(
      mode: mode ?? this.mode,
      selectedImage: clearImage ? null : selectedImage ?? this.selectedImage,
      result: clearResult ? null : result ?? this.result,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class VisionController extends StateNotifier<VisionState> {
  VisionController({
    required VisionRepository repository,
    ChatController? chatController,
    MemoryRepository? memoryRepository,
    ImagePicker? imagePicker,
  })  : _repository = repository,
        _chatController = chatController,
        _memoryRepository = memoryRepository,
        _imagePicker = imagePicker ?? ImagePicker(),
        super(const VisionState());

  final VisionRepository _repository;
  final ChatController? _chatController;
  final MemoryRepository? _memoryRepository;
  final ImagePicker _imagePicker;

  Future<void> pickFromCamera() async {
    state = state.copyWith(mode: VisionMode.camera, clearError: true, clearResult: true);
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      state = state.copyWith(
        mode: VisionMode.error,
        errorMessage: 'Camera permission is required to capture an image.',
      );
      return;
    }
    await _pickImage(ImageSource.camera);
  }

  Future<void> pickFromGallery() async {
    state = state.copyWith(mode: VisionMode.selectingImage, clearError: true, clearResult: true);
    await _pickImage(ImageSource.gallery);
  }

  Future<void> analyzeSelectedImage(String question) async {
    final image = state.selectedImage;
    if (image == null) {
      state = state.copyWith(mode: VisionMode.error, errorMessage: 'Select an image before analysis.');
      return;
    }
    state = state.copyWith(mode: VisionMode.analyzing, clearError: true, clearResult: true);
    final result = await _repository.analyzeImage(
      imageBytes: image.bytes,
      mimeType: image.mimeType,
      question: question,
    );
    state = state.copyWith(
      mode: result.success ? VisionMode.result : VisionMode.error,
      result: result,
      errorMessage: result.errorMessage,
    );
    if (result.success && _chatController != null) {
      await _chatController.addLocalExchange(
        userContent: 'Vision question: ${question.trim().isEmpty ? 'What do you see?' : question.trim()}',
        assistantContent: result.answer,
      );
    }
  }

  Future<void> rememberLastResult() async {
    final result = state.result;
    if (result == null || !result.success || result.answer.trim().isEmpty) {
      state = state.copyWith(
        mode: VisionMode.error,
        errorMessage: 'Analyze an image before saving a vision memory.',
      );
      return;
    }
    final memoryRepository = _memoryRepository;
    if (memoryRepository == null) {
      state = state.copyWith(
        mode: VisionMode.error,
        errorMessage: 'Memory Engine is unavailable for this vision result.',
      );
      return;
    }
    await memoryRepository.addMemory(
      content: 'Vision result: ${result.answer}',
      type: MemoryType.general,
      importance: 3,
      source: 'vision-explicit',
    );
  }

  void retake() {
    state = const VisionState();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (pickedFile == null) {
        state = state.copyWith(
          mode: VisionMode.idle,
          errorMessage: 'Image selection was cancelled.',
          clearImage: true,
        );
        return;
      }
      final file = File(pickedFile.path);
      if (!await file.exists()) {
        state = state.copyWith(mode: VisionMode.error, errorMessage: 'Selected image could not be found.');
        return;
      }
      final bytes = await file.readAsBytes();
      final mimeType = VisionService.detectMimeType(pickedFile.name, bytes);
      VisionService.validateImageBytes(bytes, mimeType);
      state = state.copyWith(
        mode: VisionMode.preview,
        selectedImage: SelectedVisionImage(path: pickedFile.path, bytes: bytes, mimeType: mimeType),
        clearError: true,
        clearResult: true,
      );
    } on VisionValidationException catch (error) {
      state = state.copyWith(mode: VisionMode.error, errorMessage: error.message);
    } catch (_) {
      final message = source == ImageSource.camera
          ? 'Camera is unavailable or could not capture an image.'
          : 'Gallery is unavailable or permission was denied.';
      state = state.copyWith(mode: VisionMode.error, errorMessage: message);
    }
  }
}
