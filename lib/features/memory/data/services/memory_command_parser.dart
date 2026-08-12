import '../../domain/models/memory_command.dart';
import '../../domain/models/memory_type.dart';

class MemoryCommandParser {
  const MemoryCommandParser();

  MemoryCommand parse(String message) {
    final normalized = message.trim();
    if (normalized.isEmpty) return const MemoryCommand(action: MemoryCommandAction.none);

    final showPattern = RegExp(r'^(show|list|what are)\s+(my\s+)?memories\??$', caseSensitive: false);
    final clearPattern = RegExp(r'^(clear|delete|forget)\s+(all\s+)?(my\s+)?memories\.?$', caseSensitive: false);
    final rememberPattern = RegExp(
      r'^(jarvis remember that|jarvis remember|remember that|remember)\s+(.+)$',
      caseSensitive: false,
    );
    final forgetPattern = RegExp(
      r'^(jarvis forget that|jarvis forget|forget that|forget)\s+(.+)$',
      caseSensitive: false,
    );
    final turkishRememberPattern = RegExp(r'^(bunu hatırla|hatırla)\s*[:,-]?\s*(.+)$', caseSensitive: false);
    final turkishForgetPattern = RegExp(r'^(bunu unut|unut)\s*[:,-]?\s*(.+)$', caseSensitive: false);

    if (showPattern.hasMatch(normalized)) {
      return const MemoryCommand(action: MemoryCommandAction.show);
    }
    if (clearPattern.hasMatch(normalized)) {
      return const MemoryCommand(action: MemoryCommandAction.clear);
    }

    final remember = rememberPattern.firstMatch(normalized) ?? turkishRememberPattern.firstMatch(normalized);
    if (remember != null) {
      final content = _cleanContent(remember.group(remember.groupCount) ?? '');
      if (content.isEmpty) return const MemoryCommand(action: MemoryCommandAction.none);
      return MemoryCommand(
        action: MemoryCommandAction.remember,
        content: content,
        type: _inferType(content),
        importance: _inferImportance(content),
      );
    }

    final forget = forgetPattern.firstMatch(normalized) ?? turkishForgetPattern.firstMatch(normalized);
    if (forget != null) {
      final content = _cleanContent(forget.group(forget.groupCount) ?? '');
      return MemoryCommand(action: MemoryCommandAction.forget, content: content);
    }

    return const MemoryCommand(action: MemoryCommandAction.none);
  }

  String _cleanContent(String value) {
    return value.trim().replaceFirst(RegExp(r'^that\s+', caseSensitive: false), '').replaceAll(RegExp(r'[.!?]+$'), '').replaceAll(RegExp(r'\s+'), ' ');
  }

  MemoryType _inferType(String content) {
    final lower = content.toLowerCase();
    if (lower.contains('prefer') || lower.contains('like') || lower.contains('sev') || lower.contains('tercih')) {
      return MemoryType.preference;
    }
    if (lower.contains('task') || lower.contains('remind') || lower.contains('görev') || lower.contains('hatırlat')) {
      return MemoryType.task;
    }
    if (lower.contains('my name') || lower.contains('i am') || lower.contains('benim') || lower.contains('adım')) {
      return MemoryType.personal;
    }
    return MemoryType.general;
  }

  int _inferImportance(String content) {
    final lower = content.toLowerCase();
    if (lower.contains('important') || lower.contains('önemli')) return 5;
    if (_inferType(content) == MemoryType.personal) return 4;
    if (_inferType(content) == MemoryType.preference) return 4;
    return 3;
  }
}
