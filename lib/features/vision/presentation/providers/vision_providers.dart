import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ai/data/providers/gemini_provider.dart';
import '../../../ai/presentation/providers/chat_controller.dart';
import '../../../memory/presentation/providers/memory_providers.dart';
import '../../data/repositories/vision_repository_impl.dart';
import '../../data/services/vision_service.dart';
import '../../domain/repositories/vision_repository.dart';
import 'vision_controller.dart';

final visionServiceProvider = Provider<VisionService>((ref) {
  return VisionService(ref.watch(aiRepositoryProvider));
});

final visionRepositoryProvider = Provider<VisionRepository>((ref) {
  return VisionRepositoryImpl(ref.watch(visionServiceProvider));
});

final visionControllerProvider = StateNotifierProvider<VisionController, VisionState>((ref) {
  return VisionController(
    repository: ref.watch(visionRepositoryProvider),
    chatController: ref.watch(chatControllerProvider.notifier),
    memoryRepository: ref.watch(memoryRepositoryProvider),
  );
});
