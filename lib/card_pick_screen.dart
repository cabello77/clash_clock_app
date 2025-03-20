import 'package:flutter/material.dart';
import 'selected_cards_screen.dart'; // Import the new screen

class CardPickScreen extends StatefulWidget {
  const CardPickScreen({Key? key}) : super(key: key);

  @override
  _CardPickScreenState createState() => _CardPickScreenState();
}

class _CardPickScreenState extends State<CardPickScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedCards = [];

  void _addCard(String card) {
    setState(() {
      _selectedCards.add(card);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick a Card'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a card...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                // Implement search logic here
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  // Example of adding a card
                  _addCard('Example Card');
                },
                child: const Text('Add Card'),
              ),
            ),
          ),
          _buildBottomSheet(),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      height: 100,
      color: Colors.grey[200],
      child: Stack(
        children: [
          ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedCards.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Chip(
                  label: Text(_selectedCards[index]),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      _selectedCards.removeAt(index);
                    });
                  },
                ),
              );
            },
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.expand_less),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectedCardsScreen(selectedCards: _selectedCards),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 