import 'package:uuid/uuid.dart';

class Note {
  final String id;
  final String content;
  final int createdAt;
  final int updatedAt;

  Note({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a new note with a generated UUID and current timestamps
  factory Note.create({String content = ''}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Note(
      id: const Uuid().v4(),
      content: content,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a Note from a SQLite map
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      content: map['content'] as String,
      createdAt: map['createdAt'] as int,
      updatedAt: map['updatedAt'] as int,
    );
  }

  /// Convert Note to SQLite map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Get the first line of content as the title
  String get title {
    if (content.isEmpty) return 'Untitled';
    final firstLine = content.split('\n').first.trim();
    return firstLine.isEmpty ? 'Untitled' : firstLine;
  }

  /// Create a copy with updated fields
  Note copyWith({
    String? id,
    String? content,
    int? createdAt,
    int? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Note(id: $id, title: $title, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note &&
        other.id == id &&
        other.content == content &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        content.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
