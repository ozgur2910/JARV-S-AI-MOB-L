import '../../domain/models/memory_type.dart';

class MemoryEntry {
  const MemoryEntry({
    required this.id,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.importance,
    required this.source,
  });

  final String id;
  final String content;
  final MemoryType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int importance;
  final String source;

  MemoryEntry copyWith({
    String? id,
    String? content,
    MemoryType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? importance,
    String? source,
  }) {
    return MemoryEntry(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      importance: importance ?? this.importance,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'type': type.name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'importance': importance,
        'source': source,
      };

  factory MemoryEntry.fromJson(Map<dynamic, dynamic> json) {
    return MemoryEntry(
      id: json['id'] as String,
      content: json['content'] as String,
      type: MemoryType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => MemoryType.general,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      importance: (json['importance'] as num).clamp(1, 5).toInt(),
      source: json['source'] as String? ?? 'manual',
    );
  }
}
