import 'package:flutter/material.dart';

class SelectedCardsScreen extends StatefulWidget {
  final List<String> selectedCards;

  const SelectedCardsScreen({Key? key, required this.selectedCards}) : super(key: key);

  @override
  _SelectedCardsScreenState createState() => _SelectedCardsScreenState();
}

class _SelectedCardsScreenState extends State<SelectedCardsScreen> {
  late List<String> _cards;
  String _deckName = ''; // Variable to store the deck name

  @override
  void initState() {
    super.initState();
    _cards = List.from(widget.selectedCards); // Create a copy of the list
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
            child: ListView.builder(
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_cards[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _cards.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement your save functionality here
          if (_deckName.isNotEmpty) {
            // Save the deck with _deckName and _cards
            // For example, you could save to a database or show a confirmation dialog
            print('Deck saved: $_deckName with cards: $_cards');
          } else {
            // Show a message to enter a deck name
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter a deck name')),
            );
          }
        },
        child: const Icon(Icons.save),
      ),
    );
  }
} 