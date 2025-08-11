import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import '../../core/theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onFiltersPressed;
  final VoidCallback onProfilePressed;
  final bool useBackButton;
  final ScrollController? scrollController;

  const CustomAppBar({
    super.key,
    required this.onFiltersPressed,
    required this.onProfilePressed,
    this.useBackButton = false,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scrollController ?? ScrollController(),
      builder: (context, child) {
        // Calcula a opacidade baseada no scroll
        double scrollOffset = scrollController?.hasClients == true
            ? scrollController!.offset
            : 0.0;

        // Opacidade varia de 1.0 (no topo) para 0.8 (após 100px de scroll)
        double opacity = (1.0 - (scrollOffset / 200.0)).clamp(0.8, 1.0);

        return Container(
          decoration: BoxDecoration(
            // Efeito de vidro com backdrop filter
            color: const Color(0xFF1C1B1F).withOpacity(opacity),
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: scrollOffset > 50 ? 10.0 : 0.0,
                sigmaY: scrollOffset > 50 ? 10.0 : 0.0,
              ),
              child: AppBar(
                backgroundColor:
                    Colors.transparent, // Transparente para o efeito
                elevation: scrollOffset > 50 ? 4.0 : 0.0, // Sombra suave
                shadowColor: Colors.black.withOpacity(0.3),
                toolbarHeight: 130.0,
                leadingWidth: 56,
                leading: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: IconButton(
                        icon: Icon(
                          useBackButton ? Icons.arrow_back : Icons.menu,
                          color: AppColors.onPrimary,
                        ),
                        onPressed: onFiltersPressed,
                        tooltip: useBackButton ? 'Voltar' : 'Filtros',
                      ),
                    ),
                  ),
                ),
                title: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo SVG com animação suave
                        AnimatedOpacity(
                          opacity: scrollOffset > 100 ? 0.9 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: SvgPicture.asset(
                            'lib/assets/images/logo.svg',
                            height: 77,
                            width: 115,
                            colorFilter: ColorFilter.mode(
                              AppColors.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        // Texto do título com animação suave
                        AnimatedOpacity(
                          opacity: scrollOffset > 100 ? 0.9 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            'RICK AND MORTY API',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.onPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                centerTitle: true,
                actions: [
                  // Ícone de perfil com animação
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: IconButton(
                          icon: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.onPrimary,
                                width: 2,
                              ),
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
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(130.0);
}
