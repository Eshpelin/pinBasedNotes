import 'package:flutter_test/flutter_test.dart';
import 'package:pin_notes/utils/debounce.dart';

void main() {
  group('Debouncer', () {
    test('executes action after specified duration', () async {
      var executed = false;
      final debouncer = Debouncer(duration: const Duration(milliseconds: 100));

      debouncer(() {
        executed = true;
      });

      expect(executed, isFalse);

      await Future.delayed(const Duration(milliseconds: 150));

      expect(executed, isTrue);

      debouncer.dispose();
    });

    test('cancels previous action when called again', () async {
      var counter = 0;
      final debouncer = Debouncer(duration: const Duration(milliseconds: 100));

      // First call
      debouncer(() {
        counter++;
      });

      await Future.delayed(const Duration(milliseconds: 50));

      // Second call before first executes - should cancel first
      debouncer(() {
        counter++;
      });

      await Future.delayed(const Duration(milliseconds: 150));

      // Should only execute once (the second call)
      expect(counter, equals(1));

      debouncer.dispose();
    });

    test('cancel() prevents action from executing', () async {
      var executed = false;
      final debouncer = Debouncer(duration: const Duration(milliseconds: 100));

      debouncer(() {
        executed = true;
      });

      debouncer.cancel();

      await Future.delayed(const Duration(milliseconds: 150));

      expect(executed, isFalse);

      debouncer.dispose();
    });

    test('dispose() cancels pending action', () async {
      var executed = false;
      final debouncer = Debouncer(duration: const Duration(milliseconds: 100));

      debouncer(() {
        executed = true;
      });

      debouncer.dispose();

      await Future.delayed(const Duration(milliseconds: 150));

      expect(executed, isFalse);
    });

    test('can handle multiple rapid calls', () async {
      var counter = 0;
      final debouncer = Debouncer(duration: const Duration(milliseconds: 100));

      // Simulate rapid typing
      for (int i = 0; i < 10; i++) {
        debouncer(() {
          counter++;
        });
        await Future.delayed(const Duration(milliseconds: 20));
      }

      // Wait for debounce to complete
      await Future.delayed(const Duration(milliseconds: 150));

      // Should only execute once after all the rapid calls
      expect(counter, equals(1));

      debouncer.dispose();
    });

    test('works correctly with zero duration', () async {
      var executed = false;
      final debouncer = Debouncer(duration: Duration.zero);

      debouncer(() {
        executed = true;
      });

      // Even with zero duration, Timer will execute in next event loop
      await Future.delayed(const Duration(milliseconds: 10));

      expect(executed, isTrue);

      debouncer.dispose();
    });

    test('multiple dispose calls are safe', () {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 100));

      expect(() {
        debouncer.dispose();
        debouncer.dispose();
        debouncer.dispose();
      }, returnsNormally);
    });

    test('can be reused after cancel', () async {
      var counter = 0;
      final debouncer = Debouncer(duration: const Duration(milliseconds: 100));

      debouncer(() {
        counter++;
      });

      debouncer.cancel();

      await Future.delayed(const Duration(milliseconds: 150));
      expect(counter, equals(0));

      // Reuse after cancel
      debouncer(() {
        counter++;
      });

      await Future.delayed(const Duration(milliseconds: 150));
      expect(counter, equals(1));

      debouncer.dispose();
    });
  });
}
