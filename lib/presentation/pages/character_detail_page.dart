import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/models/character_model.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';

class CharacterDetailPage extends StatefulWidget {
  final CharacterModel character;

  const CharacterDetailPage({super.key, required this.character});

  @override
  State<CharacterDetailPage> createState() => _CharacterDetailPageState();
}

class _CharacterDetailPageState extends State<CharacterDetailPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadFavoriteStatus();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadFavoriteStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Tentar carregar como StringList primeiro
      List<String>? favoritesJson;
      try {
        favoritesJson = prefs.getStringList('favorite_characters');
      } catch (e) {
        // Se falhar, limpar dados corrompidos
        debugPrint('Dados corrompidos detectados, limpando...');
        await prefs.remove('favorite_characters');
        favoritesJson = null;
      }

      // Se não existir ou estiver vazio, inicializar
      if (favoritesJson == null) {
        favoritesJson = <String>[];
        await prefs.setStringList('favorite_characters', favoritesJson);
      }

      final favoriteIds = <int>[];
      for (String json in favoritesJson) {
        try {
          final characterData = jsonDecode(json);
          if (characterData is Map<String, dynamic> &&
              characterData.containsKey('id')) {
            final character = CharacterModel.fromJson(characterData);
            favoriteIds.add(character.id);
          }
        } catch (e) {
          debugPrint('Erro ao decodificar personagem favorito: $e');
        }
      }

      if (mounted) {
        setState(() {
          _isFavorite = favoriteIds.contains(widget.character.id);
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar status de favorito: $e');
      // Em caso de erro, limpar tudo e começar do zero
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('favorite_characters');
        await prefs.setStringList('favorite_characters', <String>[]);
      } catch (clearError) {
        debugPrint('Erro ao limpar dados: $clearError');
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    // Animar o botão
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // Carregar favoritos com validação
      List<String> favoritesJson;
      try {
        favoritesJson =
            prefs.getStringList('favorite_characters') ?? <String>[];
      } catch (e) {
        // Se dados estão corrompidos, limpar e começar do zero
        debugPrint('Dados corrompidos durante toggle, limpando...');
        await prefs.remove('favorite_characters');
        favoritesJson = <String>[];
      }

      List<CharacterModel> favorites = [];

      // Carregar favoritos existentes com validação robusta
      for (String json in favoritesJson) {
        try {
          final characterData = jsonDecode(json);
          if (characterData is Map<String, dynamic>) {
            final character = CharacterModel.fromJson(characterData);
            favorites.add(character);
          }
        } catch (e) {
          debugPrint('Erro ao decodificar favorito existente: $e');
          // Pular este item corrompido
          continue;
        }
      }

      if (_isFavorite) {
        // Remover dos favoritos
        favorites.removeWhere((char) => char.id == widget.character.id);
      } else {
        // Adicionar aos favoritos
        favorites.add(widget.character);
      }

      // Salvar a lista atualizada com validação
      final List<String> updatedJson = [];
      for (CharacterModel char in favorites) {
        try {
          final jsonString = jsonEncode(char.toJson());
          if (jsonString.isNotEmpty) {
            updatedJson.add(jsonString);
          }
        } catch (e) {
          debugPrint('Erro ao serializar favorito: $e');
        }
      }

      // Salvar com verificação final
      await prefs.setStringList('favorite_characters', updatedJson);

      // Verificar se salvou corretamente
      final savedList = prefs.getStringList('favorite_characters');
      if (savedList != null) {
        if (mounted) {
          setState(() {
            _isFavorite = !_isFavorite;
          });

          // Mostrar feedback visual
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                    size: 24, // Aumentado de 20 para 24
                  ),
                  const SizedBox(width: 16), // Aumentado de 12 para 16
                  Expanded(
                    child: Text(
                      _isFavorite
                          ? '❤️ Adicionado aos favoritos!'
                          : '💔 Removido dos favoritos',
                      style: const TextStyle(
                        fontSize: 16, // Aumentado de 14 para 16
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: _isFavorite
                  ? const Color(0xFF9C7BF4) // Roxo claro quando adiciona
                  : const Color(0xFFFF7B7B), // Vermelho claro quando remove
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  16,
                ), // Aumentado de 8 para 16
              ),
              margin: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 20,
              ), // Margens maiores
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ), // Padding maior
              duration: const Duration(
                seconds: 3,
              ), // Aumentado de 2 para 3 segundos
              elevation: 8, // Adicionado elevação
            ),
          );
        }
      } else {
        throw Exception('Falha ao salvar favoritos');
      }
    } catch (e) {
      debugPrint('Erro ao salvar favorito: $e');

      // Mostrar erro para o usuário
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 24,
                ), // Aumentado de 20 para 24
                const SizedBox(width: 16), // Aumentado de 12 para 16
                Expanded(
                  child: Text(
                    'Erro ao salvar favorito. Dados foram reiniciados.',
                    style: const TextStyle(
                      fontSize: 16, // Aumentado de 14 para 16
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(
              0xFFFF5252,
            ), // Vermelho mais suave para erro
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // Aumentado de 8 para 16
            ),
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 20,
            ), // Margens maiores
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ), // Padding maior
            duration: const Duration(
              seconds: 4,
            ), // Aumentado de 3 para 4 segundos
            elevation: 8, // Adicionado elevação
          ),
        );

        // Limpar dados corrompidos como último recurso
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('favorite_characters');
          await prefs.setStringList('favorite_characters', <String>[]);
        } catch (clearError) {
          debugPrint('Erro crítico ao limpar dados: $clearError');
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: CustomAppBar(
        useBackButton: true,
        scrollController: _scrollController,
        // A AppBar agora gerencia automaticamente a navegação para o perfil
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
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
                      height: 300,
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
                        colors: [Color(0xFF87A1FA), Color(0xFF87A1FA)],
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
                        // Nome do personagem com botão de favorito
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.character.name.toUpperCase(),
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Botão de favorito com fundo de vidro
                            AnimatedBuilder(
                              animation: _scaleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      // Efeito de vidro
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.1,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: _isLoading
                                            ? null
                                            : _toggleFavorite,
                                        child: Center(
                                          child: _isLoading
                                              ? SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.white
                                                            .withValues(
                                                              alpha: 0.8,
                                                            ),
                                                        strokeWidth: 2,
                                                      ),
                                                )
                                              : AnimatedSwitcher(
                                                  duration: const Duration(
                                                    milliseconds: 300,
                                                  ),
                                                  child: Icon(
                                                    _isFavorite
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    key: ValueKey(_isFavorite),
                                                    color: _isFavorite
                                                        ? Colors.red
                                                        : Colors.white
                                                              .withValues(
                                                                alpha: 0.8,
                                                              ),
                                                    size: 24,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Status com indicador colorido
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

  // Widget helper para criar linhas de detalhes
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
