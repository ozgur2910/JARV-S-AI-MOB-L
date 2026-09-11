import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AssistantStatus { ready, listening, thinking, speaking, error }

extension AssistantStatusLabel on AssistantStatus {
  String get label => switch (this) {
        AssistantStatus.ready => 'Ready',
        AssistantStatus.listening => 'Listening',
        AssistantStatus.thinking => 'Thinking',
        AssistantStatus.speaking => 'Speaking',
        AssistantStatus.error => 'Error',
      };
}

final assistantStatusProvider = StateProvider<AssistantStatus>((ref) {
  return AssistantStatus.ready;
});
