import 'package:flutter/material.dart';
import '../../data/models/character_model.dart';
import '../../data/services/rick_and_morty_api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/page_transitions.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/search_dialog.dart';
import '../widgets/characters_list.dart';
import '../widgets/filters_drawer.dart';
import 'character_detail_page.dart';
import 'profile_page.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<CharacterModel> _characters = <CharacterModel>[];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasNextPage = true;
  String _currentSearch = '';
  Map<String, dynamic> _currentFilters = <String, dynamic>{};

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

  /// Carrega os personagens da API com filtros
  Future<void> _loadCharacters({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      if (refresh) {
        _characters = <CharacterModel>[];
        _currentPage = 1;
        _hasNextPage = true;
      }
    });

    try {
      // A API do Rick and Morty só aceita UM valor por filtro, não múltiplos
      // Então pegamos apenas o primeiro valor de cada filtro
      String? statusFilter = _currentFilters['status']?.isNotEmpty == true
          ? _currentFilters['status'][0]
          : null;
      String? speciesFilter = _currentFilters['species']?.isNotEmpty == true
          ? _currentFilters['species'][0]
          : null;
      String? genderFilter = _currentFilters['gender']?.isNotEmpty == true
          ? _currentFilters['gender'][0]
          : null;

      final response = await _apiService.getCharacters(
        page: _currentPage,
        name: _currentSearch.isEmpty ? null : _currentSearch,
        status: statusFilter,
        species: speciesFilter,
        gender: genderFilter,
      );

      setState(() {
        if (refresh) {
          _characters = List<CharacterModel>.from(response.results);
        } else {
          _characters.addAll(response.results);
        }
        // Verificar se há mais páginas baseado no total de páginas e página atual
        _hasNextPage = _currentPage < response.info.pages;
        if (_hasNextPage) _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
        // Se é um refresh e deu erro, garantir que a lista esteja vazia
        if (refresh) {
          _characters = <CharacterModel>[];
        }
      });
    }
  }

  /// Função específica para o pull-to-refresh
  Future<void> _onRefresh() async {
    await _loadCharacters(refresh: true);
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

  /// Navega para a página de detalhes do personagem com transição suave
  void _navigateToCharacterDetail(CharacterModel character) {
    Navigator.push(
      context,
      PageTransitions.subtleFadeTransition<void>(
        page: CharacterDetailPage(character: character),
      ),
    );
  }

  /// Abre o drawer de filtros
  void _openFiltersMenu() {
    _scaffoldKey.currentState?.openDrawer();
  }

  /// Aplica os filtros selecionados
  void _onFiltersChanged(Map<String, dynamic> filters) {
    setState(() {
      // Criar uma cópia mutável dos filtros
      _currentFilters = Map<String, dynamic>.from(filters);
    });
    _loadCharacters(refresh: true);
  }

  /// Limpa todos os filtros aplicados
  void _clearAllFilters() {
    debugPrint('HomePage: Iniciando _clearAllFilters');
    setState(() {
      // Criar novos objetos mutáveis em vez de tentar limpar os existentes
      _currentFilters = <String, dynamic>{};
      _currentSearch = '';
      _hasError = false;
      _errorMessage = '';
      _characters = <CharacterModel>[];
      _currentPage = 1;
      _hasNextPage = true;
    });
    _searchController.clear();
    debugPrint('HomePage: Chamando _loadCharacters(refresh: true)');
    _loadCharacters(refresh: true);
  }

  /// Verifica se há filtros ativos
  bool get _hasActiveFilters {
    return _currentFilters.isNotEmpty || _currentSearch.isNotEmpty;
  }

  /// Abre perfil do usuário
  void _openUserProfile() {
    Navigator.push(
      context,
      PageTransitions.subtleFadeTransition<void>(page: const ProfilePage()),
    );
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
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF000000),
      appBar: CustomAppBar(
        onFiltersPressed: _openFiltersMenu,
        onProfilePressed: _openUserProfile,
        scrollController: _scrollController,
      ),
      drawer: FiltersDrawer(
        currentFilters: _currentFilters,
        onFiltersChanged: _onFiltersChanged,
      ),
      floatingActionButton: Container(
        width: 70.0, // Aumentado de 58 para 70
        height: 70.0, // Aumentado de 58 para 70
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(
            16,
          ), // Bordas arredondadas, não mais círculo
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: _openSearchDialog,
            borderRadius: BorderRadius.circular(16),
            child: const Center(
              child: Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 34, // Aumentado de 24 para 28
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: CharactersList(
          characters: _characters,
          scrollController: _scrollController,
          isLoading: _isLoading,
          hasError: _hasError,
          errorMessage: _errorMessage,
          hasNextPage: _hasNextPage,
          onCharacterTap: _navigateToCharacterDetail,
          onRetry: () => _loadCharacters(refresh: true),
          isFiltered: _hasActiveFilters,
          onClearFilters: _clearAllFilters,
        ),
      ),
    );
  }
}
