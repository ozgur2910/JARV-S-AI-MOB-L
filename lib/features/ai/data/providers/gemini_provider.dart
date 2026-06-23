import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/storage_providers.dart';
import '../../domain/repositories/ai_repository.dart';
import '../repositories/ai_repository_impl.dart';
import '../services/gemini_service.dart';

final aiServiceProvider = Provider<AIService>((ref) {
  return GeminiService(ref.watch(secureStorageServiceProvider));
});

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepositoryImpl(ref.watch(aiServiceProvider));
});
