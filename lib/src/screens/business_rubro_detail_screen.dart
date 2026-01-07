import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../ui/theme/empoderate_theme.dart';
import '../components/premium_scaffold.dart';
import 'package:go_router/go_router.dart';
import '../models/business_data.dart';
import '../components/premium_negocio_list_card.dart';
import '../components/premium_negocio_section_header.dart';
import '../components/business_hero_header.dart';
import '../data/negocio/business_content_data.dart';
import 'requirement_detail_screen.dart';

class BusinessRubroDetailScreen extends StatefulWidget {
  final BusinessRubro rubro;
  final String categoryName;

  const BusinessRubroDetailScreen({
    Key? key,
    required this.rubro,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<BusinessRubroDetailScreen> createState() => _BusinessRubroDetailScreenState();
}

class _BusinessRubroDetailScreenState extends State<BusinessRubroDetailScreen> {
  // In a real app, use SharedPreferences or Hive.
  final Set<String> _completedItems = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Save selected rubro (Signal for Start Bar)
    await prefs.setString('mi_negocio.selected_rubro_id', widget.rubro.id);

    // 2. Load completed items
    final savedList = prefs.getStringList('mi_negocio.${widget.rubro.id}.completed_items');
    if (savedList != null) {
      setState(() {
        _completedItems.addAll(savedList);
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('mi_negocio.${widget.rubro.id}.completed_items', _completedItems.toList());
    
    // Also save distinct count for quick summary if needed
    await prefs.setInt('start.checklist.done_count', _completedItems.length);
  }

  // For Demo: Map the Legacy ID/Name to our new Content ID
  // Legacy "Restaurante pequeño" might have a specific name or ID.
  // Assuming matching by name for now as ID isn't clear in legacy model.
  BusinessModelContent? get _content {
    switch (widget.rubro.id) {
      case 'rest_small':
        return restaurantSmallContent;
      case 'food_truck':
        return foodTruckContent;
      case 'cafe':
        return cafeContent;
      case 'bakery':
        return bakeryContent;
      case 'fast_food':
        return fastFoodContent;
      case 'catering':
      case 'catering_events': // Reused for events category
        return cateringContent;
      // Beauty
      case 'barber':
        return barberContent;
      case 'salon':
        return salonContent;
      case 'spa':
        return spaContent;
      case 'nails':
        return nailsContent;
      // Retail
      case 'minisuper':
      case 'healthy':
        return minisuperContent;
      case 'clothing':
      case 'accessories':
        return retailStoreContent;
      // Professional
      case 'consulting':
      case 'photo':
      case 'admin':
      case 'arch':
        return professionalContent;
      // Transport
      case 'private_transport':
      case 'delivery':
      case 'moving':
        return transportContent;
      // Education
      case 'tutoring':
      case 'courses':
      case 'academy':
      case 'music_art':
        return educationContent;
      // Health
      case 'trainer':
      case 'massage':
      case 'yoga':
        return healthContent;
      // Digital
      case 'marketing':
      case 'design':
      case 'community':
      case 'ecommerce':
        return digitalContent;
      // Events
      case 'decor':
      case 'kids_party':
        return eventsContent;
      // Home
      case 'desserts':
      case 'jewelry':
      case 'handmade':
        return homeBizContent;
      default:
        // Fallback for name matching if needed (legacy safety)
        if (widget.rubro.name.toLowerCase().contains('restaurante pequeño')) {
          return restaurantSmallContent;
        }
        return null;
    }
  }
  
  void _toggleItem(String id) {
    setState(() {
      if (_completedItems.contains(id)) {
        _completedItems.remove(id);
      } else {
        _completedItems.add(id);
      }
    });
    _saveState();
  }

  void _markAsDone(String id) {
    if (!_completedItems.contains(id)) {
      setState(() {
        _completedItems.add(id);
      });
      _saveState();
    }
  }

  // No changes to logic methods

  @override
  Widget build(BuildContext context) {
    final content = _content;
    
    // Fallback for non-implemented models
    if (content == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F1520),
        body: SingleChildScrollView(
          child: Column(
            children: [
               BusinessHeroHeader(
                 title: widget.rubro.name,
                 categoryName: widget.categoryName,
                 icon: Icons.handyman, // Generic
                 onBackPressed: () => Navigator.pop(context),
               ),
               Padding(
                 padding: const EdgeInsets.all(24),
                 child: Text(
                  'Contenido detallado para "${widget.rubro.name}" en construcción. Pronto disponible.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16),
                 ),
               ),
            ],
          ),
        ),
      );
    }

    // Calculate Progress
    int totalItems = content.sections.fold(0, (sum, sec) => sum + sec.items.length);
    int completedCount = _completedItems.length;
    double progress = totalItems == 0 ? 0 : completedCount / totalItems;
    int percentage = (progress * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFF0F1520),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          children: [
            // 1. HERO HEADER
            BusinessHeroHeader(
              title: content.title,
              categoryName: widget.categoryName.toUpperCase(),
              icon: _getIconForRubro(widget.rubro.id) ?? Icons.store_mall_directory,
              onBackPressed: () => Navigator.pop(context),
            ),
            
            // 2. DASHBOARD PANEL (Progress & Stats)
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              transform: Matrix4.translationValues(0, -30, 0), // Pull up overlap
              decoration: BoxDecoration(
                color: const Color(0xFF151C2B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                children: [
                  // Progress Row
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Radial Progress
                        SizedBox(
                          width: 70, height: 70,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: 1.0,
                                color: Colors.white.withOpacity(0.05),
                                strokeWidth: 6,
                              ),
                              CircularProgressIndicator(
                                value: progress,
                                color: EmpoderateTheme.goldStrong,
                                strokeWidth: 6,
                                strokeCap: StrokeCap.round,
                              ),
                              Text(
                                '$percentage%',
                                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ESTADO DEL PROYECTO', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                percentage == 100 ? '¡Listo para Lanzar!' : (percentage > 50 ? 'En Buen Camino' : 'Iniciando Viaje'),
                                style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text('$completedCount de $totalItems pasos completados', style: GoogleFonts.outfit(color: EmpoderateTheme.goldStrong, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Colors.white.withOpacity(0.05), height: 1),
                  // Quick Stats Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickStat(Icons.calendar_today, 'TIEMPO EST.', '2-3 Meses'),
                        Container(width: 1, height: 30, color: Colors.white10),
                        _buildQuickStat(Icons.monetization_on, 'INVERSIÓN', 'Media (\$\$)'),
                        Container(width: 1, height: 30, color: Colors.white10),
                        _buildQuickStat(Icons.trending_up, 'RENTABILIDAD', 'Alta 🚀'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // 3. MARKET STUDY CARD (Glassmorphism)
                  GestureDetector(
                    onTap: () {
                      context.push('/market_study?rubroId=${widget.rubro.id}&rubroName=${widget.rubro.name}');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 30),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF00E5FF).withOpacity(0.15), // Cyan
                            const Color(0xFFD4AF37).withOpacity(0.05), // Gold trace
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.5)),
                            ),
                            child: const Icon(Icons.psychology, color: Color(0xFF00E5FF), size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'ESTUDIO DE MERCADO IA',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00E5FF).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text('GRATIS', style: GoogleFonts.outfit(color: const Color(0xFF00E5FF), fontSize: 9, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Desbloquea análisis de competencia y estrategias personalizadas.',
                                  style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward, color: Color(0xFF00E5FF), size: 18),
                        ],
                      ),
                    ),
                  ),

                  // 4. SECTIONS LOOP
                  ...content.sections.map((section) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Styled Section Header
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 16),
                          child: Row(
                            children: [
                              Container(width: 3, height: 16, color: EmpoderateTheme.goldStrong),
                              const SizedBox(width: 8),
                              Text(
                                section.title.toUpperCase(),
                                style: GoogleFonts.outfit(
                                  color: EmpoderateTheme.goldStrong,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        ...section.items.map((item) {
                           final isDone = _completedItems.contains(item.id);
                           return PremiumNegocioListCard(
                             title: item.title,
                             subtitle: item.shortDesc,
                             icon: isDone ? Icons.check_circle : item.icon,
                             // If done show bright green, otherwise standard gold accent
                             accentColor: isDone ? const Color(0xFF69F0AE) : EmpoderateTheme.goldStrong, 
                             onTap: () async {
                               await context.push('/business/requirement/${item.id}?categoryName=${widget.categoryName}&rubroName=${widget.rubro.name}');
                             },
                           );
                        }).toList(),
                        const SizedBox(height: 32),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white38, size: 16),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
        Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
  
  IconData? _getIconForRubro(String id) {
     // Basic mapping for Hero Icon (could be moved to model)
     if (id.contains('food') || id == 'cafe' || id == 'bakery') return Icons.restaurant;
     if (id == 'barber' || id == 'salon' || id == 'spa') return Icons.content_cut;
     if (id == 'ecommerce' || id == 'marketing') return Icons.computer;
     return null;
  }
}

