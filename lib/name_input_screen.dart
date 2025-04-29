import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/deck_storage_service.dart';

class NameInputScreen extends StatefulWidget {
  final String? player1Name;
  final String? player2Name;
  final String? player1Deck;
  final String? player2Deck;
  final int player1Time;
  final int player2Time;

  const NameInputScreen({
    super.key,
    this.player1Name,
    this.player2Name,
    this.player1Deck,
    this.player2Deck,
    this.player1Time = 5,
    this.player2Time = 5,
  });

  @override
  _NameInputScreenState createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final TextEditingController _player1NameController = TextEditingController();
  final TextEditingController _player2NameController = TextEditingController();
  final TextEditingController _player1MinutesController = TextEditingController();
  final TextEditingController _player1SecondsController = TextEditingController();
  final TextEditingController _player2MinutesController = TextEditingController();
  final TextEditingController _player2SecondsController = TextEditingController();
  String? _player1SelectedDeck;
  String? _player2SelectedDeck;
  List<String> _decks = [];

  @override
  void initState() {
    super.initState();
    _player1NameController.text = widget.player1Name ?? '';
    _player2NameController.text = widget.player2Name ?? '';
    _player1MinutesController.text = (widget.player1Time ~/ 60).toString();
    _player1SecondsController.text = (widget.player1Time % 60).toString().padLeft(2, '0');
    _player2MinutesController.text = (widget.player2Time ~/ 60).toString();
    _player2SecondsController.text = (widget.player2Time % 60).toString().padLeft(2, '0');
    _player1SelectedDeck = widget.player1Deck;
    _player2SelectedDeck = widget.player2Deck;
    
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    final savedDecks = await DeckStorageService.getDecks();
    setState(() {
      _decks = savedDecks.map((deck) => deck['title'] as String).toList();
    });
  }

  @override
  void dispose() {
    _player1NameController.dispose();
    _player2NameController.dispose();
    _player1MinutesController.dispose();
    _player1SecondsController.dispose();
    _player2MinutesController.dispose();
    _player2SecondsController.dispose();
    super.dispose();
  }

  void _submitSettings() {
    // Parse time inputs
    int? player1Minutes = int.tryParse(_player1MinutesController.text);
    int? player1Seconds = int.tryParse(_player1SecondsController.text);
    int? player2Minutes = int.tryParse(_player2MinutesController.text);
    int? player2Seconds = int.tryParse(_player2SecondsController.text);

    // Validate time inputs
    if (player1Minutes == null || player1Seconds == null ||
        player2Minutes == null || player2Seconds == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid numbers for time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate seconds range
    if (player1Seconds >= 60 || player2Seconds >= 60) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seconds must be less than 60'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Convert to total seconds
    int player1TotalSeconds = (player1Minutes * 60) + player1Seconds;
    int player2TotalSeconds = (player2Minutes * 60) + player2Seconds;

    // Validate total time
    if (player1TotalSeconds < 1 || player2TotalSeconds < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Time must be at least 1 second'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully'),
        backgroundColor: Colors.green,
      ),
    );

    // Return the settings to the previous screen, including the selected decks
    Navigator.pop(context, {
      'player1Name': _player1NameController.text.isEmpty ? null : _player1NameController.text,
      'player2Name': _player2NameController.text.isEmpty ? null : _player2NameController.text,
      'player1Time': player1TotalSeconds,
      'player2Time': player2TotalSeconds,
      'player1Deck': _player1SelectedDeck,
      'player2Deck': _player2SelectedDeck,
    });
  }

  Widget _buildTimeInput({
    required String label,
    required TextEditingController minutesController,
    required TextEditingController secondsController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: minutesController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  labelText: 'Minutes',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: secondsController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  labelText: 'Seconds',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeckDropdown({required String label, required String? selectedDeck, required Function(String?) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedDeck,
          hint: const Text('Select a deck (optional)'),
          isExpanded: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          items: _decks.map((deck) {
            return DropdownMenuItem<String>(
              value: deck,
              child: Text(deck),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitSettings,
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Player 1 Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _player1NameController,
                      decoration: const InputDecoration(
                        labelText: 'Player 1 Name (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTimeInput(
                      label: 'Time',
                      minutesController: _player1MinutesController,
                      secondsController: _player1SecondsController,
                    ),
                    const SizedBox(height: 16),
                    _buildDeckDropdown(
                      label: 'Deck',
                      selectedDeck: _player1SelectedDeck,
                      onChanged: (value) {
                        setState(() {
                          _player1SelectedDeck = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Player 2 Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _player2NameController,
                      decoration: const InputDecoration(
                        labelText: 'Player 2 Name (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTimeInput(
                      label: 'Time',
                      minutesController: _player2MinutesController,
                      secondsController: _player2SecondsController,
                    ),
                    const SizedBox(height: 16),
                    _buildDeckDropdown(
                      label: 'Deck',
                      selectedDeck: _player2SelectedDeck,
                      onChanged: (value) {
                        setState(() {
                          _player2SelectedDeck = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _submitSettings,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
              ),
              icon: const Icon(Icons.save),
              label: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
} 