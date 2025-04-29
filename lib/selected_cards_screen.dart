import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/pokemon_card.dart';

class SelectedCardsScreen extends StatefulWidget {
  final List<PokemonCard> selectedCards;

  const SelectedCardsScreen({super.key, required this.selectedCards});

  @override
  _SelectedCardsScreenState createState() => _SelectedCardsScreenState();
}

class _SelectedCardsScreenState extends State<SelectedCardsScreen> {
  late List<PokemonCard> _cards;
  late String _deckName;
  final TextEditingController _deckNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cards = List.from(widget.selectedCards);
    _initializeDeckName();
  }

  Future<void> _initializeDeckName() async {
    final prefs = await SharedPreferences.getInstance();
    int deckCount = prefs.getInt('deckCount') ?? 0;
    deckCount++;
    await prefs.setInt('deckCount', deckCount);
    
    setState(() {
      _deckName = 'Deck #$deckCount';
      _deckNameController.text = _deckName;
    });
  }

  @override
  void dispose() {
    _deckNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selected Cards'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _deckNameController,
              decoration: const InputDecoration(
                labelText: 'Deck Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _deckName = value;
                });
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.7,
              ),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final card = _cards[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: card.smallImage != null
                                ? Image.network(
                                    card.smallImage!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              card.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              setState(() {
                                _cards.removeAt(index);
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_deckName.isNotEmpty) {
            // Create a new deck object
            final newDeck = {
              'title': _deckName,
              'wins': 0,
              'losses': 0,
              'pokemonTypes': _getPokemonTypes(),
              'cards': _cards.map((card) => card.toJson()).toList(),
            };
            
            // Return the new deck to the previous screen
            Navigator.pop(context, newDeck);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter a deck name')),
            );
          }
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  List<String> _getPokemonTypes() {
    // Extract unique Pokemon types from all cards in the deck
    Set<String> uniqueTypes = <String>{};
    
    for (var card in _cards) {
      // Add all types from the card
      uniqueTypes.addAll(card.types);
    }
    
    // If no types were found, return a default type
    if (uniqueTypes.isEmpty) {
      return ['Normal'];
    }
    
    return uniqueTypes.toList();
  }
} 