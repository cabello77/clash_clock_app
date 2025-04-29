import 'package:flutter/material.dart';
import 'card_pick_screen.dart'; // Import the CardPickScreen

class EditDeckScreen extends StatefulWidget {
  final String deckTitle;
  final List<Map<String, dynamic>> cards;

  const EditDeckScreen({
    super.key,
    required this.deckTitle,
    required this.cards,
  });

  @override
  State<EditDeckScreen> createState() => _EditDeckScreenState();
}

class _EditDeckScreenState extends State<EditDeckScreen> {
  late List<Map<String, dynamic>> cards;

  @override
  void initState() {
    super.initState();
    cards = List.from(widget.cards); // Create a copy of the cards list
  }

  void _addCard() {
    setState(() {
      cards.add({
        'name': 'New Card',
        'images': {'small': '', 'large': ''},
      });
    });
  }

  void _removeCard(int index) {
    setState(() {
      cards.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.deckTitle}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addCard,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return ListTile(
            title: Text(card['name']),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeCard(index),
            ),
          );
        },
      ),
    );
  }
}