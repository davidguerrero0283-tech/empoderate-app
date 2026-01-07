import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/legal_shielding.dart';
import '../components/premium_scaffold.dart';
import '../components/neon_widgets.dart';
import '../components/calculator_info_panel.dart';
import '../navigation/app_routes.dart';
import 'package:go_router/go_router.dart';

class TramitesScreen extends StatefulWidget {
  const TramitesScreen({Key? key}) : super(key: key);

  @override
  State<TramitesScreen> createState() => _TramitesScreenState();
}

class _TramitesScreenState extends State<TramitesScreen> {
  Map<String, dynamic>? _selectedRubro;

  final List<Map<String, dynamic>> _rubros = [
    {
      'id': 'restaurantes',
      'title': 'Restaurantes y Comida',
      'icon': Icons.restaurant_menu,
      'color': Colors.orangeAccent,
      'reqs': [
        'Aviso de Operación (Panamá Emprende)',
        'Inscripción DGI (RUC)',
        'Permiso Sanitario de Operación (MINSA)',
        'Certificado de Manipulación de Alimentos',
        'Visto Bueno de Bomberos',
        'Licencia de Licores (si aplica)',
      ],
      'steps': [
        'Registrar Aviso de Operación en línea.',
        'Inspección de local por Bomberos.',
        'Solicitar inspección de Salud (MINSA).',
        'Obtener Carnets de Salud para personal.',
        'Permiso municipal (Alcaldía).',
      ]
    },
    {
      'id': 'belleza',
      'title': 'Belleza y Barbería',
      'icon': Icons.content_cut,
      'color': kNeonPink,
      'reqs': [
        'Aviso de Operación',
        'Permisos de Salud',
        'Certificado de Bioseguridad',
        'Registro Municipal',
      ],
      'steps': [
        'Definir ubicación y contrato.',
        'Aviso de Operación.',
        'Certificados técnicos del personal.',
        'Permiso de Salud.',
      ]
    },
    {
      'id': 'comercio',
      'title': 'Comercio General',
      'icon': Icons.storefront,
      'color': kNeonCyan,
    },
    {
      'id': 'educacion',
      'title': 'Educación',
      'icon': Icons.school,
      'color': kNeonBlue,
    },
    {
      'id': 'transporte',
      'title': 'Transporte',
      'icon': Icons.directions_car,
      'color': kNeonPurple,
    },
    {
      'id': 'servicios',
      'title': 'Servicios Profesionales',
      'icon': Icons.business_center,
      'color': kNeonCopper, // Replaced Gold with Neon Copper equivalent
    },
    {
      'id': 'salud',
      'title': 'Salud y Bienestar',
      'icon': Icons.medical_services,
      'color': kNeonGreen,
    },
    {
      'id': 'talleres',
      'title': 'Talleres y Mecánicas',
      'icon': Icons.build,
      'color': Colors.blueGrey,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // If selected, use that rubro's color for header glow, else Cyan
    final Color currentColor = _selectedRubro != null 
        ? (_selectedRubro!['color'] as Color? ?? kNeonCyan) 
        : kNeonCyan;

    return PremiumScaffold(
      title: _selectedRubro == null ? 'Trámites por Rubro' : _selectedRubro!['title'],
      showBackButton: true,
      onBack: () {
        if (_selectedRubro != null) {
          setState(() => _selectedRubro = null);
        } else if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      // Global Glass Header

      
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _selectedRubro == null 
          ? _buildRubroGrid(context)
          : _buildRubroDetail(context, _selectedRubro!),
      ),
    );
  }

  Widget _buildRubroGrid(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Panel (Blueprint)
          const CalculatorInfoPanel(configId: 'tramites'),
          const SizedBox(height: 24),

          // Subtitle
          Text(
            'Selecciona tu rubro y descubre todos los requisitos, permisos y pasos oficiales para operar legalmente en Panamá.',
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.85),
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 24),

          // Link to General Checklist
          NeonWideCard(
            borderColor: kNeonGold,
            onTap: () => context.push(AppRoutes.checklistTramites),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kNeonGold.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: kNeonGold.withOpacity(0.5)),
                  ),
                  child: const Icon(Icons.playlist_add_check, color: kNeonGold, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mi Checklist de Trámites',
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gestiona tu progreso paso a paso (Aviso, DGI, Municipio...)',
                        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 32),


          // Search Card
          NeonInput(
            label: 'Buscar rubro (ej: Restaurante, Barbería...)',
            suffixText: '', 
            hint: 'Escribe para filtrar...',
          ),
          const SizedBox(height: 32),

