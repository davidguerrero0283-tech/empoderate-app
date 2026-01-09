import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../components/neon_widgets.dart';
import '../../components/how_to_use_card.dart';
import '../../features/analytics/services/analytics_service.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  late Future<void> _initFuture;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _initFuture = AnalyticsService.instance.init().then((_) {
        _stats = AnalyticsService.instance.getStats();
      });
    });
  }

  Future<void> _resetData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Resetear Analítica?'),
        content: const Text('Esto borrará todos los contadores locales. No se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Borrar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await AnalyticsService.instance.resetAnalytics();
      _loadData();
    }
  }

  void _exportData() {
    final jsonStr = AnalyticsService.instance.exportToJson();
    Clipboard.setData(ClipboardData(text: jsonStr));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('JSON copiado al portapapeles')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final totalViews = _stats['total_views'] ?? 0;
        final sessions = _stats['sessions'] ?? 0;
        final lastSeen = _stats['last_seen'] != null 
            ? DateTime.parse(_stats['last_seen']).toLocal().toString().split('.')[0]
            : 'Nunca';
        
        final Map<String, int> viewsByModule = Map<String, int>.from(_stats['views_by_module'] ?? {});
        final Map<String, int> viewsByRoute = Map<String, int>.from(_stats['views_by_route'] ?? {});

        // Sort Top Routes
        final topRoutes = viewsByRoute.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Analítica V2 (Real)',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                       IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white70),
                        tooltip: 'Recargar',
                        onPressed: _loadData,
                      ),
                      IconButton(
                        icon: const Icon(Icons.cleaning_services, color: Colors.redAccent),
                        tooltip: 'Resetear',
                        onPressed: _resetData,
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: _exportData,
                        icon: const Icon(Icons.copy, color: Color(0xFF00E5FF)),
                        label: const Text('Copiar JSON', style: TextStyle(color: Color(0xFF00E5FF))),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // How to Use Card
              const HowToUseCard(
                title: 'Analítica Local en Tiempo Real',
                icon: Icons.track_changes,
                accentColor: Color(0xFF00E5FF),
                steps: [
                  'Estos datos son reales y se guardan en tu dispositivo.',
                  'Navega por la app para ver cómo aumentan los contadores.',
                  '"Vistas Totales" cuenta cada cambio de pantalla.',
                  '"Top Rutas" te muestra qué pantallas visitas más.',
                ],
              ),

              const SizedBox(height: 16),

              // KPI Cards
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildKpiCard('Vistas Totales', '$totalViews', 'Total acumulado', Colors.blue),
                  _buildKpiCard('Sesiones', '$sessions', 'Inicios de app', Colors.green),
                  _buildKpiCard('Última Actividad', lastSeen, 'Timestamp', Colors.orange),
                  _buildKpiCard('Rutas Únicas', '${viewsByRoute.length}', 'Pantallas visitadas', Colors.purple),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Modules Breakdown
              const NeonSectionTitle(title: 'Vistas por Módulo', color: Colors.white),
              const SizedBox(height: 16),
              if (viewsByModule.isEmpty) 
                const Text('Navega para generar datos...', style: TextStyle(color: Colors.white54))
              else
                ...viewsByModule.entries.map((e) => _buildModuleRow(
                  e.key, 
                  '${e.value}', 
                  '${((e.value / totalViews) * 100).toStringAsFixed(1)}%', 
                  _getColorForModule(e.key)
                )).toList(),

              const SizedBox(height: 32),

              // Top Routes Table
              const NeonSectionTitle(title: 'Top 5 Rutas Más Visitadas', color: Colors.white),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: topRoutes.take(5).map((e) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.subdirectory_arrow_right, color: Colors.white54, size: 16),
                    title: Text(e.key, style: GoogleFonts.outfit(color: Colors.white)),
                    trailing: Text('${e.value} vistas', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                  )).toList(),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Color _getColorForModule(String module) {
    switch (module) {
      case 'Admin': return Colors.redAccent;
      case 'RRHH': return Colors.purpleAccent;
      case 'Contabilidad': return Colors.blueAccent;
      case 'Marketing': return Colors.pinkAccent;
      case 'IA Hub': return Colors.tealAccent;
      default: return Colors.grey;
    }
  }

  Widget _buildKpiCard(String title, String value, String subtitle, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border(bottom: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            value, 
            style: GoogleFonts.outfit(
              color: Colors.white, 
              fontSize: value.length > 10 ? 14 : 22, // Dynamic font for timestamps
              fontWeight: FontWeight.bold
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.outfit(color: color.withOpacity(0.8), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildModuleRow(String module, String visits, String percentage, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 10, height: 10, 
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(module, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text('$visits vistas', style: GoogleFonts.outfit(color: Colors.white70)),
          ),
          Text(percentage, style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
