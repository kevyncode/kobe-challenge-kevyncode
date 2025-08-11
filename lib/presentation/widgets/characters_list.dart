import 'package:flutter/material.dart';
import '../../data/models/character_model.dart';
import '../../core/theme/app_theme.dart';
import 'character_card.dart';
import 'empty_state_widget.dart';

class CharactersList extends StatelessWidget {
  final List<CharacterModel> characters;
  final ScrollController scrollController;
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final bool hasNextPage;
  final Function(CharacterModel) onCharacterTap;
  final VoidCallback onRetry;
  final bool isFiltered;
  final VoidCallback? onClearFilters;

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
    this.isFiltered = false,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    // Estado de erro
    if (hasError && characters.isEmpty) {
      return _buildErrorState();
    }

    // Estado vazio (sem personagens encontrados)
    if (!isLoading && characters.isEmpty) {
      return _buildEmptyState();
    }

    // Lista de personagens - DESIGN ORIGINAL sem padding extra
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16.0), // Padding original de volta
      itemCount: characters.length + (hasNextPage || isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        // Item de loading no final da lista
        if (index >= characters.length) {
          return _buildLoadingItem();
        }

        final character = characters[index];
        return Padding(
          padding: const EdgeInsets.only(
            bottom: 16.0,
          ), // Padding original simples
          child: CharacterCard(
            // SEM Center, SEM modificações extras
            character: character,
            onTap: () => onCharacterTap(character),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return EmptyStateWidget(
      title: 'Oops! Algo deu errado',
      description: 'Não foi possível carregar os personagens.\n$errorMessage',
      icon: Icons.error_outline,
      buttonText: 'Tentar Novamente',
      onButtonPressed: onRetry,
    );
  }

  Widget _buildEmptyState() {
    if (isFiltered) {
      return EmptyStateWidget(
        title: 'Nenhum personagem encontrado',
        description:
            'Não encontramos personagens que correspondam aos filtros aplicados. Tente ajustar os critérios de busca.',
        icon: Icons.filter_alt_off,
        buttonText: 'Limpar Filtros',
        onButtonPressed: onClearFilters,
        isFiltered: true,
      );
    } else {
      return EmptyStateWidget(
        title: 'Nenhum personagem encontrado',
        description:
            'Não há personagens disponíveis no momento. Verifique sua conexão e tente novamente.',
        icon: Icons.people_outline,
        buttonText: 'Recarregar',
        onButtonPressed: onRetry,
      );
    }
  }

  Widget _buildLoadingItem() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child: hasError
          ? Column(
              children: [
                Text(
                  'Erro ao carregar mais personagens',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, color: AppColors.primary),
                  label: const Text(
                    'Tentar novamente',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            )
          : const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
    );
  }
}
