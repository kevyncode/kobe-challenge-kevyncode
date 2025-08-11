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
      backgroundColor: const Color(0xFF1C1B1F),
      child: SafeArea(
        child: Column(
          children: [
            // Header do drawer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.filter_list,
                        color: Colors.white,
                        size: 32,
                      ),
                      if (activeFiltersCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$activeFiltersCount ativo${activeFiltersCount > 1 ? 's' : ''}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Filtros',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    activeFiltersCount > 0
                        ? '$activeFiltersCount filtro${activeFiltersCount > 1 ? 's' : ''} aplicado${activeFiltersCount > 1 ? 's' : ''}'
                        : 'Refine sua busca',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  // Aviso sobre limitação da API
                  if (activeFiltersCount > 3)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Apenas 1 filtro por categoria será aplicado',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.orange,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Lista de filtros
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Filtro por Status
                  _buildFilterSection(
                    title: 'Status',
                    icon: Icons.favorite,
                    activeCount: _getFilterCount('status'),
                    child: Column(
                      children: _statusOptions.map((status) {
                        return _buildCheckboxTile(
                          title: status,
                          value: _filters['status']?.contains(status) ?? false,
                          onChanged: (value) =>
                              _toggleFilter('status', status, value),
                          icon: _getStatusIcon(status),
                          color: _getStatusColor(status),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Filtro por Gênero
                  _buildFilterSection(
                    title: 'Gênero',
                    icon: Icons.people,
                    activeCount: _getFilterCount('gender'),
                    child: Column(
                      children: _genderOptions.map((gender) {
                        return _buildCheckboxTile(
                          title: gender,
                          value: _filters['gender']?.contains(gender) ?? false,
                          onChanged: (value) =>
                              _toggleFilter('gender', gender, value),
                          icon: _getGenderIcon(gender),
                          color: AppColors.primary,
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Filtro por Espécie
                  _buildFilterSection(
                    title: 'Espécie',
                    icon: Icons.category,
                    activeCount: _getFilterCount('species'),
                    child: Column(
                      children: _speciesOptions.map((species) {
                        return _buildCheckboxTile(
                          title: species,
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
                ],
              ),
            ),

            // Botões de ação
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Indicador de filtros aplicados (se houver)
                  if (activeFiltersCount > 0)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '$activeFiltersCount filtro${activeFiltersCount > 1 ? 's' : ''} selecionado${activeFiltersCount > 1 ? 's' : ''}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Botões de ação
                  Row(
                    children: [
                      // Botão Limpar
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: activeFiltersCount > 0
                              ? _clearFilters
                              : null,
                          icon: Icon(
                            Icons.clear,
                            color: activeFiltersCount > 0
                                ? Colors.white70
                                : Colors.white38,
                          ),
                          label: Text(
                            'Limpar',
                            style: TextStyle(
                              color: activeFiltersCount > 0
                                  ? Colors.white70
                                  : Colors.white38,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: activeFiltersCount > 0
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.1),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Botão Aplicar
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _applyFilters,
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text(
                            'Aplicar',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required Widget child,
    int activeCount = 0,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activeCount > 0
              ? AppColors.primary.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          width: activeCount > 0 ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: activeCount > 0
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.7),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Aviso para múltiplos filtros por categoria
                if (activeCount > 1) ...[
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Apenas o primeiro filtro será aplicado',
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    child: Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.orange,
                    ),
                  ),
                ],
                if (activeCount > 0) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: activeCount > 1
                          ? Colors.orange.withOpacity(0.2)
                          : AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: activeCount > 1
                          ? Border.all(
                              color: Colors.orange.withOpacity(0.5),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Text(
                      '$activeCount',
                      style: TextStyle(
                        color: activeCount > 1 ? Colors.orange : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required bool value,
    required Function(bool?) onChanged,
    required IconData icon,
    required Color color,
  }) {
    return CheckboxListTile(
      title: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: value ? FontWeight.w600 : FontWeight.normal,
              ),
              overflow: TextOverflow.visible,
              softWrap: true,
            ),
          ),
        ],
      ),
      value: value,
      onChanged: onChanged,
      activeColor: color,
      checkColor: Colors.white,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
    );
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

  // Método para contar filtros ativos total
  int _getActiveFiltersCount() {
    int count = 0;
    _filters.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        count += value.length;
      }
    });
    return count;
  }

  // Método para contar filtros por categoria
  int _getFilterCount(String filterType) {
    final filterList = _filters[filterType];
    if (filterList is List) {
      return filterList.length;
    }
    return 0;
  }

  // Ícones para Status
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return Icons.favorite;
      case 'dead':
        return Icons.heart_broken;
      default:
        return Icons.help_outline;
    }
  }

  // Cores para Status
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

  // Ícones para Gênero
  IconData _getGenderIcon(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return Icons.male;
      case 'female':
        return Icons.female;
      case 'genderless':
        return Icons.circle;
      default:
        return Icons.help_outline;
    }
  }

  // Ícones para Espécie
  IconData _getSpeciesIcon(String species) {
    switch (species.toLowerCase()) {
      case 'human':
        return Icons.person;
      case 'alien':
        return Icons.rocket_launch;
      case 'robot':
        return Icons.smart_toy;
      case 'animal':
        return Icons.pets;
      case 'cronenberg':
        return Icons.bug_report;
      case 'disease':
        return Icons.coronavirus;
      case 'mythological creature':
        return Icons.auto_awesome;
      default:
        return Icons.category;
    }
  }
}
