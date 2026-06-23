import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis_ai_mobile/features/ai/domain/models/chat_message.dart';

void main() {
  test('chat message serializes and restores from Hive-compatible json', () {
    final createdAt = DateTime.utc(2026, 6, 23, 12);
    final message = ChatMessage(
      id: 'message-1',
      role: ChatRole.user,
      content: 'Hello JARVIS',
      createdAt: createdAt,
    );

    final restored = ChatMessage.fromJson(message.toJson());

    expect(restored.id, message.id);
    expect(restored.role, message.role);
    expect(restored.content, message.content);
    expect(restored.createdAt, message.createdAt);
  });
}
