import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/premium_scaffold.dart';
import '../navigation/app_routes.dart';

class ChecklistHomeScreen extends StatelessWidget {
  const ChecklistHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'CHECKLIST DEL NEGOCIO',
      subtitle: 'Organiza tus trámites y tareas clave paso a paso.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOptionTile(
            context,
            icon: Icons.list_alt,
            title: 'Checklist por rubro',
            subtitle: 'Tareas específicas según tu actividad',
            onTap: () => Navigator.pushNamed(context, AppRoutes.checklistRubroSelection),
          ),
          const SizedBox(height: 16),
          _buildOptionTile(
            context,
            icon: Icons.rocket_launch,
            title: 'Plan de acción',
            subtitle: 'Pasos estratégicos para crecer',
            onTap: () => Navigator.pushNamed(context, AppRoutes.planAccion),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF001B3A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD4AF37), width: 1),
                  ),
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFF001B3A),
                    child: Icon(Icons.checklist, size: 18, color: Color(0xFFD4AF37)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Más adelante, EMPO creará un checklist automático según tu negocio.',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFD4AF37), size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFD4AF37),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white30),
          ],
        ),
      ),
    );
  }
}
