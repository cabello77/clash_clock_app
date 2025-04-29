import 'package:flutter/material.dart';
import 'services/pokemon_tcg_service.dart';
import 'models/pokemon_card.dart';
import 'selected_cards_screen.dart';

class CardPickScreen extends StatefulWidget {
  const CardPickScreen({super.key});

  @override
  _CardPickScreenState createState() => _CardPickScreenState();
}

class _CardPickScreenState extends State<CardPickScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final List<PokemonCard> _selectedCards = [];
  List<PokemonCard> _filteredCards = [];
  bool _isLoading = true;
  String? _error;
  
  late TabController _tabController;
  final PokemonTCGService _pokemonService = PokemonTCGService(
    apiKey: 'e2c585a7-f112-4edd-bc22-8fcea5c2fe20',
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _fetchCards();
  }
  
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _fetchCards(query: _searchController.text);
    }
  }

  Future<void> _fetchCards({String? query}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      Map<String, dynamic> response;
      
      // Load different card types based on current tab
      switch (_tabController.index) {
        case 0: // Pokémon cards
          response = await _pokemonService.getPokemonCards(
            query: query,
            pageSize: 50,
          );
          break;
        case 1: // Trainer cards
          response = await _pokemonService.getTrainerCards(
            query: query,
            pageSize: 50,
          );
          break;
        case 2: // Energy cards
          response = await _pokemonService.getEnergyCards(
            query: query,
            pageSize: 50,
          );
          break;
        default:
          response = await _pokemonService.searchCards(
            query: query,
            pageSize: 50,
          );
      }
      
      if (response['data'] == null) {
        throw Exception('No data received from API');
      }

      final List<dynamic> cardsData = response['data'];
      
      setState(() {
        _filteredCards = cardsData.map((card) {
          try {
            return PokemonCard.fromJson(card);
          } catch (e) {
            print('Error parsing card: $e');
            print('Card data: $card');
            rethrow;
          }
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading cards: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _filteredCards = [];
      });
    }
  }

  void _filterCards(String query) {
    _fetchCards(query: query);
  }

  void _addCard(PokemonCard card) {
    setState(() {
      _selectedCards.add(card);
    });
  }

  void _removeCard(PokemonCard card) {
    setState(() {
      final index = _selectedCards.indexWhere((c) => c.id == card.id);
      if (index != -1) {
        _selectedCards.removeAt(index);
      }
    });
  }

  int _getCardCount(PokemonCard card) {
    return _selectedCards.where((c) => c.id == card.id).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick a Card'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pokémon'),
            Tab(text: 'Trainer'),
            Tab(text: 'Energy'),
          ],
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for cards...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _fetchCards();
                              },
                            )
                          : null,
                    ),
                    onChanged: _filterCards,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_selectedCards.length}/60',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildCardGrid(),
          ),
          if (_selectedCards.isNotEmpty)
            Container(
              height: 100,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Selected Cards',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedCards.toSet().length,
                      itemBuilder: (context, index) {
                        final uniqueCards = _selectedCards.toSet().toList();
                        final uniqueCard = uniqueCards[index];
                        final count = _getCardCount(uniqueCard);
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Chip(
                            label: Text('${uniqueCard.name} (x$count)'),
                            deleteIcon: const Icon(Icons.close),
                            onDeleted: () => _removeCard(uniqueCard),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SelectedCardsScreen(
                selectedCards: _selectedCards,
              ),
            ),
          ).then((newDeck) {
            if (newDeck != null) {
              Navigator.pop(context, newDeck);
            }
          });
        },
        child: const Icon(Icons.save),
      ),
    );
  }
  
  Widget _buildCardGrid() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $_error',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _fetchCards(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (_filteredCards.isEmpty) {
      String cardType = 'cards';
      switch (_tabController.index) {
        case 0:
          cardType = 'Pokémon cards';
          break;
        case 1:
          cardType = 'Trainer cards';
          break;
        case 2:
          cardType = 'Energy cards';
          break;
      }
      return Center(
        child: Text('No $cardType found. Try searching for another term!'),
      );
    } else {
      return GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 0.7,
        ),
        itemCount: _filteredCards.length,
        itemBuilder: (context, index) {
          final card = _filteredCards[index];
          final count = _getCardCount(card);
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (count > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'x$count',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(width: 4),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.add_circle,
                            color: _selectedCards.length >= 60 ? Colors.grey : Colors.blue,
                          ),
                          onPressed: _selectedCards.length >= 60
                              ? null
                              : () => _addCard(card),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }
} 