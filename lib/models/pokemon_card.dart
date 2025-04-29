class PokemonCard {
  final String id;
  final String name;
  final String supertype;
  final List<String> subtypes;
  final String? level;
  final String? hp;
  final List<String> types;
  final List<Map<String, dynamic>>? attacks;
  final List<Map<String, dynamic>>? weaknesses;
  final List<Map<String, dynamic>>? resistances;
  final List<String>? retreatCost;
  final int? convertedRetreatCost;
  final Map<String, dynamic>? set;
  final String? number;
  final String? artist;
  final String? rarity;
  final Map<String, dynamic>? cardmarket;
  final Map<String, dynamic>? tcgplayer;
  final String? smallImage;
  final String? largeImage;
  final Map<String, dynamic>? prices;
  final List<String>? rules;  // For trainer and energy card rules text
  final String? flavorText; // Flavor text that might be on any type of card

  PokemonCard({
    required this.id,
    required this.name,
    required this.supertype,
    required this.subtypes,
    this.level,
    this.hp,
    required this.types,
    this.attacks,
    this.weaknesses,
    this.resistances,
    this.retreatCost,
    this.convertedRetreatCost,
    this.set,
    this.number,
    this.artist,
    this.rarity,
    this.cardmarket,
    this.tcgplayer,
    this.smallImage,
    this.largeImage,
    this.prices,
    this.rules,
    this.flavorText,
  });

  factory PokemonCard.fromJson(Map<String, dynamic> json) {
    try {
      // Safely extract images
      String? smallImageUrl;
      String? largeImageUrl;
      
      if (json['images'] != null) {
        final images = json['images'] as Map<String, dynamic>;
        smallImageUrl = images['small']?.toString();
        largeImageUrl = images['large']?.toString();
      }

      print('Processing card: ${json['name']}'); // Debug log
      print('Card images: $smallImageUrl, $largeImageUrl'); // Debug log

      // Parse complex objects safely
      List<Map<String, dynamic>>? attacksList;
      if (json['attacks'] != null) {
        final attacks = json['attacks'] as List<dynamic>;
        attacksList = attacks.map((attack) => attack as Map<String, dynamic>).toList();
      }
      
      List<Map<String, dynamic>>? weaknessesList;
      if (json['weaknesses'] != null) {
        final weaknesses = json['weaknesses'] as List<dynamic>;
        weaknessesList = weaknesses.map((weakness) => weakness as Map<String, dynamic>).toList();
      }
      
      List<Map<String, dynamic>>? resistancesList;
      if (json['resistances'] != null) {
        final resistances = json['resistances'] as List<dynamic>;
        resistancesList = resistances.map((resistance) => resistance as Map<String, dynamic>).toList();
      }
      
      // Handle rules text for Trainer and Energy cards
      List<String>? rulesList;
      if (json['rules'] != null) {
        rulesList = (json['rules'] as List<dynamic>).map((rule) => rule.toString()).toList();
      }

      return PokemonCard(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        supertype: json['supertype']?.toString() ?? '',
        subtypes: (json['subtypes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        level: json['level']?.toString(),
        hp: json['hp']?.toString(),
        types: (json['types'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        attacks: attacksList,
        weaknesses: weaknessesList,
        resistances: resistancesList,
        retreatCost: (json['retreatCost'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
        convertedRetreatCost: json['convertedRetreatCost'] as int?,
        set: json['set'] as Map<String, dynamic>?,
        number: json['number']?.toString(),
        artist: json['artist']?.toString(),
        rarity: json['rarity']?.toString(),
        cardmarket: json['cardmarket'] as Map<String, dynamic>?,
        tcgplayer: json['tcgplayer'] as Map<String, dynamic>?,
        smallImage: smallImageUrl,
        largeImage: largeImageUrl,
        prices: json['prices'] as Map<String, dynamic>?,
        rules: rulesList,
        flavorText: json['flavorText']?.toString(),
      );
    } catch (e) {
      print('Error parsing PokemonCard: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'supertype': supertype,
      'subtypes': subtypes,
      'level': level,
      'hp': hp,
      'types': types,
      'attacks': attacks,
      'weaknesses': weaknesses,
      'resistances': resistances,
      'retreatCost': retreatCost,
      'convertedRetreatCost': convertedRetreatCost,
      'set': set,
      'number': number,
      'artist': artist,
      'rarity': rarity,
      'cardmarket': cardmarket,
      'tcgplayer': tcgplayer,
      'images': {
        'small': smallImage,
        'large': largeImage,
      },
      'prices': prices,
      'rules': rules,
      'flavorText': flavorText,
    };
  }
} 