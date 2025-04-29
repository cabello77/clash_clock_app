import 'package:flutter/material.dart';
import 'services/deck_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeckDetailsScreen extends StatefulWidget {
  final String deckTitle;
  final int wins;
  final int losses;
  final List<String> pokemonTypes;
  final List<Map<String, dynamic>> cards;

  const DeckDetailsScreen({
    super.key,
    required this.deckTitle,
    required this.wins,
    required this.losses,
    required this.pokemonTypes,
    required this.cards,
  });

  @override
  State<DeckDetailsScreen> createState() => _DeckDetailsScreenState();
}

class _DeckDetailsScreenState extends State<DeckDetailsScreen> {
  late int wins;
  late int losses;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    wins = widget.wins;
    losses = widget.losses;
    _checkForRefreshFlag();
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
      // Refresh the deck stats
      _refreshDeckStats();
    }
  }

  Future<void> _refreshDeckStats() async {
    setState(() {
      _isLoading = true;
    });
    
    // Update deck stats from game history
    await DeckStorageService.updateDeckStatsFromGameHistory();
    
    // Get the updated deck
    final decks = await DeckStorageService.getDecks();
    final deckIndex = decks.indexWhere((deck) => deck['title'] == widget.deckTitle);
    
    if (deckIndex != -1) {
      setState(() {
        wins = decks[deckIndex]['wins'];
        losses = decks[deckIndex]['losses'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Map of Pokemon types to their colors
  static const Map<String, Color> typeColors = {
    'Colorless': Color(0xFFAAA67F),
    'Darkness': Color(0xFF705746),
    'Dragon': Color(0xFF6F35FC),
    'Fairy': Color(0xFFD685AD),
    'Fighting': Color(0xFFC22E28),
    'Fire': Color(0xFFEE8130),
    'Grass': Color(0xFF7AC74C),
    'Lightning': Color(0xFFF7D02C),
    'Metal': Color(0xFFB7B7CE),
    'Psychic': Color(0xFFA98FF3),
    'Water': Color(0xFF6390F0),
    'Normal': Color(0xFFA8A77A),
  };

  // Get color for a type, default to grey if type not in map
  Color _getTypeColor(String type) {
    return typeColors[type] ?? Colors.grey;
  }

  // Extract actual types from cards
  List<String> _getActualTypes() {
    Set<String> uniqueTypes = <String>{};
    
    for (var card in widget.cards) {
      // Check if the card has types
      if (card.containsKey('types') && card['types'] is List) {
        List<dynamic> types = card['types'];
        for (var type in types) {
          if (type is String) {
            uniqueTypes.add(type);
          }
        }
      }
    }
    
    // If we have pokemonTypes passed in and no extracted types, use those
    if (uniqueTypes.isEmpty && widget.pokemonTypes.isNotEmpty) {
      return widget.pokemonTypes;
    }
    
    return uniqueTypes.toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> actualTypes = _getActualTypes();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deckTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDeckStats,
            tooltip: 'Refresh deck stats',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deck Record',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Wins: $wins',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Losses: $losses',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Record: $wins-$losses',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (wins + losses) > 0 ? wins / (wins + losses) : 0,
                          backgroundColor: Colors.red.withOpacity(0.2),
                          color: Colors.green,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (wins + losses) > 0 
                              ? 'Win Rate: ${((wins / (wins + losses)) * 100).toStringAsFixed(1)}%' 
                              : 'Win Rate: 0.0%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pokémon Types:',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8.0,
                    children: actualTypes
                        .map((type) => Chip(
                              label: Text(
                                type,
                                style: TextStyle(
                                  color: _getTypeColor(type).computeLuminance() > 0.5 ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: _getTypeColor(type),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: widget.cards.length,
                      itemBuilder: (context, index) {
                        final card = widget.cards[index];
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  child: Container(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          card['name'],
                                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 20),
                                        Image.network(
                                          card['images']['large'] ?? card['images']['small'],
                                          height: MediaQuery.of(context).size.height * 0.6,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.image_not_supported,
                                              size: 50,
                                              color: Colors.grey,
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Card(
                            elevation: 2,
                            child: Column(
                              children: [
                                Expanded(
                                  child: Image.network(
                                    card['images']['small'],
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
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    card['name'],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}