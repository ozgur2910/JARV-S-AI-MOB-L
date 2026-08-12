enum MemoryType { preference, personal, conversation, task, general }

extension MemoryTypeLabel on MemoryType {
  String get label {
    switch (this) {
      case MemoryType.preference:
        return 'Preference';
      case MemoryType.personal:
        return 'Personal';
      case MemoryType.conversation:
        return 'Conversation';
      case MemoryType.task:
        return 'Task';
      case MemoryType.general:
        return 'General';
    }
  }
}
