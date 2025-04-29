import 'package:flutter/material.dart';
import '../models/pokemon_card.dart';
import '../services/pokemon_tcg_service.dart';
import 'pokemon_card_detail_screen.dart';
import 'dart:async';

class PokemonCardsScreen extends StatefulWidget {
  const PokemonCardsScreen({super.key});

  @override
  State<PokemonCardsScreen> createState() => _PokemonCardsScreenState();
}

class _PokemonCardsScreenState extends State<PokemonCardsScreen> with SingleTickerProviderStateMixin {
  final PokemonTCGService _pokemonService = PokemonTCGService(
    apiKey: 'e2c585a7-f112-4edd-bc22-8fcea5c2fe20',
  );
  final TextEditingController _searchController = TextEditingController();
  List<PokemonCard> _cards = [];
  bool _isLoading = false;
  String? _error;
  Timer? _debounceTimer;
  
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadCards();
  }
  
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _loadCards(query: _searchController.text);
    }
  }

  Future<void> _loadCards({String? query}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      Map<String, dynamic> response;
      
      // Load different card types based on current tab
      switch (_tabController.index) {
        case 0: // Pokémon cards
          response = await _pokemonService.getPokemonCards(query: query);
          break;
        case 1: // Trainer cards
          response = await _pokemonService.getTrainerCards(query: query);
          break;
        case 2: // Energy cards
          response = await _pokemonService.getEnergyCards(query: query);
          break;
        default:
          response = await _pokemonService.searchCards(query: query);
      }
      
      print('API Response: $response'); // Debug log
      
      if (response['data'] == null) {
        throw Exception('No data received from API');
      }

      final List<dynamic> cardsData = response['data'];
      print('Number of cards received: ${cardsData.length}'); // Debug log
      
      setState(() {
        _cards = cardsData.map((card) {
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
      print('Error loading cards: $e'); // Debug log
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _handleSearch(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _loadCards(query: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokemon TCG Collection'),
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
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search cards...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadCards();
                        },
                      )
                    : null,
              ),
              onSubmitted: _handleSearch,
              onChanged: _handleSearch,
            ),
          ),
          Expanded(
            child: _buildCardList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCardList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
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
              onPressed: () => _loadCards(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (_cards.isEmpty) {
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
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          final card = _cards[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PokemonCardDetailScreen(card: card),
                ),
              );
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        color: Colors.grey[200],
                      ),
                      child: card.smallImage != null
                          ? Image.network(
                              card.smallImage!,
                              fit: BoxFit.contain,
                            )
                          : const Center(
                              child: Icon(Icons.image_not_supported),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          card.supertype,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getSupertypeColor(card.supertype),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (card.set != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            card.set!['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
  
  Color _getSupertypeColor(String supertype) {
    switch (supertype) {
      case 'Pokémon':
        return Colors.blue;
      case 'Trainer':
        return Colors.purple;
      case 'Energy':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }
} 