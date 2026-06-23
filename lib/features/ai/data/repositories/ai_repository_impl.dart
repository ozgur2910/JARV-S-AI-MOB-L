import '../../domain/repositories/ai_repository.dart';
import '../services/gemini_service.dart';

class AiRepositoryImpl implements AiRepository {
  const AiRepositoryImpl(this._aiService);

  final AIService _aiService;

  @override
  Future<String> sendMessage(String message) => _aiService.sendMessage(message);
}
