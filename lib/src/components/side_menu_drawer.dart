import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../navigation/app_routes.dart';

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
            
            _buildDrawerItem(context, Icons.dashboard, 'Inicio', AppRoutes.home, useGo: true),
            _buildDrawerItem(context, Icons.flag, 'La Ruta al Éxito', AppRoutes.laRutaAlExito),
            _buildDrawerItem(context, Icons.business, 'Perfil del Negocio', AppRoutes.businessProfile),
            _buildDrawerItem(context, Icons.settings, 'Ajustes', AppRoutes.settings, useGo: true),
            
            const Divider(color: Colors.white12, height: 32),
            
            _buildSectionTitle('Herramientas'),
            _buildDrawerItem(context, Icons.build, 'Herramientas', AppRoutes.tools, useGo: true),
            _buildDrawerItem(context, Icons.psychology, 'Consultor IA', AppRoutes.aiChat),
            _buildDrawerItem(context, Icons.receipt_long, 'Bóveda Digital', AppRoutes.bovedaDigital, useGo: true),
            
            const Divider(color: Colors.white12, height: 32),

            _buildSectionTitle('Legales'),
            _buildDrawerItem(context, Icons.gavel, 'Aviso Legal', AppRoutes.legal), 
            _buildDrawerItem(context, Icons.privacy_tip, 'Privacidad', AppRoutes.legal), 
            
            const SizedBox(height: 16),
             _buildDrawerItem(context, Icons.logout, 'Cerrar Sesión', AppRoutes.home, useGo: true), 
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

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, String route, {bool useGo = false}) {
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
        context.pop(); // Close drawer first
        
        // Navigation logic
        if (useGo) {
          context.go(route);
        } else {
          try {
            context.push(route);
          } catch (e) {
            // Fallback to Under Construction if route fails
            context.push('/under_construction?title=${Uri.encodeComponent(title)}&route=${Uri.encodeComponent(route)}');
          }
        }
      },
      hoverColor: const Color(0xFFD4AF37).withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}
