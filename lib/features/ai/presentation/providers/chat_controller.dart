import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/storage/hive_boxes.dart';
import '../../data/providers/gemini_provider.dart';
import '../../domain/models/ai_exception.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../../memory/data/services/memory_command_parser.dart';
import '../../../memory/data/services/memory_context_builder.dart';
import '../../../memory/domain/models/memory_command.dart';
import '../../../memory/domain/repositories/memory_repository.dart';
import '../../../memory/presentation/providers/memory_providers.dart';

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
  ChatController(
    this._aiRepository,
    this._memoryRepository,
    this._commandParser,
    this._contextBuilder,
    this._box,
  ) : super(ChatState(messages: _readMessages(_box)));

  static const _messagesKey = 'messages';

  final AiRepository _aiRepository;
  final MemoryRepository _memoryRepository;
  final MemoryCommandParser _commandParser;
  final MemoryContextBuilder _contextBuilder;
  final Box<dynamic> _box;

  Future<void> reloadHistory() async {
    state = state.copyWith(messages: _readMessages(_box), clearError: true);
  }

  Future<String?> sendMessage(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty || state.isLoading) return null;

    final commandResponse = await _handleMemoryCommand(trimmed);
    if (commandResponse != null) return commandResponse;

    final userMessage = _message(ChatRole.user, trimmed);
    final assistantMessage = _message(ChatRole.assistant, '');
    final pendingMessages = [...state.messages, userMessage, assistantMessage];

    state = state.copyWith(
      messages: pendingMessages,
      isLoading: true,
      clearError: true,
    );
    await _saveMessages(pendingMessages);

    final buffer = StringBuffer();
    try {
      final memoryContext = await _contextBuilder.buildContext(trimmed);
      final effectivePrompt = memoryContext.isEmpty
          ? trimmed
          : '$memoryContext\n\nCurrent user message:\n$trimmed';
      await for (final chunk in _aiRepository.streamMessage(effectivePrompt)) {
        buffer.write(chunk);
        final streamedMessage = assistantMessage.copyWith(
          content: buffer.toString(),
        );
        final updatedMessages = _replaceLastAssistantMessage(
          pendingMessages,
          streamedMessage,
        );
        state = state.copyWith(messages: updatedMessages);
        await _saveMessages(updatedMessages);
      }

      final finalText = buffer.toString().trim();
      if (finalText.isEmpty) {
        throw const AiException(
          AiErrorType.gemini,
          'Gemini returned an empty response.',
        );
      }

      final completedMessages = _replaceLastAssistantMessage(
        state.messages,
        assistantMessage.copyWith(content: finalText),
      );
      state = state.copyWith(messages: completedMessages, isLoading: false);
      await _saveMessages(completedMessages);
      return finalText;
    } on AiException catch (error) {
      final rolledBackMessages = [...state.messages]
        ..removeWhere((message) => message.id == assistantMessage.id);
      state = state.copyWith(
        messages: rolledBackMessages,
        isLoading: false,
        errorMessage: error.message,
      );
      await _saveMessages(rolledBackMessages);
      return null;
    } catch (_) {
      final rolledBackMessages = [...state.messages]
        ..removeWhere((message) => message.id == assistantMessage.id);
      state = state.copyWith(
        messages: rolledBackMessages,
        isLoading: false,
        errorMessage: 'An unknown error occurred. Please try again.',
      );
      await _saveMessages(rolledBackMessages);
      return null;
    }
  }


  Future<String?> _handleMemoryCommand(String content) async {
    final command = _commandParser.parse(content);
    if (!command.isActionable) return null;

    final userMessage = _message(ChatRole.user, content);
    String response;
    try {
      switch (command.action) {
        case MemoryCommandAction.remember:
          final memory = await _memoryRepository.addMemory(
            content: command.content ?? '',
            type: command.type,
            importance: command.importance,
            source: 'chat-command',
          );
          response = 'Memory stored: ${memory.content}';
          break;
        case MemoryCommandAction.forget:
          final query = command.content ?? '';
          final matches = await _memoryRepository.searchMemories(query);
          if (matches.isEmpty) {
            response = 'I could not find a matching memory to forget.';
          } else {
            await _memoryRepository.deleteMemory(matches.first.id);
            response = 'Memory forgotten: ${matches.first.content}';
          }
          break;
        case MemoryCommandAction.show:
          final memories = await _memoryRepository.getAllMemories();
          response = memories.isEmpty
              ? 'No long-term memories are stored yet.'
              : memories.take(8).map((memory) => '• ${memory.content}').join('\n');
          break;
        case MemoryCommandAction.clear:
          await _memoryRepository.clearAllMemories();
          response = 'All long-term memories have been cleared.';
          break;
        case MemoryCommandAction.none:
          return null;
      }
    } catch (error) {
      response = 'Memory action failed: $error';
    }

    final assistantMessage = _message(ChatRole.assistant, response);
    final messages = [...state.messages, userMessage, assistantMessage];
    state = state.copyWith(messages: messages, clearError: true);
    await _saveMessages(messages);
    return response;
  }


  Future<void> addLocalExchange({
    required String userContent,
    required String assistantContent,
  }) async {
    final messages = [
      ...state.messages,
      _message(ChatRole.user, userContent),
      _message(ChatRole.assistant, assistantContent),
    ];
    state = state.copyWith(messages: messages, clearError: true);
    await _saveMessages(messages);
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
        .where((message) => message.content.trim().isNotEmpty)
        .toList(growable: false);
  }

  Future<void> _saveMessages(List<ChatMessage> messages) {
    return _box.put(
      _messagesKey,
      messages
          .where((message) => message.content.trim().isNotEmpty)
          .map((message) => message.toJson())
          .toList(growable: false),
    );
  }

  List<ChatMessage> _replaceLastAssistantMessage(
    List<ChatMessage> messages,
    ChatMessage streamedMessage,
  ) {
    return [
      for (final message in messages)
        if (message.id == streamedMessage.id) streamedMessage else message,
    ];
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
    ref.watch(memoryRepositoryProvider),
    ref.watch(memoryCommandParserProvider),
    ref.watch(memoryContextBuilderProvider),
    Hive.box<dynamic>(HiveBoxes.conversations),
  );
});
