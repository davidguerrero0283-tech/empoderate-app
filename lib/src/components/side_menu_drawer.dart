import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

/// Side Menu Drawer (Hamburger Menu)
/// 
/// CRITICAL: All routes MUST match GoRouter paths exactly.
/// Registered GoRouter paths for Drawer items:
/// - '/' (home) - ShellRoute
/// - '/tools' - ShellRoute
/// - '/boveda_digital' - ShellRoute
/// - '/settings' - ShellRoute
/// - '/la_ruta_al_exito' - Standard route
/// - '/business_profile' - Standard route
/// - '/ia/chat' - Standard route
/// - '/legal' - Standard route
/// - '/under_construction' - Fallback for unimplemented features

class SideMenuDrawer extends StatelessWidget {
  const SideMenuDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85, // Constrain width (max 85%)
      child: Container(
        color: const Color(0xFF001225), // Dark Navy
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(context),
            const SizedBox(height: 16),
            
            // MAIN NAVIGATION (ShellRoute - use context.go)
            _buildDrawerItem(context, Icons.dashboard, 'Inicio', '/', useGo: true),
            _buildDrawerItem(context, Icons.flag, 'La Ruta al Éxito', '/la_ruta_al_exito'),
            _buildDrawerItem(context, Icons.business, 'Perfil del Negocio', '/business_profile'),
            _buildDrawerItem(context, Icons.settings, 'Ajustes', '/settings', useGo: true),
            
            const Divider(color: Colors.white12, height: 32),
            
            // TOOLS SECTION (ShellRoute for main, push for sub-items)
            _buildSectionTitle('Herramientas'),
            _buildDrawerItem(context, Icons.build, 'Herramientas', '/tools', useGo: true),
            _buildDrawerItem(context, Icons.psychology, 'Consultor IA', '/ia/chat'),
            _buildDrawerItem(context, Icons.receipt_long, 'Bóveda Digital', '/boveda_digital', useGo: true),
            
            const Divider(color: Colors.white12, height: 32),

            // LEGAL SECTION
            _buildSectionTitle('Legales'),
            _buildDrawerItem(context, Icons.gavel, 'Aviso Legal', '/legal'), 
            _buildDrawerItem(context, Icons.privacy_tip, 'Privacidad', '/legal'), 
            
            const SizedBox(height: 16),
            // LOGOUT (Navigate to home)
            _buildDrawerItem(context, Icons.logout, 'Cerrar Sesión', '/', useGo: true), 
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 24, right: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF001B3A),
        border: Border(bottom: BorderSide(color: Color(0xFFD4AF37), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD4AF37), width: 2),
              ),
                child: const CircleAvatar(
                  radius: 36,
                  backgroundColor: Color(0xFF001B3A),
                  child: Icon(Icons.person, size: 40, color: Color(0xFFD4AF37)),
                ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'EMPO — Tu Asesor Inteligente',
            style: GoogleFonts.outfit(
              color: const Color(0xFFD4AF37),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Plan Premium',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.outfit(
          color: Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  /// Builds a Drawer item with proper navigation
  /// 
  /// [useGo] = true for ShellRoute paths (/, /tools, /boveda_digital, /settings)
  /// [useGo] = false for standard routes (will use context.push)
  Widget _buildDrawerItem(
    BuildContext context, 
    IconData icon, 
    String title, 
    String route, 
    {bool useGo = false}
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFD4AF37), size: 22),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: () {
        // Close drawer first
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        
        // Small delay to allow drawer to close smoothly
        Future.delayed(const Duration(milliseconds: 100), () {
          try {
            if (useGo) {
              // Use context.go for ShellRoute paths (main navigation)
              context.go(route);
            } else {
              // Use context.push for standard routes (modal/secondary screens)
              context.push(route);
            }
          } catch (e) {
            // Fallback to Under Construction if route fails
            debugPrint('⚠️ Navigation error to $route: $e');
            context.push(
              '/under_construction?title=${Uri.encodeComponent(title)}&route=${Uri.encodeComponent(route)}'
            );
          }
        });
      },
      hoverColor: const Color(0xFFD4AF37).withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}
