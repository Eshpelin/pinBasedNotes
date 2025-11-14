import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';

class Note {
  final String id;
  final String title; // Separate editable title field
  final String content; // Stores Quill Delta JSON
  final int createdAt;
  final int updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a new note with a generated UUID and current timestamps
  factory Note.create({String title = '', String content = ''}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    // Create empty Quill document if no content provided
    final deltaJson = content.isEmpty
        ? jsonEncode([
            {'insert': '\n'}
          ])
        : content;

    return Note(
      id: const Uuid().v4(),
      title: title,
      content: deltaJson,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a Note from a SQLite map
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      content: map['content'] as String,
      createdAt: map['createdAt'] as int,
      updatedAt: map['updatedAt'] as int,
    );
  }

  /// Convert Note to SQLite map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Get Quill Document from the stored Delta JSON
  Document get document {
    try {
      final delta = Delta.fromJson(jsonDecode(content) as List);
      return Document.fromDelta(delta);
    } catch (e) {
      // If parsing fails, treat as plain text and create a new document
      return Document()..insert(0, content);
    }
  }

  /// Get plain text content from the Quill document
  String get plainText {
    try {
      final doc = document;
      return doc.toPlainText().trim();
    } catch (e) {
      return content;
    }
  }

  /// Get display title (returns "Untitled" if title is empty)
  String get displayTitle {
    return title.trim().isEmpty ? 'Untitled' : title.trim();
  }

  /// Get preview text (first few lines of content)
  String get preview {
    final text = plainText;
    if (text.isEmpty) return 'No content';

    // Get first 3 lines or 150 characters, whichever is shorter
    final lines = text.split('\n').take(3).join('\n');
    if (lines.length > 150) {
      return '${lines.substring(0, 150)}...';
    }
    return lines;
  }

  /// Create a copy with updated fields
  Note copyWith({
    String? id,
    String? title,
    String? content,
    int? createdAt,
    int? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Note(id: $id, title: $displayTitle, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        content.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
