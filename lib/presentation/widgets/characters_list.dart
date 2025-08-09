import 'package:flutter/material.dart';
import '../../data/models/character_model.dart';
import '../../core/theme/app_theme.dart';
import 'character_card.dart';

class CharactersList extends StatelessWidget {
  final List<CharacterModel> characters;
  final ScrollController scrollController;
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final bool hasNextPage;
  final Function(CharacterModel) onCharacterTap;
  final VoidCallback onRetry;

  const CharactersList({
    super.key,
    required this.characters,
    required this.scrollController,
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
    required this.hasNextPage,
    required this.onCharacterTap,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (hasError) {
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
              'Erro ao carregar personagens',
              style: AppTextStyles.titleMedium,
            ),
            SizedBox(height: AppSpacing.small),
            Text(
              errorMessage,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.medium),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (characters.isEmpty && isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (characters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: AppSizes.iconLarge * 2,
              color: AppColors.onSurfaceVariant,
            ),
            SizedBox(height: AppSpacing.medium),
            Text(
              'Nenhum personagem encontrado',
              style: AppTextStyles.titleMedium,
            ),
            SizedBox(height: AppSpacing.small),
            Text('Tente buscar por outro nome', style: AppTextStyles.bodySmall),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: characters.length + (hasNextPage ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == characters.length) {
          return isLoading
              ? Container(
                  padding: EdgeInsets.all(AppSpacing.medium),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              : const SizedBox.shrink();
        }

        final character = characters[index];
        return CharacterCard(
          character: character,
          onTap: () => onCharacterTap(character),
        );
      },
    );
  }
}
