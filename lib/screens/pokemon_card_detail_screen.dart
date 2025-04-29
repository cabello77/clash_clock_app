import 'package:flutter/material.dart';
import '../models/pokemon_card.dart';

class PokemonCardDetailScreen extends StatelessWidget {
  final PokemonCard card;

  const PokemonCardDetailScreen({
    super.key,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(card.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (card.largeImage != null)
              Container(
                width: double.infinity,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                ),
                child: Image.network(
                  card.largeImage!,
                  fit: BoxFit.contain,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getSupertypeColor(card.supertype),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      card.supertype,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (card.set != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      card.set!['name'] ?? '',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  
                  // Display specific details based on card type
                  if (card.supertype == 'Pokémon') ...[
                    _buildPokemonDetails(),
                  ] else if (card.supertype == 'Trainer') ...[
                    _buildTrainerDetails(),
                  ] else if (card.supertype == 'Energy') ...[
                    _buildEnergyDetails(),
                  ],
                  
                  const SizedBox(height: 16),
                  // Common details for all card types
                  if (card.flavorText != null) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Flavor Text:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(card.flavorText!),
                    const SizedBox(height: 8),
                  ],
                  if (card.set != null) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    Text('Set: ${card.set!['name']}'),
                  ],
                  if (card.rarity != null)
                    Text('Rarity: ${card.rarity}'),
                  if (card.artist != null)
                    Text('Artist: ${card.artist}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPokemonDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (card.hp != null)
          Text('HP: ${card.hp}', style: const TextStyle(fontWeight: FontWeight.bold)),
        if (card.types.isNotEmpty)
          Text('Types: ${card.types.join(", ")}'),
        if (card.subtypes.isNotEmpty)
          Text('Subtypes: ${card.subtypes.join(", ")}'),
        
        if (card.attacks != null && card.attacks!.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('Attacks:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...card.attacks!.map((attack) => _buildAttack(attack)),
        ],
        
        const SizedBox(height: 12),
        if (card.weaknesses != null && card.weaknesses!.isNotEmpty) ...[
          const Text('Weaknesses:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...card.weaknesses!.map((weakness) => 
            Text('${weakness['type']}: ${weakness['value']}')
          ),
        ],
        
        if (card.resistances != null && card.resistances!.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('Resistances:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...card.resistances!.map((resistance) => 
            Text('${resistance['type']}: ${resistance['value']}')
          ),
        ],
        
        if (card.retreatCost != null && card.retreatCost!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Retreat Cost: ${card.retreatCost!.length}'),
        ],
      ],
    );
  }
  
  Widget _buildAttack(Map<String, dynamic> attack) {
    final String name = attack['name'] ?? '';
    final String damage = attack['damage'] ?? '';
    final String cost = (attack['cost'] as List<dynamic>?)?.join(', ') ?? '';
    final String text = attack['text'] ?? '';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('$name ', style: const TextStyle(fontWeight: FontWeight.bold)),
              if (cost.isNotEmpty)
                Text('[$cost] '),
              if (damage.isNotEmpty)
                Text('- $damage'),
            ],
          ),
          if (text.isNotEmpty)
            Text(text),
        ],
      ),
    );
  }
  
  Widget _buildTrainerDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (card.subtypes.isNotEmpty) 
          Text('Type: ${card.subtypes.join(", ")}', 
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        
        if (card.rules != null && card.rules!.isNotEmpty) ...[
          const Text('Rules:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...card.rules!.map((rule) => 
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(rule),
            )
          ),
        ] else ...[
          const Text('Effect:', style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('No rules text available for this card.'),
        ],
      ],
    );
  }
  
  Widget _buildEnergyDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (card.subtypes.isNotEmpty)
          Text('Energy Type: ${card.subtypes.join(", ")}', 
            style: const TextStyle(fontWeight: FontWeight.bold)),
        if (card.types.isNotEmpty)
          Text('Provides: ${card.types.join(", ")} Energy'),
        const SizedBox(height: 8),
        
        if (card.rules != null && card.rules!.isNotEmpty) ...[
          const Text('Special Rules:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...card.rules!.map((rule) => 
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(rule),
            )
          ),
        ],
      ],
    );
  }
  
  Color _getSupertypeColor(String supertype) {
    switch (supertype) {
      case 'Pokémon':
        return Colors.blue;
      case 'Trainer':
        return Colors.purple;
      case 'Energy':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
} 