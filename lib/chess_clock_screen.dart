import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'models/game_history.dart';
import 'name_input_screen.dart';
import 'services/deck_storage_service.dart';

class ChessClockScreen extends StatefulWidget {
  const ChessClockScreen({super.key});

  @override
  State<ChessClockScreen> createState() => _ChessClockScreenState();
}

class _ChessClockScreenState extends State<ChessClockScreen> {
  // Timer variables
  Timer? _timer;
  int _player1Time = 300; // 5 minutes in seconds
  int _player2Time = 300;
  int _initialPlayer1Time = 300;
  int _initialPlayer2Time = 300;
  bool _isPlayer1Turn = true;
  bool _isRunning = false;
  int _moveCount = 0;
  
  // Player names
  String? _player1Name;
  String? _player2Name;
  String? _player1Deck;
  String? _player2Deck;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRunning) {
        setState(() {
          if (_isPlayer1Turn) {
            if (_player1Time > 0) {
              _player1Time--;
            } else {
              _timer?.cancel();
              _showWinnerSelectionDialog(defaultWinner: _player2Name ?? 'Player 2');
            }
          } else {
            if (_player2Time > 0) {
              _player2Time--;
            } else {
              _timer?.cancel();
              _showWinnerSelectionDialog(defaultWinner: _player1Name ?? 'Player 1');
            }
          }
        });
      }
    });
  }
  
  void _showWinnerSelectionDialog({String? defaultWinner}) {
    // Pause the game while the dialog is open
    setState(() {
      _isRunning = false;
    });
    
    // Show the dialog for winner selection
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Who won this match?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[100],
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(_player1Name ?? 'Player 1');
                    },
                    child: Text(_player1Name ?? 'Player 1'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[100],
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(_player2Name ?? 'Player 2');
                    },
                    child: Text(_player2Name ?? 'Player 2'),
                  ),
                ],
              ),
              if (defaultWinner != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Timer suggests $defaultWinner won',
                  style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                ),
              ],
            ],
          ),
        );
      },
    ).then((winner) {
      if (winner != null) {
        _saveGameHistory(winner: winner);
        _showPostGameOptions();
      } else {
        // If dialog was dismissed without selection (shouldn't happen with barrierDismissible: false)
        _showWinnerSelectionDialog(defaultWinner: defaultWinner); 
      }
    });
  }
  
  void _showPostGameOptions() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Match Complete'),
          content: const Text('What would you like to do next?'),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'New Game',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
            ),
            TextButton(
              child: const Text('Exit', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
                // Set a flag in shared preferences to indicate stats should be refreshed
                SharedPreferences.getInstance().then((prefs) {
                  prefs.setBool('refresh_deck_stats', true);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEndGameDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('End Game'),
          content: const Text('Are you sure you want to end the game?', style: TextStyle(color: Colors.black)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('End Game', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
                _endGame();
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleTimer() {
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  void _resetGame() {
    setState(() {
      _player1Time = _initialPlayer1Time;
      _player2Time = _initialPlayer2Time;
      _isPlayer1Turn = true;
      _isRunning = false;
      _moveCount = 0;
    });
  }

  void _switchPlayer() {
    if (_isRunning) {
      setState(() {
        _isPlayer1Turn = !_isPlayer1Turn;
        _moveCount++;
      });
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _openSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NameInputScreen(
          player1Name: _player1Name,
          player2Name: _player2Name,
          player1Deck: _player1Deck,
          player2Deck: _player2Deck,
          player1Time: _player1Time,
          player2Time: _player2Time,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _player1Name = result['player1Name'];
        _player2Name = result['player2Name'];
        _player1Deck = result['player1Deck'];
        _player2Deck = result['player2Deck'];
        _player1Time = result['player1Time'];
        _player2Time = result['player2Time'];
        _initialPlayer1Time = result['player1Time'];
        _initialPlayer2Time = result['player2Time'];
        _isRunning = false;
        _moveCount = 0;
      });
    }
  }

  Future<void> _saveGameHistory({required String winner}) async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString('gameHistory');
    List<GameHistory> history = [];
    
    if (historyJson != null) {
      final List<dynamic> historyList = json.decode(historyJson);
      history = historyList.map((item) => GameHistory.fromMap(item)).toList();
    }

    final gameHistory = GameHistory(
      player1Name: _player1Name ?? 'Player 1',
      player2Name: _player2Name ?? 'Player 2',
      player1Deck: _player1Deck,
      player2Deck: _player2Deck,
      player1TimeElapsed: _initialPlayer1Time - _player1Time,
      player2TimeElapsed: _initialPlayer2Time - _player2Time,
      moveCount: _moveCount,
      dateTime: DateTime.now(),
      winner: winner,
    );

    // Add game to history
    history.add(gameHistory);
    await prefs.setString('gameHistory', json.encode(history.map((e) => e.toMap()).toList()));
    
    // Update deck statistics
    await DeckStorageService.updateDeckStatsFromGameHistory();
    
    // Set flag for other screens to refresh
    await prefs.setBool('refresh_deck_stats', true);
    
    // Log the update for debugging
    debugPrint('Game saved: ${_player1Deck ?? "No deck"} vs ${_player2Deck ?? "No deck"}, Winner: $winner');
    debugPrint('Player 1: ${_player1Name ?? "Player 1"}, Player 2: ${_player2Name ?? "Player 2"}');
    if (_player1Deck != null || _player2Deck != null) {
      debugPrint('Deck stats updated. Refresh flag set.');
    }
  }

  void _endGame() {
    _timer?.cancel();
    _showWinnerSelectionDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _switchPlayer,
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: _isPlayer1Turn ? Colors.red : Colors.grey[300],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RotatedBox(
                      quarterTurns: 2,
                      child: Text(
                        _player2Name ?? 'Player 2',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    RotatedBox(
                      quarterTurns: 2,
                      child: Text(
                        _formatTime(_player2Time),
                        style: const TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    RotatedBox(
                      quarterTurns: 2,
                      child: Text(
                        'Moves: ${_moveCount.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 100,
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    _isRunning ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: _toggleTimer,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _resetGame,
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: _openSettings,
                ),
                IconButton(
                  icon: const Icon(Icons.stop, color: Colors.white),
                  onPressed: _showEndGameDialog,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _switchPlayer,
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: _isPlayer1Turn ? Colors.grey[300] : Colors.blue,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _player1Name ?? 'Player 1',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(_player1Time),
                      style: const TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Moves: ${_moveCount.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 