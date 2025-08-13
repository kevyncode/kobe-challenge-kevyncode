import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/character_model.dart';
import '../../core/theme/app_theme.dart';

class CharacterCard extends StatelessWidget {
  final CharacterModel character;
  final VoidCallback onTap;

  const CharacterCard({
    super.key,
    required this.character,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 200, // Alterado de 160 para 200
        constraints: const BoxConstraints(
          maxWidth: 400,
          minHeight: 200, // Alterado de 160 para 200
          maxHeight: 200, // Alterado de 160 para 200
        ),
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
        child: Stack(
          children: [
            // Imagem de fundo - ocupa todo o card
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.large),
              child: CachedNetworkImage(
                imageUrl: character.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200, // Alterado de 160 para 200
                placeholder: (context, url) => Container(
                  width: double.infinity,
                  height: 200, // Alterado de 160 para 200
                  color: AppColors.surface,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 3,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: double.infinity,
                  height: 200, // Alterado de 160 para 200
                  color: AppColors.surface,
                  child: Icon(
                    Icons.person,
                    color: AppColors.onSurfaceVariant,
                    size: 60,
                  ),
                ),
              ),
            ),
            // Background com a cor #87A1FA para o nome
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60, // Área do texto mantida
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(AppRadius.large),
                    bottomRight: Radius.circular(AppRadius.large),
                  ),
                  color: const Color(0xFF87A1FA), // Cor exata solicitada
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      character.name.toUpperCase(),
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
