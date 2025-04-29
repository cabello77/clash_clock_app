import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'services/deck_storage_service.dart';
import 'welcome_page_screen.dart';
import 'main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = value;
      prefs.setBool('isDarkMode', value);
    });
    // Show a snackbar to inform the user about theme change
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isDarkMode ? 'Dark mode enabled' : 'Light mode enabled',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black54,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _signOut() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      // Set user as not authenticated
      await prefs.setBool('isAuthenticated', false);
      
      if (!mounted) return;
      
      // Show success message and return to welcome screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Successfully signed out',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Navigate to welcome screen, clearing the navigation stack
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => WelcomePageScreen(
          onLoginSuccess: () {
            // This shouldn't be called immediately as user is signing out
          },
        )),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error signing out: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _deleteAllDecks() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      // Delete all decks by setting an empty list
      await prefs.setString(DeckStorageService.decksKey, json.encode([]));
      // Set refresh flag for other screens
      await prefs.setBool('refresh_deck_stats', true);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'All decks deleted successfully',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error deleting decks: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteAllRecords() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      // Delete all game records by removing the gameHistory key
      await prefs.remove('gameHistory');
      // Also update deck stats since records are gone
      await DeckStorageService.updateDeckStatsFromGameHistory();
      // Set refresh flag for other screens
      await prefs.setBool('refresh_deck_stats', true);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'All game records deleted successfully',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error deleting records: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle app theme'),
                  value: isDarkMode,
                  onChanged: _toggleDarkMode,
                  secondary: Icon(
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: isDarkMode ? Colors.amber : Colors.blueGrey,
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete All Decks', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('This action cannot be undone'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete All Decks'),
                        content: const Text(
                          'Are you sure you want to delete all decks?\n\nThis action cannot be undone and will reset all wins and losses.',
                          style: TextStyle(color: Colors.black),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteAllDecks();
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Delete All Records', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('This will reset all game history and stats'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete All Records'),
                        content: const Text(
                          'Are you sure you want to delete all game records?\n\nThis will reset win/loss statistics for all decks.',
                          style: TextStyle(color: Colors.black),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteAllRecords();
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: Colors.blue),
                  title: const Text('About'),
                  subtitle: const Text('App version 1.0.0'),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Clash Clock',
                      applicationVersion: '1.0.0',
                      applicationIcon: Image.asset(
                        'assets/invert_logo.png',
                        width: 50,
                        height: 50,
                      ),
                      children: [
                        const Text(
                          'A custom timer application for card game matches with deck tracking and performance statistics.',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.blue),
                  title: const Text('Sign Out'),
                  subtitle: const Text('Return to login screen'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign Out'),
                        content: const Text(
                          'Are you sure you want to sign out?',
                          style: TextStyle(color: Colors.black),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _signOut();
                            },
                            child: const Text('Sign Out', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                const SizedBox(height: 10),
              ],
            ),
    );
  }
} 