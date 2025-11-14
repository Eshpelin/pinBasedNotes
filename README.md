# PIN Notes

A secure, privacy-focused note-taking app for Android that uses a multi-vault model where each PIN protects a separate, encrypted collection of notes.

## What is PIN Notes?

PIN Notes is a lightweight Android application that allows you to create and manage encrypted notes. Each PIN you use corresponds to a unique, encrypted database (a "vault"), allowing you to keep different sets of notes entirely separate and secure. All data is stored locally on your device.

### Key Features

- **Multi-Vault System**: Each PIN creates and unlocks a separate, independent vault for your notes.
- **Military-Grade Encryption**: All notes are stored in an encrypted SQLCipher database using 256-bit AES.
- **Auto-Lock**: The app automatically locks when it goes to the background, requiring re-authentication.
- **Completely Private**: No internet connection required, no cloud sync, no data collection.
- **Simple & Clean**: Minimalist interface focused on security and ease of use.
- **Offline-First**: Everything works completely offline.

## How It Works

1. **Enter a PIN**: On the main screen, enter a PIN.
2. **Open or Create a Vault**: 
    - If a vault for that PIN already exists, it will be unlocked.
    - If it's a new PIN, a new, empty vault will be created and secured with that PIN.
3. **Manage Notes**: Add, edit, and delete notes within the currently open vault.
4. **Auto-Lock**: The app automatically locks when you leave, securing the vault.

**Important**: Since each PIN opens a different vault, forgetting a PIN means losing access to the notes stored within that specific vault. There is no recovery mechanism.

## Prerequisites

- **Flutter SDK**: Version 3.0.0 or higher
- **Android SDK**:
  - Minimum SDK: 21 (Android 5.0 Lollipop)
  - Target SDK: 35 (Android 15)
  - Compile SDK: 35
- **Java/Kotlin**: For Android build tools
- **Android NDK**: Version 26.3 or higher (automatically installed during build)

## Getting Started

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repository-url>
   cd pinBasedNotes
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**

   For development (debug mode):
   ```bash
   flutter run
   ```

## Implementation Details

The app is built using modern Flutter practices, with a focus on security, performance, and maintainability.

### Architecture
- **State Management**: **Riverpod** and **Flutter Hooks** are used for reactive state management.
- **Database**: **SQLCipher** (via the `sqflite_sqlcipher` package) provides transparent, 256-bit AES encryption.
- **UI**: The UI is built with standard Flutter widgets.

### Core Components

- **`main.dart`**: The app's entry point, setting up the Riverpod `ProviderScope`.

- **`data/db/vault_manager.dart`**: The core of the security model. It's responsible for:
  - Opening a database file (`vault_<pin>.db`) using the PIN as the decryption key.
  - Creating a new encrypted database if one for the entered PIN does not exist.
  - Handling database migrations for schema updates.
  - Managing a separate, unencrypted database (`meta.db`) to track PIN attempts for rate-limiting purposes, preventing brute-force attacks against existing vaults.

- **`providers/`**: Riverpod providers that manage the app's state.

- **`ui/screens/`**: The app's screens, including the PIN entry and notes list.

## Security Implementation

The app's security relies on the robust, industry-standard SQLCipher library and a multi-vault model.

### Encryption & Vault Logic
1. The user enters a PIN on the `PinEntryScreen`.
2. `VaultManager.openVault()` is called with this PIN.
3. The manager checks if a database file corresponding to the PIN (e.g., `vault_1234.db`) exists.
4. **If the file exists**, `sqflite_sqlcipher` attempts to decrypt it using the PIN as the key.
    - If successful, the vault is opened.
    - If it fails (due to a library error, as the PIN is part of the filename), an exception is thrown.
5. **If the file does not exist**, a new database file is created and encrypted using the new PIN.
6. This design means there is no "incorrect PIN" error in the traditional sense. An unrecognized PIN simply leads to a new, empty vault.

### Auto-Lock Mechanism
To protect user data, the app automatically locks itself by monitoring the app's lifecycle. When the app is paused or detached, it programmatically navigates back to the `PinEntryScreen`, requiring re-authentication on the next launch.

### Rate Limiting
To prevent programmatic brute-force attacks, the app limits the number of unique PINs that can be tried in a single day. This is managed by the `MetaDbManager`, which logs a hash of each PIN attempt in a separate, unencrypted database.

## Build Configuration

### Android

The app has been configured with the following Android settings:

- **Gradle**: Version 8.9
- **Android Gradle Plugin**: Version 8.7.0
- **Kotlin**: Version 2.1.10
- **Compile SDK**: 35
- **Target SDK**: 35
- **Minimum SDK**: 21

### Known Issues & Solutions

#### SSL Certificate Issues (Resolved)
If you encounter SSL certificate errors during Gradle builds, the project includes configurations to bypass certificate validation during development.

## Building for Production

### Release Build

1. **Generate a keystore** (one-time setup).
2. **Configure signing** in `android/key.properties`.
3. **Build the release APK**:
   ```bash
   flutter build apk --release
   ```

## Contributing

Contributions are welcome! If you'd like to improve PIN Notes, please feel free to fork the repository and submit a pull request.

## Troubleshooting

### Common Issues

**Q: I entered my PIN and my notes are gone!**
- You may have accidentally typed a new PIN, which created a new, empty vault. Try re-opening the app and carefully entering your original PIN.

**Q: Build fails with Gradle errors**
- Ensure you have Java 17 or higher installed and that your environment is configured correctly.

## License

MIT License

Copyright (c) 2025

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Disclaimer

This app is provided as-is. Please be aware that forgetting a PIN means the notes in that specific vault are irrecoverable. We recommend keeping regular device backups.

## Contact

For issues, questions, or suggestions, please open an issue in the repository.

---

**Built with Flutter** | **Secured with SQLCipher** | **Privacy First**
