import 'package:flutter/material.dart';
import '../../data/models/character_model.dart';
import '../../data/services/favorites_service.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/character_card.dart';
import 'character_detail_page.dart';

/// Página que exibe os personagens favoritos
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoritesService _favoritesService = FavoritesService();
  List<CharacterModel> _favorites = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  /// Carrega a lista de favoritos
  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final favorites = await _favoritesService.getFavorites();
      if (mounted) {
        setState(() {
          _favorites = favorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  /// Remove um personagem dos favoritos
  Future<void> _removeFromFavorites(CharacterModel character) async {
    try {
      await _favoritesService.removeFromFavorites(character.id);

      if (mounted) {
        setState(() {
          _favorites.removeWhere((fav) => fav.id == character.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${character.name} removido dos favoritos'),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'Desfazer',
              textColor: AppColors.onPrimary,
              onPressed: () => _addBackToFavorites(character),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover favorito: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Adiciona novamente um personagem aos favoritos (ação de desfazer)
  Future<void> _addBackToFavorites(CharacterModel character) async {
    try {
      await _favoritesService.addToFavorites(character);
      _loadFavorites(); // Recarrega a lista
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao restaurar favorito: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Limpa todos os favoritos
  Future<void> _clearAllFavorites() async {
    if (_favorites.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Limpar Favoritos', style: AppTextStyles.headlineMedium),
        content: Text(
          'Tem certeza que deseja remover todos os personagens dos favoritos?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Limpar',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _favoritesService.clearFavorites();
        if (mounted) {
          setState(() {
            _favorites.clear();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Todos os favoritos foram removidos'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao limpar favoritos: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  /// Navega para a página de detalhes do personagem
  void _navigateToCharacterDetail(CharacterModel character) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterDetailPage(character: character),
      ),
    ).then((_) {
      // Recarrega a lista quando volta da página de detalhes
      // para sincronizar se o favorito foi removido
      _loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Favoritos', style: AppTextStyles.displayMedium),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all, color: AppColors.error),
              onPressed: _clearAllFavorites,
              tooltip: 'Limpar todos os favoritos',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// Constrói o corpo da página
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppSizes.iconLarge * 2,
              color: AppColors.error,
            ),
            SizedBox(height: AppSpacing.medium),
            Text(
              'Erro ao carregar favoritos',
              style: AppTextStyles.titleMedium,
            ),
            SizedBox(height: AppSpacing.small),
            Text(
              _errorMessage,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.medium),
            ElevatedButton(
              onPressed: _loadFavorites,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: AppSizes.iconLarge * 2,
              color: AppColors.onSurfaceVariant,
            ),
            SizedBox(height: AppSpacing.medium),
            Text('Nenhum favorito ainda', style: AppTextStyles.titleMedium),
            SizedBox(height: AppSpacing.small),
            Text(
              'Adicione personagens aos seus favoritos\npara vê-los aqui',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Contador de favoritos
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.medium),
          color: AppColors.surface,
          child: Text(
            '${_favorites.length} ${_favorites.length == 1 ? 'favorito' : 'favoritos'}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Lista de favoritos
        Expanded(
          child: ListView.builder(
            itemCount: _favorites.length,
            itemBuilder: (context, index) {
              final character = _favorites[index];
              return Dismissible(
                key: Key('favorite_${character.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: AppSpacing.medium),
                  color: AppColors.error,
                  child: const Icon(Icons.delete, color: AppColors.onPrimary),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      title: Text(
                        'Remover Favorito',
                        style: AppTextStyles.headlineMedium,
                      ),
                      content: Text(
                        'Deseja remover ${character.name} dos favoritos?',
                        style: AppTextStyles.bodyMedium,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            'Cancelar',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            'Remover',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) => _removeFromFavorites(character),
                child: CharacterCard(
                  character: character,
                  onTap: () => _navigateToCharacterDetail(character),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
