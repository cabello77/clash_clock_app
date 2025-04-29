import 'package:flutter/material.dart';
import 'card_pick_screen.dart'; // Import the CardPickScreen
import 'deck_details_screen.dart'; // Import the DeckDetailsScreen
import 'services/deck_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeckListScreen extends StatefulWidget {
  const DeckListScreen({super.key});

  @override
  State<DeckListScreen> createState() => _DeckListScreenState();
}

class _DeckListScreenState extends State<DeckListScreen> with WidgetsBindingObserver {
  List<Map<String, dynamic>> decks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkForRefreshFlag();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkForRefreshFlag();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkForRefreshFlag();
  }

  Future<void> _checkForRefreshFlag() async {
    final prefs = await SharedPreferences.getInstance();
    final shouldRefresh = prefs.getBool('refresh_deck_stats') ?? false;
    
    if (shouldRefresh) {
      // Reset the flag
      await prefs.setBool('refresh_deck_stats', false);
      // Load the decks with updated stats
      _loadDecks();
    } else {
      // Normal load
      _loadDecks();
    }
  }

  Future<void> _loadDecks() async {
    setState(() {
      _isLoading = true;
    });
    
    // First update stats from game history
    await DeckStorageService.updateDeckStatsFromGameHistory();
    
    // Then load the updated decks
    final savedDecks = await DeckStorageService.getDecks();
    setState(() {
      decks = savedDecks;
      _isLoading = false;
    });
  }

  void _addNewDeck(Map<String, dynamic> newDeck) async {
    // Set the display image to the first card in the deck
    if (newDeck['cards'].isNotEmpty) {
      newDeck['displayImage'] = newDeck['cards'][0]['images']['small'];
    }
    await DeckStorageService.saveDeck(newDeck);
    _loadDecks(); // Reload decks to show the new one
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDecks,
            tooltip: 'Refresh deck stats',
          ),
        ],
      ),
      body: _isLoading 
      ? const Center(child: CircularProgressIndicator())
      : decks.isEmpty 
        ? const Center(child: Text('No decks yet. Add your first deck!'))
        : GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 0.6,
          ),
          itemCount: decks.length,
          itemBuilder: (context, index) {
            final deck = decks[index];
            
            return GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeckDetailsScreen(
                      deckTitle: deck['title'],
                      wins: deck['wins'],
                      losses: deck['losses'],
                      pokemonTypes: List<String>.from(deck['pokemonTypes']),
                      cards: List<Map<String, dynamic>>.from(deck['cards']),
                    ),
                  ),
                );
                // Refresh the deck stats when returning from details
                _loadDecks();
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 4,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          deck['displayImage'] ?? deck['cards'][0]['images']['small'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              deck['title'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'W: ${deck['wins']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'L: ${deck['losses']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          padding: const EdgeInsets.all(10.0),
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CardPickScreen()),
          );
          
          if (result != null) {
            _addNewDeck(result);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 