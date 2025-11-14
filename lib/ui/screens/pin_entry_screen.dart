import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../data/db/vault_manager.dart';
import '../../providers/pin_provider.dart';
import 'notes_list_screen.dart';

class PinEntryScreen extends HookConsumerWidget {
  const PinEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pin = useState('');
    final errorMessage = useState<String?>(null);
    final isLoading = useState(false);

    void onNumberPressed(String number) {
      if (pin.value.length < 10) {
        pin.value += number;
        errorMessage.value = null;
      }
    }

    void onBackspace() {
      if (pin.value.isNotEmpty) {
        pin.value = pin.value.substring(0, pin.value.length - 1);
        errorMessage.value = null;
      }
    }

    void onClear() {
      pin.value = '';
      errorMessage.value = null;
    }

    Future<void> onEnter() async {
      if (pin.value.length < 4 || pin.value.length > 10) {
        errorMessage.value = 'PIN must be 4-10 digits';
        return;
      }

      isLoading.value = true;
      errorMessage.value = null;

      try {
        // Try to open the vault with this PIN
        await VaultManager.openVault(pin.value);

        // Success - set the PIN in the provider and navigate
        ref.read(pinProvider.notifier).state = pin.value;

        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const NotesListScreen(),
            ),
          );
        }
      } on IncorrectPinException catch (e) {
        errorMessage.value = e.message;
      } on VaultException catch (e) {
        errorMessage.value = e.message;
      } catch (e) {
        errorMessage.value = 'Failed to open vault: $e';
      } finally {
        isLoading.value = false;
      }
    }

    final isPinValid = pin.value.length >= 4 && pin.value.length <= 10;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // App Title
              const Icon(
                Icons.lock_outline,
                size: 64,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              const Text(
                'PIN Notes',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your PIN to access your vault',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // PIN Display
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: errorMessage.value != null ? Colors.red : Colors.grey.shade300,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  pin.value.isEmpty ? 'Enter PIN' : '•' * pin.value.length,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: pin.value.isEmpty ? Colors.grey : Colors.black,
                    letterSpacing: 8,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // PIN Length Indicator
              Text(
                '${pin.value.length}/10 digits',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              // Error Message
              if (errorMessage.value != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage.value!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 48),

              // Numeric Keypad
              _NumericKeypad(
                onNumberPressed: onNumberPressed,
                onBackspace: onBackspace,
                onClear: onClear,
                onEnter: onEnter,
                isEnterEnabled: isPinValid && !isLoading.value,
                isLoading: isLoading.value,
              ),

              const Spacer(),

              // Info Text
              const Text(
                'Each PIN creates a separate encrypted vault.\nForgetting your PIN means losing access forever.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumericKeypad extends StatelessWidget {
  final Function(String) onNumberPressed;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onEnter;
  final bool isEnterEnabled;
  final bool isLoading;

  const _NumericKeypad({
    required this.onNumberPressed,
    required this.onBackspace,
    required this.onClear,
    required this.onEnter,
    required this.isEnterEnabled,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Rows 1-3: Numbers 1-9
        for (int row = 0; row < 3; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int col = 1; col <= 3; col++)
                  _KeypadButton(
                    text: '${row * 3 + col}',
                    onPressed: () => onNumberPressed('${row * 3 + col}'),
                  ),
              ],
            ),
          ),

        // Row 4: Clear, 0, Backspace
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _KeypadButton(
              text: 'C',
              onPressed: onClear,
              isSpecial: true,
            ),
            _KeypadButton(
              text: '0',
              onPressed: () => onNumberPressed('0'),
            ),
            _KeypadButton(
              icon: Icons.backspace_outlined,
              onPressed: onBackspace,
              isSpecial: true,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Enter Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isEnterEnabled ? onEnter : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Enter',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isSpecial;

  const _KeypadButton({
    this.text,
    this.icon,
    required this.onPressed,
    this.isSpecial = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSpecial ? Colors.grey.shade200 : Colors.white,
          foregroundColor: Colors.black,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: icon != null
            ? Icon(icon, size: 28)
            : Text(
                text!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
