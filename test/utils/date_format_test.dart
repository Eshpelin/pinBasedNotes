import 'package:flutter_test/flutter_test.dart';
import 'package:pin_notes/utils/date_format.dart';

void main() {
  group('DateFormatter', () {
    group('formatTimestamp()', () {
      test('returns "Just now" for timestamps less than 1 minute ago', () {
        final now = DateTime.now();
        final timestamp = now.millisecondsSinceEpoch - 30000; // 30 seconds ago

        final result = DateFormatter.formatTimestamp(timestamp);

        expect(result, equals('Just now'));
      });

      test('returns minutes for timestamps less than 1 hour ago', () {
        final now = DateTime.now();
        final timestamp = now.millisecondsSinceEpoch - 5 * 60 * 1000; // 5 minutes ago

        final result = DateFormatter.formatTimestamp(timestamp);

        expect(result, equals('5 minutes ago'));
      });

      test('returns singular "minute" for 1 minute ago', () {
        final now = DateTime.now();
        final timestamp = now.millisecondsSinceEpoch - 60 * 1000; // 1 minute ago

        final result = DateFormatter.formatTimestamp(timestamp);

        expect(result, equals('1 minute ago'));
      });

      test('returns hours for timestamps less than 24 hours ago', () {
        final now = DateTime.now();
        final timestamp = now.millisecondsSinceEpoch - 3 * 60 * 60 * 1000; // 3 hours ago

        final result = DateFormatter.formatTimestamp(timestamp);

        expect(result, equals('3 hours ago'));
      });

      test('returns singular "hour" for 1 hour ago', () {
        final now = DateTime.now();
        final timestamp = now.millisecondsSinceEpoch - 60 * 60 * 1000; // 1 hour ago

        final result = DateFormatter.formatTimestamp(timestamp);

        expect(result, equals('1 hour ago'));
      });

      test('returns days for timestamps less than 7 days ago', () {
        final now = DateTime.now();
        final timestamp = now.millisecondsSinceEpoch - 3 * 24 * 60 * 60 * 1000; // 3 days ago

        final result = DateFormatter.formatTimestamp(timestamp);

        expect(result, equals('3 days ago'));
      });

      test('returns singular "day" for 1 day ago', () {
        final now = DateTime.now();
        final timestamp = now.millisecondsSinceEpoch - 24 * 60 * 60 * 1000; // 1 day ago

        final result = DateFormatter.formatTimestamp(timestamp);

        expect(result, equals('1 day ago'));
      });

      test('returns formatted date with time for same year', () {
        final now = DateTime.now();
        final date = DateTime(now.year, 1, 15, 14, 30); // Jan 15, 2:30 PM
        final timestamp = date.millisecondsSinceEpoch;

        final result = DateFormatter.formatTimestamp(timestamp);

        expect(result, contains('Jan 15'));
        expect(result, contains('2:30'));
      });

      test('returns formatted date without time for different year', () {
        final now = DateTime.now();
        final date = DateTime(now.year - 1, 6, 20); // Last year, June 20
        final timestamp = date.millisecondsSinceEpoch;

        final result = DateFormatter.formatTimestamp(timestamp);

        expect(result, contains('Jun 20'));
        expect(result, contains('${now.year - 1}'));
        expect(result, isNot(contains(':')));
      });
    });

    group('formatFullDateTime()', () {
      test('returns full date and time', () {
        final date = DateTime(2024, 3, 15, 14, 30);
        final timestamp = date.millisecondsSinceEpoch;

        final result = DateFormatter.formatFullDateTime(timestamp);

        expect(result, equals('Mar 15, 2024 2:30 PM'));
      });
    });

    group('formatDate()', () {
      test('returns formatted date without time', () {
        final date = DateTime(2024, 7, 4);
        final timestamp = date.millisecondsSinceEpoch;

        final result = DateFormatter.formatDate(timestamp);

        expect(result, equals('Jul 4, 2024'));
      });
    });

    group('formatTime()', () {
      test('returns formatted time without date', () {
        final date = DateTime(2024, 3, 15, 9, 15);
        final timestamp = date.millisecondsSinceEpoch;

        final result = DateFormatter.formatTime(timestamp);

        expect(result, equals('9:15 AM'));
      });

      test('returns PM time correctly', () {
        final date = DateTime(2024, 3, 15, 16, 45);
        final timestamp = date.millisecondsSinceEpoch;

        final result = DateFormatter.formatTime(timestamp);

        expect(result, equals('4:45 PM'));
      });
    });
  });
}
