import 'package:flutter/material.dart';
import '../../data/models/character_model.dart';
import '../../data/services/rick_and_morty_api_service.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/search_dialog.dart';
import '../widgets/characters_list.dart';
import 'character_detail_page.dart';

/// Página principal que exibe a lista de personagens do Rick and Morty
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RickAndMortyApiService _apiService = RickAndMortyApiService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<CharacterModel> _characters = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasNextPage = true;
  String _currentSearch = '';

  @override
  void initState() {
    super.initState();
    _loadCharacters();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Carrega os personagens da API
  Future<void> _loadCharacters({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      if (refresh) {
        _characters.clear();
        _currentPage = 1;
        _hasNextPage = true;
      }
    });

    try {
      final response = await _apiService.getCharacters(
        page: _currentPage,
        name: _currentSearch.isEmpty ? null : _currentSearch,
      );

      setState(() {
        if (refresh) {
          _characters = response.results;
        } else {
          _characters.addAll(response.results);
        }
        _hasNextPage = response.hasNextPage;
        if (_hasNextPage) _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  /// Trata o scroll da lista para carregar mais itens
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasNextPage) {
      _loadCharacters();
    }
  }

  /// Realiza a busca por personagens
  void _searchCharacters(String query) {
    if (_currentSearch != query) {
      setState(() {
        _currentSearch = query;
      });
      _loadCharacters(refresh: true);
    }
  }

  /// Limpa a busca
  void _clearSearch() {
    _searchController.clear();
    _searchCharacters('');
  }

  /// Navega para a página de detalhes do personagem
  void _navigateToCharacterDetail(CharacterModel character) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterDetailPage(character: character),
      ),
    );
  }

  /// Abre menu de filtros (implementação futura)
  void _openFiltersMenu() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Filtros - Em breve!')));
  }

  /// Abre perfil do usuário (implementação futura)
  void _openUserProfile() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Perfil - Em breve!')));
  }

  /// Abre dialog de busca
  void _openSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SearchDialog(
          controller: _searchController,
          onSearch: _searchCharacters,
          onClear: _clearSearch,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        onFiltersPressed: _openFiltersMenu,
        onProfilePressed: _openUserProfile,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openSearchDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.search, color: Colors.white),
      ),
      body: CharactersList(
        characters: _characters,
        scrollController: _scrollController,
        isLoading: _isLoading,
        hasError: _hasError,
        errorMessage: _errorMessage,
        hasNextPage: _hasNextPage,
        onCharacterTap: _navigateToCharacterDetail,
        onRetry: () => _loadCharacters(refresh: true),
      ),
    );
  }
}
