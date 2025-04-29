import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'chess_clock_screen.dart';
import 'deck_list_screen.dart';
import 'records_screen.dart';
import 'settings_screen.dart';
import 'welcome_page_screen.dart';
import 'screens/pokemon_cards_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
    
    // Listen for changes to theme preference
    prefs.setBool('themeListenerActive', true);
    
    // Set up a listener for theme changes
    Future.delayed(const Duration(seconds: 1), () async {
      while (true) {
        await Future.delayed(const Duration(seconds: 1));
        final currentPref = prefs.getBool('isDarkMode') ?? false;
        if (currentPref != _isDarkMode) {
          setState(() {
            _isDarkMode = currentPref;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clash Clock',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.white,
          onPrimary: Colors.black,
          secondary: Colors.grey[200]!,
          onSecondary: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16.0),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.grey[900]!,
          onPrimary: Colors.white,
          secondary: Colors.grey[800]!,
          onSecondary: Colors.white,
          surface: Colors.grey[850]!,
          onSurface: Colors.white,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.white),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        useMaterial3: true,
        cardTheme: CardTheme(
          color: Colors.grey[800],
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.grey[850],
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
          contentTextStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: WelcomePageScreen(
        onLoginSuccess: () async {
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AuthHandler()),
            (Route<dynamic> route) => false,
          );
        },
      ),
    );
  }
}

class AuthHandler extends StatefulWidget {
  const AuthHandler({super.key});

  @override
  _AuthHandlerState createState() => _AuthHandlerState();
}

class _AuthHandlerState extends State<AuthHandler> {
  final ValueNotifier<bool> isAuthenticated = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? savedAuthStatus = prefs.getBool('isAuthenticated');
    if (savedAuthStatus != null && savedAuthStatus) {
      isAuthenticated.value = true;
    }
  }

  Future<void> _setAuthStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', status);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isAuthenticated,
      builder: (context, value, child) {
        if (value) {
          return const MyHomePage(title:" " );
        } else {
          return WelcomePageScreen(
            onLoginSuccess: () async {
              isAuthenticated.value = true;
              await _setAuthStatus(true);
              navigatorKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Minimalist Clash Clock')),
                (Route<dynamic> route) => false,
              );
            },
          );
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 5,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'This is an unofficial Pokémon fan app. Not affiliated with Nintendo or The Pokémon Company.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10, 
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/invert_logo.png',
                  width: 250, // Adjust the size as needed
                ),
                const SizedBox(height: 60),
                GestureDetector(
                  onTap: () {
                    navigatorKey.currentState?.push(
                      MaterialPageRoute(builder: (context) => const ChessClockScreen()),
                    );
                  },
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Center(
                      child: Text(
                        'Start Clock',
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    navigatorKey.currentState?.push(
                      MaterialPageRoute(builder: (context) => const DeckListScreen()),
                    );
                  },
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Center(
                      child: Text(
                        'Manage Decks',
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    navigatorKey.currentState?.push(
                      MaterialPageRoute(builder: (context) => const PokemonCardsScreen()),
                    );
                  },
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Center(
                      child: Text(
                        'Pokemon TCG Cards',
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: GestureDetector(
              onTap: () {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                    builder: (context) => const RecordsScreen(),
                    fullscreenDialog: true,
                  ),
                );
              },
              child: Container(
                width: 100,
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Center(
                  child: Text(
                    'Records',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
              child: Container(
                width: 100,
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Center(
                  child: Text(
                    'Settings',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
