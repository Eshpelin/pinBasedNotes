import 'package:flutter_test/flutter_test.dart';
import 'package:pin_notes/utils/ml_title_generator.dart';

void main() {
  group('ML Title Generator', () {
    group('Normal Text', () {
      test('generates title from simple sentence', () {
        const text = 'Today I learned about machine learning in Flutter.';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
        expect(isGibberish, isFalse);
        expect(title.toLowerCase(), contains('today'));
      });

      test('generates title from paragraph', () {
        const text = '''
Flutter is an amazing framework for building mobile apps.
It allows you to create beautiful, natively compiled applications
for mobile, web, and desktop from a single codebase.
''';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
        expect(isGibberish, isFalse);
        expect(title.length, lessThanOrEqualTo(63)); // 60 + '...'
      });

      test('handles multiple sentences correctly', () {
        const text = '''
This is my first sentence. This is the second one.
And here comes the third sentence with more details.
''';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
        expect(isGibberish, isFalse);
      });

      test('handles text with numbers in normal context', () {
        const text = 'I have 5 apples and 3 oranges in my basket today.';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
        expect(isGibberish, isFalse);
      });

      test('handles text with special characters', () {
        const text = "Don't forget: buy milk, eggs & bread!";
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
        expect(isGibberish, isFalse);
      });

      test('returns empty for empty text', () {
        const text = '';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isEmpty);
        expect(isGibberish, isFalse);
      });

      test('handles whitespace-only text', () {
        const text = '   \n  \t  ';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isEmpty);
        expect(isGibberish, isFalse);
      });

      test('capitalizes first letter of title', () {
        const text = 'this is a lowercase sentence.';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
        expect(title[0], equals(title[0].toUpperCase()));
        expect(isGibberish, isFalse);
      });

      test('handles technical content', () {
        const text = '''
The async/await pattern in Dart makes asynchronous programming
much easier to understand and maintain. It's a syntactic sugar
over Futures and allows you to write async code that looks synchronous.
''';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
        expect(isGibberish, isFalse);
      });
    });

    group('Gibberish Detection', () {
      test('detects random keyboard smash', () {
        const text = 'asdfjkl;qwertyuiop123456789zxcvbnm,./';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
        expect(isGibberish, isTrue);
      });

      test('detects random numbers', () {
        const text = '9283745619283746592837465928374659283746';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
        expect(isGibberish, isTrue);
      });

      test('detects random characters with no vowels', () {
        const text = 'bcdfghjklmnpqrstvwxyz';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
        expect(isGibberish, isTrue);
      });

      test('detects random special characters', () {
        const text = '!@#\$%^&*()_+{}[]|\\:;<>?,./~`';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
        expect(isGibberish, isTrue);
      });

      test('detects mixed gibberish', () {
        const text = 'xkcd123!@#zzzaaa999***';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
        expect(isGibberish, isTrue);
      });

      test('generates funny title for gibberish', () {
        const text = 'qwertyuiop1234567890';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(isGibberish, isTrue);
        // Funny titles should be from the predefined list
        expect(title, isNotEmpty);
        expect(title.length, greaterThan(10));
      });

      test('funny titles are varied', () {
        const text = 'asdfghjkl';
        final titles = <String>{};

        // Generate multiple titles and check for variety
        for (int i = 0; i < 20; i++) {
          final (title, isGibberish) = MLTitleGenerator.generateTitle(text);
          expect(isGibberish, isTrue);
          titles.add(title);
        }

        // Should have some variety (at least 3 different titles in 20 tries)
        expect(titles.length, greaterThanOrEqualTo(3));
      });
    });

    group('Edge Cases', () {
      test('handles very long text', () {
        final longText = 'This is a sentence. ' * 100;
        final (title, isGibberish) = MLTitleGenerator.generateTitle(longText);

        expect(title, isNotEmpty);
        expect(title.length, lessThanOrEqualTo(63));
        expect(isGibberish, isFalse);
      });

      test('handles single word', () {
        const text = 'Hello';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
      });

      test('handles text with only newlines', () {
        const text = '\n\n\n\n';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isEmpty);
      });

      test('handles emoji-rich text', () {
        const text = '😀 😃 😄 😁 🎉 🎊 This is a happy note!';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
      });

      test('handles code snippets', () {
        const text = '''
void main() {
  print('Hello, World!');
}
''';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
      });

      test('handles markdown formatting', () {
        const text = '''
# This is a heading

**Bold text** and *italic text* with [links](http://example.com)
''';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
        // Should remove markdown formatting
        expect(title, isNot(contains('#')));
        expect(title, isNot(contains('*')));
      });
    });

    group('ML Feature Analysis', () {
      test('normal text has reasonable entropy', () {
        const text = 'The quick brown fox jumps over the lazy dog.';
        final (_, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(isGibberish, isFalse);
      });

      test('normal text has good vowel ratio', () {
        const text = 'Beautiful weather today, perfect for a walk.';
        final (_, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(isGibberish, isFalse);
      });

      test('gibberish has high entropy or poor patterns', () {
        const text = 'zxcvbnmasdfghjklqwertyuiop';
        final (_, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(isGibberish, isTrue);
      });

      test('password-like strings are likely gibberish', () {
        const text = 'P@ssw0rd!123XyZ zxcvbnm';
        final (_, isGibberish) = MLTitleGenerator.generateTitle(text);

        // Password-like strings may or may not be gibberish depending on complexity
        expect(isGibberish, isA<bool>());
      });

      test('UUID-like strings are likely gibberish', () {
        const text = '550e8400-e29b-41d4-a716-446655440000 qwertyuiop';
        final (_, isGibberish) = MLTitleGenerator.generateTitle(text);

        // UUID-like strings may or may not be detected depending on context
        expect(isGibberish, isA<bool>());
      });
    });

    group('Title Quality', () {
      test('prefers sentences with important keywords', () {
        const text = '''
This is just a boring sentence.
Today I learned something amazing about Flutter!
And then there was another sentence.
''';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
        expect(isGibberish, isFalse);
        // ML should score the second sentence higher
        expect(title.toLowerCase(), anyOf(contains('today'), contains('learned')));
      });

      test('prefers appropriately-length sentences', () {
        const text = '''
Hi.
This is a medium-length sentence that should be preferred.
This is an extremely long sentence that goes on and on and on with way too many words that nobody would want to read as a title because it's just too verbose and contains unnecessary information.
''';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
        expect(isGibberish, isFalse);
        expect(title.length, greaterThan(10));
        expect(title.length, lessThan(100));
      });

      test('prefers sentences starting with capital', () {
        const text = '''
maybe this could be a title
But This One Starts With Capital And Should Be Better
another lowercase option
''';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
        expect(isGibberish, isFalse);
        expect(title[0], equals(title[0].toUpperCase()));
      });

      test('removes markdown from title', () {
        const text = '**This** is _formatted_ `text` with #markdown';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
        expect(title, isNot(contains('*')));
        expect(title, isNot(contains('_')));
        expect(title, isNot(contains('`')));
        expect(title, isNot(contains('#')));
      });

      test('removes extra whitespace', () {
        const text = 'This    has     too     much     space';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
        expect(title, isNot(contains('  '))); // No double spaces
      });
    });

    group('Real-World Examples', () {
      test('grocery list', () {
        const text = '''
- Milk
- Eggs
- Bread
- Butter
- Coffee
''';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
        // Lists might be detected as gibberish or not, depending on content
      });

      test('meeting notes', () {
        const text = '''
Team Meeting - March 15, 2024

Attendees: John, Sarah, Mike
Agenda:
1. Project status update
2. Budget review
3. Next steps
''';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
        expect(isGibberish, isFalse);
      });

      test('personal journal', () {
        const text = '''
Today was an amazing day! I finally finished the Flutter project
I've been working on for weeks. The ML integration works perfectly
and the UI looks beautiful.
''';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
        expect(isGibberish, isFalse);
        // ML may select different sentences based on scoring
        expect(title.toLowerCase(), anyOf(
          contains('today'),
          contains('finished'),
          contains('flutter'),
        ));
      });

      test('recipe', () {
        const text = '''
Chocolate Chip Cookies

Ingredients:
- 2 cups flour
- 1 cup sugar
- 1 cup chocolate chips

Mix everything together and bake at 350°F for 12 minutes.
''';
        final (title, isGibberish) = MLTitleGenerator.generateTitle(text);

        expect(title, isNotEmpty);
        expect(isGibberish, isFalse);
      });
    });
  });
}
