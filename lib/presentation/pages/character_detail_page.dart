import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/character_model.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';

class CharacterDetailPage extends StatefulWidget {
  final CharacterModel character;

  const CharacterDetailPage({super.key, required this.character});

  @override
  State<CharacterDetailPage> createState() => _CharacterDetailPageState();
}

class _CharacterDetailPageState extends State<CharacterDetailPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Fundo preto
      appBar: CustomAppBar(
        onFiltersPressed: () => Navigator.of(context).pop(), // Seta de voltar
        onProfilePressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Perfil - Em breve!')));
        },
        useBackButton: true, // Parâmetro para usar seta ao invés de menu
        scrollController: _scrollController, // Passar o scroll controller
      ),
      body: SingleChildScrollView(
        controller: _scrollController, // Adicionar o controller no scroll
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card expandido com informações
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.large),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Imagem do personagem
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.large),
                      topRight: Radius.circular(AppRadius.large),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget.character.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 300, // Altura maior para a página de detalhes
                      placeholder: (context, url) => Container(
                        height: 300,
                        color: AppColors.surface,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 300,
                        color: AppColors.surface,
                        child: Icon(
                          Icons.person,
                          color: AppColors.onSurfaceVariant,
                          size: 80,
                        ),
                      ),
                    ),
                  ),
                  // Seção com nome e informações
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFF87A1FA), // Mesma cor dos cards
                          Color(0xFF87A1FA),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(AppRadius.large),
                        bottomRight: Radius.circular(AppRadius.large),
                      ),
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nome do personagem
                        Text(
                          widget.character.name.toUpperCase(),
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Status com indicador colorido (sem label)
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getStatusColor(widget.character.status),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${widget.character.status} - ${widget.character.species}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Gênero
                        _buildDetailRow(
                          label: 'Gender:',
                          value: widget.character.gender,
                        ),
                        const SizedBox(height: 16),

                        // Espécie
                        _buildDetailRow(
                          label: 'Species:',
                          value: widget.character.species,
                        ),
                        const SizedBox(height: 16),

                        // Origem
                        _buildDetailRow(
                          label: 'Origin:',
                          value: widget.character.origin.name,
                        ),
                        const SizedBox(height: 16),

                        // Última localização conhecida
                        _buildDetailRow(
                          label: 'Last known location:',
                          value: widget.character.location.name,
                        ),
                        const SizedBox(height: 16),

                        // Primeira aparição
                        _buildDetailRow(
                          label: 'First seen in:',
                          value: widget.character.episodes.isNotEmpty
                              ? 'Episode ${widget.character.episodes.first.replaceAll(RegExp(r'[^0-9]'), '')}'
                              : 'Unknown',
                        ),
                        const SizedBox(height: 16),

                        // Número de episódios
                        _buildDetailRow(
                          label: 'Episodes:',
                          value:
                              '${widget.character.episodes.length} episode${widget.character.episodes.length != 1 ? 's' : ''}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper para criar linhas de detalhes sem ícones
  Widget _buildDetailRow({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Cor do status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return AppColors.statusAlive;
      case 'dead':
        return AppColors.statusDead;
      default:
        return AppColors.statusUnknown;
    }
  }
}
