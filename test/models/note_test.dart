import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_notes/data/models/note.dart';

void main() {
  group('Note Model', () {
    test('create() generates a new note with UUID and timestamps', () {
      final note = Note.create();

      expect(note.id, isNotEmpty);
      expect(note.id.length, equals(36)); // UUID format
      expect(note.createdAt, isNotNull);
      expect(note.updatedAt, isNotNull);
      expect(note.createdAt, equals(note.updatedAt));
    });

    test('create() with empty content creates valid Quill Delta JSON', () {
      final note = Note.create();
      final decoded = jsonDecode(note.content);

      expect(decoded, isList);
      expect(decoded, equals([
        {'insert': '\n'}
      ]));
    });

    test('create() with custom content stores it correctly', () {
      const customContent = '{"ops":[{"insert":"Hello"}]}';
      final note = Note.create(content: customContent);

      expect(note.content, equals(customContent));
    });

    test('fromMap() creates note from database map', () {
      final map = {
        'id': '123-456-789',
        'content': 'Test content',
        'createdAt': 1000000,
        'updatedAt': 2000000,
      };

      final note = Note.fromMap(map);

      expect(note.id, equals('123-456-789'));
      expect(note.content, equals('Test content'));
      expect(note.createdAt, equals(1000000));
      expect(note.updatedAt, equals(2000000));
    });

    test('toMap() converts note to database map', () {
      final note = Note(
        id: '123-456-789',
        content: 'Test content',
        createdAt: 1000000,
        updatedAt: 2000000,
      );

      final map = note.toMap();

      expect(map['id'], equals('123-456-789'));
      expect(map['content'], equals('Test content'));
      expect(map['createdAt'], equals(1000000));
      expect(map['updatedAt'], equals(2000000));
    });

    test('plainText returns text from Quill Delta', () {
      final deltaJson = jsonEncode([
        {'insert': 'Hello World\n'}
      ]);
      final note = Note(
        id: '123',
        content: deltaJson,
        createdAt: 1000,
        updatedAt: 1000,
      );

      expect(note.plainText, equals('Hello World'));
    });

    test('plainText falls back to raw content on parse error', () {
      final note = Note(
        id: '123',
        content: 'invalid json',
        createdAt: 1000,
        updatedAt: 1000,
      );

      expect(note.plainText, equals('invalid json'));
    });

    test('title returns first line of content', () {
      final deltaJson = jsonEncode([
        {'insert': 'First Line\nSecond Line\n'}
      ]);
      final note = Note(
        id: '123',
        content: deltaJson,
        createdAt: 1000,
        updatedAt: 1000,
      );

      expect(note.title, equals('First Line'));
    });

    test('title returns "Untitled" for empty content', () {
      final note = Note.create();
      expect(note.title, equals('Untitled'));
    });

    test('title returns "Untitled" for whitespace-only content', () {
      final deltaJson = jsonEncode([
        {'insert': '   \n'}
      ]);
      final note = Note(
        id: '123',
        content: deltaJson,
        createdAt: 1000,
        updatedAt: 1000,
      );

      expect(note.title, equals('Untitled'));
    });

    test('preview returns first 3 lines', () {
      final deltaJson = jsonEncode([
        {'insert': 'Line 1\nLine 2\nLine 3\nLine 4\n'}
      ]);
      final note = Note(
        id: '123',
        content: deltaJson,
        createdAt: 1000,
        updatedAt: 1000,
      );

      expect(note.preview, equals('Line 1\nLine 2\nLine 3'));
    });

    test('preview truncates at 150 characters', () {
      final longText = 'a' * 200;
      final deltaJson = jsonEncode([
        {'insert': '$longText\n'}
      ]);
      final note = Note(
        id: '123',
        content: deltaJson,
        createdAt: 1000,
        updatedAt: 1000,
      );

      expect(note.preview.length, equals(153)); // 150 + '...'
      expect(note.preview, endsWith('...'));
    });

    test('preview returns "No content" for empty note', () {
      final note = Note.create();
      expect(note.preview, equals('No content'));
    });

    test('copyWith() creates a new note with updated fields', () {
      final original = Note(
        id: '123',
        content: 'original',
        createdAt: 1000,
        updatedAt: 1000,
      );

      final updated = original.copyWith(
        content: 'updated',
        updatedAt: 2000,
      );

      expect(updated.id, equals('123'));
      expect(updated.content, equals('updated'));
      expect(updated.createdAt, equals(1000));
      expect(updated.updatedAt, equals(2000));
      expect(updated, isNot(same(original)));
    });

    test('equality operator works correctly', () {
      final note1 = Note(
        id: '123',
        content: 'test',
        createdAt: 1000,
        updatedAt: 1000,
      );

      final note2 = Note(
        id: '123',
        content: 'test',
        createdAt: 1000,
        updatedAt: 1000,
      );

      final note3 = Note(
        id: '456',
        content: 'test',
        createdAt: 1000,
        updatedAt: 1000,
      );

      expect(note1, equals(note2));
      expect(note1, isNot(equals(note3)));
    });

    test('hashCode is consistent', () {
      final note1 = Note(
        id: '123',
        content: 'test',
        createdAt: 1000,
        updatedAt: 1000,
      );

      final note2 = Note(
        id: '123',
        content: 'test',
        createdAt: 1000,
        updatedAt: 1000,
      );

      expect(note1.hashCode, equals(note2.hashCode));
    });

    test('toString() returns formatted string', () {
      final deltaJson = jsonEncode([
        {'insert': 'Test Title\n'}
      ]);
      final note = Note(
        id: '123',
        content: deltaJson,
        createdAt: 1000,
        updatedAt: 2000,
      );

      final str = note.toString();

      expect(str, contains('123'));
      expect(str, contains('Test Title'));
      expect(str, contains('1000'));
      expect(str, contains('2000'));
    });

    group('Image Handling', () {
      test('handles Delta with embedded image', () {
        // Sample base64 image data (1x1 transparent PNG)
        const base64Image = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
        final deltaJson = jsonEncode([
          {'insert': 'Text before image\n'},
          {'insert': {'image': 'data:image/png;base64,$base64Image'}},
          {'insert': '\nText after image\n'}
        ]);

        final note = Note(
          id: '123',
          content: deltaJson,
          createdAt: 1000,
          updatedAt: 1000,
        );

        expect(note.content, contains('data:image/png;base64'));
        expect(note.content, contains(base64Image));
      });

      test('plainText handles images correctly', () {
        const base64Image = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
        final deltaJson = jsonEncode([
          {'insert': 'Text before\n'},
          {'insert': {'image': 'data:image/png;base64,$base64Image'}},
          {'insert': '\nText after\n'}
        ]);

        final note = Note(
          id: '123',
          content: deltaJson,
          createdAt: 1000,
          updatedAt: 1000,
        );

        // Quill includes image embed as a special character in plainText
        final plainText = note.plainText;
        expect(plainText, isNotEmpty);
        expect(plainText, contains('Text before'));
        expect(plainText, contains('Text after'));
      });

      test('title extraction works with images in content', () {
        const base64Image = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
        final deltaJson = jsonEncode([
          {'insert': 'My Title\n'},
          {'insert': {'image': 'data:image/png;base64,$base64Image'}},
          {'insert': '\nBody text\n'}
        ]);

        final note = Note(
          id: '123',
          content: deltaJson,
          createdAt: 1000,
          updatedAt: 1000,
        );

        expect(note.title, equals('My Title'));
      });

      test('preview works with images in content', () {
        const base64Image = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
        final deltaJson = jsonEncode([
          {'insert': 'Title\n'},
          {'insert': {'image': 'data:image/png;base64,$base64Image'}},
          {'insert': '\nThis is the body text\n'}
        ]);

        final note = Note(
          id: '123',
          content: deltaJson,
          createdAt: 1000,
          updatedAt: 1000,
        );

        final preview = note.preview;
        expect(preview, isNotEmpty);
        expect(preview, isNot(equals('No content')));
      });

      test('handles multiple images in content', () {
        const base64Image = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
        final deltaJson = jsonEncode([
          {'insert': 'First image:\n'},
          {'insert': {'image': 'data:image/png;base64,$base64Image'}},
          {'insert': '\nSecond image:\n'},
          {'insert': {'image': 'data:image/jpeg;base64,$base64Image'}},
          {'insert': '\nEnd\n'}
        ]);

        final note = Note(
          id: '123',
          content: deltaJson,
          createdAt: 1000,
          updatedAt: 1000,
        );

        expect(note.content, contains('data:image/png;base64'));
        expect(note.content, contains('data:image/jpeg;base64'));
        final plainText = note.plainText;
        expect(plainText, contains('First image'));
        expect(plainText, contains('Second image'));
      });

      test('content storage preserves image data', () {
        const base64Image = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
        final deltaJson = jsonEncode([
          {'insert': 'Title\n'},
          {'insert': {'image': 'data:image/png;base64,$base64Image'}},
          {'insert': '\n'}
        ]);

        final note = Note(
          id: '123',
          content: deltaJson,
          createdAt: 1000,
          updatedAt: 1000,
        );

        // Verify image data is preserved in content
        expect(note.content, contains('data:image/png;base64'));
        expect(note.content, contains(base64Image));

        // Test copyWith preserves image data
        final copied = note.copyWith(updatedAt: 2000);
        expect(copied.content, equals(note.content));
        expect(copied.content, contains('data:image/png;base64'));
      });
    });
  });
}
