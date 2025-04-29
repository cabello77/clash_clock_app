import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DeckStorageService {
  static const String _decksKey = 'saved_decks';
  static const String _deckCountKey = 'deck_count';
  
  // Public accessors for the keys
  static String get decksKey => _decksKey;
  static String get deckCountKey => _deckCountKey;

  // Save a new deck
  static Future<void> saveDeck(Map<String, dynamic> deck) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing decks
    final String? decksJson = prefs.getString(_decksKey);
    List<Map<String, dynamic>> decks = [];
    
    if (decksJson != null) {
      final List<dynamic> decoded = json.decode(decksJson);
      decks = decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    }
    
    // Add new deck
    decks.add(deck);
    
    // Save updated decks
    await prefs.setString(_decksKey, json.encode(decks));
  }

  // Get all saved decks
  static Future<List<Map<String, dynamic>>> getDecks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? decksJson = prefs.getString(_decksKey);
    
    if (decksJson == null) {
      return [];
    }
    
    final List<dynamic> decoded = json.decode(decksJson);
    return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  // Update an existing deck
  static Future<bool> updateDeck(String deckTitle, Map<String, dynamic> updatedDeck) async {
    final prefs = await SharedPreferences.getInstance();
    final String? decksJson = prefs.getString(_decksKey);
    
    if (decksJson == null) {
      return false;
    }
    
    List<dynamic> decoded = json.decode(decksJson);
    List<Map<String, dynamic>> decks = decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    
    int deckIndex = decks.indexWhere((deck) => deck['title'] == deckTitle);
    if (deckIndex == -1) {
      return false;
    }
    
    decks[deckIndex] = updatedDeck;
    await prefs.setString(_decksKey, json.encode(decks));
    return true;
  }

  // Update deck stats based on game history
  static Future<void> updateDeckStatsFromGameHistory() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get decks
    final String? decksJson = prefs.getString(_decksKey);
    if (decksJson == null) {
      return;
    }
    
    List<dynamic> decodedDecks = json.decode(decksJson);
    List<Map<String, dynamic>> decks = decodedDecks.map((item) => Map<String, dynamic>.from(item)).toList();
    
    // Get game history
    final String? historyJson = prefs.getString('gameHistory');
    if (historyJson == null) {
      return;
    }
    
    List<dynamic> historyList = json.decode(historyJson);
    
    // Reset win/loss counters for all decks
    for (var deck in decks) {
      deck['wins'] = 0;
      deck['losses'] = 0;
    }
    
    // Count wins and losses for each deck
    for (var gameData in historyList) {
      final String? player1Name = gameData['player1Name'] ?? 'Player 1';
      final String? player2Name = gameData['player2Name'] ?? 'Player 2';
      final String? player1Deck = gameData['player1Deck'];
      final String? player2Deck = gameData['player2Deck'];
      final String winner = gameData['winner'];
      
      if (player1Deck != null && player1Deck.isNotEmpty) {
        int deckIndex = decks.indexWhere((deck) => deck['title'] == player1Deck);
        if (deckIndex != -1) {
          if (winner == player1Name) {
            decks[deckIndex]['wins'] = (decks[deckIndex]['wins'] as int) + 1;
          } else if (winner == player2Name) {
            decks[deckIndex]['losses'] = (decks[deckIndex]['losses'] as int) + 1;
          }
        }
      }
      
      if (player2Deck != null && player2Deck.isNotEmpty) {
        int deckIndex = decks.indexWhere((deck) => deck['title'] == player2Deck);
        if (deckIndex != -1) {
          if (winner == player2Name) {
            decks[deckIndex]['wins'] = (decks[deckIndex]['wins'] as int) + 1;
          } else if (winner == player1Name) {
            decks[deckIndex]['losses'] = (decks[deckIndex]['losses'] as int) + 1;
          }
        }
      }
    }
    
    // Save updated decks
    await prefs.setString(_decksKey, json.encode(decks));
  }

  // Get the next deck number
  static Future<int> getNextDeckNumber() async {
    final prefs = await SharedPreferences.getInstance();
    int deckCount = prefs.getInt(_deckCountKey) ?? 0;
    deckCount++;
    await prefs.setInt(_deckCountKey, deckCount);
    return deckCount;
  }
} 