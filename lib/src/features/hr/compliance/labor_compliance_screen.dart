import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../components/premium_scaffold.dart';
import '../../../components/neon_widgets.dart';

/// Pantalla de Obligaciones Laborales - Versión simple sin rebuild loops
class LaborComplianceScreen extends StatelessWidget {
  const LaborComplianceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Obligaciones Laborales',
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF4081).withOpacity(0.2),
                    const Color(0xFFFF4081).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF4081).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4081).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.assignment_turned_in, color: Color(0xFFFF4081), size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gestiona tus Obligaciones',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mantén tu negocio en cumplimiento',
                          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Sección de Herramientas
            Text(
              'Herramientas de Cumplimiento',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Cards de herramientas
            _buildToolCard(
              context,
              title: 'CSS / Cuota Obrero Patronal',
              subtitle: 'Gestión de seguro social',
              icon: Icons.health_and_safety,
              color: const Color(0xFF00E5FF),
              route: '/hr/obligaciones/css',
            ),
            const SizedBox(height: 12),

            _buildToolCard(
              context,
              title: 'Décimo Tercer Mes',
              subtitle: 'Cálculo y registro del XIII mes',
              icon: Icons.card_giftcard,
              color: Colors.amber,
              route: '/decimo_calculator',
            ),
            const SizedBox(height: 12),

            _buildToolCard(
              context,
              title: 'Vacaciones',
              subtitle: 'Gestión de periodos vacacionales',
              icon: Icons.beach_access,
              color: Colors.pinkAccent,
              route: '/vacation_calculator',
            ),
            const SizedBox(height: 12),

            _buildToolCard(
              context,
              title: 'Permisos y Licencias',
              subtitle: 'Control de ausencias justificadas',
              icon: Icons.event_note,
              color: const Color(0xFF9575CD),
              route: '/hr/obligaciones/permisos',
            ),
            const SizedBox(height: 12),

            _buildToolCard(
              context,
              title: 'Contratos y Reglamentos',
              subtitle: 'Plantillas y documentación legal',
              icon: Icons.description,
              color: const Color(0xFFE040FB),
              route: '/rrhh/plantillas',
            ),
            const SizedBox(height: 12),

            _buildToolCard(
              context,
              title: 'Calendario de Obligaciones',
              subtitle: 'Fechas límite y recordatorios',
              icon: Icons.calendar_today,
              color: const Color(0xFFFFB74D),
              route: '/hr/obligaciones/calendario',
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String? route,
  }) {
    return GestureDetector(
      onTap: () {
        if (route != null) {
          context.push(route);
        } else {
          context.push('/under_construction?title=${Uri.encodeComponent(title)}');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.15),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              route != null ? Icons.arrow_forward_ios : Icons.construction,
              color: route != null ? color : Colors.orange,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
