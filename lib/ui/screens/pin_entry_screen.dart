import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../data/db/vault_manager.dart';
import '../../providers/pin_provider.dart';
import 'notes_list_screen.dart';
import 'rate_limit_error_screen.dart';

class PinEntryScreen extends HookConsumerWidget {
  const PinEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinController = useTextEditingController();
    final pinText = useState(''); // Track text for UI updates
    final errorMessage = useState<String?>(null);
    final isLoading = useState(false);
    final obscurePin = useState(true);
    final focusNode = useFocusNode();

    // Auto-focus the text field when screen loads
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        focusNode.requestFocus();
      });
      return null;
    }, []);

    Future<void> onEnter() async {
      final pin = pinController.text.trim();

      if (pin.length < 4 || pin.length > 20) {
        errorMessage.value = 'PIN must be 4-20 characters';
        return;
      }

      isLoading.value = true;
      errorMessage.value = null;

      try {
        // Try to open the vault with this PIN
        await VaultManager.openVault(pin);

        // Success - set the PIN in the provider and navigate
        ref.read(pinProvider.notifier).state = pin;

        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const NotesListScreen(),
            ),
          );
        }
      } on RateLimitExceededException catch (_) {
        // Navigate to rate limit error screen
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const RateLimitErrorScreen(),
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

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),

                // App Title
                Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
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

                // PIN Input Field
                TextField(
                  controller: pinController,
                  focusNode: focusNode,
                  obscureText: obscurePin.value,
                  maxLength: 20,
                  autofocus: true,
                  enabled: !isLoading.value,
                  decoration: InputDecoration(
                    labelText: 'PIN',
                    hintText: 'Enter 4-20 characters',
                    prefixIcon: const Icon(Icons.vpn_key),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePin.value ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        obscurePin.value = !obscurePin.value;
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorText: errorMessage.value,
                    errorMaxLines: 2,
                    counterText: '${pinText.value.length}/20',
                  ),
                  onChanged: (value) {
                    // Update text state for UI rebuilds
                    pinText.value = value;
                    // Clear error when user starts typing
                    if (errorMessage.value != null) {
                      errorMessage.value = null;
                    }
                  },
                  onSubmitted: (_) {
                    if (!isLoading.value) {
                      onEnter();
                    }
                  },
                ),

                const SizedBox(height: 32),

                // Enter Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: !isLoading.value && pinText.value.length >= 4
                        ? onEnter
                        : null,
                    child: isLoading.value
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Unlock Vault',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 48),

                // Info Text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Important',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Each PIN creates a separate encrypted vault\n'
                        '• Use alphanumeric characters for stronger security\n'
                        '• Forgetting your PIN means losing access forever\n'
                        '• Recommended: 12+ characters (letters + numbers)',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade900,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
