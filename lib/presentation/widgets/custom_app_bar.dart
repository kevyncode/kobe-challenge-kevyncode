import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onFiltersPressed;
  final VoidCallback onProfilePressed;

  const CustomAppBar({
    super.key,
    required this.onFiltersPressed,
    required this.onProfilePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.onPrimary),
        onPressed: onFiltersPressed,
        tooltip: 'Filtros',
      ),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo SVG
          SvgPicture.asset(
            'assets/images/logo.svg',
            height: 40,
            width: 60,
            colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
          ),
          const SizedBox(height: 4),
          // Texto do título
          Text(
            'RICK AND MORTY API',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.onPrimary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        // Ícone de perfil
        IconButton(
          icon: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.onPrimary, width: 2),
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.onPrimary,
              size: 20,
            ),
          ),
          onPressed: onProfilePressed,
          tooltip: 'Perfil',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
