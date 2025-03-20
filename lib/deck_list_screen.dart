import 'package:flutter/material.dart';
import 'card_pick_screen.dart'; // Import the CardPickScreen
import 'deck_details_screen.dart'; // Import the DeckDetailsScreen

class DeckListScreen extends StatelessWidget {
  const DeckListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example data for decks
    final List<Map<String, dynamic>> decks = [
      {
        'title': 'Deck A',
        'wins': 10,
        'losses': 5,
        'pokemonTypes': ['Fire', 'Water'],
        'cards': ['Card 1', 'Card 2', 'Card 3']
      },
      {
        'title': 'Deck B',
        'wins': 8,
        'losses': 7,
        'pokemonTypes': ['Grass', 'Electric'],
        'cards': ['Card 4', 'Card 5', 'Card 6']
      },
      // Add more decks as needed
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck List'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Number of columns
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: decks.length, // Number of items
        itemBuilder: (context, index) {
          final deck = decks[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeckDetailsScreen(
                    deckTitle: deck['title'],
                    wins: deck['wins'],
                    losses: deck['losses'],
                    pokemonTypes: List<String>.from(deck['pokemonTypes']),
                    cards: List<String>.from(deck['cards']),
                  ),
                ),
              );
            },
            child: Card(
              elevation: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image, size: 50, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text(
                    deck['title'],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Wins: ${deck['wins']}', // Example data
                    style: TextStyle(fontSize: 14, color: Colors.green),
                  ),
                  Text(
                    'Losses: ${deck['losses']}', // Example data
                    style: TextStyle(fontSize: 14, color: Colors.red),
                  ),
                ],
              ),
            ),
          );
        },
        padding: const EdgeInsets.all(10.0),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CardPickScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 