          // Grid
          LayoutBuilder(
            builder: (context, constraints) {
               int cols = 1;
               if (constraints.maxWidth > 900) cols = 3;
               else if (constraints.maxWidth > 600) cols = 2;
               
               double spacing = 16;
               double itemWidth = (constraints.maxWidth - (spacing * (cols - 1))) / cols;

               return Wrap(
                 spacing: spacing,
                 runSpacing: spacing,
                 children: _rubros.map((rubro) => SizedBox(
                   width: itemWidth,
                   child: NeonGridCard(
                     title: rubro['title'],
                     icon: rubro['icon'],
                     neonColor: rubro['color'] ?? kNeonBlue,
                     onTap: () => setState(() => _selectedRubro = rubro),
                   ),
                 )).toList(),
               );
            },
          ),
          const SizedBox(height: 40),
          const LegalShielding(type: ShieldType.tramites),
        ],
      ),
    );
  }

  Widget _buildRubroDetail(BuildContext context, Map<String, dynamic> rubro) {
    final reqs = (rubro['reqs'] as List<String>?) ?? ['Aviso de Operación', 'Registro Municipal', 'Inscripción DGI'];
    final steps = (rubro['steps'] as List<String>?) ?? ['Paso 1: Aviso Operación', 'Paso 2: Permisos', 'Paso 3: Inicio'];
    final Color rubroColor = rubro['color'] ?? kNeonCyan;

    return SingleChildScrollView( 
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A) REQUISITOS GENERALES
          NeonSectionTitle(title: 'A. Requisitos Legales Generales', color: rubroColor),
          const SizedBox(height: 16),
          ...reqs.map((req) => _buildCheckboxTile(req, rubroColor)),
          const SizedBox(height: 32),

          // B) PERMISOS ESPECÍFICOS
          NeonSectionTitle(title: 'B. Permisos Específicos', color: rubroColor),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPermitCard('Permiso Salud', Icons.health_and_safety, Colors.greenAccent),
                const SizedBox(width: 16),
                _buildPermitCard('Fumigación', Icons.bug_report, Colors.orangeAccent),
                const SizedBox(width: 16),
                _buildPermitCard('Bomberos', Icons.fire_extinguisher, Colors.redAccent),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // C) PASOS DEL TRÁMITE
          NeonSectionTitle(title: 'C. Guía Paso a Paso', color: rubroColor),
          const SizedBox(height: 16),
          NeonWideCard(
            borderColor: rubroColor,
            child: Column(
              children: steps.asMap().entries.map((entry) => _buildStepItem(entry.key + 1, entry.value, rubroColor)).toList(),
            ),
          ),
          const SizedBox(height: 40),

          // ACTION BUTTONS
          Center(
            child: Column(
              children: [
                NeonButton(
                  text: 'Generar Checklist Completo',
                  primary: true, 
                  color: rubroColor,
                  icon: Icons.checklist_rtl,
                  onTap: () => _showChecklistSuccess(context),
                ),
                const SizedBox(height: 24),
                
                // Time Card
                NeonCard(
                  borderColor: rubroColor,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time, color: rubroColor),
                      const SizedBox(width: 12),
                      Text('Tiempo estimado: 5-12 días hábiles', style: GoogleFonts.outfit(color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Secondary Actions
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    NeonButton(text: 'Ver Costos Estimados', onTap: () => _showCostEstimator(context), primary: false, color: Colors.pinkAccent),
                    NeonButton(text: 'Requisitos Municipales', onTap: () => _showMunicipalReqs(context), primary: false, color: Colors.amberAccent),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const LegalShielding(type: ShieldType.tramites),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile(String title, Color color) {
     return Padding(
       padding: const EdgeInsets.only(bottom: 8.0),
       child: NeonCard(
         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
         borderColor: Colors.white12, // Subtle border
         child: Row(
           children: [
             Icon(Icons.circle_outlined, color: color, size: 20),
             const SizedBox(width: 12),
             Expanded(
               child: Text(
                 title, 
                 style: GoogleFonts.outfit(color: Colors.white, fontSize: 16)
               ),
             ),
           ],
         ),
       ),
     );
  }

  Widget _buildPermitCard(String title, IconData icon, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 8)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildStepItem(int num, String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Text('PASO $num', style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(text, style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, height: 1.4)),
          ),
        ],
      ),
    );
  }

  void _showChecklistSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generando Checklist Personalizado (Simulado)...')),
    );
    Future.delayed(const Duration(seconds: 1), () {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF0F1520),
          title: const Text('¡Checklist Listo!', style: TextStyle(color: Colors.white)),
          content: const Text('Se ha guardado una lista de verificación en tu sección de Tareas.', style: TextStyle(color: Colors.white70)),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
    });
  }

  void _showCostEstimator(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F1520),
        title: const Text('Costos Estimados (Aprox)', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('• Aviso de Operación: \$15 - \$55', style: TextStyle(color: Colors.white70)),
            Text('• Muncipio (Rótulo): \$10 - \$50', style: TextStyle(color: Colors.white70)),
            Text('• Bomberos / Salud: \$20 - \$100', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 12),
            Text('* Precios varían por ubicación.', style: TextStyle(color: Colors.white30, fontSize: 12)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
      ),
    );
  }

  void _showMunicipalReqs(BuildContext context) {
     ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Consultando requisitos municipales...')),
    );
  }
}
