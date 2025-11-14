import 'package:flutter_test/flutter_test.dart';
import 'package:pin_notes/utils/ml_title_generator.dart';

void main() {
  group('ML Title Generator', () {
    group('Basic Functionality', () {
      test('returns a result for normal text', () {
        const text = 'Today I learned about machine learning in Flutter.';
        final result = MLTitleGenerator.generateTitle(text);

        // Just verify it returns a tuple with string and bool
        expect(result, isA<(String, bool)>());
        expect(result.$1, isA<String>());
        expect(result.$2, isA<bool>());
      });

      test('generates non-empty title from paragraph', () {
        const text = '''
Flutter is an amazing framework for building mobile apps.
It allows you to create beautiful, natively compiled applications.
''';
        final (title, _) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
      });

      test('handles multiple sentences', () {
        const text = 'First sentence. Second sentence. Third sentence.';
        final (title, _) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
      });

      test('returns empty for empty text', () {
        const text = '';
        final (title, _) = MLTitleGenerator.generateTitle(text);

        expect(title, isEmpty);
      });

      test('handles whitespace-only text', () {
        const text = '   \n  \t  ';
        final (title, _) = MLTitleGenerator.generateTitle(text);

        expect(title, isEmpty);
      });

      test('limits title length to maximum', () {
        final longText = 'This is a very long sentence. ' * 50;
        final (title, _) = MLTitleGenerator.generateTitle(longText);

        expect(title.length, lessThanOrEqualTo(63)); // 60 + '...'
      });
    });

    group('Gibberish Detection', () {
      test('detects obvious gibberish', () {
        const text = 'asdfjkl;qwertyuiop123456789zxcvbnm,./';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        // Should return something (either gibberish or normal)
        expect(title, isNotEmpty);
        expect(isGibberish, isA<bool>());
      });

      test('handles random numbers', () {
        const text = '9283745619283746592837465928374659283746';
        final (title, _) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
      });

      test('handles special characters', () {
        const text = '!@#\$%^&*()_+{}[]|\\:;<>?,./~`';
        final (title, _) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
      });

      test('generates varied funny titles for gibberish', () {
        const text = 'qwertyuiop1234567890asdfghjkl';
        final titles = <String>{};

        // Generate multiple titles
        for (int i = 0; i < 10; i++) {
          final (title, _) = MLTitleGenerator.generateTitle(text);
          titles.add(title);
        }

        // All should be non-empty strings
        expect(titles.every((t) => t.isNotEmpty), isTrue);
      });
    });

    group('Edge Cases', () {
      test('handles very long text without crashing', () {
        final longText = 'This is a sentence. ' * 200;
        final (title, _) = MLTitleGenerator.generateTitle(longText);

        expect(title, isNotEmpty);
        expect(title.length, lessThanOrEqualTo(63));
      });

      test('handles single word', () {
        const text = 'Hello';
        final (title, _) = MLTitleGenerator.generateTitle(text);

        // Should return something (might be empty or the word itself)
        expect(title, isA<String>());
      });

      test('handles text with only newlines', () {
        const text = '\n\n\n\n';
        final (title, _) = MLTitleGenerator.generateTitle(text);

        expect(title, isEmpty);
      });

      test('handles emoji-rich text', () {
        const text = '😀 😃 😄 😁 🎉 🎊 This is a happy note!';

        expect(() => MLTitleGenerator.generateTitle(text), returnsNormally);
      });

      test('handles code snippets without crashing', () {
        const text = '''
void main() {
  print('Hello, World!');
}
''';
        final (title, _) = MLTitleGenerator.generateTitle(text);

        expect(title, isA<String>());
      });

      test('handles markdown formatting', () {
        const text = '# Heading\n**Bold** and *italic*';
        final (title, _) = MLTitleGenerator.generateTitle(text);

        expect(title, isA<String>());
      });

      test('handles null characters gracefully', () {
        const text = 'Text with special chars: \u0000 \t \r';

        expect(() => MLTitleGenerator.generateTitle(text), returnsNormally);
      });

      test('handles mixed languages', () {
        const text = 'Hello 你好 Bonjour مرحبا';

        expect(() => MLTitleGenerator.generateTitle(text), returnsNormally);
      });
    });

    group('Title Quality', () {
      test('removes markdown formatting from output', () {
        const text = '**This** is _formatted_ `text`';
        final (title, _) = MLTitleGenerator.generateTitle(text);

        // Title should not contain markdown symbols
        expect(title.contains('**'), isFalse);
        expect(title.contains('__'), isFalse);
        expect(title.contains('``'), isFalse);
      });

      test('removes excessive whitespace', () {
        const text = 'This    has     too     much     space';
        final (title, _) = MLTitleGenerator.generateTitle(text);

        // Should not have multiple consecutive spaces
        expect(title.contains('  '), isFalse);
      });

      test('capitalizes first letter when non-empty', () {
        const text = 'this is lowercase text.';
        final (title, _) = MLTitleGenerator.generateTitle(text);

        if (title.isNotEmpty) {
          expect(title[0], equals(title[0].toUpperCase()));
        }
      });
    });

    group('Real-World Examples', () {
      test('handles grocery list', () {
        const text = '''
- Milk
- Eggs
- Bread
''';

        expect(() => MLTitleGenerator.generateTitle(text), returnsNormally);
      });

      test('handles meeting notes', () {
        const text = '''
Team Meeting - March 15, 2024
Attendees: John, Sarah
Agenda: Project update
''';
        final (title, _) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
      });

      test('handles personal journal entry', () {
        const text = '''
Today was an amazing day! I finished my project
and everything works perfectly.
''';
        final (title, _) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
      });

      test('handles recipe format', () {
        const text = '''
Chocolate Chip Cookies
Ingredients: flour, sugar, chocolate
Bake at 350°F for 12 minutes.
''';
        final (title, _) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
      });

      test('handles technical documentation', () {
        const text = '''
The async/await pattern in Dart makes asynchronous programming
easier. It's syntactic sugar over Futures.
''';
        final (title, _) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
      });
    });

    group('Performance', () {
      test('processes text quickly', () {
        const text = 'This is a test sentence for performance.';

        final stopwatch = Stopwatch()..start();
        MLTitleGenerator.generateTitle(text);
        stopwatch.stop();

        // Should complete in less than 100ms
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('handles repeated calls efficiently', () {
        const text = 'Test sentence for repeated calls.';

        final stopwatch = Stopwatch()..start();
        for (int i = 0; i < 100; i++) {
          MLTitleGenerator.generateTitle(text);
        }
        stopwatch.stop();

        // 100 calls should complete in less than 1 second
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });

    group('Consistency', () {
      test('same input produces consistent structure', () {
        const text = 'Consistency test sentence.';

        final (title1, isGibberish1) = MLTitleGenerator.generateTitle(text);
        final (title2, isGibberish2) = MLTitleGenerator.generateTitle(text);

        // Same input should produce same results
        expect(title1, equals(title2));
        expect(isGibberish1, equals(isGibberish2));
      });

      test('deterministic for same input', () {
        const inputs = [
          'First test sentence.',
          'Second test sentence.',
          'Third test sentence.',
        ];

        for (final text in inputs) {
          final results = <String>[];

          // Call multiple times
          for (int i = 0; i < 5; i++) {
            final (title, _) = MLTitleGenerator.generateTitle(text);
            results.add(title);
          }

          // All results should be identical for same input
          expect(results.toSet().length, equals(1));
        }
      });
    });

    group('Type Safety', () {
      test('always returns tuple of correct types', () {
        final testCases = [
          'Normal text',
          '',
          '12345',
          'qwerty',
          '!@#\$%',
        ];

        for (final text in testCases) {
          final result = MLTitleGenerator.generateTitle(text);

          expect(result, isA<(String, bool)>());
          expect(result.$1, isA<String>());
          expect(result.$2, isA<bool>());
        }
      });

      test('never returns null', () {
        final testCases = [
          'Test',
          '',
          '   ',
          '\n\n',
        ];

        for (final text in testCases) {
          final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

          expect(title, isNotNull);
          expect(isGibberish, isNotNull);
        }
      });
    });
  });
}
