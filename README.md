# PIN Notes

A secure, privacy-focused note-taking app for Android that uses PIN authentication and SQLCipher encryption to keep your notes completely private and encrypted on your device.

## What is PIN Notes?

PIN Notes is a lightweight Android application that allows you to create and manage encrypted notes protected by a PIN code. All notes are stored locally on your device in an encrypted SQLCipher database, ensuring that only you can access your sensitive information.

### Key Features

- **PIN Protection**: Secure access to all your notes with a 4-digit PIN
- **Military-Grade Encryption**: All notes are stored in an encrypted SQLCipher database
- **Auto-Lock**: Automatically locks when you switch apps or the app goes to background
- **Completely Private**: No internet connection required, no cloud sync, no data collection
- **Simple & Clean**: Minimalist interface focused on security and ease of use
- **Offline-First**: Everything works completely offline

## How It Works

1. **First Launch**: Set up your 4-digit PIN
2. **Create Notes**: Add, edit, and delete notes as needed
3. **Auto-Lock**: App automatically locks when you leave it
4. **Access Anytime**: Enter your PIN to unlock and access your encrypted notes

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

   To build a release APK:
   ```bash
   flutter build apk --release
   ```

   To build a debug APK:
   ```bash
   flutter build apk --debug
   ```

### Running on Emulator or Device

1. **Start an Android emulator** or connect an Android device via USB
2. **Enable USB debugging** on your Android device (if using a physical device)
3. **Check connected devices**:
   ```bash
   flutter devices
   ```
4. **Run the app**:
   ```bash
   flutter run
   ```

## Technical Details

### Architecture

- **State Management**: Riverpod + Flutter Hooks
- **Database**: SQLCipher (encrypted SQLite)
- **Platform**: Android (Flutter)
- **Language**: Dart

### Dependencies

- `hooks_riverpod` - Reactive state management
- `flutter_hooks` - React-style hooks for Flutter
- `sqflite_sqlcipher` - Encrypted SQLite database
- `path_provider` - Access to device file system
- `uuid` - Generate unique IDs for notes
- `intl` - Internationalization and date formatting

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
├── providers/                # Riverpod state providers
│   ├── pin_provider.dart     # PIN authentication state
│   ├── lifecycle_provider.dart # App lifecycle management
│   └── notes_provider.dart   # Notes CRUD operations
├── services/                 # Business logic
│   └── database_service.dart # SQLCipher database operations
└── ui/                       # User interface
    └── screens/              # App screens
        ├── pin_entry_screen.dart
        └── notes_list_screen.dart
```

## Security Features

### Encryption
- **SQLCipher**: Industry-standard database encryption
- **256-bit AES**: Military-grade encryption algorithm
- **Key Derivation**: PBKDF2 key derivation from your PIN

### Privacy
- **No Network Access**: App works completely offline
- **No Analytics**: Zero tracking or data collection
- **Local Storage Only**: All data stays on your device
- **Auto-Lock**: Protects your notes when you leave the app

### Best Practices
- Choose a strong, memorable 4-digit PIN
- Don't share your PIN with anyone
- Keep your device secure with a lock screen
- Regularly backup your device

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
If you encounter SSL certificate errors during Gradle builds, the project includes configurations to bypass certificate validation during development. This was necessary due to network security settings.

## Building for Production

### Release Build

1. **Generate a keystore** (one-time setup):
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA \
           -keysize 2048 -validity 10000 -alias upload
   ```

2. **Configure signing** in `android/key.properties`:
   ```properties
   storePassword=<your-store-password>
   keyPassword=<your-key-password>
   keyAlias=upload
   storeFile=<path-to-keystore>/upload-keystore.jks
   ```

3. **Build the release APK**:
   ```bash
   flutter build apk --release
   ```

4. **Find your APK** at:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

## Contributing

This is a private project, but contributions from authorized collaborators are welcome!

### Development Guidelines

1. Follow Flutter/Dart best practices
2. Maintain code consistency with existing patterns
3. Test on multiple Android versions
4. Document any new features or changes
5. Keep security as the top priority

## Troubleshooting

### Common Issues

**Q: Build fails with Gradle errors**
- Ensure you have Java 17 or higher installed
- Clear Gradle cache: `./gradlew clean` in the `android/` directory
- Delete `android/.gradle` and rebuild

**Q: SQLCipher database errors**
- Ensure Android NDK is properly installed
- Check that your device/emulator meets minimum SDK requirements

**Q: App crashes on startup**
- Check logcat for detailed errors: `flutter logs`
- Ensure all dependencies are properly installed: `flutter pub get`

**Q: Can't access notes after app update**
- Notes are encrypted with your PIN - ensure you're using the correct PIN
- Database encryption key is derived from your PIN

## License

Copyright (c) 2024. All rights reserved.

This is a private project. Unauthorized copying, modification, or distribution is prohibited.

## Disclaimer

This app is provided as-is for personal use. While we use industry-standard encryption (SQLCipher), we recommend:
- Keeping regular device backups
- Using a strong device lock screen
- Not storing extremely sensitive information without additional security measures
- Understanding that if you forget your PIN, your notes cannot be recovered

## Contact

For issues, questions, or suggestions, please open an issue in the repository.

---

**Built with Flutter** | **Secured with SQLCipher** | **Privacy First**
