import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/character_model.dart';
import '../../data/services/favorites_service.dart';
import '../../core/theme/app_theme.dart';

/// Página de detalhes de um personagem específico
class CharacterDetailPage extends StatefulWidget {
  final CharacterModel character;

  const CharacterDetailPage({super.key, required this.character});

  @override
  State<CharacterDetailPage> createState() => _CharacterDetailPageState();
}

class _CharacterDetailPageState extends State<CharacterDetailPage> {
  final FavoritesService _favoritesService = FavoritesService();
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  /// Verifica se o personagem está nos favoritos
  Future<void> _checkFavoriteStatus() async {
    final isFavorite = await _favoritesService.isFavorite(widget.character.id);
    if (mounted) {
      setState(() {
        _isFavorite = isFavorite;
      });
    }
  }

  /// Alterna o status de favorito do personagem
  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isFavorite) {
        await _favoritesService.removeFromFavorites(widget.character.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removido dos favoritos'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } else {
        await _favoritesService.addToFavorites(widget.character);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Adicionado aos favoritos'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Retorna a cor baseada no status do personagem
  Color _getStatusColor() {
    switch (widget.character.status.toLowerCase()) {
      case 'alive':
        return AppColors.statusAlive;
      case 'dead':
        return AppColors.statusDead;
      default:
        return AppColors.statusUnknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.character.name, style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _isLoading
              ? Container(
                  margin: EdgeInsets.all(AppSpacing.medium),
                  width: AppSizes.iconMedium,
                  height: AppSizes.iconMedium,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite
                        ? AppColors.error
                        : AppColors.onSurfaceVariant,
                  ),
                  onPressed: _toggleFavorite,
                  tooltip: _isFavorite
                      ? 'Remover dos favoritos'
                      : 'Adicionar aos favoritos',
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do personagem
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.large),
                child: CachedNetworkImage(
                  imageUrl: widget.character.imageUrl,
                  width: AppSizes.characterImageLarge * 2,
                  height: AppSizes.characterImageLarge * 2,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: AppSizes.characterImageLarge * 2,
                    height: AppSizes.characterImageLarge * 2,
                    color: AppColors.surface,
                    child: const Icon(
                      Icons.person,
                      size: 64,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: AppSizes.characterImageLarge * 2,
                    height: AppSizes.characterImageLarge * 2,
                    color: AppColors.surface,
                    child: const Icon(
                      Icons.error,
                      size: 64,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: AppSpacing.large),

            // Nome do personagem
            Text(
              widget.character.name,
              style: AppTextStyles.displayLarge,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: AppSpacing.medium),

            // Informações básicas
            _buildInfoSection('Informações Básicas', [
              _buildInfoRow(
                'Status',
                widget.character.status,
                _getStatusColor(),
              ),
              _buildInfoRow('Espécie', widget.character.species),
              _buildInfoRow('Gênero', widget.character.gender),
              if (widget.character.type.isNotEmpty)
                _buildInfoRow('Tipo', widget.character.type),
            ]),

            SizedBox(height: AppSpacing.large),

            // Localização
            _buildInfoSection('Localização', [
              _buildInfoRow('Origem', widget.character.origin.name),
              _buildInfoRow(
                'Última localização',
                widget.character.location.name,
              ),
            ]),

            SizedBox(height: AppSpacing.large),

            // Episódios
            _buildInfoSection('Episódios', [
              _buildInfoRow(
                'Total de episódios',
                '${widget.character.episodes.length}',
              ),
              if (widget.character.episodes.isNotEmpty)
                _buildInfoRow(
                  'Primeiro episódio',
                  widget.character.firstEpisodeNumber,
                ),
              if (widget.character.episodes.isNotEmpty)
                _buildInfoRow(
                  'Último episódio',
                  widget.character.lastEpisodeNumber,
                ),
            ]),
          ],
        ),
      ),
    );
  }

  /// Constrói uma seção de informações
  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.headlineMedium),
        SizedBox(height: AppSpacing.small),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.medium),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  /// Constrói uma linha de informação
  Widget _buildInfoRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.small),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '$label:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.small),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: valueColor ?? AppColors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
