import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/character_model.dart';
import '../models/api_response_model.dart';

/// Serviço responsável por fazer chamadas para a API do Rick and Morty
class RickAndMortyApiService {
  static const String _baseUrl = 'rickandmortyapi.com';
  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxRetries = 3;

  /// Singleton instance
  static final RickAndMortyApiService _instance =
      RickAndMortyApiService._internal();
  factory RickAndMortyApiService() => _instance;
  RickAndMortyApiService._internal();

  /// Cliente HTTP para fazer as requisições
  final http.Client _client = http.Client();

  /// Método auxiliar para fazer requisições com timeout e retry
  Future<http.Response> _makeRequest(Uri uri, {int retries = 0}) async {
    try {
      final response = await _client.get(uri).timeout(_timeout);
      return response;
    } catch (e) {
      if (retries < _maxRetries) {
        // Aguarda um pouco antes de tentar novamente
        await Future.delayed(Duration(seconds: retries + 1));
        return _makeRequest(uri, retries: retries + 1);
      }
      throw ApiException(
        'Timeout na requisição após $_maxRetries tentativas. Verifique sua conexão.',
      );
    }
  }

  /// Verifica se a API está disponível
  Future<bool> isApiAvailable() async {
    try {
      final uri = Uri.https(_baseUrl, '/api');
      final response = await _client.get(uri).timeout(Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Busca personagens com filtros opcionais
  ///
  /// [page] - Número da página (padrão: 1)
  /// [name] - Nome do personagem para filtrar
  /// [status] - Status do personagem (alive, dead, unknown)
  /// [species] - Espécie do personagem
  /// [gender] - Gênero do personagem (male, female, genderless, unknown)
  /// [type] - Tipo do personagem
  /// [location] - Localização do personagem
  /// [origin] - Origem do personagem
  Future<ApiResponseModel<CharacterModel>> getCharacters({
    int page = 1,
    String? name,
    String? status,
    String? species,
    String? gender,
    String? type,
    String? location,
    String? origin,
  }) async {
    try {
      // Constrói os parâmetros da query
      final Map<String, String> queryParams = {'page': page.toString()};

      // Adiciona filtros apenas se não estiverem vazios
      if (name != null && name.isNotEmpty) {
        queryParams['name'] = name;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status.toLowerCase();
      }
      if (species != null && species.isNotEmpty) {
        queryParams['species'] = species;
      }
      if (gender != null && gender.isNotEmpty) {
        queryParams['gender'] = gender.toLowerCase();
      }
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }
      if (origin != null && origin.isNotEmpty) {
        queryParams['origin'] = origin;
      }

      final uri = Uri.https(_baseUrl, '/api/character', queryParams);
      final response = await _makeRequest(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return ApiResponseModel.fromJson(
          jsonData,
          (json) => CharacterModel.fromJson(json),
        );
      } else if (response.statusCode == 404) {
        // Retorna resposta vazia quando não encontra resultados
        return const ApiResponseModel(
          info: ApiInfoModel(count: 0, pages: 0),
          results: [],
        );
      } else {
        throw ApiException(
          'Falha ao carregar personagens',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erro de conexão: ${e.toString()}');
    }
  }

  /// Busca um personagem específico pelo ID
  Future<CharacterModel> getCharacterById(int id) async {
    try {
      final uri = Uri.https(_baseUrl, '/api/character/$id');
      final response = await _makeRequest(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return CharacterModel.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw ApiException('Personagem não encontrado', 404);
      } else {
        throw ApiException('Falha ao carregar personagem', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erro de conexão: ${e.toString()}');
    }
  }

  /// Busca múltiplos personagens pelos IDs
  Future<List<CharacterModel>> getCharactersByIds(List<int> ids) async {
    if (ids.isEmpty) return [];

    try {
      final idsString = ids.join(',');
      final uri = Uri.https(_baseUrl, '/api/character/$idsString');
      final response = await _makeRequest(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // A API retorna um array se múltiplos IDs, um objeto se apenas um ID
        if (jsonData is List) {
          return jsonData
              .map(
                (item) => CharacterModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else {
          return [CharacterModel.fromJson(jsonData as Map<String, dynamic>)];
        }
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw ApiException(
          'Falha ao carregar personagens',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erro de conexão: ${e.toString()}');
    }
  }

  /// Busca todos os personagens favoritos pelos IDs
  Future<List<CharacterModel>> getFavoriteCharacters(
    List<int> favoriteIds,
  ) async {
    if (favoriteIds.isEmpty) return [];

    try {
      return await getCharactersByIds(favoriteIds);
    } catch (e) {
      throw ApiException(
        'Erro ao carregar personagens favoritos: ${e.toString()}',
      );
    }
  }

  /// Busca localizações disponíveis
  Future<List<String>> getAvailableLocations() async {
    try {
      final uri = Uri.https(_baseUrl, '/api/location');
      final response = await _makeRequest(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final results = jsonData['results'] as List;
        return results
            .map((location) => location['name'] as String)
            .toSet() // Remove duplicatas
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  /// Busca espécies disponíveis (método auxiliar para sugestões)
  Future<List<String>> getAvailableSpecies() async {
    // Como a API não tem endpoint específico para espécies,
    // retornamos uma lista baseada na documentação
    return [
      'Human',
      'Alien',
      'Robot',
      'Animal',
      'Cronenberg',
      'Disease',
      'Mythological Creature',
      'Humanoid',
      'Unknown',
    ];
  }

  /// Busca tipos disponíveis (método auxiliar para sugestões)
  Future<List<String>> getAvailableTypes() async {
    // Como a API não tem endpoint específico para tipos,
    // retornamos uma lista vazia ou tipos conhecidos
    return [];
  }

  /// Método NOVO para fazer busca combinada com múltiplos filtros
  /// Implementa a lógica "também" (OR) para filtros combinados
  Future<List<CharacterModel>> getCharactersWithCombinedFilters({
    int page = 1,
    String? searchQuery,
    Map<String, dynamic>? filters,
  }) async {
    try {
      Set<CharacterModel> combinedResults = {};
      bool hasFilters = false;

      // Se há filtros, faz requisições separadas para cada um
      if (filters != null && filters.isNotEmpty) {
        // Status filters
        if (filters['status'] != null && filters['status'].isNotEmpty) {
          hasFilters = true;
          for (String status in filters['status']) {
            debugPrint('Buscando personagens com status: $status');
            final statusResults = await _getSingleFilterResults(
              page: page,
              name: searchQuery,
              status: status,
            );
            combinedResults.addAll(statusResults);
          }
        }

        // Gender filters
        if (filters['gender'] != null && filters['gender'].isNotEmpty) {
          hasFilters = true;
          for (String gender in filters['gender']) {
            debugPrint('Buscando personagens com gênero: $gender');
            final genderResults = await _getSingleFilterResults(
              page: page,
              name: searchQuery,
              gender: gender,
            );
            combinedResults.addAll(genderResults);
          }
        }

        // Species filters
        if (filters['species'] != null && filters['species'].isNotEmpty) {
          hasFilters = true;
          for (String species in filters['species']) {
            debugPrint('Buscando personagens com espécie: $species');
            final speciesResults = await _getSingleFilterResults(
              page: page,
              name: searchQuery,
              species: species,
            );
            combinedResults.addAll(speciesResults);
          }
        }
      }

      // Se não há filtros específicos, faz busca normal
      if (!hasFilters) {
        final normalResults = await _getSingleFilterResults(
          page: page,
          name: searchQuery,
        );
        combinedResults.addAll(normalResults);
      }

      // Converter Set para List e ordenar por ID
      final sortedResults = combinedResults.toList();
      sortedResults.sort((a, b) => a.id.compareTo(b.id));

      debugPrint(
        'Total de personagens encontrados após combinação e ordenação: ${sortedResults.length}',
      );

      return sortedResults;
    } catch (e) {
      debugPrint('Erro na busca combinada: $e');
      throw ApiException('Erro na busca combinada: ${e.toString()}');
    }
  }

  /// Método auxiliar para fazer uma requisição simples com um filtro
  Future<List<CharacterModel>> _getSingleFilterResults({
    int page = 1,
    String? name,
    String? status,
    String? species,
    String? gender,
  }) async {
    try {
      final apiResponse = await getCharacters(
        page: page,
        name: name,
        status: status,
        species: species,
        gender: gender,
      );

      // Se há mais páginas, busca todas
      List<CharacterModel> allResults = List.from(apiResponse.results);

      // Para filtros combinados, buscar todas as páginas para garantir que temos todos os resultados
      if (apiResponse.info.pages > 1) {
        for (
          int currentPage = 2;
          currentPage <= apiResponse.info.pages;
          currentPage++
        ) {
          try {
            final nextPageResponse = await getCharacters(
              page: currentPage,
              name: name,
              status: status,
              species: species,
              gender: gender,
            );
            allResults.addAll(nextPageResponse.results);
          } catch (e) {
            debugPrint('Erro ao buscar página $currentPage: $e');
            // Continue mesmo se uma página falhar
          }
        }
      }

      return allResults;
    } catch (e) {
      debugPrint('Erro em _getSingleFilterResults: $e');
      return []; // Retorna lista vazia em caso de erro
    }
  }

  /// Método para fazer busca combinada com múltiplos filtros (ATUALIZADO)
  Future<ApiResponseModel<CharacterModel>> searchCharactersWithFilters({
    int page = 1,
    String? searchQuery,
    Map<String, dynamic>? filters,
  }) async {
    try {
      // Usa o novo método de filtros combinados
      final combinedResults = await getCharactersWithCombinedFilters(
        page: page,
        searchQuery: searchQuery,
        filters: filters,
      );

      // Simula paginação nos resultados combinados
      final totalResults = combinedResults.length;
      final itemsPerPage = 20;
      final totalPages = (totalResults / itemsPerPage).ceil();

      final startIndex = (page - 1) * itemsPerPage;
      final endIndex = (startIndex + itemsPerPage).clamp(0, totalResults);

      final paginatedResults = startIndex < totalResults
          ? combinedResults.sublist(startIndex, endIndex)
          : <CharacterModel>[];

      return ApiResponseModel(
        info: ApiInfoModel(count: totalResults, pages: totalPages),
        results: paginatedResults,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Erro na busca filtrada: ${e.toString()}');
    }
  }

  /// Limpa cache (se implementado no futuro)
  void clearCache() {
    // Implementação futura para limpar cache local
  }

  /// Libera recursos do cliente HTTP
  void dispose() {
    _client.close();
  }
}

/// Exceção customizada para erros da API
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() {
    return statusCode != null
        ? 'ApiException: $message (Status: $statusCode)'
        : 'ApiException: $message';
  }
}
