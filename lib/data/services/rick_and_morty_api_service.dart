import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character_model.dart';
import '../models/api_response_model.dart';

/// Serviço responsável por fazer chamadas para a API do Rick and Morty
class RickAndMortyApiService {
  static const String _baseUrl = 'https://rickandmortyapi.com/api';
  static const String _charactersEndpoint = '$_baseUrl/character';
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
      final uri = Uri.parse(_baseUrl);
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
  /// [gender] - Gênero do personagem
  Future<ApiResponseModel<CharacterModel>> getCharacters({
    int page = 1,
    String? name,
    String? status,
    String? species,
    String? gender,
  }) async {
    try {
      final uri = Uri.parse(_charactersEndpoint).replace(
        queryParameters: {
          'page': page.toString(),
          if (name != null && name.isNotEmpty) 'name': name,
          if (status != null && status.isNotEmpty) 'status': status,
          if (species != null && species.isNotEmpty) 'species': species,
          if (gender != null && gender.isNotEmpty) 'gender': gender,
        },
      );

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
      final uri = Uri.parse('$_charactersEndpoint/$id');
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
      final uri = Uri.parse('$_charactersEndpoint/$idsString');
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
