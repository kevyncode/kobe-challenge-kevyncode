import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/character_model.dart';
import '../../core/theme/app_theme.dart';

/// Widget de card para exibir personagens com layout vertical
class CharacterCard extends StatelessWidget {
  final CharacterModel character;
  final VoidCallback? onTap;

  const CharacterCard({super.key, required this.character, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Calcula altura responsiva baseada na largura da tela
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - (AppSpacing.medium * 4)) / 2; // 2 colunas
    final cardHeight = cardWidth * 1.3; // Proporção 1.3:1 para o card completo

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.medium, // Aumentado para mais espaço
        vertical: AppSpacing.medium, // Aumentado para mais espaço
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: SizedBox(
          height: cardHeight.clamp(160.0, 200.0), // Min 160px, Max 200px
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.large),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Imagem do personagem (75% da altura do card)
                Expanded(
                  flex: 3, // 3/4 do espaço para a imagem
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.large),
                      topRight: Radius.circular(AppRadius.large),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: character.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        color: AppColors.surface,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surface,
                        child: Icon(
                          Icons.person,
                          color: AppColors.onSurfaceVariant,
                          size: AppSizes.iconLarge,
                        ),
                      ),
                    ),
                  ),
                ),
                // Nome do personagem com fundo gradiente (25% da altura)
                Expanded(
                  flex: 1, // 1/4 do espaço para o nome
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFF87A1FA), // Cor solicitada
                          Color(
                            0xFF87A1FA,
                          ), // Mesma cor para um gradiente sólido
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(AppRadius.large),
                        bottomRight: Radius.circular(AppRadius.large),
                      ),
                    ),
                    padding: const EdgeInsets.only(
                      left: 16.0, // 16px da parede esquerda
                      right: 8.0, // Padding menor na direita
                      top: 8.0,
                      bottom: 8.0,
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      character.name.toUpperCase(),
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontSize: 15, // 15px
                        fontWeight: FontWeight.w900, // 900 black
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.left,
                      maxLines: 2, // Permite 2 linhas para nomes maiores
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
