import 'package:flutter/material.dart';

class OverlookDeckScreen extends StatelessWidget {
  const OverlookDeckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overlook Deck'),
      ),
      body: const Center(
        child: Text('Overlook Deck Screen'),
      ),
    );
  }
} 