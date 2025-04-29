class GameHistory {
  final String? player1Name;
  final String? player2Name;
  final String? player1Deck;
  final String? player2Deck;
  final int player1TimeElapsed;
  final int player2TimeElapsed;
  final int moveCount;
  final DateTime dateTime;
  final String winner;

  GameHistory({
    this.player1Name,
    this.player2Name,
    this.player1Deck,
    this.player2Deck,
    required this.player1TimeElapsed,
    required this.player2TimeElapsed,
    required this.moveCount,
    required this.dateTime,
    required this.winner,
  });

  Map<String, dynamic> toMap() {
    return {
      'player1Name': player1Name,
      'player2Name': player2Name,
      'player1Deck': player1Deck,
      'player2Deck': player2Deck,
      'player1TimeElapsed': player1TimeElapsed,
      'player2TimeElapsed': player2TimeElapsed,
      'moveCount': moveCount,
      'dateTime': dateTime.toIso8601String(),
      'winner': winner,
    };
  }

  factory GameHistory.fromMap(Map<String, dynamic> map) {
    return GameHistory(
      player1Name: map['player1Name'],
      player2Name: map['player2Name'],
      player1Deck: map['player1Deck'],
      player2Deck: map['player2Deck'],
      player1TimeElapsed: map['player1TimeElapsed'],
      player2TimeElapsed: map['player2TimeElapsed'],
      moveCount: map['moveCount'],
      dateTime: DateTime.parse(map['dateTime']),
      winner: map['winner'],
    );
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
} 