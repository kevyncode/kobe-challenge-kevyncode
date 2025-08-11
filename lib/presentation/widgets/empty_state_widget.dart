import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final bool isFiltered;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.search_off,
    this.buttonText,
    this.onButtonPressed,
    this.isFiltered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone grande
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),

            // Título
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),

            // Descrição
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Botão de ação (se fornecido)
            if (buttonText != null && onButtonPressed != null)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    debugPrint('EmptyStateWidget: InkWell onTap - início');
                    debugPrint('EmptyStateWidget: isFiltered: $isFiltered');
                    debugPrint('EmptyStateWidget: buttonText: $buttonText');

                    try {
                      onButtonPressed!();
                      debugPrint(
                        'EmptyStateWidget: onButtonPressed executado com sucesso',
                      );
                    } catch (e) {
                      debugPrint(
                        'EmptyStateWidget: Erro ao executar onButtonPressed: $e',
                      );
                    }

                    debugPrint('EmptyStateWidget: InkWell onTap - fim');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isFiltered ? Icons.filter_alt_off : Icons.refresh,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          buttonText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
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
