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
  final Set<String> _completedTramites = {}; // Tracks full completion IDs

  @override
  void initState() {
    super.initState();
    _calculateGlobalProgress(); // Initial calc
  }

  // Reload progress when coming back from detail
  void _calculateGlobalProgress() async {
     // Scoped Progress Calculation
     final tramites = RubroTramitesRepository.getTramitesForRubro(widget.categoryId, widget.rubroId);
     if (tramites.isEmpty) {
        if(mounted) setState(() { _progress = 0; _isLoading = false; });
        return;
     }

     final prefs = await SharedPreferences.getInstance();
     int totalItems = 0;
     int checkedItems = 0;
     _completedTramites.clear(); // Reset before recalc

     for (var t in tramites) {
        final detail = RubroTramitesRepository.getTramiteDetail(t.id);
        if (detail != null) {
           final itemsCount = detail.requisitos.length + detail.pasos.length;
           totalItems += itemsCount;

           // SCOPED KEY
           final key = 'tramite_progress_${widget.categoryId}_${widget.rubroId}_${t.id}';
           final checkedList = prefs.getStringList(key) ?? [];
           checkedItems += checkedList.length;
           
           // Determine if THIS trámite is fully complete
           if (itemsCount > 0 && checkedList.length >= itemsCount) {
             _completedTramites.add(t.id);
           }
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
    // 1. Calculate completion for THIS specific item
    //    (Ideally we would cache this map to avoid re-reading prefs constantly 
    //     but for a list of 6 items it's fine)
    final prefs =  SharedPreferences.getInstance().then((p) => p); // We need sync access or FutureBuilder
    // Better strategy: We already load progress in _calculateGlobalProgress, 
    // let's store a Map<String, bool> _completedMap in State.
    
    // BUT since we are in a simple widget, let's use a FutureBuilder for the individual card status
    // OR better, populate a local Map in _calculateGlobalProgress
    
    final isCompleted = _completedTramites.contains(item.id); 

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      // Dynamic Color: Green if completed, Standard dark if not
      color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCompleted ? Colors.greenAccent : Colors.white12,
          width: isCompleted ? 1.5 : 1.0
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            // Green circle if completed
            color: isCompleted ? Colors.green.withOpacity(0.2) : EmpoderateTheme.goldStrong.withOpacity(0.1),
            shape: BoxShape.circle,
            boxShadow: isCompleted 
                ? [ BoxShadow(color: Colors.greenAccent.withOpacity(0.3), blurRadius: 8) ] 
                : null
          ),
          child: Icon(
            isCompleted ? Icons.check : Icons.description_outlined, 
            color: isCompleted ? Colors.greenAccent : EmpoderateTheme.goldStrong
          ),
        ),
        title: Text(
          item.nombre,
          style: GoogleFonts.outfit(
            color: isCompleted ? Colors.white : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            decoration: isCompleted ? TextDecoration.none : null
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.entidad != null)
              Text(item.entidad!, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13)),
              
            if (isCompleted)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'COMPLETADO', 
                  style: GoogleFonts.outfit(
                    color: Colors.greenAccent, 
                    fontSize: 11, 
                    fontWeight: FontWeight.bold, 
                    letterSpacing: 1.0
                  )
                ),
              )
          ],
        ),
        trailing: Icon(
           Icons.chevron_right, 
           color: isCompleted ? Colors.greenAccent.withOpacity(0.5) : Colors.white30
        ),
        onTap: () async {
          // Navigate with SCOPED path for independent checklist storage
          await context.push('/mi_negocio_rubro/category/${widget.categoryId}/rubro/${widget.rubroId}/tramite/${item.id}');
          _calculateGlobalProgress(); // Refresh progress on return
        },
      ),
    );
  }
}


