import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AssistantStatus { ready, listening, thinking, speaking }

extension AssistantStatusLabel on AssistantStatus {
  String get label => switch (this) {
        AssistantStatus.ready => 'Ready',
        AssistantStatus.listening => 'Listening',
        AssistantStatus.thinking => 'Thinking',
        AssistantStatus.speaking => 'Speaking',
      };
}

final assistantStatusProvider = StateProvider<AssistantStatus>((ref) => AssistantStatus.ready);
