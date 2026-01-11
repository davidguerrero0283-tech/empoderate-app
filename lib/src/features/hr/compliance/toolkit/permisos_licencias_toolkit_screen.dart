import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../components/premium_scaffold.dart';
import '../../../../ui/theme/empoderate_theme.dart';

class PermisosLicenciasToolkitScreen extends StatelessWidget {
  const PermisosLicenciasToolkitScreen({super.key});

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      title: 'Permisos y Licencias',
      isNeonTitle: true,
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Licencias Comunes'),
            const SizedBox(height: 12),
            _buildLicenseCard(
              title: 'Licencia de Paternidad',
              badge: 'Ley 27',
              content: '3 días hábiles remunerados para el padre, a partir del nacimiento del hijo.',
              requirement: 'Se debe notificar a la empresa con anticipación y presentar certificado de nacimiento.',
              color: Colors.blueAccent,
              icon: Icons.child_care,
            ),
            const SizedBox(height: 12),
            _buildLicenseCard(
              title: 'Lactancia Materna',
              badge: 'Ley 135',
              content: 'Tiempo para extracción de leche dentro de la jornada laboral. Obligatorio si la empresa tiene más de 20 mujeres.',
              requirement: 'Depende de jornada (ej. 15 min cada 2 horas o según acuerdo).',
              color: Colors.pinkAccent,
              icon: Icons.baby_changing_station,
            ),
            const SizedBox(height: 12),
            _buildLicenseCard(
              title: 'Licencia de Maternidad',
              badge: 'CSS / Código Trabajo',
              content: '14 semanas forzosas de descanso retribuido (6 antes y 8 después del parto).',
              requirement: 'Pago a cargo de la CSS si tiene 9 cuotas en los últimos 12 meses. Si no, paga el empleador.',
              color: Colors.purpleAccent,
              icon: Icons.pregnant_woman,
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('Herramientas Rápidas'),
            const SizedBox(height: 12),
            _buildToolsGrid(context),

            const SizedBox(height: 32),
            _buildSectionTitle('Fuentes Oficiales'),
            const SizedBox(height: 8),
            _buildLinkButton('MITRADEL - Licencias', 'https://www.mitradel.gob.pa/'),
            _buildLinkButton('Caja de Seguro Social (Trámites)', 'https://w3.css.gob.pa/'),
             const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Text(
      'Guía oficial sobre ausencias remuneradas y derechos del trabajador según la legislación panameña actual.',
      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        color: EmpoderateTheme.gold,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildLicenseCard({
    required String title,
    required String badge,
    required String content,
    required String requirement,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                      child: Text(badge, style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(6)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline, color: color, size: 14),
                const SizedBox(width: 8),
                Expanded(child: Text(requirement, style: const TextStyle(color: Colors.white60, fontSize: 11))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildToolButton(
            icon: Icons.description_outlined,
            label: 'Generar Solicitud',
            color: Colors.tealAccent,
            onTap: () {
               // Placeholder logic or navigation to templates
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abriendo Plantillas...')));
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildToolButton(
            icon: Icons.open_in_browser,
            label: 'Trámite CSS',
            color: Colors.blueAccent,
            onTap: () => _launchUrl('https://w3.css.gob.pa/'),
          ),
        ),
      ],
    );
  }

  Widget _buildToolButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.1),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkButton(String text, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton.icon(
        onPressed: () => _launchUrl(url),
        icon: const Icon(Icons.link, size: 16),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white70,
          side: const BorderSide(color: Colors.white24),
          alignment: Alignment.centerLeft,
          minimumSize: const Size(double.infinity, 40),
        ),
      ),
    );
  }
}
