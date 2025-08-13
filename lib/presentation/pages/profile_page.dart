import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/theme/app_theme.dart';
import '../../data/models/character_model.dart';
import '../../data/services/local_auth_service.dart';
import '../widgets/character_card.dart';
import '../widgets/dialogs/login_dialog.dart';
import '../widgets/dialogs/signup_dialog.dart';
import '../widgets/dialogs/edit_profile_dialog.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/settings_tab.dart';
import 'character_detail_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final LocalAuthService _authService = LocalAuthService();

  // Dados do usuário
  String _userName = '';
  String _userEmail = '';
  bool _isLoggedIn = false;
  bool _isLoading = true;

  // Lista de favoritos - agora carregada do SharedPreferences
  List<CharacterModel> _favoriteCharacters = [];
  bool _isLoadingFavorites = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _checkAuthStatus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    // Quando mudamos para a aba de favoritos (index 0), recarregar
    if (_tabController.index == 0 && _isLoggedIn) {
      _loadFavorites();
    }
  }

  Future<void> _checkAuthStatus() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        setState(() {
          _isLoggedIn = true;
          _userName = user['name'] ?? '';
          _userEmail = user['email'] ?? '';
        });
        // Carregar favoritos após login
        _loadFavorites();
      }
    } catch (e) {
      debugPrint('Erro ao verificar status de login: $e');
    }

    setState(() => _isLoading = false);
  }

  // Novo método para carregar favoritos do SharedPreferences
  Future<void> _loadFavorites() async {
    if (_isLoadingFavorites) return;

    setState(() => _isLoadingFavorites = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> favoritesJson;

      try {
        favoritesJson =
            prefs.getStringList('favorite_characters') ?? <String>[];
      } catch (e) {
        debugPrint('Erro ao carregar favoritos: $e');
        favoritesJson = <String>[];
      }

      List<CharacterModel> loadedFavorites = [];

      for (String json in favoritesJson) {
        try {
          final characterData = jsonDecode(json);
          if (characterData is Map<String, dynamic>) {
            final character = CharacterModel.fromJson(characterData);
            loadedFavorites.add(character);
          }
        } catch (e) {
          debugPrint('Erro ao decodificar favorito: $e');
        }
      }

      if (mounted) {
        setState(() {
          _favoriteCharacters = loadedFavorites;
        });
      }
    } catch (e) {
      debugPrint('Erro geral ao carregar favoritos: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingFavorites = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: _buildAppBar(),
      body: _isLoggedIn ? _buildLoggedInView() : _buildLoginView(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF000000),
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
      ),
      title: Text(
        'Perfil',
        style: AppTextStyles.headlineMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
      actions: [
        if (_isLoggedIn)
          IconButton(
            onPressed: _showLogoutDialog,
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Sair',
          ),
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: _buildAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
            const SizedBox(height: 24),
            Text(
              'Carregando perfil...',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF000000),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone de perfil animado
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    AppColors.primary.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(Icons.person, size: 60, color: AppColors.primary),
            ),
            const SizedBox(height: 40),

            Text(
              '👋 Olá! Faça login para continuar',
              style: AppTextStyles.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            Text(
              'Acesse sua conta para gerenciar favoritos, configurações e muito mais.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white70,
                height: 1.6,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),

            // Botões de ação
            _buildActionButton(
              onPressed: _showLoginDialog,
              icon: Icons.login_rounded,
              label: 'Entrar',
              isPrimary: true,
            ),
            const SizedBox(height: 16),

            _buildActionButton(
              onPressed: _showSignUpDialog,
              icon: Icons.person_add_rounded,
              label: 'Criar Conta',
              isPrimary: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isPrimary,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: isPrimary
          ? ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, color: Colors.white),
              label: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, color: AppColors.primary),
              label: Text(
                label,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
    );
  }

  Widget _buildLoggedInView() {
    return Column(
      children: [
        // Header do perfil
        ProfileHeader(userName: _userName, userEmail: _userEmail),

        // Tabs
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            indicatorWeight: 4,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700),
            tabs: const [
              Tab(text: 'Favoritos'),
              Tab(text: 'Configurações'),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildFavoritesTab(), _buildSettingsTabContent()],
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesTab() {
    if (_isLoadingFavorites) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF000000),
              AppColors.primary.withValues(alpha: 0.03),
            ],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (_favoriteCharacters.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF000000),
              AppColors.primary.withValues(alpha: 0.03),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0), // Reduzido de 40.0 para 24.0
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, // Reduzido de 120 para 80
                  height: 80, // Reduzido de 120 para 80
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.15),
                        AppColors.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.favorite_border_rounded,
                    size: 40, // Reduzido de 60 para 40
                    color: AppColors.primary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 20), // Reduzido de 32 para 20
                Text(
                  '💫 Nenhum favorito ainda',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16, // Reduzido de 18 para 16
                  ),
                ),
                const SizedBox(height: 12), // Reduzido de 16 para 12
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ), // Padding lateral
                  child: Text(
                    'Explore os personagens e adicione seus favoritos aqui! Seus personagens favoritos aparecerão nesta seção.',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.4, // Reduzido de 1.6 para 1.4
                      fontSize: 13, // Reduzido de 14 para 13
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3, // Limitando a 3 linhas
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 24), // Reduzido de 32 para 24
                SizedBox(
                  height: 44, // Altura fixa para o botão
                  child: ElevatedButton.icon(
                    onPressed: _loadFavorites,
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 18,
                    ), // Ícone menor
                    label: const Text(
                      'Atualizar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14, // Tamanho menor
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ), // Padding menor
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF000000),
            AppColors.primary.withValues(alpha: 0.03),
          ],
        ),
      ),
      child: Column(
        children: [
          // Header com contador
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.favorite, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${_favoriteCharacters.length} ${_favoriteCharacters.length == 1 ? 'favorito' : 'favoritos'}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _loadFavorites,
                  icon: const Icon(Icons.refresh, color: Colors.white70),
                  tooltip: 'Atualizar favoritos',
                ),
              ],
            ),
          ),
          // Lista de favoritos
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _favoriteCharacters.length,
              itemBuilder: (context, index) {
                final character = _favoriteCharacters[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: CharacterCard(
                    character: character,
                    onTap: () => _navigateToCharacterDetail(character),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCharacterDetail(CharacterModel character) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterDetailPage(character: character),
      ),
    ).then((_) {
      // Recarregar favoritos quando voltar da página de detalhes
      _loadFavorites();
    });
  }

  Widget _buildSettingsTabContent() {
    return SettingsTab(
      onEditProfile: _editProfile,
      onLogout: _showLogoutDialog,
    );
  }

  // Métodos dos dialogs
  void _showLoginDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoginDialog(onLogin: _handleLogin),
    );
  }

  void _showSignUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SignUpDialog(onSignUp: _handleSignUp),
    );
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(
        currentName: _userName,
        currentEmail: _userEmail,
        onSave: _handleProfileUpdate,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1B1F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.logout, color: Colors.red, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Sair da Conta', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'Tem certeza que deseja sair da sua conta? Você precisará fazer login novamente para acessar seus dados.',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: _handleLogout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Sair', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Handlers
  Future<void> _handleLogin(String email, String password) async {
    try {
      final user = await _authService.login(email, password);
      if (user != null && mounted) {
        setState(() {
          _isLoggedIn = true;
          _userEmail = user['email'];
          _userName = user['name'];
        });
        if (mounted) {
          Navigator.pop(context);
          _showSuccessSnackBar('Login realizado com sucesso! 🎉');
          // Carregar favoritos após login bem-sucedido
          _loadFavorites();
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorSnackBar(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  Future<void> _handleSignUp(String name, String email, String password) async {
    try {
      await _authService.register(name, email, password);
      if (mounted) {
        setState(() {
          _isLoggedIn = true;
          _userName = name;
          _userEmail = email;
        });
        Navigator.pop(context);
        _showSuccessSnackBar('Conta criada com sucesso! Bem-vindo! 🎊');
        // Carregar favoritos após registro
        _loadFavorites();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorSnackBar(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  Future<void> _handleProfileUpdate(String name, String email) async {
    try {
      await _authService.updateProfile(name, email);
      if (mounted) {
        setState(() {
          _userName = name;
          _userEmail = email;
        });
        Navigator.pop(context);
        _showSuccessSnackBar('Perfil atualizado com sucesso! ✨');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorSnackBar('Erro ao atualizar perfil: $e');
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.logout();
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _favoriteCharacters.clear();
          _userName = '';
          _userEmail = '';
        });
        Navigator.pop(context);
        _showSuccessSnackBar('Logout realizado com sucesso! 👋');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorSnackBar('Erro ao fazer logout: $e');
      }
    }
  }

  // Utilities
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
