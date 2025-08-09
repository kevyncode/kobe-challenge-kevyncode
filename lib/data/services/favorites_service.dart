import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/character_model.dart';

/// Serviço responsável por gerenciar os personagens favoritos
class FavoritesService {
  static const String _favoritesKey = 'favorite_characters';

  /// Singleton instance
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  /// Cache dos favoritos em memória
  List<CharacterModel>? _cachedFavorites;

  /// Adiciona um personagem aos favoritos
  Future<void> addToFavorites(CharacterModel character) async {
    try {
      final favorites = await getFavorites();

      // Verifica se já não está nos favoritos
      if (!favorites.any((fav) => fav.id == character.id)) {
        favorites.add(character);
        await _saveFavorites(favorites);
        _cachedFavorites = favorites;
      }
    } catch (e) {
      throw FavoritesException('Erro ao adicionar favorito: ${e.toString()}');
    }
  }

  /// Remove um personagem dos favoritos
  Future<void> removeFromFavorites(int characterId) async {
    try {
      final favorites = await getFavorites();
      favorites.removeWhere((character) => character.id == characterId);
      await _saveFavorites(favorites);
      _cachedFavorites = favorites;
    } catch (e) {
      throw FavoritesException('Erro ao remover favorito: ${e.toString()}');
    }
  }

  /// Verifica se um personagem está nos favoritos
  Future<bool> isFavorite(int characterId) async {
    try {
      final favorites = await getFavorites();
      return favorites.any((character) => character.id == characterId);
    } catch (e) {
      return false;
    }
  }

  /// Retorna a lista de personagens favoritos
  Future<List<CharacterModel>> getFavorites() async {
    // Retorna cache se disponível
    if (_cachedFavorites != null) {
      return List.from(_cachedFavorites!);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_favoritesKey);

      if (favoritesJson == null) {
        _cachedFavorites = [];
        return [];
      }

      final List<dynamic> favoritesList = json.decode(favoritesJson);
      final favorites = favoritesList
          .map((item) => CharacterModel.fromJson(item as Map<String, dynamic>))
          .toList();

      _cachedFavorites = favorites;
      return List.from(favorites);
    } catch (e) {
      throw FavoritesException('Erro ao carregar favoritos: ${e.toString()}');
    }
  }

  /// Limpa todos os favoritos
  Future<void> clearFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
      _cachedFavorites = [];
    } catch (e) {
      throw FavoritesException('Erro ao limpar favoritos: ${e.toString()}');
    }
  }

  /// Retorna o número de favoritos
  Future<int> getFavoritesCount() async {
    final favorites = await getFavorites();
    return favorites.length;
  }

  /// Salva a lista de favoritos no SharedPreferences
  Future<void> _saveFavorites(List<CharacterModel> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = json.encode(
        favorites.map((character) => character.toJson()).toList(),
      );
      await prefs.setString(_favoritesKey, favoritesJson);
    } catch (e) {
      throw FavoritesException('Erro ao salvar favoritos: ${e.toString()}');
    }
  }

  /// Força a atualização do cache
  Future<void> refreshCache() async {
    _cachedFavorites = null;
    await getFavorites();
  }

  /// Obtém IDs dos favoritos (útil para sincronização)
  Future<List<int>> getFavoriteIds() async {
    final favorites = await getFavorites();
    return favorites.map((character) => character.id).toList();
  }
}

/// Exceção customizada para erros do serviço de favoritos
class FavoritesException implements Exception {
  final String message;

  const FavoritesException(this.message);

  @override
  String toString() => 'FavoritesException: $message';
}
