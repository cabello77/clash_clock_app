import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/game_history.dart';
import 'services/deck_storage_service.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> with WidgetsBindingObserver {
  List<GameHistory> _gameHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadGameHistory();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadGameHistory();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadGameHistory();
  }

  Future<void> _loadGameHistory() async {
    setState(() {
      _isLoading = true;
    });
    
    // First update deck stats based on game history
    await DeckStorageService.updateDeckStatsFromGameHistory();
    
    // Then load the game history
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString('gameHistory');
    if (historyJson != null) {
      final List<dynamic> historyList = json.decode(historyJson);
      setState(() {
        _gameHistory = historyList.map((item) => GameHistory.fromMap(item)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _gameHistory = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGameHistory,
            tooltip: 'Refresh game history',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _gameHistory.isEmpty
              ? const Center(
                  child: Text(
                    'No games played yet',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: _gameHistory.length,
                  itemBuilder: (context, index) {
                    final game = _gameHistory[_gameHistory.length - 1 - index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Game ${_gameHistory.length - index}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${game.dateTime.day}/${game.dateTime.month}/${game.dateTime.year}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        game.player1Name ?? 'Player 1',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      if (game.player1Deck != null)
                                        Text(
                                          'Deck: ${game.player1Deck}',
                                          style: const TextStyle(fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      Text(
                                        'Time: ${game.formatTime(game.player1TimeElapsed)}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        game.player2Name ?? 'Player 2',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      if (game.player2Deck != null)
                                        Text(
                                          'Deck: ${game.player2Deck}',
                                          style: const TextStyle(fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      Text(
                                        'Time: ${game.formatTime(game.player2TimeElapsed)}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Moves: ${game.moveCount}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Winner: ${game.winner}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 