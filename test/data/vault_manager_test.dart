import 'package:flutter_test/flutter_test.dart';
import 'package:pin_notes/data/db/vault_manager.dart';

void main() {
  group('VaultManager Exceptions', () {
    group('IncorrectPinException', () {
      test('creates exception with message', () {
        final exception = IncorrectPinException('Wrong PIN');

        expect(exception.message, equals('Wrong PIN'));
      });

      test('toString() returns message', () {
        final exception = IncorrectPinException('Invalid PIN');

        expect(exception.toString(), equals('Invalid PIN'));
      });
    });

    group('RateLimitExceededException', () {
      test('creates exception with message', () {
        final exception = RateLimitExceededException('Too many attempts');

        expect(exception.message, equals('Too many attempts'));
      });

      test('toString() returns message', () {
        final exception = RateLimitExceededException('Rate limit reached');

        expect(exception.toString(), equals('Rate limit reached'));
      });
    });

    group('VaultException', () {
      test('creates exception with message', () {
        final exception = VaultException('Database error');

        expect(exception.message, equals('Database error'));
      });

      test('toString() returns message', () {
        final exception = VaultException('Vault operation failed');

        expect(exception.toString(), equals('Vault operation failed'));
      });
    });

    group('VaultManager Constants', () {
      test('maxPinAttemptsPerDay is 10', () {
        expect(VaultManager.maxPinAttemptsPerDay, equals(10));
      });
    });
  });
}
