import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/neon_widgets.dart';
import '../../components/premium_scaffold.dart';
import '../../components/how_to_use_card.dart';
import 'admin_users_screen.dart';
import 'admin_content_screen.dart';
import '../../navigation/app_routes.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Mock Data for Dashboard
  bool _pwaReady = false;

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Panel de Control',
      showBackButton: true,
      useScroll: false,  // Body maneja su propio scroll
      usePadding: false, // Padding manual en body
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Welcome Section
            Text(
              'Bienvenido, Administrador',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Gestión centralizada de Empodérate',
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // How to Use Card
            const HowToUseCard(
              title: '¿Cómo usar el Panel de Control?',
              icon: Icons.dashboard_customize,
              steps: [
                'Revisa las estadísticas rápidas en las tarjetas superiores.',
                'Accede a los módulos de gestión (Usuarios, Contenido) tocando cada opción.',
                'Verifica el estado del sistema en la sección inferior.',
                'Usa el menú lateral (Admin V2) para acceder a Analytics, Auditoría y más.',
              ],
            ),

            const SizedBox(height: 16),

            // 2. Quick Stats Row
            Row(
              children: [
                Expanded(child: _buildStatCard('Usuarios', '1,240', Icons.people, const Color(0xFF00E5FF))),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Contenido', '58', Icons.article, const Color(0xFFD4AF37))),
              ],
            ),
            const SizedBox(height: 16),
             Row(
              children: [
                Expanded(child: _buildStatCard('Ventas', '\$3.4k', Icons.attach_money, const Color(0xFFE040FB))),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Soporte', '5', Icons.support_agent, const Color(0xFF00E676))),
              ],
            ),
            const SizedBox(height: 32),

            // 3. Modules Grid
            const NeonSectionTitle(title: 'Módulos de Gestión', color: Colors.blueAccent),
            const SizedBox(height: 16),
            
            NeonListTile(
              icon: Icons.people_outline,
              title: 'Gestión de Usuarios',
              subtitle: 'Administrar roles, accesos y perfiles.',
              onTap: () => context.go('/admin/users'),
              iconColor: const Color(0xFF00E5FF),
            ),
            
            NeonListTile(
              icon: Icons.library_books_outlined,
              title: 'Gestor de Contenido (CMS)',
              subtitle: 'Blog, Cursos y Recursos.',
              onTap: () => context.go('/admin/content'),
              iconColor: const Color(0xFFD4AF37),
            ),

            NeonListTile(
              icon: Icons.public_outlined,
              title: 'Blog Externo (Sitio Web)',
              subtitle: 'Ver versión estática optimizada para Google.',
              onTap: () => context.go(AppRoutes.adminBlog),
              iconColor: const Color(0xFF00E676),
            ),

             NeonListTile(
              icon: Icons.settings_applications_outlined,
              title: 'Configuración Global',
              subtitle: 'Ajustes de la aplicación y sistema.',
              onTap: () => context.push(AppRoutes.adminConfig),
              iconColor: Colors.white54,
            ),

            const SizedBox(height: 32),

            // 4. System Health (Checklist)
            const NeonSectionTitle(title: 'Estado del Sistema', color: Colors.tealAccent),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF001220),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Sistema PWA Activo', style: GoogleFonts.outfit(color: Colors.white)),
                    subtitle: Text('Aplicación instalable y cacheada', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
                    value: _pwaReady,
                    onChanged: (val) => setState(() => _pwaReady = val),
                    activeColor: Colors.tealAccent,
                  ),
                  const Divider(color: Colors.white10),
                  const ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.greenAccent),
                    title: Text('Base de Datos', style: TextStyle(color: Colors.white)),
                    subtitle: Text('Conectada (Simulada)', style: TextStyle(color: Colors.white54)),
                    dense: true,
                  ),
                  const ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.greenAccent),
                    title: Text('API Gateway', style: TextStyle(color: Colors.white)),
                    subtitle: Text('Online', style: TextStyle(color: Colors.white54)),
                    dense: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF001220),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), Colors.transparent],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
