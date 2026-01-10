import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart'; // NEW For reading progress
import 'package:proyecto_empoderate/ui/theme/empoderate_theme.dart';
import 'package:proyecto_empoderate/src/components/premium_scaffold.dart';
import 'package:proyecto_empoderate/src/models/business_data.dart';
import '../data/rubro_tramites_repository.dart';

class RubroDetailScreen extends StatefulWidget { // CONVERTED TO STATEFUL
  final String categoryId;
  final String rubroId;

  const RubroDetailScreen({
    Key? key,
    required this.categoryId,
    required this.rubroId,
  }) : super(key: key);

  @override
  State<RubroDetailScreen> createState() => _RubroDetailScreenState();
}

class _RubroDetailScreenState extends State<RubroDetailScreen> {
  // Progress State
  double _progress = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculateGlobalProgress(); // Initial calc
  }

  // Reload progress when coming back from detail
  void _calculateGlobalProgress() async {
     // This logic is a bit simplistic: it counts a trámite as "started/progressing" 
     // based on checked items. For a more rigorous % we would sum total requirements vs checked requirements.
     // Here we'll do: (Total Checked Items across all Rubro Trámites) / (Total Requirements + Pasos) = Real %

     final tramites = RubroTramitesRepository.getTramitesForRubro(widget.categoryId, widget.rubroId);
     if (tramites.isEmpty) {
        if(mounted) setState(() { _progress = 0; _isLoading = false; });
        return;
     }

     final prefs = await SharedPreferences.getInstance();
     int totalItems = 0;
     int checkedItems = 0;

     for (var t in tramites) {
        final detail = RubroTramitesRepository.getTramiteDetail(t.id);
        if (detail != null) {
           final itemsCount = detail.requisitos.length + detail.pasos.length;
           totalItems += itemsCount;

           final checkedList = prefs.getStringList('tramite_progress_${t.id}') ?? [];
           checkedItems += checkedList.length;
        }
     }

     if (mounted) {
       setState(() {
          _progress = totalItems == 0 ? 0 : (checkedItems / totalItems);
          if (_progress > 1.0) _progress = 1.0; // Safety
          _isLoading = false;
       });
     }
  }

  @override
  Widget build(BuildContext context) {
    // DIAGNOSTIC LOGS
    debugPrint('RubroDetailScreen BUILD START');
    debugPrint('Params: categoryId=${widget.categoryId}, rubroId=${widget.rubroId}');

    // Default / Fallback Values
    String displayTitle = 'RUBRO DETALLE';
    String description = '';
    
    // SAFE LAYOUT BUILDER
    return Builder(
      builder: (context) {
        try {
          // 1. Data Lookup (Protected)
          if (widget.categoryId.isNotEmpty && widget.rubroId.isNotEmpty) {
             final category = categoryData.firstWhere(
               (c) => c.id == widget.categoryId,
               orElse: () => categoryData.first
             );
             final rubro = category.rubros.firstWhere(
               (r) => r.id == widget.rubroId, 
               orElse: () => BusinessRubro(id: widget.rubroId, name: widget.rubroId.toUpperCase(), description: '')
             );
             displayTitle = rubro.name;
             description = rubro.description;
             debugPrint('Lookup Success: $displayTitle');
          } else {
             debugPrint('Warning: Empty IDs passed to RubroDetail');
             displayTitle = 'RUBRO NO IDENTIFICADO';
          }
        } catch (e, stack) {
          debugPrint('Error in RubroDetailScreen lookup: $e');
          debugPrint(stack.toString());
          displayTitle = 'RUBRO (RECUPERADO)';
        }

        // 2. Fetch Tramites
        final tramites = RubroTramitesRepository.getTramitesForRubro(widget.categoryId, widget.rubroId);

        // 3. Build UI
        return PremiumScaffold(
          title: displayTitle.toUpperCase(),
          showBackButton: true,
          isNeonTitle: true,
          useScroll: false,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PROGRESS BAR
                if (!_isLoading && tramites.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _buildProgressHeader(),
                  ),

                // Subtitle / Description
                if (description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      description,
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ),

                // TRAMITES SECTION TITLE
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.assignment_turned_in_outlined, color: EmpoderateTheme.goldStrong),
                      const SizedBox(width: 8),
                      Text(
                        'TRÁMITES Y REQUISITOS',
                        style: GoogleFonts.outfit(
                          color: EmpoderateTheme.goldStrong,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2
                        ),
                      ),
                    ],
                  ),
                ),

                // TRAMITES LIST
                if (tramites.isEmpty)
                   _buildEmptyState()
                else
                   ...tramites.map((t) => _buildTramiteCard(context, t)).toList(),
                   
                const SizedBox(height: 48), // Bottom spacing
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressHeader() {
    final pct = (_progress * 100).toInt();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progreso de Apertura', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
              Text('$pct%', style: GoogleFonts.outfit(color: EmpoderateTheme.goldStrong, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(
                  _progress == 1.0 ? Colors.greenAccent : EmpoderateTheme.goldStrong
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
     return Container(
       width: double.infinity,
       padding: const EdgeInsets.all(32),
       decoration: BoxDecoration(
         color: Colors.white.withOpacity(0.05),
         borderRadius: BorderRadius.circular(16),
         border: Border.all(color: Colors.white12),
       ),
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           const Icon(Icons.assignment_outlined, size: 48, color: Colors.white24),
           const SizedBox(height: 16),
           Text(
             'Pendiente de completar',
             style: GoogleFonts.outfit(color: Colors.white54, fontSize: 16),
           ),
           const SizedBox(height: 8),
           Text(
             'Aún no hay trámites cargados para este rubro.',
             style: GoogleFonts.outfit(color: Colors.white30, fontSize: 12),
             textAlign: TextAlign.center,
           ),
         ],
       ),
     );
  }

  Widget _buildTramiteCard(BuildContext context, TramiteRef item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: EmpoderateTheme.goldStrong.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.description_outlined, color: EmpoderateTheme.goldStrong),
        ),
        title: Text(
          item.nombre,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: item.entidad != null 
            ? Text(item.entidad!, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13)) 
            : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.white30),
        onTap: () async {
          // Navigate and WAIT for return to update progress
          await context.push('/mi_negocio_rubro/tramite/${item.id}');
          _calculateGlobalProgress(); // Refresh progress on return
        },
      ),
    );
  }
}


