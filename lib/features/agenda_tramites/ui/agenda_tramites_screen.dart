// Agenda de Trámites - Main Screen
// Premium UI with theme support

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../ui/theme/color_palette.dart';
import '../../../src/components/how_to_use_card.dart';
import '../domain/tramite_event.dart';
import '../domain/agenda_rules.dart';
import '../data/agenda_repository.dart';
import 'widgets/tramite_card.dart';
import 'widgets/summary_cards.dart';
import 'tramite_form_screen.dart';
import 'tramite_detail_screen.dart';

class AgendaTramitesScreen extends StatefulWidget {
  const AgendaTramitesScreen({Key? key}) : super(key: key);

  @override
  State<AgendaTramitesScreen> createState() => _AgendaTramitesScreenState();
}

class _AgendaTramitesScreenState extends State<AgendaTramitesScreen> {
  final _repository = AgendaRepository();
  List<TramiteEvent> _tramites = [];
  List<TramiteEvent> _filteredTramites = [];
  bool _isLoading = true;
  String _searchQuery = '';
  CategoriaEntidad? _selectedCategoria;

  @override
  void initState() {
    super.initState();
    _loadTramites();
  }

  Future<void> _loadTramites() async {
    setState(() => _isLoading = true);
    try {
      final tramites = await _repository.loadAll();
      setState(() {
        _tramites = tramites;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando trámites: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    _filteredTramites = _tramites.where((t) {
      final matchesSearch = _searchQuery.isEmpty ||
          t.titulo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.entidad.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategoria = _selectedCategoria == null ||
          t.categoria == _selectedCategoria;

      return matchesSearch && matchesCategoria;
    }).toList();

    // Sort by proximaFecha
    _filteredTramites.sort((a, b) => a.proximaFecha.compareTo(b.proximaFecha));
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _onCategoriaSelected(CategoriaEntidad? categoria) {
    setState(() {
      _selectedCategoria = categoria;
      _applyFilters();
    });
  }

  Future<void> _marcarRealizado(TramiteEvent tramite) async {
    final updated = AgendaRules.marcarRealizado(tramite);
    await _repository.upsert(updated);
    await _loadTramites();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trámite marcado como realizado')),
      );
    }
  }

  Future<void> _editarTramite(TramiteEvent tramite) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TramiteFormScreen(tramite: tramite),
      ),
    );

    if (result == true) {
      await _loadTramites();
    }
  }

  Future<void> _verDetalle(TramiteEvent tramite) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TramiteDetailScreen(tramite: tramite),
      ),
    );

    if (result == true) {
      await _loadTramites();
    }
  }

  Future<void> _agregarTramite() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TramiteFormScreen(),
      ),
    );

    if (result == true) {
      await _loadTramites();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      appBar: _buildAppBar(isDark),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(isDark),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _agregarTramite,
        backgroundColor: isDark ? AppColors.premiumGold : AppColors.lightAccent,
        icon: Icon(Icons.add, color: isDark ? AppColors.background : Colors.white),
        label: Text(
          'Nuevo',
          style: TextStyle(
            color: isDark ? AppColors.background : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? AppColors.background : Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Agenda de Trámites',
            style: GoogleFonts.outfit(
              color: isDark ? AppColors.premiumGold : AppColors.lightTextPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Recordatorios y vencimientos',
            style: GoogleFonts.outfit(
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 2,
          decoration: BoxDecoration(
            color: isDark ? AppColors.premiumGold : AppColors.lightAccent,
            boxShadow: [
              BoxShadow(
                color: (isDark ? AppColors.premiumGold : AppColors.lightAccent).withOpacity(0.3),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    return RefreshIndicator(
      onRefresh: _loadTramites,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Help Card: Para qué sirve
            HowToUseCard(
              title: '¿Para qué sirve la Agenda de Trámites?',
              icon: Icons.info_outline,
              accentColor: isDark ? AppColors.premiumGold : AppColors.lightAccent,
              steps: const [
                'Centraliza todos tus trámites empresariales: impuestos, permisos, licencias.',
                'Te alerta antes de que venzan tus obligaciones legales.',
                'Evita multas y sanciones por incumplimientos.',
                'Organiza recordatorios recurrentes (mensuales, anuales, etc.).',
              ],
            ),

            // Help Card: Cómo usar
            HowToUseCard(
              title: '¿Cómo usar esta sección?',
              icon: Icons.help_outline,
              accentColor: const Color(0xFF00E5FF),
              steps: const [
                'Toca "Nuevo" para agregar un trámite (ej: Declaración de renta).',
                'Configura la fecha de vencimiento y frecuencia de repetición.',
                'Revisa las tarjetas de resumen para ver próximos y vencidos.',
                'Marca como "Realizado" cuando completes un trámite.',
              ],
            ),

            // Summary Cards
            SummaryCardsWidget(tramites: _tramites),
            const SizedBox(height: 24),

            // Search Bar
            _buildSearchBar(isDark),
            const SizedBox(height: 16),

            // Filter Chips
            _buildFilterChips(isDark),
            const SizedBox(height: 24),

            // Tramites List
            _filteredTramites.isEmpty
                ? _buildEmptyState(isDark)
                : _buildTramitesList(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return TextField(
      onChanged: _onSearchChanged,
      style: TextStyle(
        color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
      ),
      decoration: InputDecoration(
        hintText: 'Buscar trámite...',
        hintStyle: TextStyle(
          color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: isDark ? AppColors.premiumGold : AppColors.lightAccent,
        ),
        filled: true,
        fillColor: isDark ? AppColors.surface : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    final categorias = [null, ...CategoriaEntidad.values];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categorias.map((cat) {
          final isSelected = _selectedCategoria == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(cat?.displayName ?? 'Todos'),
              selected: isSelected,
              onSelected: (_) => _onCategoriaSelected(cat),
              backgroundColor: isDark ? AppColors.surface : Colors.white,
              selectedColor: isDark ? AppColors.premiumGold : AppColors.lightAccent,
              labelStyle: TextStyle(
                color: isSelected
                    ? (isDark ? AppColors.background : Colors.white)
                    : (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTramitesList(bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredTramites.length,
      itemBuilder: (context, index) {
        final tramite = _filteredTramites[index];
        return TramiteCard(
          tramite: tramite,
          onTap: () => _verDetalle(tramite),
          onMarcarRealizado: () => _marcarRealizado(tramite),
          onEditar: () => _editarTramite(tramite),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay trámites',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega tu primer trámite o ajusta los filtros',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
