# Clash Clock App

A timer app for Pokémon TCG players, featuring:
- Chess-style timer for tracking player turns
- Deck management system with win/loss tracking
- Pokémon TCG card browser
- Game history records

## Table of Contents
- [Features](#features)
- [Installation](#installation)
- [Development Setup](#development-setup)
- [Dependencies](#dependencies)
- [Building and Running](#building-and-running)
- [Contributing](#contributing)
- [Version History](#version-history)

## Features
- **Chess-style Timer**: Track player turns with precision timing
- **Deck Management**: Create, edit, and track your Pokémon TCG decks
- **Win/Loss Tracking**: Monitor your performance with detailed statistics
- **Card Browser**: Browse and search Pokémon TCG cards
- **Game History**: Review past matches and outcomes
- **User Authentication**: Secure login and registration system

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/clash_clock_app.git
   cd clash_clock_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Create a Firebase project
   - Add your Firebase configuration to `lib/firebase_options.dart`
   - Enable Authentication and Firestore in your Firebase console

4. Run the app:
   ```bash
   flutter run
   ```

## Development Setup
### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / Xcode (for platform-specific development)
- Firebase account

### Environment Setup
1. Install Flutter following the [official guide](https://flutter.dev/docs/get-started/install)
2. Set up your preferred IDE (Android Studio, VS Code, etc.)
3. Install Flutter and Dart plugins for your IDE
4. Configure Firebase project and add configuration files

## Dependencies
- `firebase_core: ^2.15.1`
- `firebase_auth: ^4.7.1`
- `shared_preferences: ^2.5.3`
- `http: ^1.3.0`
- `cupertino_icons: ^1.0.8`

## Building and Running
### Development Build
```bash
flutter run
```

### Release Build
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### Platform-Specific Builds
See `RELEASE_STEPS.md` for detailed platform-specific build instructions.

## Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Version History
- Version 3.0.0: Major UI overhaul and performance improvements
- Version 2.0.1: Fixed deck stats tracking issue
- See the [CHANGELOG](CHANGELOG.md) for complete version history

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Recent Updates
- Version 2.0.1: Fixed deck stats tracking issue where wins and losses weren't properly updating
- See the [CHANGELOG](CHANGELOG.md) for more details 
