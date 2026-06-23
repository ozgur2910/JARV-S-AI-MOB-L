import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/storage/hive_boxes.dart';
import '../../data/providers/gemini_provider.dart';
import '../../domain/models/ai_exception.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/repositories/ai_repository.dart';

class ChatState {
  const ChatState({
    required this.messages,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<ChatMessage> messages;
  final bool isLoading;
  final String? errorMessage;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  ChatController(this._aiRepository, this._box)
      : super(ChatState(messages: _readMessages(_box)));

  static const _messagesKey = 'messages';

  final AiRepository _aiRepository;
  final Box<dynamic> _box;

  Future<void> sendMessage(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty || state.isLoading) return;

    final userMessage = _message(ChatRole.user, trimmed);
    final pendingMessages = [...state.messages, userMessage];
    state = state.copyWith(
      messages: pendingMessages,
      isLoading: true,
      clearError: true,
    );
    await _saveMessages(pendingMessages);

    try {
      final response = await _aiRepository.sendMessage(trimmed);
      final assistantMessage = _message(ChatRole.assistant, response);
      final updatedMessages = [...pendingMessages, assistantMessage];
      state = state.copyWith(messages: updatedMessages, isLoading: false);
      await _saveMessages(updatedMessages);
    } on AiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unknown error occurred. Please try again.',
      );
    }
  }

  Future<void> clearConversation() async {
    state = const ChatState(messages: []);
    await _box.delete(_messagesKey);
  }

  static List<ChatMessage> _readMessages(Box<dynamic> box) {
    final raw = box.get(_messagesKey);
    if (raw is! List) return [];
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map(ChatMessage.fromJson)
        .toList(growable: false);
  }

  Future<void> _saveMessages(List<ChatMessage> messages) {
    return _box.put(
      _messagesKey,
      messages.map((message) => message.toJson()).toList(growable: false),
    );
  }

  static ChatMessage _message(ChatRole role, String content) {
    final now = DateTime.now();
    return ChatMessage(
      id: '${now.microsecondsSinceEpoch}-${role.name}',
      role: role,
      content: content,
      createdAt: now,
    );
  }
}

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  return ChatController(
    ref.watch(aiRepositoryProvider),
    Hive.box<dynamic>(HiveBoxes.conversations),
  );
});
