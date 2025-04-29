import 'dart:convert';
import 'package:http/http.dart' as http;

class PokemonTCGService {
  static const String baseUrl = 'https://api.pokemontcg.io/v2';
  final String apiKey;

  PokemonTCGService({required this.apiKey});

  Future<Map<String, dynamic>> searchCards({
    String? query,
    int page = 1,
    int pageSize = 20,
    String? supertype,
  }) async {
    try {
      // Build the query string
      String searchQuery = '';
      
      // Add supertype filter if provided
      if (supertype != null && supertype.isNotEmpty) {
        searchQuery = 'supertype:"$supertype"';
      }
      
      // Add name search if query is provided
      if (query != null && query.isNotEmpty) {
        // Split the query into words to handle variations
        final words = query.split(' ');
        final baseName = words[0];
        
        // Add to existing query or create new one
        if (searchQuery.isNotEmpty) {
          searchQuery += ' AND name:"$baseName"';
        } else {
          searchQuery = 'name:"$baseName"';
        }
        
        // Add additional search terms if present
        if (words.length > 1) {
          final additionalTerms = words.sublist(1).join(' ');
          searchQuery += ' AND (name:"$additionalTerms" OR subtypes:"$additionalTerms")';
        }
      }

      final queryParams = {
        'q': searchQuery,
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        'orderBy': 'name',
        'select': 'id,name,images,supertype,subtypes,hp,types,attacks,weaknesses,resistances,retreatCost,convertedRetreatCost,set,rarity,artist,rules,flavorText',
      };

      final uri = Uri.parse('$baseUrl/cards').replace(queryParameters: queryParams);
      
      print('Requesting URL: $uri'); // Debug log
      
      final response = await http.get(
        uri,
        headers: {
          'X-Api-Key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Raw API Response: $data'); // Debug log
        return data;
      } else {
        print('Error Response: ${response.body}'); // Debug log
        throw Exception('Failed to load cards: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception in searchCards: $e'); // Debug log
      rethrow;
    }
  }

  // Method to get trainer cards specifically
  Future<Map<String, dynamic>> getTrainerCards({
    String? query,
    int page = 1,
    int pageSize = 20,
  }) async {
    return searchCards(
      query: query,
      page: page,
      pageSize: pageSize,
      supertype: 'Trainer',
    );
  }

  // Method to get energy cards specifically
  Future<Map<String, dynamic>> getEnergyCards({
    String? query,
    int page = 1,
    int pageSize = 20,
  }) async {
    return searchCards(
      query: query,
      page: page,
      pageSize: pageSize,
      supertype: 'Energy',
    );
  }

  // Method to get pokemon cards specifically
  Future<Map<String, dynamic>> getPokemonCards({
    String? query,
    int page = 1,
    int pageSize = 20,
  }) async {
    return searchCards(
      query: query,
      page: page,
      pageSize: pageSize,
      supertype: 'Pokémon',
    );
  }

  Future<Map<String, dynamic>> getCardById(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/cards/$id');
      
      final response = await http.get(
        uri,
        headers: {
          'X-Api-Key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error Response: ${response.body}'); // Debug log
        throw Exception('Failed to load card: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception in getCardById: $e'); // Debug log
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSets() async {
    try {
      final uri = Uri.parse('$baseUrl/sets');
      
      final response = await http.get(
        uri,
        headers: {
          'X-Api-Key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error Response: ${response.body}'); // Debug log
        throw Exception('Failed to load sets: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception in getSets: $e'); // Debug log
      rethrow;
    }
  }
} 