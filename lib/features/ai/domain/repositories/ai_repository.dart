abstract class AiRepository {
  Future<String> sendMessage(String message);

  Stream<String> streamMessage(String message);
}
