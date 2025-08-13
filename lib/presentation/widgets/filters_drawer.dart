import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class FiltersDrawer extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const FiltersDrawer({
    super.key,
    required this.currentFilters,
    required this.onFiltersChanged,
  });

  @override
  State<FiltersDrawer> createState() => _FiltersDrawerState();
}

class _FiltersDrawerState extends State<FiltersDrawer> {
  late Map<String, dynamic> _filters;

  // Opções de filtros
  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Genderless',
    'Unknown',
  ];
  final List<String> _statusOptions = ['Alive', 'Dead', 'Unknown'];
  final List<String> _speciesOptions = [
    'Human',
    'Alien',
    'Robot',
    'Animal',
    'Cronenberg',
    'Disease',
    'Mythological Creature',
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    final int activeFiltersCount = _getActiveFiltersCount();

    return Drawer(
      backgroundColor: const Color(0xFF0F0F0F),
      child: SafeArea(
        child: Column(
          children: [
            // Header do drawer - Mais elegante
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.tune,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Filtros',
                              style: AppTextStyles.headlineMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                              ),
                            ),
                            Text(
                              activeFiltersCount > 0
                                  ? '$activeFiltersCount filtro${activeFiltersCount > 1 ? 's' : ''} ativo${activeFiltersCount > 1 ? 's' : ''}'
                                  : 'Refine sua busca',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (activeFiltersCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '$activeFiltersCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Lista de filtros com design moderno
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0F0F0F),
                      const Color(0xFF1A1A1A).withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    // Filtro por Status
                    _buildModernFilterSection(
                      title: 'Status de Vida',
                      icon: Icons.favorite_rounded,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.statusAlive.withValues(alpha: 0.1),
                          AppColors.statusDead.withValues(alpha: 0.1),
                        ],
                      ),
                      activeCount: _getFilterCount('status'),
                      child: Column(
                        children: _statusOptions.map((status) {
                          return _buildModernCheckboxTile(
                            title: _getStatusDisplayName(status),
                            value:
                                _filters['status']?.contains(status) ?? false,
                            onChanged: (value) =>
                                _toggleFilter('status', status, value),
                            icon: _getStatusIcon(status),
                            color: _getStatusColor(status),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Filtro por Gênero
                    _buildModernFilterSection(
                      title: 'Gênero',
                      icon: Icons.people_rounded,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.1),
                          AppColors.primary.withValues(alpha: 0.05),
                        ],
                      ),
                      activeCount: _getFilterCount('gender'),
                      child: Column(
                        children: _genderOptions.map((gender) {
                          return _buildModernCheckboxTile(
                            title: _getGenderDisplayName(gender),
                            value:
                                _filters['gender']?.contains(gender) ?? false,
                            onChanged: (value) =>
                                _toggleFilter('gender', gender, value),
                            icon: _getGenderIcon(gender),
                            color: AppColors.primary,
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Filtro por Espécie
                    _buildModernFilterSection(
                      title: 'Espécie',
                      icon: Icons.category_rounded,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF87A1FA).withValues(alpha: 0.1),
                          const Color(0xFF87A1FA).withValues(alpha: 0.05),
                        ],
                      ),
                      activeCount: _getFilterCount('species'),
                      child: Column(
                        children: _speciesOptions.map((species) {
                          return _buildModernCheckboxTile(
                            title: _getSpeciesDisplayName(species),
                            value:
                                _filters['species']?.contains(species) ?? false,
                            onChanged: (value) =>
                                _toggleFilter('species', species, value),
                            icon: _getSpeciesIcon(species),
                            color: const Color(0xFF87A1FA),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Botões de ação modernos
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Resumo dos filtros aplicados
                  if (activeFiltersCount > 0)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.08),
                            AppColors.primary.withValues(alpha: 0.12),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Filtros Ativos',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getFilterSummary(),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Botões de ação
                  Row(
                    children: [
                      // Botão Limpar
                      Expanded(
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: activeFiltersCount > 0
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Colors.white.withValues(alpha: 0.1),
                              width: 1.5,
                            ),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: activeFiltersCount > 0
                                ? _clearFilters
                                : null,
                            icon: Icon(
                              Icons.clear_rounded,
                              color: activeFiltersCount > 0
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : Colors.white.withValues(alpha: 0.3),
                              size: 20,
                            ),
                            label: Text(
                              'Limpar',
                              style: TextStyle(
                                color: activeFiltersCount > 0
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : Colors.white.withValues(alpha: 0.3),
                                fontSize: 14, // Alterado de 16 para 14
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Botão Aplicar
                      Expanded(
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withValues(alpha: 0.8),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _applyFilters,
                            icon: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: const Text(
                              'Aplicar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14, // Alterado de 16 para 14
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernFilterSection({
    required String title,
    required IconData icon,
    required Widget child,
    required Gradient gradient,
    int activeCount = 0,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: activeCount > 0
              ? AppColors.primary.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: activeCount > 0
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header da seção
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: activeCount > 0
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: activeCount > 0
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: 0.7),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (activeCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      '$activeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Conteúdo da seção
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildModernCheckboxTile({
    required String title,
    required bool value,
    required Function(bool?) onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: value ? color.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: value
            ? Border.all(color: color.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: CheckboxListTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: value
                    ? color.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: value ? color : Colors.white.withValues(alpha: 0.6),
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: value
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.8),
                  fontWeight: value ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        value: value,
        onChanged: onChanged,
        activeColor: color,
        checkColor: Colors.white,
        controlAffinity: ListTileControlAffinity.trailing,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: const CircleBorder(), // Checkbox redondo
        side: BorderSide(
          color: value ? color : Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  // Métodos auxiliares para nomes mais amigáveis
  String _getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return 'Vivo';
      case 'dead':
        return 'Morto';
      case 'unknown':
        return 'Desconhecido';
      default:
        return status;
    }
  }

  String _getGenderDisplayName(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return 'Masculino';
      case 'female':
        return 'Feminino';
      case 'genderless':
        return 'Sem gênero';
      case 'unknown':
        return 'Desconhecido';
      default:
        return gender;
    }
  }

  String _getSpeciesDisplayName(String species) {
    switch (species.toLowerCase()) {
      case 'human':
        return 'Humano';
      case 'alien':
        return 'Alienígena';
      case 'robot':
        return 'Robô';
      case 'animal':
        return 'Animal';
      case 'cronenberg':
        return 'Cronenberg';
      case 'disease':
        return 'Doença';
      case 'mythological creature':
        return 'Criatura Mitológica';
      default:
        return species;
    }
  }

  void _toggleFilter(String filterType, String value, bool? isSelected) {
    setState(() {
      if (_filters[filterType] == null) {
        _filters[filterType] = <String>[];
      }

      if (isSelected == true) {
        if (!_filters[filterType].contains(value)) {
          _filters[filterType].add(value);
        }
      } else {
        _filters[filterType].remove(value);
        if (_filters[filterType].isEmpty) {
          _filters.remove(filterType);
        }
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _filters.clear();
    });
    widget.onFiltersChanged(_filters);
    Navigator.pop(context);
  }

  void _applyFilters() {
    widget.onFiltersChanged(_filters);
    Navigator.pop(context);
  }

  int _getActiveFiltersCount() {
    int count = 0;
    _filters.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        count += value.length;
      }
    });
    return count;
  }

  int _getFilterCount(String filterType) {
    final filterList = _filters[filterType];
    if (filterList is List) {
      return filterList.length;
    }
    return 0;
  }

  String _getFilterSummary() {
    List<String> active = [];

    _filters.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        switch (key) {
          case 'status':
            final statusNames = value
                .map((v) => _getStatusDisplayName(v))
                .join(', ');
            active.add('Status: $statusNames');
            break;
          case 'gender':
            final genderNames = value
                .map((v) => _getGenderDisplayName(v))
                .join(', ');
            active.add('Gênero: $genderNames');
            break;
          case 'species':
            final speciesNames = value
                .map((v) => _getSpeciesDisplayName(v))
                .join(', ');
            active.add('Espécie: $speciesNames');
            break;
        }
      }
    });

    return active.join('\n');
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return Icons.favorite_rounded;
      case 'dead':
        return Icons.heart_broken_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

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

  IconData _getGenderIcon(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return Icons.male_rounded;
      case 'female':
        return Icons.female_rounded;
      case 'genderless':
        return Icons.circle_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  IconData _getSpeciesIcon(String species) {
    switch (species.toLowerCase()) {
      case 'human':
        return Icons.person_rounded;
      case 'alien':
        return Icons.rocket_launch_rounded;
      case 'robot':
        return Icons.smart_toy_rounded;
      case 'animal':
        return Icons.pets_rounded;
      case 'cronenberg':
        return Icons.bug_report_rounded;
      case 'disease':
        return Icons.coronavirus_rounded;
      case 'mythological creature':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
