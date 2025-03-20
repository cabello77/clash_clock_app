import 'package:flutter/material.dart';

class NameInputScreen extends StatefulWidget {
  const NameInputScreen({Key? key}) : super(key: key);

  @override
  _NameInputScreenState createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final TextEditingController _player1NameController = TextEditingController();
  final TextEditingController _player2NameController = TextEditingController();
  final TextEditingController _player1TimeController = TextEditingController();
  final TextEditingController _player2TimeController = TextEditingController();

  void _submitSettings() {
    // Handle settings submission
    // You can pass the data back to the ChessClockScreen or save it as needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Name and Time Input'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _player1NameController,
              decoration: const InputDecoration(labelText: 'Player 1 Name (Optional)'),
            ),
            TextField(
              controller: _player1TimeController,
              decoration: const InputDecoration(labelText: 'Player 1 Time (in minutes)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _player2NameController,
              decoration: const InputDecoration(labelText: 'Player 2 Name (Optional)'),
            ),
            TextField(
              controller: _player2TimeController,
              decoration: const InputDecoration(labelText: 'Player 2 Time (in minutes)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitSettings,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
} 