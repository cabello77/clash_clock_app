import 'package:flutter/material.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example data for matches
    final List<Map<String, String>> matches = [
      {'winner': 'Player 1', 'moves': '35', 'deck': 'Deck A'},
      {'winner': 'Player 2', 'moves': '40', 'deck': ''},
      {'winner': 'Player 1', 'moves': '28', 'deck': 'Deck B'},
      {'winner': 'Player 2', 'moves': '50', 'deck': 'Deck C'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Records'),
      ),
      body: ListView.builder(
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final match = matches[index];
          return ListTile(
            title: Text('Winner: ${match['winner']}'),
            subtitle: Text('Moves: ${match['moves']}'),
            trailing: match['deck']!.isNotEmpty
                ? Text('Deck: ${match['deck']}')
                : null,
          );
        },
      ),
    );
  }
} 