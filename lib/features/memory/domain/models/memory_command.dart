import 'memory_type.dart';

enum MemoryCommandAction { remember, forget, show, clear, none }

class MemoryCommand {
  const MemoryCommand({
    required this.action,
    this.content,
    this.type = MemoryType.general,
    this.importance = 3,
  });

  final MemoryCommandAction action;
  final String? content;
  final MemoryType type;
  final int importance;

  bool get isActionable => action != MemoryCommandAction.none;
}
